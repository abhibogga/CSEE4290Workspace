// FIX: Removed invalid 'reg' declarations from the input ports in the module definition.
module ucode_rom(mul_opcode, clk, rst, immediate, reg1, reg2, dest_reg, ghost_pc, output_instruction);

    // FIX: All inputs are wires by default. No need to specify 'reg'.
    input [6:0] mul_opcode;
    input clk;
    input rst;
    input [15:0] immediate; 
    input [3:0] reg1;
    input [3:0] reg2;
    input [3:0] dest_reg;
    input [3:0] ghost_pc;

    // FIX: The output should be a 'reg' since it's assigned inside an 'always' block.
    output reg [31:0] output_instruction;
    
    // FIX: A ROM is modeled as a register array.
    reg [31:0] rom [0:30];

    // FIX: This entire block is now combinational (`always @(*)`). 
    // It acts like a logic block that defines the ROM contents based on the current inputs.
    always @(*) begin
        // Default case to avoid latches
        for (integer i = 0; i < 31; i = i + 1) begin
            rom[i] = 32'b0; // Default to NOP or 0
        end

        case(mul_opcode)
            // FIX: Added a colon ':' after the case condition.
            7'b0010000: begin //mul imm
                // Define the micro-code sequence for this operation directly in the ROM array.
                rom[0] = {7'b0000000, 4'b0001, 4'b0000, immediate}; // mov
                rom[1] = {7'b0110001, 4'b0000, 4'b0000, 4'b0000, 13'b0}; // add
                rom[2] = {7'b0010010, 4'b0001, 4'b0001, 1'b0, 16'd1}; // sub
                rom[3] = {7'b0011010, 4'b1110, 4'b0001, 1'b0, 16'd0}; // cmp
                rom[4] = {7'b1100001, 4'b0001, 5'b0000, -16'd3}; // bne
            end

            7'b0011000: begin //muls imm
                // Define the micro-code sequence for this operation here.
                // e.g., rom[5] = ...
            end

            7'b0110000: begin //mul reg
                // Define the micro-code sequence for this operation here.
                // e.g., rom[10] = ...
            end

            7'b0111000: begin //muls reg
                // Define the micro-code sequence for this operation here.
                // e.g., rom[15] = ...
            end
        endcase
    end

    // FIX: Simplified the output logic. On every clock edge, the output instruction
    // is simply the instruction from the ROM at the address specified by ghost_pc.
    always @(posedge clk) begin
        if (rst) begin
            output_instruction <= 32'b0;
        end else begin
            output_instruction <= rom[ghost_pc];
        end
    end

endmodule
