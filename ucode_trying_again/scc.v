`include "iFetch.v"
`include "iDecode.v"
`include "execute.v"
//`include "mem.v"
`include "register.v"
`include "ucode.v"
`include "mux.v"


module scc
(
	input         clk,    // Core clock
	input         clk_en, // Clock enable
	input         rst, // Active low reset
	input  [31:0] instruction, // Instruction memory read value
	input  [31:0] dataIn,     // Data memory read value

	output  reg [1:0] err_bits,
	output reg [31:0] instruction_memory_v, // Instruction memory address
	
	output reg [31:0] data_memory_v,      // Data memory address

	output wire [31:0] programCounter, 

    //Outputs to talk to instruction_and_data.v
    output wire writeFlag, 
    output wire [31:0] dataOut, 
    output wire [31:0] addressIn, 
    output wire memoryRead,
    input [31:0] memoryDataIn,
    
    output wire halt


	
);


	//Lets intialize IF module
	wire [31:0] instructionForID;

	iFetch IF (
		.clk(clk), 
		.rst(rst), 
		.fetchedInstruction(instruction), 
		.programCounter(programCounter), 
		.filteredInstruction(filtered_instruction), 
		.exeOverride(exeOverride),
		.exeData(exeData)
	);

	wire [31:0] filtered_instruction;

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
		.instruction(instructionForID),
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
		.halt(halt),
		.mul_trigger(mul_trigger),
		.mul_type(mul_type)
	);

	wire mul_trigger;
	wire [31:0] ucode_inst;
	wire mux_ctrl;	
	wire [1:0] mul_type;

	ucode Ucode (
		.clk(clk),
		.rst(rst),
		.start_mul(mul_trigger),
		.mux_ctrl(mux_ctrl),
		.dest_reg(out_destRegister),
		.source_reg(out_sourceFirstReg),
		.immediate(out_imm),
		.output_instruction(ucode_inst),
		.readDataSecond(readDataSec),
		.mul_type(mul_type)
	);


	mux mux (
		.filtered_instruction(filtered_instruction),
		.ucode_instruction(ucode_inst),
		.control(mux_ctrl),
		.finalized_instruction(instructionForID)
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
	    .memoryDataOut(dataOut),
	    .memoryAddressOut(addressIn),
	    .memoryWrite(writeFlag), 
	    .memoryRead(memoryRead), 
	    .memoryDataIn(memoryDataIn)
	);


	register REGFILE (
	    .clk(clk),
	    .rst(rst),

	    // Register addresses
	    .rd(exe_readRegDest),     // destination register index (from EXE or Decode)
	    .rs1(exe_readRegFirst),   // source register 1 (from EXE or Decode)
	    .rs2(exe_readRegSec),     // source register 2 (from EXE or Decode)

	    // Write-back control
	    .write(exe_writeToReg),   // enable write (from EXE)
	    .writeData(exe_writeData),// data to write back into rd

	    // Read outputs
	    .out_rd(readDataDest),
	    .out_rs1(readDataFirst),
	    .out_rs2(readDataSec)
	);


endmodule
