//CODE WRITTEN BY TEAM, BUT SYNTAX ERRORS AND ADDITIONAL COMMENTS PROVIDED BY CHATGPT FOR UNDERSTANDING
//`include "uCodeControl.v"
//`include "uCodeROM.v"
module iDecode(
    input  [31:0] instruction, 
    input         clk, 
    input         rst, 

    output reg        branch, 
    output reg        loadStore,       
    output reg        dataRegister, 
    output reg        dataRegisterImm, 
    output reg        specialEncoding,
    output reg        setFlags,  
    output reg [2:0]  aluFunction,     
    output reg [3:0]  branchInstruction, 
    output reg        regWrite, 
    output reg        regRead, 
    output reg [3:0]  out_destRegister,
    output reg [3:0]  out_sourceFirstReg, 
    output reg [3:0]  out_sourceSecReg,
    output reg [15:0] out_imm, 
    output reg [1:0]  firstLevelDecode_out, 
    output reg [3:0]  secondLevelDecode_out,
    output reg        halt,
    output reg	      mul_trigger,
    output reg [1:0]  mul_type
);


    // === Field extraction ===
    wire [1:0] firstLevelDecode     = instruction[31:30]; 
    wire       specialBit           = instruction[29]; 
    wire [3:0] secondLevelDecode    = instruction[28:25];
    wire [2:0] aluOperationCommands = instruction[27:25];
    wire [3:0] branchCondition      = instruction[24:21]; 
    wire [3:0] destReg              = instruction[24:21]; 
    wire [3:0] sourceFirstReg       = instruction[20:17]; 
    wire [3:0] sourceSecReg         = instruction[16:13]; 
    wire [15:0] imm                 = instruction[15:0];
    wire [6:0] opcode		    = instruction[31:25];


    always @(*) begin
        //$display("Instr raw = %h", instruction);
        // ---------- Defaults to avoid latches / stale values ----------
        branch              = 1'b0;
        loadStore           = 1'b0;
        dataRegister        = 1'b0;
        dataRegisterImm     = 1'b0;
        specialEncoding     = specialBit;
        setFlags            = 1'b0;
        aluFunction         = 3'd0;
        branchInstruction   = 4'd0;
        regWrite            = 1'b0;
        regRead             = 1'b0;
        out_destRegister    = 4'd0;
        out_sourceFirstReg  = 4'd0;
        out_sourceSecReg    = 4'd0;
        out_imm             = 16'd0;
        firstLevelDecode_out= firstLevelDecode;
        secondLevelDecode_out = secondLevelDecode;
        aluFunction         = aluOperationCommands;
	
	mul_trigger         = 1'b0; //default
        // Halt detect (keep your pattern)
        halt = (instruction[31:25] == 7'b1101000);

        // Special / Flags
        setFlags        = secondLevelDecode[4]; // bit 28 is set flags

        case (firstLevelDecode)
            2'b11: begin
                branch             = 1'b1;
                branchInstruction  = branchCondition;
                out_sourceFirstReg = sourceFirstReg; 
                out_sourceSecReg   = sourceSecReg;
                regRead            = 1'b1;
                regWrite           = 1'b0;
            end
            2'b10: begin
                loadStore          = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
            end
            2'b01: begin
                dataRegister       = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                out_sourceSecReg   = sourceSecReg;
		
		case (opcode)
		   7'b0110000: begin //mulr
			mul_trigger = 1'b1;
			mul_type = 2'b1;
			out_sourceFirstReg = sourceFirstReg;
			out_destRegister = destReg;
			//we don't need to send immediate right?
		   end
	
		   7'b0111000: begin //mulsr
			mul_trigger = 1'b1;
			mul_type = 2'd3;
			out_sourceFirstReg = sourceFirstReg;
			out_destRegister = destReg;
			//do we need to send the second register?
		   end
		endcase
            end
            2'b00: begin
                dataRegisterImm    = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                regRead            = 1'b1;
		out_imm = imm;
                regWrite           = 1'b1; // ALU result will be written
           
		case (opcode)
		   7'b0010000: begin // muli
			mul_trigger = 1'b1;
			mul_type = 2'b0;
			out_sourceFirstReg = sourceFirstReg;
			out_destRegister = destReg;
			out_imm = imm; //send these over to ucode control

		   end

		   7'b0011000: begin //mulsi
			mul_trigger = 1'b1;
			mul_type = 2'd2;
			out_sourceFirstReg = sourceFirstReg;
			out_destRegister = destReg;
			out_imm = imm; //send these over to ucode control
		   end

		endcase

		
	     end

            default: begin
                // all defaults already safe       

            end
        endcase
    end
endmodule
