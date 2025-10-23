//FORMATTED CODE BY CHAT-GPT, CODE IS DONE BY GROUP 7 HOWEVER
//COMMENTS ALSO ADDED BY CHAT-GPT
module iDecode(
    input  [31:0] instruction, 
    input         clk, 
    input         rst, 

    output reg        branch, 
    output reg        loadStore,       // 0 = Load, 1 = Store
    output reg        dataRegister, 
    output reg        dataRegisterImm, 
    output reg        specialEncoding,
    output reg        setFlags,  
    output reg [2:0]  aluFunction,     // ALU function selector
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

    // === Field extraction (adjust bit slices if your ISA differs) ===
    wire [1:0] firstLevelDecode     = instruction[31:30]; 
    wire       specialBit           = instruction[29]; 
    wire [3:0] secondLevelDecode    = instruction[28:25];
    wire [2:0] aluOperationCommands = instruction[27:25];
    wire [3:0] branchCondition      = instruction[24:21]; 
    wire [3:0] destReg              = instruction[24:21]; 
    wire [3:0] sourceFirstReg       = instruction[20:17]; 
    wire [3:0] sourceSecReg         = instruction[16:13]; 
    wire [15:0] imm                 = instruction[15:0];

    always @(*) begin
        //$display("Instr raw = %h", instruction);
        // ---------- Defaults to avoid latches / stale values ----------
        branch              = 1'b0;
        loadStore           = 1'b0;
        dataRegister        = 1'b0;
        dataRegisterImm     = 1'b0;
        specialEncoding     = 1'b0;
        setFlags            = 1'b0;
        aluFunction         = 3'd0;
        branchInstruction   = 4'd0;
        regWrite            = 1'b0;
        regRead             = 1'b0;
        out_destRegister    = 4'd0;
        out_sourceFirstReg  = 4'd0;
        out_sourceSecReg    = 4'd0;
        out_imm             = 16'd0;
        firstLevelDecode_out= firstLevelDecode;
        secondLevelDecode_out = secondLevelDecode;
        aluFunction         = aluOperationCommands;

        // Halt detect (keep your pattern)
        halt = (instruction[31:25] == 7'b1101000);

        // Special / Flags
        specialEncoding = specialBit;
        setFlags        = secondLevelDecode[4]; // bit 28 is set flags

        // Common immediate (for data-imm path)
        out_imm = imm;

        // ---------- Main decode ----------
        case (firstLevelDecode)
            // BRANCH
            2'b11: begin
                branch             = 1'b1;
                branchInstruction  = branchCondition;
                // If your branch uses two regs, expose them:
                out_sourceFirstReg = sourceFirstReg; 
                out_sourceSecReg   = sourceSecReg;
                regRead            = 1'b1;
                regWrite           = 1'b0;
            end

            // LOAD / STORE
            2'b10: begin
                loadStore          = 1'b1;
                out_destRegister   = destReg;          // for LOAD dest, for STORE may be base
                out_sourceFirstReg = sourceFirstReg;   // base register
            end

            // DATA-REGISTER (R-R)
            2'b01: begin
                dataRegister       = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                out_sourceSecReg   = sourceSecReg;
            end

            // DATA-IMMEDIATE (R-Imm)
            2'b00: begin
                dataRegisterImm    = 1'b1;
                out_destRegister   = destReg;
                out_sourceFirstReg = sourceFirstReg;
                // out_imm already set to imm above
                regRead            = 1'b1;
                regWrite           = 1'b1; // ALU result will be written
            end

            default: begin
                // all defaults already safe
               
            end
        endcase
    end
endmodule
