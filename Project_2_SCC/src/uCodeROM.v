module u_Code_Rom (
    input        clk, 
    input        rst,
    input  [7:0] u_addr,  
    output reg [31:0] uc_instr
);
    always @(*) begin
        //$readmemh("uCodeROM.mem", memory);
        case (u_addr)
            8'b00000000: begin //ADDRESS for MUL Regular instructions
                
            end
        endcase
    end
endmodule
