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
    "group6" {
        $AsmFile = "assembler/tests/ALU_Test.asm"
        $VerilogFile = "alu_tb.v"
    }
    "mem" {
        $AsmFile = "assembler/tests/MemTest.asm"
        $VerilogFile = "memory_tb.v"
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


iverilog -o test $VerilogFile 
vvp ./test
gtkwave dump.vcd

