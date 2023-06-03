`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2023 17:23:34
// Design Name: 
// Module Name: AES_tb
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


module AES_tb();
    reg clk = 0;
    reg [127:0] plain_text [0:63];
    wire [127:0] enc_text [0:63];

    reg [127:0]key = 128'h_000102030405060708090a0b0c0d0e0f;

    //128'h_00112233445566778899aabbccddeeff - чистый текст; 
    //128'h_69c4e0d86a7b0430d8cdb78070b4c55a - шифр

    integer i;
    initial begin
        for(i=0; i<64;i=i+1)
            plain_text[i] = 128'h_00112233445566778899aabbccddeeff;
    end

    ECB ecb_encrypt(clk, plain_text, key, enc_text);
    //    CTR ctr_encrypt(clk, plain_text, key, enc_text);

    integer act = 0;
/*      
    always @(clk) begin
        if (enc_text[0] == 128'h_69c4e0d86a7b0430d8cdb78070b4c55a) begin
            for(i=0; i<64;i=i+1)
                plain_text[i] = 128'h_69c4e0d86a7b0430d8cdb78070b4c55a; 
        end
        else begin
            for(i=0; i<64;i=i+1)
                plain_text[i] = 128'h_00112233445566778899aabbccddeeff;
        end
    end   
*/

    always @(clk) begin
        act = !act;
        if (act) begin
            for(i=0; i<64;i=i+1)
                plain_text[i] = 128'h_69c4e0d86a7b0430d8cdb78070b4c55a;
        end
        else begin
            for(i=0; i<64;i=i+1)
                plain_text[i] = 128'h_00112233445566778899aabbccddeeff;
        end
    end

    always
    #5 clk = !clk;

endmodule
