module ucode_mux(r_reg_1, r_reg_2, r_reg_d, g_reg_1, g_reg_2, g_reg_d, out_reg_1, out_reg_2, out_reg_d, ghost_flag_bit)

  input [3:0] r_reg_1, r_reg_2, r_reg_d, g_reg_1, g_reg_2, g_reg_d;
  input ghost_flag_bit;
  output [3:0] out_reg_1, out_reg_2, out_reg_d;

  always(*) begin
	case (ghost_flag_bit)
	   1b'0: //regular mode
		begin
		     out_reg_1 = r_reg_1;
		     out_reg_2 = r_reg_2;
		     out_reg_d = r_reg_d;
		end
	    1b'1: //ucode mode
		begin
		     out_reg_1 = g_reg_1;
		     out_reg_2 = g_reg_2;
		     out_reg_d = g_reg_d;
		end

	endcase
  end
