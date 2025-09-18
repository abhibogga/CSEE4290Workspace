`timescale 1ns/1ns
`include "Count.v"
module tb_count();  

    //Define inputs as reg
    reg clk; 
    reg rst; 


    //Define outputs as wire
    wire [2:0] count; 

    //Define moudle
    Count counter(
        .clk(clk), 
        .rst(rst), 
        .count(count)
    );

    //Define clk

    always begin 
        clk = 0; 
        #5;
        clk = 1; 
        #5;
    end



    initial begin 
        $dumpvars(0, tb_count);

        rst = 1; 
        repeat (4) @(posedge clk); //start at not counting
				   //see if it waits the right amount of time

	rst = 0;
	repeat (10) @(posedge clk); //see if it counts to 7 then 3

	rst = 1;
	repeat (2) @(posedge clk); //interrupt counting with 
				   //another reset. See if it works

	rst = 0;
	repeat(30) @(posedge clk); //let it run

        $finish; 
    end


    //Logic

endmodule