module ucode_rom(mul_opcode, clk, rst, immediate, reg1, reg2, dest_reg, result_g, imm_g, reg1_g, reg2_g, output_instruction);

  input reg [6:0] mul_opcode;
  input clk;
  input rst;
  input reg [15:0] immediate, 
  input reg [3:0] reg1;
  input reg [3:0] reg2;
  input reg [3:0] dest_reg;
  input reg [4:0] ghost_pc; //5 bits handles up to decimal 32, which I think covers the number of lines total in ucode rom


  output reg [31:0] result_g;
  output reg [15:0] imm_g;
  output reg [3:0] reg1_g;
  output reg [3:0] reg2_g;
 
  output reg [31:0] output_instruction;

  wire [31:0] mov_instruction, add_instruction, sub_instruction, cmp_instruction, bne_instruction;

  always(@posedge clk)begin

	  case(mul_opcode)
	     7'b0010000 //mul imm
	                
	        assign imm_g = immediate;
	        assign reg1_g = reg1;
	        assign reg2_g = reg2; //sending to ghost register file
        

		//if I send the information to reg file on this clock, do I need to wait before these below instructions can work? registers update on a flop....
	        mov_instruction = {7'b0000000, 4'b0001, 4'b0000, immediate}; //these are 32 bit instructions
		rom[0] <= mov_instruction;

		add_instruction = {7'b0110001, 4'b0000, 4'b0000, 4'b0000, 13'b0000000000000};
		rom[1] <= add_instruction;

	        sub_instruction = {7'b0010010, 4'b0001, 4'b0001, 1'b0, 16'd1};
		rom[2] <= sub_instruction;	

	        cmp_instruction = {7'b0011010, 4'b1110, 4'b0001, 1'b0, 16'd0};
		rom[3] <= cmp_instruction;        
	
		bne_instruction = {7'b1100001, 4'b0001, 5'b0000, 16'd-3}; // ??pc relative address..-3? //send these to ifetch?
		rom[4] <= bne_instruction


	     7'b0011000 //muls imm
		which_one = 2'b01;
		//some sort of trigger to set flags?        


	     7'b0110000 //mul reg
	        which_one = 2'b10;

	     7'b0111000 //muls reg
		whiche_one = 2'b11;
		//trigger flags to be set?
	endcase
  end


  reg [31:0] rom [0:30] //31 32-bit lines = 4 Multiply codes  + 6 insts per algo (4 algos ) + some buffer


  always(*) begin
	//logic to send instruction

	case(ghost_pc)
	   5'b0000
		output_instruction = mov_instruction;
	   5'b0001
		output_instruction = add_instruction;
	   5'b0010
		output_instruction = sub_instruction;
	   5'b0011
		output_instruction = cmp_instruction;
	   5'b0100
		output_instruction = bne_instruction;
	endcase
  end

endmodule
