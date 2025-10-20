module ucode(
    input clk, 
    input rst, 
    input regOneData, 
    input regTwoData, 
    input destRegData, 
    input [31:0] uPC, 
    output wire [31:0] u_instruction, 
);


//MUL Rd, #imm Code
/*
@00000000
22 20 00 00  
04 40 00 00  
00 60 00 0A  
26 86 00 01  
35 C8 00 00  
C2 00 00 08  
62 44 20 00  
08 22 00 01  
0A 66 00 01  
35 C6 00 00  
C2 20 FF E4  
22 04 00 00  
D0 00 00 00 
*/





endmodule