iverilog -o test lut_tb.v 
vvp ./test
gtkwave dump.vcd
