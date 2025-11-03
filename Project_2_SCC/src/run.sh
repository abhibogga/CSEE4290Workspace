#!/bin/bash

Profile="$1"

case "$Profile" in
    group2)
        AsmFile="simple_crc.asm"
        VerilogFile="scc_tb_simple_crc.v"
    ;;
    group6)
        AsmFile="shift_count.asm"
        VerilogFile="shift_count_tb.v"
    ;;
    group5)
        AsmFile="floatAdd.asm"
        VerilogFile="scc_tb.v"
    ;;
    bubble)
        AsmFile="BubbleSort.asm"
        VerilogFile="oct_10_checkpoint.v"
    ;;
    *)
        echo "❌ Invalid profile '$Profile'. Valid options: group2, group6, group5, bubble"
        exit 1
    ;;
esac

python3 assembler/parser/assembler.py assembler/tests/$AsmFile assembler/parser/instructions.json

iverilog -o test testbenches/$VerilogFile
vvp ./test
gtkwave dump.vcd
