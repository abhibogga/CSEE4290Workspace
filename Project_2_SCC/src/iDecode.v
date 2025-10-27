//CODE WRITTEN BY TEAM, BUT SYNTAX ERRORS AND ADDITIONAL COMMENTS PROVIDED BY CHATGPT FOR UNDERSTANDING
module iDecode(
    input  [31:0] instruction, 
    input         clk, 
    input         rst, 

    output reg        branch, 
    output reg        loadStore,       
    output reg        dataRegister, 
    output reg        dataRegisterImm, 
    output reg        specialEncoding,
    output reg        setFlags,  
    output reg [2:0]  aluFunction,     
    output reg [3:0]  branchInstruction, 
    output reg        regWrite, 
    output reg        regRead, 
    output reg [3:0]  out_destRegister,
    output reg [3:0]  out_sourceFirstReg, 
    output reg [3:0]  out_sourceSecReg,
    output reg [15:0] out_imm, 
    output reg [1:0]  firstLevelDecode_out, 
    output reg [3:0]  secondLevelDecode_out,
    output reg        halt
);

    reg  [31:0] ifid_instr;
    wire        hold_if;

    reg hold_if_cal; //This was added because original hold_if was asserting itself at the same time the IF/ID Instruction was latching. 
    always @(posedge clk) begin
        if (rst) 
            hold_if_cal <= 1'b1;
        else
            hold_if_cal <= hold_if;
    end

    // Latch to IF/ID (freeze on hold_if)
    always @(posedge clk) begin
        if (rst) begin
            ifid_instr <= 32'h0;
        end else if (!hold_if_cal) begin
            ifid_instr <= instruction;
        end
    end

    // Microcode wires driven by submodules (must be wires, not regs)
    wire        uc_active;
    wire [31:0] uc_instr;
    wire [7:0]  uc_addr;

    // Instruction seen by the rest of decode
    wire [31:0] instruction;


    // Field extraction from effective instruction
    wire [1:0]  firstLevelDecode     = instruction[31:30]; 
    wire        specialBit           = instruction[29]; 
    wire [3:0]  secondLevelDecode    = instruction[28:25];
    wire [2:0]  aluOperationCommands = instruction[27:25];
    wire [3:0]  branchCondition      = instruction[24:21]; 
    wire [3:0]  destReg              = instruction[24:21]; 
    wire [3:0]  sourceFirstReg       = instruction[20:17]; 
    wire [3:0]  sourceSecReg         = instruction[16:13]; 
    wire [15:0] imm                  = instruction[15:0];

    always @(*) begin
        branch                = 1'b0;
        loadStore             = 1'b0;
        dataRegister          = 1'b0;
        dataRegisterImm       = 1'b0;
        specialEncoding       = 1'b0;
        setFlags              = 1'b0;
        aluFunction           = 3'd0;
        branchInstruction     = 4'd0;
        regWrite              = 1'b0;
        regRead               = 1'b0;
        out_destRegister      = 4'd0;
        out_sourceFirstReg    = 4'd0;
        out_sourceSecReg      = 4'd0;
        out_imm               = 16'd0;
        firstLevelDecode_out  = firstLevelDecode;
        secondLevelDecode_out = secondLevelDecode;
        aluFunction           = aluOperationCommands;

        halt = (instruction[31:25] == 7'b1101000);

        specialEncoding = specialBit;
        setFlags        = secondLevelDecode[0];
        out_imm         = imm;

        case (firstLevelDecode)
            2'b11: begin
                branch             = 1'b1;
                branchInstruction  = branchCondition;
                out_sourceFirstReg = sourceFirstReg; 
                out_sourceSecReg   = sourceSecReg;
                regRead            = 1'b1;
                regWrite           = 1'b0;
            end
            2'b10: begin
                loadStore          = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
            end
            2'b01: begin
                dataRegister       = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                out_sourceSecReg   = sourceSecReg;
            end
            2'b00: begin
                dataRegisterImm    = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                regRead            = 1'b1;
                regWrite           = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule
