#!/bin/bash

# --- PARAMETERS ---
Profile="$1"
AsmFile=""
VerilogFile=""

# --- PRESET GROUP DEFINITIONS ---
case "${Profile,,}" in
    group2)
        AsmFile="simple_crc.asm"
        VerilogFile="scc_tb_simple_crc.v"
        ;;
    group3)
        AsmFile="encrypt_decrypt.asm"
        VerilogFile="scc_encrypt_tb.v"
        ;;
    group1)
        AsmFile="new_lut.asm"
        VerilogFile="lut_tb.v"
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
        echo "❌ Invalid profile '$Profile'. Valid options are: group1, group2, group3, group5, group6, bubble"
        exit 1
        ;;
esac

# --- RUN SIMULATION ---
echo "✅ Profile selected: $Profile"
echo "📌 Assembly File: $AsmFile"
echo "📌 Verilog Testbench: $VerilogFile"

python3 assembler/parser/assembler.py assembler/tests/$AsmFile assembler/parser/instructions.json

iverilog -o test testbenches/$VerilogFile
vvp ./test
gtkwave dump.vcd
