`timescale 1ns/1ns

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
        .
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

        rst = 0; 
        repeat (200) @(posedge clk)

        $finish; 
    end


    //Logic

endmodule