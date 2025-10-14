module ghost(clk, rst, rd_g, rs1_g, rs2_g, write_g, writeData_g, out_rd_g, out_rs1_g, out_rs2_g);
    //define inputs here
    input clk; 
    input rst; 
    input [3:0] rd_g; 
    input [3:0] rs1_g; 
    input [3:0] rs2_g;  
    input write_g;
    input [31:0] writeData_g;  

    //define outputs here
    output wire [31:0] out_rd_g;
    output wire [31:0] out_rs1_g; 
    output wire [31:0] out_rs2_g; 

    //_g means _ghost for these ghost registers being used by ucode algo

    //Define states/registers here
    reg [31:0] ghost [15:0]; //let's just make 16 ghost registers bc why not lol

    integer i;
    //Logic
    always @(posedge clk) begin 
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) registerFile[i] <= 32'd0;
        end else if (write_g) begin
            registerFile[rd_g] <= writeData_g;
        end
    end

    //comb logic
    assign out_rd_g = ghost[rd_g]; 
    assign out_rs1_g = ghost[rs1_g];
    assign out_rs2_g = ghost[rs2_g];

endmodule
