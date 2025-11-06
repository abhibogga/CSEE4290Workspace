module register(clk, rst, rd, rs1, rs2, write, writeData, out_rd, out_rs1, out_rs2);
    //define inputs here
    input clk; 
    input rst; 
    input [3:0] rd; 
    input [3:0] rs1; 
    input [3:0] rs2;  
    input write;
    input [31:0] writeData;  

    //define outputs here
    output wire [31:0] out_rd;
    output wire [31:0] out_rs1; 
    output wire [31:0] out_rs2; 


    //Define states/registers here
    reg [31:0] registerFile [15:0];

    integer i;
    //Logic
    always @(posedge clk) begin 
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                registerFile[i] <= 32'd0;
        end 
        else begin
            // write only if enabled and not register 14
            if (write && (rd != 4'd14)) begin
                registerFile[rd] <= writeData;
                $display("WRITE -> R[%0d] = %0d (0x%08h)", rd, $signed(writeData), writeData);
            end
            // keep R14 permanently zero
            registerFile[14] <= 32'd0;
        end
    end

    //comb logic
    assign out_rd = registerFile[rd]; 
    assign out_rs1 = registerFile[rs1];
    assign out_rs2 = registerFile[rs2];

    

    wire [31:0] dbg_R0  = registerFile[0];
    wire [31:0] dbg_R1  = registerFile[1];
    wire [31:0] dbg_R2  = registerFile[2];
    wire [31:0] dbg_R3  = registerFile[3];
    wire [31:0] dbg_R4  = registerFile[4];
    wire [31:0] dbg_R5  = registerFile[5];
    wire [31:0] dbg_R6  = registerFile[6];
    wire [31:0] dbg_R7  = registerFile[7];
    wire [31:0] dbg_R8  = registerFile[8];
    wire [31:0] dbg_R9  = registerFile[9];
    wire [31:0] dbg_R10 = registerFile[10];
    wire [31:0] dbg_R11 = registerFile[11];
    wire [31:0] dbg_R12 = registerFile[12];
    wire [31:0] dbg_R13 = registerFile[13];
    wire [31:0] dbg_R14 = registerFile[14];
    wire [31:0] dbg_R15 = registerFile[15];


endmodule