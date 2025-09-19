iverilog -o test .\testbenches\sep_18_checkpoint.v

vvp .\test


gtkwave dump.vcd