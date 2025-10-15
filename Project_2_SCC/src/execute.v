module execute(
    input clk, 
    input rst, 
    input [1:0] firstLevelDecode, 
    input specialEncoding, 
    input [3:0] secondLevelDecode, 
    input [2:0] aluFunctions, 
    input [3:0] branchInstruction,
    input signed [15:0] imm,
    input [3:0] destReg, 
    input [3:0] sourceFirstReg, 
    input [3:0] sourceSecReg,
    input setFlags, 
    input [31:0] readDataDest,
    input [31:0] readDataFirst, 
    input [31:0] readDataSec,

    output reg [3:0] readRegDest,
    output reg [3:0] readRegFirst,
    output reg [3:0] readRegSec,
    output reg [31:0] writeData,
    output reg writeToReg, 
    output reg exeOverride, 
    output wire [15:0] exeData,

    output reg [31:0] memoryDataOut, 
    output reg [31:0] memoryAddressOut, 
    output reg memoryWrite
);

    assign exeData = imm; 
    reg [3:0] flags; // NZCV
    reg [3:0] flags_next; 


    //other registers
    reg  signed [31:0] immExt;
    reg signed [32:0] tempDiff;


    //Registers for Register additions
    reg [32:0] aluRegister;

    // Reset
    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            flags       <= 4'b0000; 
            exeOverride <= 1'b0; 
            writeToReg  <= 1'b0; 
        end
        exeOverride = 0; 
    end


    // Combinational logic
    always @(*) begin 
        // Defaults
        exeOverride     = 1'b0;
        readRegDest     = 4'd0;
        readRegFirst    = 4'd0;
        readRegSec      = 4'd0;
        writeToReg      = 1'b0; 
        writeData       = 32'd0;
        memoryWrite     = 1'b0;
        memoryDataOut   = 32'd0;
        memoryAddressOut = 32'd0;
        immExt = 0; 
        tempDiff = 0; 

        case (firstLevelDecode)
            2'b11: begin 
                // Branch logic
                case (branchInstruction)
                    4'b0000: begin //We need to see if the branch is taken 
                        if (flags[2] == 1'b1) begin 
                            //$display("Zero Flag Branch Taken");
                            exeOverride = 1; 
                        end else begin 
                            exeOverride = 0; 
                        end 
                    end   

                    4'b0001: begin 
                       
                        if (flags[2] == 1'b0) begin 
                            //$display("Non Zero Flag Branch Taken");
                            exeOverride = 1; 
                        end else begin 
                            exeOverride = 0; 
                        end 
                    end
                endcase

                
            end

            2'b10: begin 
                if (aluFunctions[0] == 1) begin //Stor
                    readRegFirst = sourceFirstReg; // base
                    readRegDest   = destReg;   // data to store

                    
                    memoryAddressOut = readDataFirst + {{16{imm[15]}}, imm};
                    memoryDataOut = readRegDest;
                    memoryWrite   = 1'b1;

                    writeToReg   = 1'b0; // store doesn’t write back

                    
                end
            end

            2'b00: begin 
                // ALU / MOV
                case ({firstLevelDecode, specialEncoding})
                    3'b000: begin //MOV functions
                        case (aluFunctions)
                            3'b000: begin // MOV
                                
                                readRegDest = destReg; 
                                writeData = {{16{imm[15]}}, imm};
                                //$display(imm);
                                
                                
                                writeToReg  = 1'b1;  
                            end
                        endcase
                    end

                    3'b001: begin 
                        case (secondLevelDecode)
                            4'b1001: begin //ADDS
                                
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                
                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} + {1'b0, immExt};
                                writeData = tempDiff[31:0];

                                // Update flags
                                flags[3] = writeData[31];           // N
                                flags[2] = (writeData == 32'd0);    // Z
                                flags[1] = tempDiff[32];           // C = NOT borrow
                                flags[0] = (readDataFirst[31] ^ immExt[31]) & 
                                           (readDataFirst[31] ^ writeData[31]); // V

                            end  

                            4'b1010: begin //SUBS
                               
                                //Algorithm provided by chat-gpt
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} - {1'b0, immExt};
                                writeData = tempDiff[31:0];

                                // Update flags
                                flags[3] = writeData[31];           // N
                                flags[2] = (writeData == 32'd0);    // Z
                                flags[1] = ~tempDiff[32];           // C = NOT borrow
                                flags[0] = (readDataFirst[31] ^ immExt[31]) & 
                                           (readDataFirst[31] ^ writeData[31]); // V

                            end
                        endcase
                    end
                    
                endcase
            end


            2'b01: begin 
                case (secondLevelDecode) // Since all of them are 011 we just need the second level decode
                    4'b1001: begin //ADDS
                        
                        readRegDest = destReg; 
                        readRegFirst = sourceFirstReg; 
                        readRegSec = sourceSecReg; 

                        aluRegister = readDataFirst + readDataSec; 

                        writeToReg = 1; 

                        writeData = aluRegister; 


                        //Update the flags
                        flags[3] = writeData[31];           // N
                        flags[2] = (writeData == 32'd0);    // Z
                        flags[1] = aluRegister[32];           // C = NOT borrow
                        flags[0] = (readDataFirst[31] == readDataSec[31]) && 
                                    (writeData[31] != readDataFirst[31]); // V


                    end  

                    4'b1010: begin //SUBS
                        //$display("subs taken"); 
                        readRegDest = destReg; 
                        readRegFirst = sourceFirstReg; 
                        readRegSec = sourceSecReg; 

                        aluRegister = readDataFirst - readDataSec; 

                        $display("Source Reg First in SUBS:   %b", readRegFirst); 
                        writeToReg = 1; 

                        writeData = aluRegister; 


                        //Update the flags
                        flags[3] = writeData[31];           // N
                        flags[2] = (writeData == 32'd0);    // Z
                        flags[1] = ~aluRegister[32];           // C = NOT borrow
                        flags[0] = (readDataFirst[31] == readDataSec[31]) && 
                                    (writeData[31] != readDataFirst[31]); // V

                    end
                    

                endcase

            end
        endcase
    end
endmodule
