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
    output reg mux_ctrl
);

    // --- FSM State Definitions ---
    // We need 5 states: Idle, Clear (for Imm=0), Move, Add, and Halt
    localparam [2:0] sIdle         = 3'b000;
    localparam [2:0] sClear        = 3'b001; // State to clear R_dest if Imm=0
    localparam [2:0] sMov          = 3'b010; // initial state that moves a 0 into Rd
    localparam [2:0] sKeep_adding  = 3'b011; 
    localparam [2:0] sHalt         = 3'b100; 
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

    // --- Instruction Opcode ---
    localparam [6:0] MOV_OPCODE = 7'b0000000; // Mov register immediate, used for loading the immediate value in source register into destination register in the beginning
    localparam [6:0] ADD_OPCODE = 7'b0110001; // e.g., ADD Rd, Rs1, Rs2, used to 
    localparam [6:0] SUB_OPCODE = 7'b0110010; // used to clear destination reg when imm is 0: SUB Rd, Rd, Rd
    localparam [6:0] ADDS_OPCODE = 7'b0111001;

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


        case (state_reg)
            
            sIdle: begin
                // Wait for the decoder to signal 'start_mul'
                mux_ctrl = 0;
                if (start_mul) begin
                    // A MUL instruction has arrived. Decide what to do.
			
                    if (immediate == 0) begin //might want to take this out because this could be true with mulr and Rs2 is R0
                        state_next = sClear;
                    end else begin
                        state_next = sMov;
                        count_next = immediate; // Load counter
			register_decrementer_count_next = readDataSecond; //load counter
			true_mul_type = mul_type;
			true_source_reg = source_reg;
			flags_hold = flags_in; //hold the old flags
                    end
                end else begin
                    state_next = sIdle;
		    output_instruction = {5'b11001,27'b0}; //NO OP
                end
            end
            
            sClear: begin
                // Handle immediate = 0. Issue SUB R_dest, R_dest, R_dest
                // This results in R_dest = 0.
                output_instruction = {SUB_OPCODE, dest_reg, dest_reg, dest_reg, 13'b0};
                state_next = sHalt; // We are done
		mux_ctrl = 1;
            end

            sMov: begin
                output_instruction = {MOV_OPCODE, dest_reg, 5'b0, 16'b0};
		//zero out Rd to start looping adder
	//	true_source_reg = source_reg;
		
                mux_ctrl = 1;
                // Check if we are done (i.e., immediate was 1)
                if (count_reg == 0 | register_decrementer_count == 0) begin //are we done decrementing?
                    state_next = sHalt;
                end else begin
                    state_next = sKeep_adding;
                end
            end

            sKeep_adding: begin
                mux_ctrl = 1;                

		if (true_mul_type == 2'd0) begin //MULI
			count_next = count_reg - 1;
			output_instruction = {ADD_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};              
	                if (count_next == 0) begin
	                    // This was the last ADD. Go to halt.
	                    state_next = sHalt;
	                end else begin
	                    // More ADDs needed. Stay in this state.
	                    state_next = sKeep_adding;
	                end	
		end
		else if (true_mul_type == 2'd1) begin
			register_decrementer_count_next = register_decrementer_count - 1;
			output_instruction = {ADD_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};
			if (register_decrementer_count_next == 0) begin
			    state_next = sHalt;
			end else begin
			    state_next = sKeep_adding;
			end
		end 
		else if (true_mul_type == 2'd2) begin //MULSI
			count_next = count_reg - 1;
			output_instruction = {ADDS_OPCODE, dest_reg, dest_reg, true_source_reg, 13'b0};
			 if (count_next == 0) begin
	                    // This was the last ADD. Go to halt.
	                    state_next = sHalt;
	                end else begin
	                    // More ADDs needed. Stay in this state.
	                    state_next = sKeep_adding;
	                end 
		end //come back to do MULSR


            end

            sHalt: begin
                // Done. Hand control back to the main IF stage.
                mux_ctrl = 0;
                state_next = sIdle; // Wait for the next MUL
            end

            default: begin
                // Safety case
                state_next = sIdle;
                mux_ctrl = 0;
            end
        endcase
    end

endmodule
