clear 

iverilog -o test .\testbenches\oct_17_checkpoint.v

vvp .\test


gtkwave dump.vcd