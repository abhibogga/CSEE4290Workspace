//FORMATTED CODE BY CHAT-GPT, CODE IS DONE BY GROUP 7 HOWEVER
//COMMENTS ALSO ADDED BY CHAT-GPT
module iFetch(
    input clk, 
    input rst, 
    input [31:0] fetchedInstruction,
    input exeOverride, 
    input [15:0] exeData, //15 bit imm
	input mul_trigger,
    input mul_release,					
					  
 
					
							   
					   
	input [31:0] readDataFirst,
    input [6:0] opcode,				   
    output reg [31:0] programCounter,
    output reg [31:0] filteredInstruction
);

    //Registers/States here: 
    reg [1:0] state, stateNext; 
    parameter sIdle = 0, sFilter = 1, sUcode = 2;

    //reg [31:0] PC; 
    reg [31:0] PC_next;  // <--- added

    //Branching offset things
    wire [15:0] imm16 = fetchedInstruction[15:0];
    wire signed [31:0] branchOffsetAddress = {{16{imm16[15]}}, imm16};
									

    wire [15:0] imm16_exe = exeData;
    wire signed [31:0] branchOffsetAddress_exe = {{16{imm16_exe[15]}}, imm16_exe};

	   

    //====================
    // Sequential Logic
    //====================
    always @(posedge clk) begin 
        state <= stateNext; 

        if (rst) begin 
            //PC <= 0; 
            programCounter <= 0; 
            state <= sIdle; 
        end 
									  
        else begin 
            if (state != sIdle) begin 
                // Update PC and programCounter together
                //PC <= PC_next;
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
                if (exeOverride) begin 
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

				else if (mul_trigger) begin
					PC_next = programCounter + 4; 
					stateNext = sUcode;
				end			 
						   
												  
				   
			   
                // === Default ===
                else begin 
                    PC_next = programCounter + 4; 
                end
            end

		   sUcode: begin
				filteredInstruction = fetchedInstruction;
				PC_next = programCounter; //tryna keep it frozen
				if (mul_release) begin
					stateNext = sFilter;
				  
				end
				else begin
					stateNext = sUcode;
				end

			end
	 
		 


																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											 
            default: 
                stateNext = sIdle;
        endcase
    end

endmodule
