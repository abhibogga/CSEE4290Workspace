iverilog -o test .\tb_count.v

vvp .\test


gtkwave dump.vcd