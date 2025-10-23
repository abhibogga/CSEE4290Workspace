iverilog -o test ucode_tb.v 
vvp ./test
gtkwave dump.vcd


iverilog -o test ./testbenches/ucode_tb.v scc_f25_top.v
