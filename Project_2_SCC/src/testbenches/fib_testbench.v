`timescale 1ps/1ps
`include "scc_f25_top.v"

module fib_tb();

// Inputs
reg clk;
reg rst; 
reg clk_en; 
reg seen_halt;

// Outputs
wire halt_f; 
wire [1:0] err_bits; 
wire [31:0] instruction_memory_v; 
wire [31:0] data_memory_in_v; 

// DUT
scc_f25_top topMod (
    .clk(clk),
    .clk_en(clk_en), 
    .rst(rst), 
    .halt_f(halt_f), 
    .err_bits(err_bits), 
    .instruction_memory_v(instruction_memory_v), 
    .data_memory_in_v(data_memory_in_v)
); 

// Clock
always begin 
    clk = 1; #5;
    clk = 0; #5;
end

// Capture halt_f (if it pulses)
always @(posedge clk or posedge rst) begin
  if (rst) seen_halt <= 1'b0;
  else if (halt_f) seen_halt <= 1'b1;
end

// --- Self-checking for Fibonacci sequence in memory ---
// Expected outputs: F[0..9] = 0,1,1,2,3,5,8,13,21,34 at 0x400,0x404,...,0x424

// File parsing (same style as before)
integer fd, mem;
reg [31:0] addr, value;
reg [255:0] line;

// Storage for observed + expected values
reg [31:0] expected [0:9];
reg [31:0] observed [0:9];
integer     seen_mask;   // bit i set when we saw address for index i
integer i;
integer pass;

// Test process
initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0, fib_tb);

    // Init
    rst     = 1; 
    clk_en  = 1; 
    seen_halt = 0;

    // Initialize expected sequence
    expected[0] = 32'd0;
    expected[1] = 32'd1;
    expected[2] = 32'd1;
    expected[3] = 32'd2;
    expected[4] = 32'd3;
    expected[5] = 32'd5;
    expected[6] = 32'd8;
    expected[7] = 32'd13;
    expected[8] = 32'd21;
    expected[9] = 32'd34;

    // Clear observed and mask
    for (i = 0; i < 10; i = i + 1) begin
        observed[i] = 32'hXXXXXXXX;
    end
    seen_mask = 0;

    // Release reset after 3 clocks
    repeat (3) @(posedge clk);
    rst = 0;

    // Let it run a bit
    repeat (60) @(posedge clk);

    // Wait for HALT (latched)
    wait (seen_halt == 1);
    @(posedge clk);

    $display("\nCPU halted. Checking Fibonacci outputs...\n");

    // Parse scc_out.txt
    fd = $fopen("scc_out.txt", "r");
    if (fd == 0) begin
        $display("TEST FAILED: Could not find scc_out.txt.");
        $finish;
    end

    // Skip first line
    line = ($fgets(line, fd));

    // Read lines: each like "0x%h,0x%h"
    while ($fgets(line, fd)) begin
        mem = $sscanf(line, "0x%h,0x%h", addr, value);
        if (mem == 2) begin
            // Only care about 0x400..0x424, word aligned
            if ((addr >= 32'h00000400) && (addr <= 32'h00000424) && ((addr & 32'h3) == 0)) begin
                i = (addr - 32'h00000400) >> 2; // index 0..9
                if (i >= 0 && i < 10) begin
                    observed[i] = value;
                    seen_mask = seen_mask | (1 << i);
                end
            end
        end
    end
    $fclose(fd);

    // Self-check each entry
    pass = 1;
    for (i = 0; i < 10; i = i + 1) begin
        if ((seen_mask & (1 << i)) == 0) begin
            $display("MISSING: addr 0x%08h (index %0d) not found in scc_out.txt", 32'h00000400 + (i<<2), i);
            pass = 0;
        end else if (observed[i] !== expected[i]) begin
            $display("MISMATCH @ addr 0x%08h (index %0d): expected 0x%08h, got 0x%08h",
                     32'h00000400 + (i<<2), i, expected[i], observed[i]);
            pass = 0;
        end else begin
            $display("OK @ addr 0x%08h (index %0d): 0x%08h",
                     32'h00000400 + (i<<2), i, observed[i]);
        end
    end

    $display("");
    if (pass) begin
        $display("TEST PASSED: Fibonacci outputs match expected sequence.");
    end else begin
        $display("TEST FAILED: One or more outputs mismatched / missing.");
    end
    $finish; 
end

endmodule
