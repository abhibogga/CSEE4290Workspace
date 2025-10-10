//JUSTIFICATION FOR MODULE

/*Note: The PC is implemented as a dedicated register module (pcReg) instead of being stored
in the general-purpose register file. This isolates control flow updates (branches, jumps)
from ALU and data-path writes, preventing port contention and simplifying fetch logic.
*/

module programCounterModule(
    input clk,
    input rst, 

    input [31:0] writeValue,

    output reg [31:0] pcValue    

);


    always @(posedge clk) begin
        if (rst) begin 
            pcValue <= 0; 
        end else begin 
            pcValue <= writeValue; 
        end
    end


endmodule


