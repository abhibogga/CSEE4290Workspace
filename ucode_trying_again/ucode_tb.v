`timescale 1ps/1ps
`include "scc_f25_top.v"

// FIX: Added module declaration
module ucode_tb;

	// FIX: Signals assigned in always/initial blocks must be regs
	reg clk;
	reg rst;
	reg clk_en;

	// FIX: Declared the missing wire for the module output
	wire halt_f;

	wire [1:0] err_bits;
	wire [31:0] instruction_memory_v;
	wire [31:0] data_memory_in_v;

	//Initialize module:
	scc_f25_top topMod (
	    .clk(clk),
	    .clk_en(clk_en),
	    .rst(rst),
	    .halt_f(halt_f),
	    .err_bits(err_bits),
	    .instruction_memory_v(instruction_memory_v),
	    .data_memory_in_v(data_memory_in_v)
	);

	//Define clk action
	always begin
	    clk = 1;
	    #5;
	    clk = 0;
	    #5;
	end

	//Define testbench action
	initial begin
	    $dumpvars(1, ucode_tb);
	    $monitor;
	    rst = 1;
	    clk_en = 1;

	    repeat (3) @(posedge clk);

	    rst = 0;
	    repeat (100) @(posedge clk);
	    $display;
	    $finish;

	end

endmodule
