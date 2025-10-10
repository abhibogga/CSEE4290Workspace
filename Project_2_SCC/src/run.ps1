iverilog -o test .\testbenches\oct_10_checkpoint.v

vvp .\test


gtkwave dump.vcd