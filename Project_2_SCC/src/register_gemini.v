module register(clk, rst, rd, rs1, rs2, write, writeData, out_rd, out_rs1, out_rs2, ucode_flag);
    //define inputs here
    input clk; 
    input rst; 
    input [3:0] rd; 
    input [3:0] rs1; 
    input [3:0] rs2;  
    input write;
    input [31:0] writeData;
    input ucode_flag;

    //define outputs here
    output wire [31:0] out_rd;
    output wire [31:0] out_rs1; 
    output wire [31:0] out_rs2; 

    //Define states/registers here
    reg [31:0] registerFile [15:0];
    reg [31:0] ghost_register_file [15:0];
    
    // FIX: Simplified state logic. We only need to know the previous state to detect transitions.
    reg [1:0] state, statePrev;
    parameter sIdle = 0, sRegular = 1, sUcode = 2;

    integer i;

    // Sequential Logic for writing to registers
    always @(posedge clk) begin 
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                registerFile[i] <= 32'd0;
                // FIX: Added index [i] to reset each element of the array
                ghost_register_file[i] <= 32'd0;
            end
            state <= sIdle;
            statePrev <= sIdle;
        end else begin
            // Update previous state tracker
            statePrev <= state;

            // Determine current state based on flag
            if (ucode_flag) begin
                state <= sUcode;
            end else begin
                state <= sRegular;
            end
            
            // Register Write Logic
            if (write) begin
                if (ucode_flag == 0) begin
                    // Regular mode: Write to the main register file
                    registerFile[rd] <= writeData;
                end else begin // ucode_flag is 1
                    // Ucode mode: Write to the ghost register file
                    // FIX: Added index [rd] to write to a specific ghost register
                    ghost_register_file[rd] <= writeData;
                end
            end

            // FIX: Detect the TRANSITION from regular state to ucode state to copy registers
            // This happens when the current state is sUcode and the previous state was sRegular.
            if (state == sUcode && statePrev == sRegular) begin
                for (integer j = 0; j < 16; j = j + 1) begin
                    ghost_register_file[j] <= registerFile[j];
                end
            end
        end
    end

    // Combinational Logic for reading from registers
    // FIX: Used the ternary operator to conditionally assign outputs.
    // This is the correct way to implement this multiplexer.
    assign out_rd  = (ucode_flag) ? ghost_register_file[rd]  : registerFile[rd];
    assign out_rs1 = (ucode_flag) ? ghost_register_file[rs1] : registerFile[rs1];
    assign out_rs2 = (ucode_flag) ? ghost_register_file[rs2] : registerFile[rs2];
    
    // FIX: The broken FSM `always @(*)` block has been removed, as its logic is now
    // handled more cleanly and directly in the main sequential `always @(posedge clk)` block.

endmodule
