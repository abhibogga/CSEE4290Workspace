iverilog -o test testbench.v 
vvp ./test
gtkwave dump.vcd
