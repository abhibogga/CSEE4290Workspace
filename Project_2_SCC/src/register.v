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
    output reg [31:0] out_rd;
    output reg [31:0] out_rs1; 
    output reg [31:0] out_rs2; 


    //Define states/registers here
    reg [31:0] registerFile [15:0];


    //Logic
    always @(posedge clk) begin 
        if (write) begin 
            registerFile[rd] <= writeData;
        end
    end

    //comb logic
    assign out_rd = registerFile[rd]; 
    assign out_rs1 = registerFile[rs1];
    assign out_rs2 = registerFile[rs2];




endmodule