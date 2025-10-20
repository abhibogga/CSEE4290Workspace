module register(clk, rst, rd, rs1, rs2, write, writeData, out_rd, out_rs1, out_rs2, uCodeFlag);
    //define inputs here
    input clk; 
    input rst; 
    input [3:0] rd; 
    input [3:0] rs1; 
    input [3:0] rs2;  
    input write;
    input [31:0] writeData;  
    input uCodeFlag; 

    //define outputs here
    output wire [31:0] out_rd;
    output wire [31:0] out_rs1; 
    output wire [31:0] out_rs2; 


    //Define states/registers here
    reg [31:0] registerFile [15:0];

    reg [31:0] uCodeRegisterFile [15:0];

    integer i;
    //Logic
    always @(posedge clk) begin 

        if (uCodeFlag) begin 

            if (rst) begin
                for (i = 0; i < 16; i = i + 1)
                    uCodeRegisterFile[i] <= 32'd0;
            end else begin
                // write only if enabled and not register 14
                if (write && (rd != 4'd14)) begin
                    uCodeRegisterFile[rd] <= writeData;
                    $display("WRITE -> uCodeR[%0d] = %0d (0x%08h)", rd, $signed(writeData), writeData);
                end
                // keep R14 permanently zero
                uCodeRegisterFile[14] <= 32'd0;
            end

        end else begin 
            if (rst) begin
                for (i = 0; i < 16; i = i + 1)
                    registerFile[i] <= 32'd0;
            end else begin
                // write only if enabled and not register 14
                if (write && (rd != 4'd14)) begin
                    registerFile[rd] <= writeData;
                    $display("WRITE -> R[%0d] = %0d (0x%08h)", rd, $signed(writeData), writeData);
                end
                // keep R14 permanently zero
                registerFile[14] <= 32'd0;
            end
        end
        
    end

    //comb logic
    assign out_rd = uCodeFlag ? uCodeRegisterFile[rd] : registerFile[rd];
    assign out_rs1 = uCodeFlag ? uCodeRegisterFile[rs1] : registerFile[rs1];
    assign out_rs2 = uCodeFlag ? uCodeRegisterFile[rs2] : registerFile[rs2];

    




endmodule