param(
    [string]$Profile = "",
    [string]$AsmFile = "",
    [string]$VerilogFile = ""
)

# --- PRESET GROUP DEFINITIONS ---
switch ($Profile.ToLower()) {
    "group2" {
        $AsmFile = "simple_crc.asm"
        $VerilogFile = "scc_tb_simple_crc.v"
    }
    "bubble" {
        $AsmFile = "BubbleSort.asm"
        $VerilogFile = "oct_10_checkpoint.v"
    }

    "group6" {
        $AsmFile = "shift_count.asm"
        $VerilogFile = "shift_count_tb.v"
    }

    "simpleMul" {
        $AsmFile = "test_mul.asm"
        $VerilogFile = "testbench.v"
    }

    "" {
        Write-Error "❌ Invalid profile '$Profile'. Valid options are: group2, group6, mem."
        exit 1
    }
    default {
        Write-Error "❌ Invalid profile '$Profile'. Valid options are: group2, group6, mem."
        exit 1
    }
}
python3 assembler/parser/assembler.py assembler/tests/$AsmFile assembler/parser/instructions.json


iverilog -o test testbenches/$VerilogFile 
vvp ./test
gtkwave dump.vcd