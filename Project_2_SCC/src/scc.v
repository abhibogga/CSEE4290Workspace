

module scc
(
	input         clk,    // Core clock
	input         clk_en, // Clock enable
	input         rst, // Active low reset
	input  [31:0] instruction, // Instruction memory read value
	input  [31:0] dataIn,     // Data memory read value

	output  reg [1:0] err_bits,
	output reg [31:0] instruction_memory_v, // Instruction memory address
	
	output reg [31:0] data_memory_v      // Data memory address
	
);

/******************************************************************************/
// Register declaration
/* The program counter (pointing to the next instruction to be fetched) */
reg [61:0] PC;
/* Processor state register (Holds NZCV flags`) */
reg [3:0] PSTATE;

/*****************************************************************************/



endmodule