`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date:
 // Design Name: 
// Module Name: makeheader
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

// makes packets
// accepts user input of message into memory
// makes header, grabs corresponding block of input data, constructs a packet
// and calculates a checksum

// SNmax bookkept by messageinput module
// 

module makepacket(
    input clk,
    input reset,
    input [31:0] ISN,
    input readyin,                  // goes high to trigger generation of a new packet
    input [15:0] window,
    input [31:0] seq,
    input [31:0] ack,
    input [8:0] flags,
    input [16*8*5 - 1 : 0] message, // outgoing message data 
    output reg [32*9 - 1:0] packet, // 9 octets - 4 header, 1 checksum, 4 data
    output reg readyout             // goes high when new packet is ready
    );


    wire [31:0] octet1;                                 // source/dest port
    wire [31:0] octet2;                                 // seq
    wire [31:0] octet3;                                 // ack
    wire [31:0] octet4;                                 // flags and window size
    wire [31:0] octet5;                                 // checksum
    wire [31:0] octet6, octet7, octet8, octet9;         // data

    // HEADER: source, destination, seq, ack, flags. four octets.

    assign octet1 = 32'd0;
    assign octet2 = seq;
    assign octet3 = ack;
    assign octet4 = {7'd0, flags, window};

    // DATA: pick which packet to send based on current SN. four octets.

    wire [31:0] index;
    assign index = seq - ISN - 32'd1; // SN = 1 / index = 0 at first entry into S_TRANSMITTING 

    wire [16*8 - 1 : 0] messagepart0, messagepart1, messagepart2, messagepart3, messagepart4; // breaking up the message into packets
    wire [16*8 - 1 : 0] messagetosend;                                                        // message to send 

    assign messagepart0 = message[16*8*1 - 1 : 0];
    assign messagepart1 = message[16*8*2 - 1 : 16*8*1];
    assign messagepart2 = message[16*8*3 - 1 : 16*8*2];
    assign messagepart3 = message[16*8*4 - 1 : 16*8*3];
    assign messagepart4 = message[16*8*5 - 1 : 16*8*4];

    assign messagetosend =  (index == 32'd0) ? messagepart0 : 
                            (index == 32'd1) ? messagepart1 : 
                            (index == 32'd2) ? messagepart2 : 
                            (index == 32'd3) ? messagepart3 :
                            (index == 32'd4) ? messagepart4 :
                                               128'd0;


    assign octet6 = messagetosend[32*4 - 1 : 32*3];
    assign octet7 = messagetosend[32*3 - 1 : 32*2];
    assign octet8 = messagetosend[32*2 - 1 : 32*1];
    assign octet9 = messagetosend[32*1 - 1 : 32*0];

    // CHECKSUM: complement of ones complement sum of every 16-bit word. 1 octet. 

    wire [31:0] sum; 
    wire [15:0] checksum;
    assign sum = octet1[31:16] + octet1[15:0] + 
                 octet2[31:16] + octet2[15:0] + 
                 octet3[31:16] + octet3[15:0] + 
                 octet4[31:16] + octet4[15:0] + 
                 octet6[31:16] + octet6[15:0] +  // skip octet 5 because that's where the checksum goes
                 octet7[31:16] + octet7[15:0] +
                 octet8[31:16] + octet8[15:0] + 
                 octet9[31:16] + octet9[15:0];

    assign checksum = (sum[31:16] + sum[15:0]) < sum[15:0] ?  ~(sum[31:16] + sum[15:0] + 16'b1) :
                                                              ~(sum[31:16] + sum[15:0]);

    assign octet5 = {checksum, 16'd0};


    // STATE MACHINE

    parameter WAIT = 2'b0; // idle
    parameter MAKE = 2'b1; // make and transmit packet
    reg [1:0] state;

    always @(posedge clk) begin
        case(state) 

            WAIT : begin
                readyout <= 1'b0;
                state <= !reset & readyin ? MAKE : WAIT;

            end

            MAKE : begin

                readyout <= 1'b1;
                packet <= {octet1, octet2, octet3, octet4, octet5, octet6, octet7, octet8, octet9};

                state <= WAIT;
            end

            default : state <= WAIT;

        endcase

    end

endmodule