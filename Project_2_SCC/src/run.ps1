iverilog -o test shift_count_tb.v 
vvp ./test
gtkwave dump.vcd

