`timescale 1ns/1ns
`include "doubling_down.v"

module tb_count();

    // Inputs are 'reg'
    reg clk;
    reg rst;

    // Outputs are 'wire'
    wire [2:0] count;

    // Instantiate the design under test (DUT)
    Count counter (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    // Generate a 10ns period clock (100 MHz)
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        $dumpvars(0, tb_count);
        clk = 0;
        rst = 1; // Start in reset

        // Hold reset for a few cycles
        repeat (4) @(posedge clk);
        $display("Time: %0t - De-asserting reset.", $time);
        rst = 0;

        // Let it run for a while to see the full counting sequence
        repeat(10) @(posedge clk);
        $display("Time: %0t - Asserting reset to interrupt.", $time);
        rst = 1;

        // Hold reset again
        repeat (5) @(posedge clk);
        $display("Time: %0t - De-asserting reset again.", $time);
        rst = 0;

        // Let it run for the full sequence one more time
        repeat(30) @(posedge clk);

        $display("Time: %0t - Simulation finished.", $time);
        $finish;
    end

endmodule
