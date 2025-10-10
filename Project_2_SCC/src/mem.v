module mem(
    input clk, 
    input writeIn,
    input rst,  
    input [31:0] addressIn, 
    input [31:0] dataIn, 
    output wire [31:0] dataOut,
    output wire [31:0] addressOut,
    output writeFlag; 
); 


    //when we get a response from writeIn, we need to wire our addresses to the instruction_and_data module
    assign writeFlag = writeIn; 
    assign dataOut = dataIn; 
    assign addressOut = addressIn; 
    

endmodule