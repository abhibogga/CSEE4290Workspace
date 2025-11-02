/*
 * Microcode (uCode) Controller FSM
 *
 * This module implements a 'MUL R_dest, R_source, #immediate' instruction
 * by generating a sequence of simpler instructions:
 * 1. MOV R_dest, 0
 * 2. ADD R_dest, R_dest, R_source  (repeated 'immediate' times)
 *
 * It takes control from the main IF stage, injects these instructions
 * into the pipeline, and then returns control.
 *
 * It correctly handles:
 * - immediate = 0 (results in R_dest = 0)
 * - immediate = 1 (results in MOV R_dest, R_source)
 * - immediate > 1 (results in MOV + (Imm) ADDs)
 * gemini helped in getting the fire started but group still did the heavy lifting
 */
module ucode (
    input wire clk,
    input wire rst, // Active-high reset
    
    // Control signal from main Instruction Decoder (ID) stage
    input wire start_mul, // '1' for one cycle when a MUL is decoded
    
    // Operands from the decoded MUL instruction
    input wire [3:0] dest_reg,   // Address of R_dest (e.g., R1)
    input wire [3:0] source_reg, // Address of R_source (e.g., R0)
    input wire [15:0] immediate,  // Multiplier value (e.g., 3)
    input wire [31:0] readDataSecond,
    input wire [1:0] mul_type,
    input wire [3:0] flags_in, //from execute


    // Outputs to pipeline MUX
    output reg [31:0] output_instruction, // The generated MOV/ADD/SUB
    output reg mux_ctrl,
    output reg mul_release,
    output reg [3:0] flags_back_out
);

    // --- FSM State Definitions ---
    // We need 5 states: Idle, Clear (for Imm=0), Move, Add, and Halt
    localparam [2:0] sIdle         = 3'b000;
    localparam [2:0] sClear        = 3'b001; // State to clear R_dest if Imm=0
    localparam [2:0] sMov          = 3'b010; // initial state that moves a 0 into Rd
    localparam [2:0] sKeep_adding  = 3'b011; 
    localparam [2:0] sHalt         = 3'b100; 
    localparam [2:0] sFix_it       = 3'b101; //twos comp result if corrected_imm was used
    localparam [1:0] MULI          = 2'd0;
    localparam [1:0] MULR          = 2'd1;
    localparam [1:0] MULSI         = 2'd2;
    localparam [1:0] MULSR         = 2'd3;



    reg [2:0] state_reg, state_next; //5 states, each needing 3 bits to hold it

    // --- Internal Counter ---
    // This is your 'scratch' register, used to count down the ADDs.
    reg [15:0] count_reg, count_next;
    reg [3:0] true_source_reg;
    reg [31:0] register_decrementer_count, register_decrementer_count_next;

    reg [3:0] flags_hold;
    reg [1:0] true_mul_type;
    reg [15:0] corrected_imm; //if immediate is twos comp negative
    reg [31:0] corrected_readDataSecond;
    reg [1:0] fix, fix_next;
    reg [3:0] dest_reg_hold;

    // --- Instruction Opcode ---
    localparam [6:0] MOV_OPCODE  = 7'b0000000; // Mov register immediate, used for loading the immediate value in source register into destination register in the beginning
    localparam [6:0] ADD_OPCODE  = 7'b0110001; // e.g., ADD Rd, Rs1, Rs2, used to 
    localparam [6:0] SUB_OPCODE  = 7'b0110010; // used to clear destination reg when imm is 0: SUB Rd, Rd, Rd
    localparam [6:0] SUBI_OPCODE = 7'b0010010; //used for fix it state
    localparam [6:0] SUBS_OPCODE = 7'b0111010; //used for multiplying by zero
    localparam [6:0] ADDS_OPCODE = 7'b0111001;
    localparam [6:0] NOT_OPCODE  = 7'b0110110;

    // --- Synchronous Block (State & Counter Registers) ---
    // This always block flops the 'next' values into the 'current' registers
    // on the rising clock edge.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= sIdle;
            count_reg <= 16'b0;
        end else begin
            state_reg <= state_next;
            count_reg <= count_next;
	    register_decrementer_count <= register_decrementer_count_next;
	    fix <= fix_next;
        end
    end

    // --- Combinatorial Block (Next-State & Output Logic) ---
    // This block determines what to do *in* the current state (outputs)
    // and where to go *next* (state_next).
    always @(*) begin
        // Default assignments (safer FSM design)
        state_next = state_reg;
        count_next = count_reg;
	register_decrementer_count_next = register_decrementer_count;
        output_instruction = {5'b11001,27'b0}; // Default to NOP
	mux_ctrl = 0;        
	mul_release = 0;

	corrected_imm = 16'b0;
	corrected_readDataSecond = 32'b0;

        case (state_reg)
            
            sIdle: begin
                // Wait for the decoder to signal 'start_mul'
//                mul_release = 1;
		mux_ctrl = 0;
                if (start_mul) begin
                    // A MUL instruction has arrived. Decide what to do.
			
                    if (mul_type == MULI && immediate == 0) begin //might want to take this out because this could be true with mulr and Rs2 is R0
                        state_next = sClear;
			flags_hold = flags_in;
                    end else begin
                        state_next = sMov;
			true_mul_type = mul_type;
			true_source_reg = source_reg;
			flags_hold = flags_in; //hold the old flags
			
			
			if (mul_type == MULI || mul_type == MULSI) begin
				if (immediate[15] == 1) begin
				    corrected_imm = ~(immediate - 1);
				    count_next = corrected_imm;
			        end else begin
				    count_next = immediate;
			        end

			end

			else if (mul_type == MULR || mul_type == MULSR) begin
				if (readDataSecond[31] == 1) begin
				    corrected_readDataSecond = ~(readDataSecond - 1);
				    register_decrementer_count_next = corrected_readDataSecond;
				end else begin
				    register_decrementer_count_next = readDataSecond;
				end
			end



                    end
                end else begin
                    state_next = sIdle;
		    output_instruction = {5'b11001,27'b0}; //NO OP
                end
            end
            
            sClear: begin
                // Handle immediate = 0. Issue SUB R_dest, R_dest, R_dest
                // This results in R_dest = 0.
                output_instruction = {SUBS_OPCODE, dest_reg, dest_reg, dest_reg, 13'b0};
                state_next = sHalt; // We are done
		mux_ctrl = 1;
		flags_back_out = flags_hold;
            end

            sMov: begin
                output_instruction = {MOV_OPCODE, dest_reg, 5'b0, 16'b0};	
                mux_ctrl = 1;
                if (mul_type == MULI || mul_type == MULSI) begin
			if (count_reg == 0) begin
				state_next = sHalt;
			end else begin
				state_next = sKeep_adding;
			end
		end else if (mul_type == MULR || mul_type == MULSR) begin
			if (register_decrementer_count == 0) begin
				state_next = sHalt;
			end else begin
				state_next = sKeep_adding;
			end
		end
            end

	    sKeep_adding: begin
	        mux_ctrl = 1;
	        dest_reg_hold = dest_reg;

	    /********** MULI (immediate, plain) **********/
	        if (true_mul_type == MULI) begin
	        // decrement counter and emit an ADD
	             count_next = count_reg - 1;
	             output_instruction = {ADD_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};

	        if (count_next == 0) begin
	            // last ADD was emitted
	            if (corrected_imm != 0) begin
	                state_next = sFix_it;
	                fix_next = 2'b10;
	            end else begin
	                state_next = sHalt;
	            end
	        end else begin
	            // more ADDs needed
	            state_next = sKeep_adding;
	        end
	    end

	    /********** MULR (register count in readDataSecond) **********/
	    else if (true_mul_type == MULR) begin
	        register_decrementer_count_next = register_decrementer_count - 1;
	        output_instruction = {ADD_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};

	        if (register_decrementer_count_next == 0) begin
	            if (corrected_readDataSecond != 0) begin
	                state_next = sFix_it;
	                fix_next = 2'b10;
	            end else begin
	                state_next = sHalt;
	            end
	        end else begin
	            state_next = sKeep_adding;
	        end
	    end

	    /********** MULSI (signed immediate with flags update) **********/
	    else if (true_mul_type == MULSI) begin
	        count_next = count_reg - 1;
	        output_instruction = {ADDS_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};

	        if (count_next == 0) begin
	            if (corrected_imm != 0) begin
	                state_next = sFix_it;
	                fix_next = 2'b10;
	            end else begin
	                state_next = sHalt;
	            end
	        end else begin
	            state_next = sKeep_adding;
	        end
	    end

	    /********** MULSR (signed register count with flags update) **********/
	    else if (true_mul_type == MULSR) begin
	        register_decrementer_count_next = register_decrementer_count - 1;
	        output_instruction = {ADDS_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};

	        if (register_decrementer_count_next == 0) begin
	            if (corrected_readDataSecond != 0) begin
	                state_next = sFix_it;
	                fix_next = 2'b10;
	            end else begin
	                state_next = sHalt;
	            end
	        end else begin
	            state_next = sKeep_adding;
	        end
	    end

	    else begin
	        // safe default: stay or go to halt
	        state_next = sKeep_adding;
	    end
	end

	sFix_it: begin
	    mux_ctrl = 1;
	    // Use fix as state-step: emit SUBI first iteration, then NOT next
	    if (fix == 2'b10) begin
	        // First fix instruction -> produce SUBI to convert to one's complement (as you intended)
	        fix_next = 2'b01;
	        state_next = sFix_it; // stay here so next cycle will do the NOT
	        output_instruction = {SUBI_OPCODE, dest_reg_hold, dest_reg_hold, 1'b0, 16'b1};
	    end else begin
	        // Second fix instruction -> NOT to finish
	        state_next = sHalt;
	        output_instruction = {NOT_OPCODE, dest_reg_hold, dest_reg_hold, 17'b0};
	    end
	end


            sHalt: begin
                // Done. Hand control back to the main IF stage.
                mux_ctrl = 1; //making this 1 for now
		output_instruction = {5'b11001, 27'b0}; //NOOP
		mul_release = 1;
                state_next = sIdle; // Wait for the next MUL
		flags_back_out = flags_hold; //send out the old flags
            end

            default: begin
                // Safety case
                state_next = sIdle;
                mux_ctrl = 0;
            end
        endcase
    end

endmodule
