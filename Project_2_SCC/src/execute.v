module execute(
    input clk, 
    input rst, 
    input [1:0] firstLevelDecode, 
    input specialEncoding, 
    input [3:0] secondLevelDecode, 
    input [2:0] aluFunctions, 
    input [3:0] branchInstruction
)


    //Define extra registers here


    //Comb logic
    always @(*) begin 
        case (firstLevelDecode) 

            (2'b11): begin 
                //This means that it is a conditional branch and we need to do sum about it

            end

        endcase
    end

endmodule