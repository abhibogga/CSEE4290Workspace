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

    //I/O for memory
    output reg [31:0] memoryDataOut, 
    output reg [31:0] memoryAddressOut, 
    output reg memoryWrite, 
    output reg memoryRead, 
    input [31:0] memoryDataIn
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
    // Reset / flag register
    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            flags <= 4'b0000;
        end else begin
            // Always capture next flags; gating happens in comb logic
            flags <= flags_next;
        end
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
        memoryRead      = 1'b0; 
        memoryAddressOut = 32'd0;
        immExt = 0; 
        tempDiff = 0; 

        flags_next = flags; //MAYBE TAKE OUT IDK

        case (firstLevelDecode)
            2'b11: begin 
                // Branch logic
                case (branchInstruction)
                    //$display("t=%0t | flags_next = %b (bin) | old flags = %b",$time, flags_next, flags);
                    4'b0000: begin //BEQ
                        //$display("beq considered");
                        if (flags[2] == 1'b1) begin 
                            //$display("beq taken");
                            exeOverride = 1; 
                        end else begin 
                            exeOverride = 0; 
                        end 
                    end   

                    4'b0001: begin  //BNE
                       
                        if (flags[2] == 1'b0) begin 
                            //$display("Non Zero Flag Branch Taken");
                            exeOverride = 1; 
                        end else begin 
                            exeOverride = 0; 
                        end 
                    end


                    4'b0100: begin //BMI
                        //$display("BMI? flags=%b | N=%b Z=%b C=%b V=%b", flags, flags[3], flags[2], flags[1], flags[0]);
                       
                        if (flags[3] == 1'b1) begin 
                            //$display("BMI? flags=%b | N=%b Z=%b C=%b V=%b", flags, flags[3], flags[2], flags[1], flags[0]);
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
                    memoryDataOut = readDataDest;
                    memoryWrite   = 1'b1;

                    writeToReg   = 1'b0; // store doesn’t write back

                    
                end else begin //Load
                    

                    //First we get the calculate the address
                    readRegFirst = sourceFirstReg; // base
                    memoryAddressOut = readDataFirst + {{16{imm[15]}}, imm};
                    //$display(imm);
                    //$display("memory address out = %0d (dec) = 0x%0h (hex)", memoryAddressOut, memoryAddressOut);

                    //Then we use that address to look into memory, so load that address into an output
                    memoryRead = 1; 
                    //Read that value
                    readRegDest = destReg; 
                    writeData = memoryDataIn;
                    
                    
                    writeToReg  = 1'b1; 
                    //Load it into the desination register

                    



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

                            3'b010: begin //CLR - imm
                               
                                //Algorithm provided by chat-gpt
                                readRegDest  = destReg;
                                
                                writeToReg   = 1'b1; 

                                
                                writeData = 32'b0;

                                

                            end
                        endcase
                    end

                    3'b001: begin 
                        case (secondLevelDecode)
                            4'b1001: begin //ADDS - imm
                                
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                
                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} + {1'b0, immExt};
                                writeData = tempDiff[31:0];

                                // Update flags
                                flags_next[3] = writeData[31];                     // N
                                flags_next[2] = (writeData == 32'd0);              // Z
                                flags_next[1] = tempDiff[32];                   // C
                                flags_next[0] = (~(readDataFirst[31] ^ immExt[31])) &
                                                ( readDataFirst[31] ^ writeData[31]);

                                //$display("flags_next = %b (bin))",
                                            //flags_next);

                            end  

                            4'b1010: begin //SUBS - imm
                               
                                //Algorithm provided by chat-gpt
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} - {1'b0, immExt};
                                writeData = tempDiff[31:0];

                                //$display("tempdiff", tempDiff); 

                                // Update flags
                                flags_next[3] = writeData[31];           // N
                                flags_next[2] = (writeData == 32'd0);    // Z
                                flags_next[1] = ~tempDiff[32];           // C = NOT borrow
                                flags_next[0] = (readDataFirst[31] ^ immExt[31]) &
                                                (readDataFirst[31] ^ writeData[31]);

                                //$display("flags_next = %b (bin))",
                                            //flags_next);
                            end


                            4'b0001: begin //ADD - imm
                                
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                
                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} + {1'b0, immExt};
                                writeData = tempDiff[31:0];

                               

                            end  

                            4'b0010: begin //SUB - imm
                               
                                //Algorithm provided by chat-gpt
                                readRegDest  = destReg;
                                readRegFirst = sourceFirstReg; 
                                writeToReg   = 1'b1; 

                                immExt   = {{16{imm[15]}}, imm};
                                tempDiff = {1'b0, readDataFirst} - {1'b0, immExt};
                                writeData = tempDiff[31:0];

                                

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


                        flags_next[3] = writeData[31];                     // N
                        flags_next[2] = (writeData == 32'd0);              // Z
                        flags_next[1] = aluRegister[32];                   // C
                        flags_next[0] = (~(readDataFirst[31] ^ readDataSec[31])) &
                                        ( readDataFirst[31] ^ writeData[31]); // V

                        //$display("flags_next = %b (bin))",
                                            //flags_next);

                    end  

                    4'b1010: begin //SUBS
                        //$display("subs taken"); 
                        readRegDest = destReg; 
                        readRegFirst = sourceFirstReg; 
                        readRegSec = sourceSecReg; 

                        aluRegister = readDataFirst - readDataSec; 

                        

                        //$display("Source Reg First in SUBS:   %b", readRegFirst); 
                        writeToReg = 1; 

                        writeData = aluRegister; 


                        //Update the flags
                        flags_next[3] = writeData[31];           // N
                        flags_next[2] = (writeData == 32'd0);    // Z
                        flags_next[1] = ~aluRegister[32];           // C = NOT borrow
                        flags_next[0] = (readDataFirst[31] ^ readDataSec[31]) &
                                        (readDataFirst[31] ^ writeData[31]);   // V

                       // $display("flags_next = %b (bin))",
                                            //flags_next);
                    end
                    


                     4'b0001: begin //ADD
                        
                        readRegDest = destReg; 
                        readRegFirst = sourceFirstReg; 
                        readRegSec = sourceSecReg; 

                        aluRegister = readDataFirst + readDataSec; 

                        writeToReg = 1; 

                        writeData = aluRegister; 


                        

                    end  

                    4'b0010: begin //SUB
                        //$display("subs taken"); 
                        readRegDest = destReg; 
                        readRegFirst = sourceFirstReg; 
                        readRegSec = sourceSecReg; 

                        aluRegister = readDataFirst - readDataSec; 

                        //$display("Source Reg First in SUBS:   %b", readRegFirst); 
                        writeToReg = 1; 

                        writeData = aluRegister; 


                        

                    end
                    

                endcase

            end
        endcase
    end
endmodule
