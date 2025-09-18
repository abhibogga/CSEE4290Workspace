module Count(clk, rst, count); 
    //Define inputs here
    input clk; 

    input rst; 

    //Define outputs here
    output reg [2:0] count;

    //Define Registers
    reg [2:0] seven_counter;
    reg [1:0] three_counter;

    //Define States
    parameter s_idle = 0, s_count = 1; 

    reg [1:0] state, state_next;

    reg isDone; 

    //Define Logic
    always @(posedge clk) begin
        state = state_next;
    end

    always @(posedge clk) begin
        case (state)
            s_idle: begin
                if (rst == 1) begin 
                    state_next <= s_idle; 
                end else if (rst == 0 && isDone == 0) begin
                    state_next <= s_count; 
                    seven_counter <= 0; 
                    three_counter <= 0; //Possibly look at this
            
                end else begin
                    state_next <= s_idle;
                end

            end

        s_count: begin 
            if (rst == 1) begin 
                state_next <= s_idle; 
            end else if (rst == 0) begin
                
                count = seven_counter; 

                if (three_counter < 3) begin 
                    if (seven_counter < 7) begin 
                        seven_counter <= seven_counter + 1;
                        state_next <= s_count;
                    end else begin
                        seven_counter <= 0; 
                        three_counter <= three_counter + 1;
                        state_next <= s_count;
                    end
                end else begin 
                    count <= 7; 
                    state_next <= s_idle; 
                    isDone <= 1; 
                end
            end
        end


        default begin 
            state_next <= s_idle; 
            isDone <= 0; 
        end
        endcase 

    end 

    

endmodule