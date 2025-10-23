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
    //Should have its own scratchpad registers/states here:
    reg [1:0] ustate, ustateNext; 
    parameter usIdle = 0, usFilter = 1;

    //Should have own program counter according to discussion with classmates?
    reg [31:0] uPC; 
    reg [31:0] uPC_next;
    
    wire [6:0] op_code     = ifid_instr[31:25];
    //Tags begin here
    wire       is_mul  = (op_code == 7'b0010000);
    wire       is_muls = (op_code == 7'b0011000);

    //Since it is taking place of IF, does this mean it tracks state same as IF?
    //Sequential Logic
    always @(posedge clk) begin
        ustate <= ustateNext; 
        if (rst) begin //Just logic i'm following off of IF
            ustate   <= usIdle;
            uc_addr  <= 8'b00000000; //Default address for uc instruction
        end 
        else begin 
            if (ustate == usFilter) //
                ustate   <= ustateNext;
                uc_addr  <= start_seq ? 8'b00000000 : next_uc_addr;
        end
    end

    //Combinational Logic
    always @(*) begin 
        //Not sure yet
    end


endmodule