module Count(
    input clk,
    input rst,
    // Change output from a 'reg' to a 'wire' (writing 'wire' is optional)
    output [2:0] count
);

    // Internal Registers
    reg [2:0] seven_counter;
    reg [1:0] three_counter;
    reg isDone;

    // State declaration
    parameter S_IDLE = 0, S_COUNT = 1;
    reg state;

    // This is the key change: Make the output a direct combinational
    // reflection of the internal counter. No more lag!
    assign count = seven_counter;

    // FSM Logic
    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            seven_counter <= 3'b0; // On reset, count is 0
            three_counter <= 3'b0;
            isDone <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (!isDone) begin
                        state <= S_COUNT;
                        // Pre-load the counter so its FIRST value will be 1
                        seven_counter <= 3'd1;
                    end
                end

                S_COUNT: begin
                    // The main counting logic. 'count' will update automatically.
                    if (three_counter < 3) begin
                        if (seven_counter < 7) begin
                            seven_counter <= seven_counter + 1; // Count up
                        end else begin
                            seven_counter <= 3'd1; // Roll over back to 1
                            three_counter <= three_counter + 1;
                        end
                    end else begin
                        state <= S_IDLE;
                        isDone <= 1'b1;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
