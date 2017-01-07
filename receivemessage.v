`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: receivemessage.v
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

// a BRAM for building the received data

module receivemessage #(parameter LOGSIZE=32, WIDTH=64)(
	input wire clk,
	input wire reset,
	input wire write,
	input wire [LOGSIZE-1:0] readaddr,
	input wire [WIDTH-1:0] din,
	output reg [WIDTH-1:0] dout,
	);

	(* ram_style = "block" *) // does this work on the nexys or only on the labkit

	reg [WIDTH-1:0] mem[(1<<LOGSIZE) - 1:0];

	always @(posedge clk) begin
		if (we) mem[addr] <= din;
		dout <= mem[addr];

	end


endmodule