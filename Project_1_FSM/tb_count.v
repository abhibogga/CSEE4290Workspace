`timescale 1ns/1ns

module tb_count() begin 

    //Define inputs as reg
    reg clk; 
    reg rst; 


    //Define outputs as wire
    wire [2:0] count; 

    //Define clk

    always begin 
        clk = 0; 
        #5
        clk = 1; 
        #5
    end

    initial begin 
        $dumpvars(0, tb_count)

        #200 

        rst = 0; 
        #500

        $finish; 
    end


    //Logic

endmodule