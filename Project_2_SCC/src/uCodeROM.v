module u_Code_Rom (
    input clk, 
    input rst,
    input wire  [7:0]  u_addr,  
    
    output wire [31:0] normal_instr,
);
    always @(*) begin
        case (addr)
            //Insert Algorithim for MUL or somes shit
        endcase
    end
endmodule