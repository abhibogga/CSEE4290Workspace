module iFetch_gemini(
    clk, 
    rst, 
    ghost_instruction, 
    fetchedInstruction, 
    programCounter, 
    filteredInstruction, 
    exeOverride, 
    exeData, 
    mul_opcode_out, 
    mul_imm_rd, 
    mul_imm_rs, 
    mul_imm_imm, 
    ghost_PC, 
    ucode_flag,
    ucode_done // FIX: Added undeclared input
);

    // Inputs here: 
    input clk; 
    input rst; 
    input [31:0] fetchedInstruction;
    input [31:0] ghost_instruction; 
    input exeOverride; 
    input [15:0] exeData; //15 bit imm
    input ucode_done;     // FIX: Added undeclared input

    // Outputs here: 
    output reg [31:0] programCounter;
    output reg [31:0] filteredInstruction;
    output reg [6:0] mul_opcode_out;
    output [3:0] mul_imm_rd;
    output [3:0] mul_imm_rs;
    output [15:0] mul_imm_imm; //just forward the registers and immediate to ucode_rom
    output reg [3:0] ghost_PC; ///only 30 lines in ucode rom
    output reg ucode_flag;

    // Registers/States here: 
    reg [1:0] state, stateNext;
    reg [1:0] trigger; 
    parameter sIdle = 0, sFilter = 1, sUcode = 2;

    // Branching offset things
    wire [15:0] imm16; 
    assign imm16 = fetchedInstruction[15:0];
    wire signed [31:0] branchOffsetAddress = {{16{imm16[15]}}, imm16};

    wire [15:0] imm16_exe; 
    assign imm16_exe = exeData;
    wire signed [31:0] branchOffsetAddress_exe = {{16{imm16_exe[15]}}, imm16_exe};
    
    wire [6:0] mul_opcode_inside;
    // FIX: Corrected 'mul_opcode' to 'mul_opcode_inside' which is declared
    assign mul_opcode_inside = fetchedInstruction[31:25]; 
    assign mul_imm_rd = fetchedInstruction[24:21];
    assign mul_imm_rs = fetchedInstruction[20:17];
    assign mul_imm_imm = fetchedInstruction[15:0];

    // Sequential Logic Here: 
    always @(posedge clk) begin 
        if (rst) begin 
            programCounter <= 0; 
            state <= sIdle; 
            ghost_PC <= 0;
            ucode_flag <= 0;
        end else begin 
       

	    if (stateNext == sUcode && state != sUcode) begin
		ghost_PC <= 0;
	    end  //initialize ghost_PC to be start of algorithm

	    state <= stateNext;
            
            // Sequential Logic based on current state
            case (state)
                sFilter: begin
                    if (exeOverride) begin 
                        programCounter <= programCounter + branchOffsetAddress_exe;
                    end else begin 
                        // B OPCODE: 1100000
                        if (fetchedInstruction[31:30] == 2'b11 && fetchedInstruction[28:25] == 4'b0000) begin 
                            programCounter <= programCounter + 4 + branchOffsetAddress; 
                            $display("in uncond branch");
                            $display(branchOffsetAddress); 
                        // NOP OPCODE: 1100100
                        end else if (fetchedInstruction[31:30] == 2'b11 && fetchedInstruction[28:25] == 4'b0010) begin 
                            programCounter <= programCounter + 4;
                        end else begin 
                            programCounter <= programCounter + 4; 
                        end
                    end

                    // Check for multiply instructions to forward opcode
                    if (mul_opcode_inside == 7'b0010000 || mul_opcode_inside == 7'b0011000 || mul_opcode_inside == 7'b0110000 || mul_opcode_inside == 7'b0111000) begin
                        mul_opcode_out <= mul_opcode_inside;
                    end else begin
                        mul_opcode_out <= 7'b0;
                    end
                end

                sUcode: begin
		   if (ghost_instruction[31:28] == 4'b1101) begin
			state <= sFilter; //HALT from ucode
			trigger <= 2'b01;
		   end else if (ghost_PC == 4) begin
			ghost_PC <= ghost_PC - 3;
			trigger <= 2'b10;
		   end else begin
                        ghost_PC <= ghost_PC + 1;
                   end
                end 
            endcase
        end 
    end

    // Combinational Logic Here: 
    always @(*) begin 

        case (state) 
            sIdle: begin 
                if (rst == 1) begin
		    stateNext = sIdle; 
		end else begin
		    stateNext = sFilter;
		end          
	     end

            sFilter: begin 
                // In sFilter, normal instructions are from fetchedInstruction
                filteredInstruction = fetchedInstruction;
                ucode_flag = 0; // Not in ucode mode
                
                // FIX: Transition to ucode state check
                if (mul_opcode_inside == 7'b0010000 || mul_opcode_inside == 7'b0011000 || mul_opcode_inside == 7'b0110000 || mul_opcode_inside == 7'b0111000) begin
                    stateNext = sUcode;
                end else begin
                    stateNext = sFilter; 
                end
            end

            // FIX: Corrected state name from 'ucode' to 'sUcode'
            sUcode: begin
                // In sUcode, instructions come from the ghost ROM
                filteredInstruction = ghost_instruction; 
                
                ucode_flag = 1;

                // FIX: Corrected comparison from '=' to '=='
                if (ucode_done == 1) begin
                    stateNext = sFilter;
                end else begin
                    stateNext = sUcode;
                end
            end 
            
            default: 
                stateNext = sIdle; 
        endcase
    end
endmodule
