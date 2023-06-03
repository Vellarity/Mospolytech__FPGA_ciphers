`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2023 02:40:20
// Design Name: 
// Module Name: cbc_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cbc_tb(

    );
    reg clk = 0;
    integer counter;
    

    
    wire [127:0] data_in = 128'h1122334455667700ffeeddccbbaa9988;
    wire [127:0] data_out;
    wire block_done;
    reg reset_n = 1;
    reg start_trigger = 0;
    
    initial 
    begin
        start_trigger=1;
        counter=0;
        
    end
    
    always 
    begin 
        #2 clk = ~clk;
        if (clk == 1)
           counter = counter + 1;
    end
    
    gost_cbc cbc_enc(
        .data_in(data_in),
        .data_out(data_out),
        .start_trigger(start_trigger),
        .done_block(block_done),
        .reset_n(reset_n),
        .clk(clk)
    );
endmodule
