`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: receivepacket.v
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

// checksumming received data and passing it to state machine / screen display as necessary
// block of memory containing received message lives here

module receivepacket(
	input clk,
	input reset,
	input ready,
	input ISN,
	input [32*9 - 1 : 0] packet,

	output reg [31:0] seq,
	output reg [31:0] ack,
	output reg [8:0] flags,
	output [16*8*5 - 1 : 0] message
	);

	wire [31:0] octet1;                                 // source/dest port
    wire [31:0] octet2;                                 // seq
    wire [31:0] octet3;                                 // ack
    wire [31:0] octet4;                                 // flags and window size
    wire [31:0] octet5;                                 // checksum
    wire [31:0] octet6, octet7, octet8, octet9;         // data

    // break down the packet

    assign octet1 = packet[32*9 - 1 : 32*8];
    assign octet2 = packet[32*8 - 1 : 32*7];
    assign octet3 = packet[32*7 - 1 : 32*6];
    assign octet4 = packet[32*6 - 1 : 32*5];
    assign octet5 = packet[32*5 - 1 : 32*4];
    assign octet6 = packet[32*4 - 1 : 32*3];
    assign octet7 = packet[32*3 - 1 : 32*2];
    assign octet8 = packet[32*2 - 1 : 32*1];
    assign octet9 = packet[32*1 - 1 : 32*0];

    // CHECKSUM: complement of ones complement sum of every 16-bit word.
    // if checksum = 0, packet is intact

    wire [31:0] sum; 
    wire [15:0] checksum;
    wire goodpacket;
    assign sum = octet1[31:16] + octet1[15:0] + 
                 octet2[31:16] + octet2[15:0] + 
                 octet3[31:16] + octet3[15:0] + 
                 octet4[31:16] + octet4[15:0] + 
                 octet5[31:16] + octet5[15:0] + // notice - including the checksum octet here!
                 octet6[31:16] + octet6[15:0] + 
                 octet7[31:16] + octet7[15:0] +
                 octet8[31:16] + octet8[15:0] + 
                 octet9[31:16] + octet9[15:0];

    assign checksum = (sum[31:16] + sum[15:0]) < sum[15:0] ?  ~(sum[31:16] + sum[15:0] + 16'b1) :
                                                              ~(sum[31:16] + sum[15:0]);

    assign goodpacket = ~|checksum; // goodpacket = 1 only if checksum = 0

    // REGISTERS FOR INCOMING MESSAGE

    reg [16*8 - 1 : 0] messagepart1 = "[     blank    ]"; 
    reg [16*8 - 1 : 0] messagepart2 = "[     blank    ]"; 
    reg [16*8 - 1 : 0] messagepart3 = "[     blank    ]"; 
    reg [16*8 - 1 : 0] messagepart4 = "[     blank    ]"; 
    reg [16*8 - 1 : 0] messagepart5 = "[     blank    ]"; 


    assign message = {messagepart1, messagepart2, messagepart3, messagepart4, messagepart5};

    // STATE MACHINE FOR TRACKING PACKETS AND UPDATING OUTPUTS

    parameter HOLD 		 = 2'b00; // hold current values
    parameter UPDATE_OOO = 2'b01; // received packet out of order OR receiving control packets, update flags, ACK, and SEQ only
    parameter UPDATE_ALL = 2'b10; // received packet in order, update flags, ACK, SEQ, and message
    parameter RESET 	 = 2'b11; // reset state

    reg [1:0] state, laststate;
    reg [31:0] highestSNreceived;

    wire [31:0] SNreceived;
    assign SNreceived = octet2 - ISN;

    wire [16*8 - 1 : 0] messagereceived;
    assign messagereceived = {octet6, octet7, octet8, octet9};

    always @(posedge clk) begin

    	laststate <= state;

    	case(state)
    		HOLD : begin

    			highestSNreceived <= (!reset & ready & goodpacket & (SNreceived == highestSNreceived + 32'd1)) ? octet2 : highestSNreceived;

    			state <= (!reset & ready & goodpacket & (SNreceived == highestSNreceived + 32'd1)) ? UPDATE_ALL : 
    					 (!reset & ready & goodpacket) ? UPDATE_OOO : 
    					 reset ? RESET : 
    					 HOLD;
    		end

    		UPDATE_OOO : begin

    			seq <= octet2;
    			ack <= octet3;
    			flags <= octet4[24:16];

    			state <= HOLD;
    		end

    		UPDATE_ALL : begin

    			seq <= octet2;
    			ack <= octet3;
    			flags <= octet4[24:16];

    			messagepart1 <= (SNreceived == 32'd1) ? messagereceived : messagepart1;
    			messagepart2 <= (SNreceived == 32'd2) ? messagereceived : messagepart2;
    			messagepart3 <= (SNreceived == 32'd3) ? messagereceived : messagepart3;
    			messagepart4 <= (SNreceived == 32'd4) ? messagereceived : messagepart4;
    			messagepart5 <= (SNreceived == 32'd5) ? messagereceived : messagepart5;

    			state <= HOLD;
    		end

    		RESET : begin

				messagepart1 <= "[     blank    ]";
				messagepart2 <= "[     blank    ]";
				messagepart3 <= "[     blank    ]";
				messagepart4 <= "[     blank    ]";
				messagepart5 <= "[     blank    ]";

				seq <= 32'd0;
				ack <= 32'd0;
				flags <= 9'd0;

				highestSNreceived <= 32'd0;

				state <= HOLD;
    		end

    		default : state <= RESET;

    	endcase
    end

endmodule