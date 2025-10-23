iverilog -o test ucode_tb.v 
vvp ./test
gtkwave dump.vcd

