`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2023 17:23:34
// Design Name: 
// Module Name: AES
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

module AES(clk, plain_text128, e128, d128);
    input  clk;
    input  wire[127:0] plain_text128;
    output reg[127:0] e128;
    output reg[127:0] d128;

    // The plain text used as input
    //wire[127:0] in = 128'h_00112233445566778899aabbccddeeff;

    // The different keys used for testing (one of each type)
    wire[127:0] key128 = 128'h_000102030405060708090a0b0c0d0e0f;

    // The result of the encryption module for every type
    wire[127:0] encrypted128;

    // The result of the decryption module for every type
    wire[127:0] decrypted128;
    
    aesEncrypt a(plain_text128,key128,encrypted128);
    aesDecrypt a2(encrypted128,key128,decrypted128);
    
    always @(plain_text128) begin 
         e128 = encrypted128;
         d128 = decrypted128;
    end

endmodule