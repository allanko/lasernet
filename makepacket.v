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
    input control,  // if high, sending control packets (no data). if low, sending data packets.
    input [31:0] ISN,
    input readyin,
    input [15:0] window,
    input [31:0] seq,
    input [31:0] ack,
    input [8:0] flags,
    input [63:0] dataout, // message data from BRAM buffer
    input [31:0] SNmax,  // SN for the last packet of data - the maximum index in the data to transmit
    output [31:0] index,   // address of data to get from BRAM
    output reg [223:0] packet, // 7 octets - 4 header, 1 checksum, 2 data
    output reg readyout
    );


    wire [31:0] octet1;     // source/dest port
    wire [31:0] octet2;     // seq
    wire [31:0] octet3;     // ack
    wire [31:0] octet4;     // flags and window size
    wire [31:0] octet5;     // checksum
    wire [31:0] octet6;     // data
    wire [31:0] octet7;     // data

    // HEADER: source, destination, seq, ack, flags. four octets.

    assign octet1 = 32'd0;
    assign octet2 = seq;
    assign octet3 = ack;
    assign octet4 = {7'd0, flags, window};

    // DATA: read from memory. two octets.

    wire [31:0] index;
    assign index = seq - ISN - 32'd1; // SN = 1 / index = 0 at first entry into S_TRANSMITTING

    assign octet6 = control ? 32'd0 : dataout[63:32];
    assign octet7 = control ? 32'd0 : dataout[31:0];

    // CHECKSUM: complement of ones complement sum of every 16-bit word. 1 octet.

    wire [31:0] sum; 
    wire [15:0] checksum;
    assign sum = octet1[31:16] + octet1[15:0] + 
                 octet2[31:16] + octet2[15:0] + 
                 octet3[31:16] + octet3[15:0] + 
                 octet4[31:16] + octet4[15:0] + 
                 octet6[31:16] + octet6[15:0] + 
                 octet7[31:16] + octet7[15:0];

    assign checksum = (sum[31:16] + sum[15:0]) < sum[15:0] ?  ~(sum[31:16] + sum[15:0] + 16'd1) :
                                                              ~(sum[31:16] + sum[15:0]);

    assign octet5 = {checksum, 16'd0};


    // STATE MACHINE

    parameter WAIT = 2'd0; // idle
    parameter MAKE = 2'd1; // make and transmit packet
    reg [1:0] state;

    always @(posedge clk) begin
        case(state) 

            WAIT : begin
                readyout <= 1'b0;
                state <= !reset & readyin ? MAKE : WAIT;

            end

            MAKE : begin

                readyout <= 1'b1;
                packet <= {octet1, octet2, octet3, octet4, octet5, octet6, octet7};

                state <= WAIT;
            end

            default : state <= WAIT;

        endcase

    end

endmodule