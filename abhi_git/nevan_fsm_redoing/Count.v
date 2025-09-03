module Count(clk,rst,count);

	input clk;
	input rst;
	output reg [2:0] count;

	reg[2:0] seven;
	reg[1:0] three;

	parameter idle = 0, counting = 1;

	reg state;

	always(@posedge clk) begin
		case(state)
			idle:
			begin
				if (rst == 1)
				begin
					state = idle;
					count = 0;
				end					
				else
				begin
					state = counting;
					count = 1'b1; //?set 1 as the initial for no
						//delay?
				end

			end

			counting:
			begin
				if (rst == 1)
				begin
					state = idle;
					
				end				
				else
				begin
					state = counting;
					if (three <3)
					begin
						if (seven < 7)
							seven = seven + 1;
						else
						begin
							seven = 0;
							three = three +1;
						end
						
					end
					else
						state = idle;
				end
			end
			
		endcase
	end
endmodule
