// A counter that counts from 0-7, three times, then stops.
module Count(
    input clk,
    input rst,
    output reg [2:0] count
);

    // Internal counters
    reg [2:0] seven_counter;
    reg [1:0] three_counter;

    // FSM state declaration
    parameter IDLE = 1'b0;
    parameter COUNTING = 1'b1;
    reg state;

    always @(posedge clk) begin
        // On reset, initialize ALL registers to a known state.
        if (rst) begin
            state <= IDLE;
            count <= 3'b0;
            seven_counter <= 3'b0;
            three_counter <= 2'b0;
        end else begin
            case (state)
                IDLE: begin
                    // When not in reset, transition to the COUNTING state.
                    // The counters will start on the *next* clock cycle.
                    state <= COUNTING;
                end

                COUNTING: begin
                    if (three_counter < 3) begin
                        if (seven_counter < 7) begin
                            // Increment the 0-7 counter
                            seven_counter <= seven_counter + 1;
                        end else begin
                            // When 0-7 counter finishes, reset it and increment the 0-3 counter
                            seven_counter <= 3'b0;
                            three_counter <= three_counter + 1;
                        end
                    end else begin
                        // If we've counted to 7 three times, go back to idle and wait for a reset.
                        state <= IDLE;
                    end
                end

                // A default case is good practice to handle any unknown states.
                default: begin
                    state <= IDLE;
                end
            endcase

            // --- Concurrent Logic ---
            // Always assign the output based on the current counter value.
            // This is outside the 'case' so it happens in every state.
            count <= seven_counter;
        end
    end

endmodule
