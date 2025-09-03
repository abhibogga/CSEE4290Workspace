// A counter that counts from 0-7, three times, then stops.
// This version does not use an explicit state machine.
module Count(
    input clk,
    input rst,
    output reg [2:0] count
);

    // Internal counters
    reg [2:0] seven_counter;
    reg [1:0] three_counter;

    always @(posedge clk) begin
        // On reset, initialize ALL registers to a known state.
        if (rst) begin
            seven_counter <= 3'b0;
            three_counter <= 2'b0;
        // If not in reset, proceed with the counting logic.
        end else begin
            // The counter is only active when we haven't completed three full 0-7 cycles.
            // This condition effectively stops the counter when it's done.
            if (three_counter < 3) begin
                if (seven_counter < 7) begin
                    // Increment the 0-7 counter
                    seven_counter <= seven_counter + 1;
                end else begin
                    // When 0-7 counter finishes, reset it and increment the cycle counter
                    seven_counter <= 3'b0;
                    three_counter <= three_counter + 1;
                end
            end
        end

        // The output 'count' is a registered copy of the internal 'seven_counter'.
        // It's placed here so it updates correctly on reset and during counting.
        count <= seven_counter;
    end

endmodule
