iverilog -o test scc_tb.v 
vvp ./test
gtkwave dump.vcd
