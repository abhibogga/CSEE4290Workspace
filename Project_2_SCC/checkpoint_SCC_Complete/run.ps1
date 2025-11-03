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
    "group3" {
        $AsmFile = "encrypt_decrypt.asm"
        $VerilogFile = "scc_encrypt_tb.v"
    }
    "group1" {
        $AsmFile = "new_lut.asm"
        $VerilogFile = "lut_tb.v"
    }
    "group6" {
        $AsmFile = "shift_count.asm"
        $VerilogFile = "shift_count_tb.v"
    }
    "group5" {
        $AsmFile = "floatAdd.asm"
        $VerilogFile = "scc_tb.v"
    }
    "bubble" {
        $AsmFile = "BubbleSort.asm"
        $VerilogFile = "oct_10_checkpoint.v"
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
