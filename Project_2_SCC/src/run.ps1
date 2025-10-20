iverilog -o test ./testbenches/ucode_tb.v scc_f25_top.v
vvp ./test
gtkwave dump.vcd
clear 

iverilog -o test .\testbenches\oct_10_checkpoint.v

vvp .\test


gtkwave dump.vcd
