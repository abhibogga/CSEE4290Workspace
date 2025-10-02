module iFetch(clk, rst, fetchedInstruction, programCounter, filteredInstruction);

    //Inputs here: 
    input clk; 
    input rst; 
    input [31:0] fetchedInstruction;
    

    //Outputs here: 
    output reg [31:0] programCounter;
    output reg [31:0] filteredInstruction;


    //Registers/States here: 
    reg [1:0] state, stateNext; 

    parameter sIdle = 0, sFilter = 1;

    reg [31:0] PC; 


    

    //Sequential Logic Here: 
    always @(posedge clk) begin 
        state <= stateNext; 


        //Sequential Logic For States: 
        if (state == sFilter) begin 
            
            programCounter <= PC;
            PC <= PC + 4; 
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