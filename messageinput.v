`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: messageinput.v
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

// a modified BRAM for entering data 

// i can't really finish this until i know how text input works...

module messageinput #(parameter LOGSIZE=32, WIDTH=64)( // width = 64 - two octets per packet
	input wire clk,
	input wire reset,
	input wire write,
	input wire [LOGSIZE-1:0] readaddr,
	input wire [WIDTH-1:0] din,
	output reg [WIDTH-1:0] dout,
	output reg [LOGSIZE-1:0] maxaddr // highest address written
	);

	(* ram_style = "block" *) // does this work on the nexys or only on the labkit

	reg [WIDTH-1:0] mem[(1<<LOGSIZE) - 1:0];

	reg [LOGSIZE-1:0] index = d1; // initialize index at index = 1

	always @(posedge clk) begin
		dout <= mem[addr];

	end


endmodule