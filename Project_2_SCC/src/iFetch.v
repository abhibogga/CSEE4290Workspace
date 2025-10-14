module iFetch(clk, rst, fetchedInstruction, programCounter, filteredInstruction, exeOverride, exeData);

    //Inputs here: 
    input clk; 
    input rst; 
    input [31:0] fetchedInstruction;

    input exeOverride; 
    input [15:0] exeData; //15 bit imm
    

    //Outputs here: 
    output reg [31:0] programCounter;
    output reg [31:0] filteredInstruction;


    //Registers/States here: 
    reg [1:0] state, stateNext; 

    parameter sIdle = 0, sFilter = 1;

    reg [31:0] PC; 


    //Branching offset things
    wire [15:0] imm16; 

    assign imm16 = fetchedInstruction[15:0];
    wire signed [31:0] branchOffsetAddress = {{16{imm16[15]}}, imm16};

    wire [15:0] imm16_exe; 
    assign imm16_exe = exeData;
    wire signed [31:0] branchOffsetAddress_exe = {{16{imm16_exe[15]}}, imm16_exe};
    

    //Sequential Logic Here: 
    always @(posedge clk) begin 
        state <= stateNext; 

        if (rst) begin 
            PC <= 0; 
            programCounter <= 0; 
            state <= sIdle; 
        end else begin 
            //Sequential Logic For States: 
            if (state == sFilter) begin 

                if (exeOverride) begin 
                    
                    programCounter = programCounter + branchOffsetAddress_exe;
                    PC = programCounter + 4;
                    
                end else begin 
                    //Prefetch logic, LOOKING FOR B, NOP, AND BR

                    //B OPCODE: 1100000
                    //NOP OPCODE: 1100100

                    if (fetchedInstruction[31:30] == 2'b11 && fetchedInstruction[28:25] == 4'b0000) begin 
                        //This is uncoditional branch with imm offset, so lets just change PC to whatever value is in here:
                        
                        programCounter <= PC + 4 + branchOffsetAddress;   
                        $display("in uncond branch");
                        $display(branchOffsetAddress); 
                    end else if (fetchedInstruction[31:30] == 2'b11 && fetchedInstruction[28:25] == 4'b0010) begin 
                        //This will be no operation (NOP), we just load, current PC value into PC + 4
                        programCounter <= PC;
                        PC <= PC + 4;
                    end else begin 
                        //Continue program counter as regular
                        programCounter <= PC;
                        PC <= PC + 4; 
                end
                end
                
                
            end
        end


        
    end

    //Logic 
    always @(*) begin 
        case (state) 

            sIdle: begin 

                if (rst) begin 
                    stateNext = sIdle; 
                end else begin 
                    stateNext = sFilter; 
                    PC = 0; 
                end

            end


            sFilter: begin 

                //Now we need to fetch whatever the memory module is giving us
                filteredInstruction = fetchedInstruction; 

                //Update State
                stateNext = sFilter; 

            end

            

             default: 
                stateNext = sIdle; 
        endcase
    end

endmodule