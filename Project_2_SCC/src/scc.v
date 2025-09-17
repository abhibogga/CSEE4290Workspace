

module scc
(
	input         clk,    // Core clock
	input         clk_en, // Clock enable
	input         rst, // Active low reset
	input  [31:0] instruction, // Instruction memory read value
	input  [63:0] dataIn,     // Data memory read value

	output  [3:0] err_bits,
	output [31:0] instruction_memory_a, // Instruction memory address
	output        instruction_memory_en,// Instruction memory read enable
	output [63:0] data_memory_a,        // Data memory address
	output [63:0] data_memory_out_v,    // Data memory write value
	output  [1:0] data_memory_s,        // Data memory read/write size
);

/******************************************************************************/
// Register declaration
/* The program counter (pointing to the next instruction to be fetched) */
reg [61:0] PC;
/* Processor state register (Holds NZCV flags`) */
reg [3:0] PSTATE;

/*****************************************************************************/



endmodule