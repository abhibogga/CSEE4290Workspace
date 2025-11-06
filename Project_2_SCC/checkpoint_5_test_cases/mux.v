module mux (

  input wire [31:0] filtered_instruction,
  input wire [31:0] ucode_instruction,
  input wire	    control, //from ucode control verilog block

  output reg [31:0] finalized_instruction

);

  always @(*) begin
     case(control)
	1'b0: finalized_instruction = filtered_instruction;  //0=regular 
	1'b1: finalized_instruction = ucode_instruction; //1=ucode
	default: finalized_instruction = filtered_instruction; //init
     endcase
  end

endmodule
