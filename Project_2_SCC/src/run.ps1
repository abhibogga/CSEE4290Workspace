iverilog -o test .\testbenches\oct_3_checkpoint.v

vvp .\test


gtkwave dump.vcd