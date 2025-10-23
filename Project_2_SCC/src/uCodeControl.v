module u_code_control (
    input clk, 
    input rst,
    input wire  [31:0] ifid_instr,
    //input wire [3:0] id_rd, //Destination register
    //input wire [3:0] id_rn, //Operand register 1
    //input wire [3:0] id_rm, //Operand register 2

    output reg  hold_if,
    output reg  uc_active,
    output reg [7:0] uc_addr
);

endmodule