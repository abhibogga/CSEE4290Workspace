`include "iFetch.v"
`include "iDecode.v"

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
    output wire [31:0] addressIn 

	
);


//Lets intialize IF module
wire [31:0] instrcutionForID; 
iFetch IF (
	.clk(clk), 
	.rst(rst), 
	.fetchedInstruction(instruction), 
	.programCounter(programCounter), 
	.filteredInstruction(instrcutionForID)
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
        .branchInstruction(branchInstruction)
    );






endmodule