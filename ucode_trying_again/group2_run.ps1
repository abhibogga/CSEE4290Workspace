iverilog -o test scc_tb_simple_crc.v
vvp ./test
gtkwave dump.vcd
