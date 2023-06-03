`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2023 15:55:07
// Design Name: 
// Module Name: main
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


module Main
(
	input  wire clockIN,
	input  wire uartRxIN,
	output wire uartTxOUT
);

defparam uart.CLOCK_FREQUENCY = 50_000_000;
defparam uart.BAUD_RATE       = 921600;

reg [7:0] txData;
reg txLoad  = 1'b0;

wire txReset = 1'b1;
wire rxReset = 1'b1;
wire [7:0] rxData;
wire txIdle;
wire txReady;
wire rxIdle;
wire rxReady;

UART uart
(
	.clockIN(clockIN),
	
	.nTxResetIN(txReset),
	.txDataIN(txData),
	.txLoadIN(txLoad),
	.txIdleOUT(txIdle),
	.txReadyOUT(txReady),
	.txOUT(uartTxOUT),
	
	.nRxResetIN(rxReset),
	.rxIN(uartRxIN), 
	.rxIdleOUT(rxIdle),
	.rxReadyOUT(rxReady),
	.rxDataOUT(rxData)
);

wire [127:0] key = 128'h_000102030405060708090a0b0c0d0e0f;

reg dataCount = 0;
wire dataCnt = 0;
reg [127:0] to_enc_storage;
reg [127:0] enc_storage;
reg isDataFull = 0;
reg readyToOutput = 0;

dataController enc_data_controller(rxData, dataCnt, to_enc_storage, isDataFull);

aesEncrypt aes_ecnrypt_128(to_enc_storage, key, enc_storage);

always@ (rxData) begin
    dataCount = dataCount + 1;
end
assign dataCnt = dataCount;

//как-то надо писать enc_storage в txData по готовности

always @(posedge rxReady or negedge txReady) begin
	if(~txReady)
		txLoad <= 1'b0;
	else if(rxReady) begin
		txLoad <= 1'b1;
		txData <= rxData;
	end
end

endmodule