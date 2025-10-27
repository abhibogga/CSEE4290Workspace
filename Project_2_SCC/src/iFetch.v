//FORMATTED CODE BY CHAT-GPT, CODE IS DONE BY GROUP 7 HOWEVER
//COMMENTS ALSO ADDED BY CHAT-GPT
module iFetch(
    input clk, 
    input rst, 
    input [31:0] fetchedInstruction,
    input exeOverride, 
    input exeOverrideBR,
    input [15:0] exeData, //15 bit imm
//    input mul_trigger,
  //  input mul_release,
    input control,
    input [31:0] readDataFirst, //for BR

    input [6:0] opcode,
    output reg [31:0] programCounter,
    output reg [31:0] filteredInstruction
);

    //Registers/States here: 
    reg [1:0] state, stateNext; 
    parameter sIdle = 0, sFilter = 1, sUcode = 2;
 
    reg [31:0] PC_next;

    //Branching offset things
    wire [15:0] imm16 = fetchedInstruction[15:0];
    wire signed [31:0] branchOffsetAddress = {{16{imm16[15]}}, imm16};

    wire [15:0] imm16_exe = exeData;
    wire signed [31:0] branchOffsetAddress_exe = {{16{imm16_exe[15]}}, imm16_exe};
    wire signed [31:0] for_br = {{16{readDataFirst[15]}}, readDataFirst};
       
    always @(posedge clk) begin 
        state <= stateNext; 

        if (rst) begin 
            programCounter <= 0; 
            state <= sIdle; 
        end 

        else begin 
            if (state == sFilter) begin 
                programCounter <= PC_next;
            end
        end
    end

    //====================
    // Combinational Logic
    //====================

    always @(*) begin 
        // default
        PC_next = programCounter + 4;

        case (state)
            sIdle: begin 
                if (rst) begin 
                    stateNext = sIdle; 
                end else begin 
                    stateNext = sFilter; 
                    programCounter = 0; 
                end
            end

            sFilter: begin 
                filteredInstruction = fetchedInstruction; 
                stateNext = sFilter;

                // === Conditional branch override from EXE ===
                if (exeOverrideBR) begin
			PC_next = programCounter + for_br;
		end

		else if (exeOverride) begin
			PC_next = programCounter + branchOffsetAddress_exe;
		end


                // === Unconditional branch (B) ===
                else if (fetchedInstruction[31:25] == 7'b1100000) begin
                    PC_next = programCounter + branchOffsetAddress;
                end 

                // === NOP ===
                else if (fetchedInstruction[31:25] == 7'b1100100) begin 
                    PC_next = programCounter + 4; 
                end 

		else if (control) begin
		    PC_next = programCounter; //freeze PC
		    stateNext = sUcode;
		end

                // === Default ===
                else begin 
                    PC_next = programCounter + 4; 
                end
            end

	   sUcode: begin
		if (control) begin
		    stateNext = sUcode;
		end
		else begin
		    stateNext = sFilter;
		end

	   end

           default: 
                stateNext = sIdle;
        endcase
    end

endmodule
