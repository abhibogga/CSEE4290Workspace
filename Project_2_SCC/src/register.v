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
    reg [1:0] state, stateNext;

    parameter sIdle = 0, sRegular = 1, sUcode = 2;

    integer i;
    //Logic
    always @(posedge clk) begin 
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) registerFile[i] <= 32'd0;
            for (i = 0; i< 16; i = i +1) ghost_register_file <= 32'd0;
	end else begin
	      if (ucode_flag == 0) begin
		 if (write) begin
		     registerFile[rd] <= writeData;
		 end 
	      end
	      else if (ucode_flag == 1) begin
		 if (statePrev = 1) begin
			for (integer j = 0; j < 16; j = j+1) begin
			      ghost_register_file[j] <= registerFile[j]
			      //copies regular registers to ghost in preparation 
			      //for algo insts
			end
		 end else if (statePrev = 2) begin
			ghost_register_file <= writeData;
		 end

	      end
       
	 end
    end

    if (ucode_flag == 0) begin
   	 assign out_rd = registerFile[rd]; 
   	 assign out_rs1 = registerFile[rs1];
   	 assign out_rs2 = registerFile[rs2];
   end else if (ucode_flag == 0) begin
	 assign out_rd = ghost_register_file[rd];
	 assign out_rs1 = ghost_register_file[rs1];
	 assign out_rs2 = ghost_register_file[rs2];	
   end


   always @(*) begin //FSM
	case (state)
	    sIdle: begin
		if (rst) begin
		    stateNext = sIdle;
		end else begin
		    if (ucode_flag) begin
			stateNext = sUcode;			
		    end
	 	    else begin
			stateNext = sRegular;
		    end
	    end
	    sUcode: begin
		if (rst) begin
		    stateNext = sIdle;
		end
		end else begin
		    if (ucode_flag
	
	    end

   end	



endmodule
