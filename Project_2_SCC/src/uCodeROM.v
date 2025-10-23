module u_Code_Rom (
    input        clk, 
    input        rst,
    input  [7:0] u_addr,  
    output reg [31:0] uc_instr
);
    always @(*) begin
        case (u_addr)
            8'h00: uc_instr = 32'h00000000;
            default: uc_instr = 32'h00000000;
        endcase
    end
endmodule
