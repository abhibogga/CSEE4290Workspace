`include "iFetch_gemini.v"
`include "iDecode.v"
`include "execute.v"
`include "mem.v"
`include "register_gemini.v"
`include "ucode_rom_gemini.v"

module scc
(
    input         clk,    // Core clock
    input         clk_en, // Clock enable
    input         rst,    // Active low reset
    input  [31:0] instruction, // Instruction memory read value
    input  [31:0] dataIn,      // Data memory read value

    output reg [1:0] err_bits,
    output reg [31:0] instruction_memory_v, // Instruction memory address
    
    output reg [31:0] data_memory_v,      // Data memory address

    output wire [31:0] programCounter, 

    //Outputs to talk to instruction_and_data.v
    output wire writeFlag, 
    output wire [31:0] dataOut, 
    output wire [31:0] addressIn, 
    output wire halt
);

    // Wires for IF <-> UCODE <-> REG communication
    wire [31:0] instrcutionForID; 
    wire [6:0] mul_opcode_scc;
    wire [3:0] mul_imm_rd_scc;
    wire [3:0] mul_imm_rs_scc;
    // FIX: Corrected width from [3:0] to [15:0] to match module port
    wire [15:0] mul_imm_imm_scc; 
    wire [3:0] ghost_PC_scc; // FIX: Width should be [4:0] to match ucode_rom input
    wire ucode_flag;
    // FIX: Added wire for ucode_rom output to iFetch ghost_instruction input
    wire [31:0] ucode_instruction_scc;
    wire ucode_done;

    iFetch_gemini IF (
        .clk(clk), 
        .rst(rst), 
        .fetchedInstruction(instruction), 
        .ghost_instruction(ucode_instruction_scc), // FIX: Connected feedback from ucode_rom
        .programCounter(programCounter), 
        .filteredInstruction(instrcutionForID), 
        .exeOverride(exeOverride),
        .exeData(exeData), // FIX: Added missing comma
        .mul_opcode_out(mul_opcode_scc),
        .mul_imm_rd(mul_imm_rd_scc),
        .mul_imm_rs(mul_imm_rs_scc), // FIX: Added missing connection for rs
        .mul_imm_imm(mul_imm_imm_scc),
        .ghost_PC(ghost_PC_scc),
        .ucode_flag(ucode_flag),
	.ucode_done(ucode_done)
    );

    ucode_rom ucode_rom (
        .clk(clk),
        .mul_opcode(mul_opcode_scc),
        .rst(rst), // FIX: Added missing comma
        .immediate(mul_imm_imm_scc), // FIX: Corrected typo from mul_imm_scc
        .reg1(mul_imm_rs_scc),
	.reg2(4'b0000);
        .dest_reg(mul_imm_rd_scc), // FIX: Added missing connection for dest
        .ghost_pc(ghost_PC_scc), // FIX: Added missing connection for ghost_pc
        .output_instruction(ucode_instruction_scc), // FIX: Added missing connection for output
	.ucode_done(ucode_done)
    );
        
    register REGFILE (
          .clk(clk),
          .rst(rst),

          // Register addresses
          .rd(exe_readRegDest),    // destination register index (from EXE or Decode)
          .rs1(exe_readRegFirst),   // source register 1 (from EXE or Decode)
          .rs2(exe_readRegSec),     // source register 2 (from EXE or Decode)

          // Write-back control
          .write(exe_writeToReg),   // enable write (from EXE)
          .writeData(exe_writeData),// data to write back into rd

          // Read outputs
          .out_rd(readDataDest),
          .out_rs1(readDataFirst),
          .out_rs2(readDataSec), // FIX: Added missing comma
          .ucode_flag(ucode_flag)
    );

    
    //Decode Inputs/Outputs
    wire        branch;
    wire        loadStore;
    wire        dataRegister;
    wire        dataRegisterImm;
    wire        specialEncoding;
    wire        setFlags;
    wire [2:0]  aluFunction;
    wire        regWrite;
    wire        regRead;
    wire [3:0]  out_destRegister;
    wire [3:0]  out_sourceFirstReg;
    wire [3:0]  out_sourceSecReg;
    wire [15:0] out_imm;
    wire [3:0] branchInstruction; 
    wire [1:0] firstLevelDecode; 
    wire [3:0] secondLevelDecode; 

    //Init module
    iDecode ID (
        .instruction(instrcutionForID),
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .loadStore(loadStore),
        .dataRegister(dataRegister),
        .dataRegisterImm(dataRegisterImm),
        .specialEncoding(specialEncoding),
        .setFlags(setFlags),
        .aluFunction(aluFunction),
        .regWrite(regWrite),
        .regRead(regRead),
        .out_destRegister(out_destRegister),
        .out_sourceFirstReg(out_sourceFirstReg),
        .out_sourceSecReg(out_sourceSecReg),
        .out_imm(out_imm), 
        .branchInstruction(branchInstruction), 
        .firstLevelDecode_out(firstLevelDecode), 
        .secondLevelDecode_out(secondLevelDecode), 
        .halt(halt)
    );


    //Exe wires
    wire [3:0] exe_readRegDest;
    wire [3:0] exe_readRegFirst;
    wire [3:0] exe_readRegSec;
    wire [31:0] exe_writeData;
    wire        exe_writeToReg;
    wire        exeOverride;
    wire [15:0] exeData;

    // Memory interface outputs
    wire [31:0] exe_memoryDataOut;
    wire [31:0] exe_memoryAddressOut;
    wire        exe_memoryWrite;

    //Register File Reads
    wire [31:0] readDataDest; 
    wire [31:0] readDataFirst;
    wire [31:0] readDataSec;

    execute EXE (
        .clk(clk),
        .rst(rst),

        // Control inputs from Decode
        .firstLevelDecode(firstLevelDecode),
        .specialEncoding(specialEncoding),
        .secondLevelDecode(secondLevelDecode),
        .aluFunctions(aluFunction),
        .branchInstruction(branchInstruction),
        .imm(out_imm),
        .destReg(out_destRegister),
        .sourceFirstReg(out_sourceFirstReg),
        .sourceSecReg(out_sourceSecReg),
        .setFlags(setFlags),

        // Register file read values
        .readDataDest(readDataDest),
        .readDataFirst(readDataFirst),
        .readDataSec(readDataSec),

        // Register file control outputs
        .readRegDest(exe_readRegDest),
        .readRegFirst(exe_readRegFirst),
        .readRegSec(exe_readRegSec),
        .writeData(exe_writeData),
        .writeToReg(exe_writeToReg),

        // Branch control (to IF)
        .exeOverride(exeOverride),
        .exeData(exeData),

        // Memory interface (to instruction_and_data)
        .memoryDataOut(exe_memoryDataOut),
        .memoryAddressOut(exe_memoryAddressOut),
        .memoryWrite(exe_memoryWrite)
    );

    mem MEM (
        .clk(clk),
        .rst(rst),

        // Inputs from Execute
        .writeIn(exe_memoryWrite),
        .addressIn(exe_memoryAddressOut),
        .dataIn(exe_memoryDataOut),

        // Outputs to memory module (instruction_and_data.v)
        .dataOut(dataOut),
        .addressOut(addressIn),
        .writeFlag(writeFlag)
    );

endmodule
