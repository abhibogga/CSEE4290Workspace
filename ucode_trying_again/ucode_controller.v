//this module loads the machine code for the two instructions that will be sent through
//the stages and send those instructions to the mux as well as a control signal


//this module also has the FSM to determine when to supply the MOV instruction, the ADD instruction, and when to unfreeze PC
//and hand over control to the regular main memory instructions


//example:

//MOV R0, #2
//MUL R1, R0, #3


//FSM psuedocode:


module ucode_controller (

  input reg [15:0] immediate,
  input wire rst,
  

  output reg mux_ctrl

)

  //define states
  reg state, state_next
  parameter sMove = 2'b00, sKeep_adding = 2'b01, sHalt = 2'b10;

  //flop the states on each clock

  always @(posedge clk) begin 
     
     state <= state_next //load the assigned next state to the new current state

  end

  reg [31:0] scratch [0:3] //making 4 local scratchpad registers




  case (state)

	2'b00: //mov
	   output_instruction = {mov_opcode, dest_reg, source_reg};
	   //once this inst is done, the next clock will have the write reg to the correct value
	   state_next = sKeep_adding;
	   mux_ctrl = 1; //tell mux to take instructions from here NOT IF

	2'b01: //add (king inst)
	   output_instruction = {add_opcode, dest_reg, dest_reg, dest_reg};

	   mux_ctrl = 1; //tell mux to take instructions from here NOT IF

	   

	   if 

	2'b10: //halt
	   mux_ctrl = 0; //go back to regular IF







endmodule
