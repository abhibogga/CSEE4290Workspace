module execute(dataRegisterImm, dest_reg, imm, dest_reg_value);




	input reg dataRegisterImm;
	input reg [15:0] imm;
	output reg [3:0] dest_reg;
	output reg [15:0] dest_reg_value;
	

	always @(*) begin
		case (dataRegisterImm)
			1'b0: begin
			
			end	//NO OP
			1'b1: begin
				dest_reg = output_destRegister; //pass this register 
								//to register file
				dest_reg_value = imm; //also pass this to register file
			end
			default: begin
				//NO OP
			end
		endcase
	end
