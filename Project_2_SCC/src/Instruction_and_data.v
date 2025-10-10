/*******************
** Changes Fall23 **
*******************/

/*
  Original Functionality: Memory module updated on negative clock edge.
  New Functionality: Memory module updates on instruction_memory_a,
    data_memory_a, posedge data_memory_read, or posedge data_memory_write.
    Memory Module should now load or store values whenever needed and not rely
    on a clock.

  New Functionality: Dumps memory contents into a file "scc_out.txt" on HALT.
    Memory addresses and values are output at 4-byte boundaries in a CSV format.
    Example:
    Address,Value
    0x00000420,0x69696969
    0x00FACADE,0xDEADBEEF
*/


module Instruction_and_data
(
  input mem_Clk,
  input halt_f,
  input instruction_memory_en,
  input [31:0] instruction_memory_a, // instruction memory starting address
  input [31:0] data_memory_a, // data memory starting address
  input data_memory_read,
  input data_memory_write,
  input [31:0] data_memory_out_v, // data mem values to put into memory
  
  output reg [31:0] instruction_memory_v, // instruction mem values
  output reg [31:0] data_memory_in_v // data mem values to get from memory
);
integer fd;
integer i;
reg [7:0] a,b,c,d;
reg [7:0] memory [0:(2**16)-1] ; // Maximum array to hold both instruction and data memory
initial begin
  $readmemh("output.mem", memory);
end
always @(instruction_memory_a, data_memory_a, posedge data_memory_read, posedge data_memory_write) begin
  if(instruction_memory_en) begin //Grabs 32 bit instruction
    instruction_memory_v[31:24] <= memory[instruction_memory_a];
    instruction_memory_v[23:16] <= memory[instruction_memory_a+1];
    instruction_memory_v[15:8] <= memory[instruction_memory_a+2];
    instruction_memory_v[7:0] <= memory[instruction_memory_a+3];
  end
  else if (~instruction_memory_en) begin //When low the SCC program pauses until set back to high which continues fetching instructions
    instruction_memory_v <= 'hFFFFFFFF;
  end
  if(data_memory_read) begin //Load instruction
    data_memory_in_v[31:24] <= memory[data_memory_a];
    data_memory_in_v[23:16] <= memory[data_memory_a+1];
    data_memory_in_v[15:8] <= memory[data_memory_a+2];
    data_memory_in_v[7:0] <= memory[data_memory_a+3];
  end
  if(data_memory_write) begin //Store instruction
    memory[data_memory_a] <= data_memory_out_v[31:24];
    memory[data_memory_a+1] <= data_memory_out_v[23:16];
    memory[data_memory_a+2] <= data_memory_out_v[15:8];
    memory[data_memory_a+3] <= data_memory_out_v[7:0];
    data_memory_in_v <= 'bx;
  end
end

// Outputs contents of memory on HALT
always@(posedge halt_f) begin
  $display("in here"); 
  fd = $fopen("scc_out.txt", "w");
  $fwrite(fd, "Address,Value\n");
  for(i = 32'b000000000; i < 32'h0000ffff; i=i+4) begin
    if(memory[i]===8'hXX)
      a = 8'h00;
    else
      a = memory[i];
    if(memory[i+1]===8'hXX)
      b = 8'h00;
    else
      b = memory[i+1];
    if(memory[i+2]===8'hXX)
      c = 8'h00;
    else
      c = memory[i+2];
    if(memory[i+3]===8'hXX)
      d = 8'h00;
    else
      d = memory[i+3];
    $fwrite(fd, "0x%h,", i, "0x%2h", a, "%2h", b, "%2h", c, "%2h", d, "\n");
  end
  $fclose(fd);
end
endmodule