module ucode_rom(mul_opcode, clk, rst, immediate, reg1, reg2, dest_reg, result_g, imm_g, reg1_g, reg2_g, mov_instruction, add_instruction, sub_instruction, cmp_instruction, bne_instruction
);

  input reg [6:0] mul_opcode;
  input clk;
  input rst;
  input reg [15:0] immediate, 
  input reg [3:0] reg1;
  input reg [3:0] reg2;
  input reg [3:0] dest_reg;

  output reg [31:0] result_g;
  output reg [15:0] imm_g;
  output reg [3:0] reg1_g;
  output reg [3:0] reg2_g;

  output reg [31:0] mov_instruction, add_instruction, sub_instruction, cmp_instruction, bne_instruction;

  always(@posedge clk)begin

	  case(mul_opcode)
	     7'b0010000 //mul imm
	                
	        assign imm_g = immediate;
	        assign reg1_g = reg1;
	        assign reg2_g = reg2; //sending to ghost register file
        
	        mov_instruction = {7'b0000000, 4'b0001, 4'b0000, immediate}; //these are 32 bit instructions
		add_instruction = {7'b0110001, 4'b0000, 4'b0000, 4'b0000, 13'b0000000000000};
	        sub_instruction = {7'b0010010, 4'b0001, 4'b0001, 1'b0, 16'd1};
	        cmp_instruction = {7'b0011010, 4'b1110, 4'b0001, 1'b0, 16'd0};
	        bne_instruction = {7'b1100001, 4'b0001, 5'b0000, 16'd-3}; // ??pc relative address..-3? //send these to ifetch?

	     7'b0011000 //muls imm
		which_one = 2'b01;
		//some sort of trigger to set flags?        


	     7'b0110000 //mul reg
	        which_one = 2'b10;

	     7'b0111000 //muls reg
		whiche_one = 2'b11;
		//trigger flags to be set?
  end
endmodule
