module iDecode(instruction, clk, rst, branch, loadStore, dataRegister, dataRegisterImm, specialEncoding, setFlags, aluFunction, regWrite, regRead, out_destRegister, out_sourceFirstReg, out_sourceSecReg, out_imm); 

    //Define inputs here
    input [31:0] instruction; 
    input clk; 
    input rst; 


    //Define outputs here
    output reg branch; 
    output reg loadStore; //0 is Load, 1 is store
    output reg dataRegister; 
    output reg dataRegisterImm; 
    output reg specialEncoding;
    output reg setFlags;  
    output reg [2:0] aluFunction; //This will determine which ALU funciton we are using
    output reg [3:0] branchInstruction; 

    output reg regWrite; 
    output reg regRead; 
    output reg [3:0] out_destRegister;
    output reg [3:0] out_sourceFirstReg; 
    output reg [3:0] out_sourceSecReg;
    output reg [15:0] out_imm; 
    


    //States for Complete decode
    wire [1:0] firstLevelDecode; 
    wire specialBit; 
    wire [3:0] secondLevelDecode; 
    wire [2:0] aluOperationCommands; 
    wire [3:0] branchCondition; 
    wire [3:0] destReg; 
    wire [3:0] sourceFirstReg; 
    wire [3:0] sourceSecReg; 
    wire [15:0] imm; 


    //Assign Registers
    assign firstLevelDecode = instruction[31:30]; 
    assign specialBit = instruction[29]; 
    assign secondLevelDecode = instruction[28];
    assign aluOperationCommands = instruction[27:25];
    assign branchCondition = instruction[24:21]; 
    assign destReg = instruction[24:21]; 
    assign sourceFirstReg = instruction[20:17]; 
    assign sourceSecReg = instruction[16:13]; 
    assign imm = instruction[15:0];


    


    always @(*) begin 

            case (firstLevelDecode)
                //Branch
                2'b11:  begin 
                    branch = 1;
                    loadStore = 0; 
                    dataRegister = 0; 
                    dataRegisterImm = 0;

                    //Now we need to return the registers
                    out_destRegister = destReg; 
                    out_sourceFirstReg = sourceFirstReg; 
                    out_sourceSecReg = sourceSecReg; 

                    branchInstruction = branchCondition; 
                end

                //Load/Store
                2'b10:  begin 
                    branch = 0;
                    loadStore = 1; 
                    dataRegister = 0; 
                    dataRegisterImm = 0; 

                    
                    //Now we need to return the registers
                    out_destRegister = destReg; 
                    out_sourceFirstReg = sourceFirstReg; 
                    out_sourceSecReg = sourceSecReg; 

                end

                //Data Register
                2'b01:  begin 
                    branch = 0;
                    loadStore = 0; 
                    dataRegister = 1; 
                    dataRegisterImm = 0;

                    //Now we need to return the registers
                    out_destRegister = destReg; 
                    out_sourceFirstReg = sourceFirstReg; 
                    out_sourceSecReg = sourceSecReg; 
                end


                //Data Imm
                2'b00:  begin 
                    branch = 0;
                    loadStore = 0; 
                    dataRegister = 0; 
                    dataRegisterImm = 1; 

                    //Now we need to return the registers
                    out_destRegister = destReg; 
                    out_sourceFirstReg = sourceFirstReg; 
                    out_imm = sourceSecReg; 
                end

                default: begin 
                    branch = 0;
                    loadStore = 0; 
                    dataRegister = 0; 
                    dataRegisterImm = 0; 
                end

            endcase


            case (specialBit)
                1'b1: begin 
                    specialEncoding = 1; 
                end

                default: begin 
                    specialEncoding = 0; 
                end
            endcase

            case (secondLevelDecode)
                1'b1: begin 
                    setFlags = 1; 
                end

                default: begin 
                    setFlags = 0; 
                end
            endcase

            aluFunction = aluOperationCommands; 

    end

endmodule