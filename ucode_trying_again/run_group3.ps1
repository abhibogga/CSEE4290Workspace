iverilog -o test scc_encrypt_tb.v
vvp ./test
gtkwave dump.vcd
