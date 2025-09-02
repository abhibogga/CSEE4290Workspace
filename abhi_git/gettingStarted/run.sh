iverilog -o test.vvp gettingStarted.v

vvp test.vvp -lx2 > run.log

gtkwave dump.lx2