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
    $dumpvars(0, ucode_tb);
    $dumpvars(0, ucode_tb.topMod.scc.REGFILE.registerFile);
    $dumpvars(0, ucode_tb.topMod.scc.REGFILE.ghost_register_file);
    $dumpvars(0, ucode_tb.topMod.scc.REGFILE.registerFile.immediate_held);

    rst = 1;
    clk_en = 1;

    repeat (3) @(posedge clk);
    //Keep rst high for 3 clks
    rst = 0;
    repeat (100) @(posedge clk);

    $finish;
// FIX: Added the missing 'end' to close the initial block
end

endmodule
