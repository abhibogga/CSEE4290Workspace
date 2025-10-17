iverilog -o ucode_test_trying ./testbenches/ucode_tb.v scc_f25_top.v


vvp .\test


gtkwave dump.vcd
