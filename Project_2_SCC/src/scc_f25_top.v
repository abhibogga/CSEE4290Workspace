`include "Instruction_and_data.v"
`include "scc.v"
module scc_f25_top (
    clk, 
    clk_en,
    rst, 
    halt_f, 
    err_bits,
    instruction_memory_v, //Be able to see the instruction and memory at the top file
    data_memory_in_v,

);

//Inputs
input clk;
input rst; 
input clk_en; 

//Outputs
output halt_f; 
output wire [1:0] err_bits; 
output wire [31:0] instruction_memory_v;
output wire [31:0] data_memory_in_v;  


//--------------------------------------------------------


wire readBit; 
wire writeBit; 

wire [31:0] programCounter; 
wire [31:0] dataFetch; 

wire [31:0] instruction; 
wire [31:0] dataIn; 

//Initialize modules: 
Instruction_and_data iFetch (
    .mem_Clk(clk), //Clk
    .halt_f(halt_f), //Checks to see if halt has been found, if so stop searching for mem
    .instruction_memory_en(1'b1), //Instruction enable, this says do we need to fetch a instrction on the neg edge
    .instruction_memory_a(programCounter), //Memory address will start at loction 0
    .data_memory_a(dataFetch), //Data memory address, will start at 0 for now as well, but I acctually don't know how this works 
    .data_memory_read(readBit), 
    .data_memory_write(writeBit), 
    .instruction_memory_v(instruction), 
    .data_memory_in_v(dataIn)
);

scc scc(
    .clk(clk), 
    .clk_en(clk_en), 
    .instruction(instruction), 
    .dataIn(dataIn), 
    .err_bits(err_bits), 
    .instruction_memory_v(instruction_memory_v),
    .data_memory_v(data_memory_in_v)
); 







endmodule