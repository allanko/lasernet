`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: checkpacket
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

// takes demodulated packets
// check checksum - if checksum wrong, throw the packet away. 
// if checksum correct:
// checks if SN = 1 + last SN - if so, pass data to display buffer and update received SN and ACK
// if SN != 1 + last SN sent, throw away data and update received ACK


module checkpacket(
    input clk,
    input reset,
    input readyin,
    input [31:0] ISN, 
    input [223:0] packet, // this needs to be >128 bits. adjust packet size later. maybe use a parameter.
    output reg [31:0] seq,
    output reg [31:0] ack,
    output reg [8:0] flags,
    output reg [63:0] data,    // two octets of data assumed
    output reg readyout           // goes high when new data available for display
    );

    // perform checksum: one's complement sum of every octet
    // if checksum == 0, packet is good

    wire [31:0] octet1;
    wire [31:0] octet2;
    wire [31:0] octet3;
    wire [31:0] octet4;
    wire [31:0] octet5;
    wire [31:0] octet6;
    wire [31:0] octet7;

    assign octet1 = packet[223:192];
    assign octet2 = packet[191:160];
    assign octet3 = packet[159:128];
    assign octet4 = packet[127:96];
    assign octet5 = packet[95:64];
    assign octet6 = packet[63:32];
    assign octet7 = packet[31:0];

    wire [31:0] sum; 
    wire [15:0] checksum;
    assign sum = octet1[31:16] + octet1[15:0] + 
                 octet2[31:16] + octet2[15:0] + 
                 octet3[31:16] + octet3[15:0] + 
                 octet4[31:16] + octet4[15:0] + 
                 octet5[31:16] + octet5[15:0] + 
                 octet6[31:16] + octet6[15:0] + 
                 octet7[31:16] + octet7[15:0];

    assign checksum = (sum[31:16] + sum[15:0]) < sum[15:0] ?  (sum[31:16] + sum[15:0] + 16'd1) :
                                                              (sum[31:16] + sum[15:0]);


    // states
    parameter WAIT = 3'd0;
    parameter CHECK = 3'd1;
    parameter INORDER = 3'd2;
    parameter OUTOFORDER = 3'd3;
    parameter RESET = 3'd4;

    reg [2:0] state;

    always @(posedge clk) begin

        case(state)

        WAIT : begin

            state <= (!reset & readyin) ? CHECK : 
                     !reset ? WAIT : 
                     RESET;
            readyout <= 1'b0;

        end

        CHECK : begin

            state <= !reset & (checksum != 16'd0) ? WAIT :
                     !reset & (octet2 == seq + 32'd1) ? INORDER : 
                     !reset ? OUTOFORDER : 
                     RESET;
        end

        INORDER : begin

            state <= !reset ? WAIT : RESET;

            readyout <= 1'b1;
            data <= {octet6, octet7};
            seq <= octet2;
            ack <= octet3;
            flags <= octet4[24:16];

        end

        OUTOFORDER : begin

            state <= !reset ? WAIT : RESET;

            readyout <= 1'b0;
            data <= data;
            seq <= seq;
            ack <= octet3;
            flags <= octet4[24:16];

        end

        RESET : begin
            state <= WAIT;
            readyout <= 1'b0;
            data <= 64'd0;
            seq <= ISN;
            ack <= 32'd0;
        end

        default : state <= RESET;

        endcase

    end
endmodule


