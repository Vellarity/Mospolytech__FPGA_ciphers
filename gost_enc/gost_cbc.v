`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2023 01:14:11
// Design Name: 
// Module Name: gost_cbc
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


module gost_cbc(
    input [127:0] data_in,
    output reg [127:0] data_out,
    output reg done_block,
    input start_trigger,
    input reset_n,
    input clk
    );
    
    reg [127:0] IV = 128'h00112233445566778899aabbccddeeff;
    reg [127:0] inner_data_in;
    reg reg_start_sycles;
    
    wire [127:0] inner_cycles_in = inner_data_in;
    wire [127:0] inner_cycles_out;
    wire start_cycles = reg_start_sycles;
    wire cycles_done;
    
    localparam IDLE = 0;
    localparam ADD_IV = 2;
    localparam WAIT_ENC = 3;
    localparam WRITE_RESULTS = 4;
    
    reg [3:0] STATE = IDLE;
    
    always @(posedge clk)
    begin
        if (reset_n == 0)
        begin
            //Всё сбросить, и меня тоже сбросить с крыши
        end
        else
        begin
            case (STATE)
                IDLE:
                    begin
                        done_block <= 0;
                        if (start_trigger)
                            STATE <= ADD_IV;
                    end
                ADD_IV:
                    begin
                        inner_data_in <= IV ^ data_in;
                        reg_start_sycles <= 1;
                        STATE <= WAIT_ENC;
                    end
                WAIT_ENC:
                    begin
                        reg_start_sycles <= 0;
                        if(cycles_done)
                        begin
                            STATE <= WRITE_RESULTS;
                        end
                    end
                WRITE_RESULTS:
                    begin
                        IV <= inner_cycles_out;
                        data_out <= inner_cycles_out;
                        done_block <= 1;
                        STATE <= IDLE;
                    end
            endcase
        end
    end
    
    gost_enc enc(
        .clk(clk),
        .reset_n(reset_n),
        .start_trigger(start_cycles),
        .data_in(inner_cycles_in),
        .data_out(inner_cycles_out),
        .cycles_done(cycles_done)
    );
endmodule
