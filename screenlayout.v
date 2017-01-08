`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: screenlayout
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

// lay out all the text on the screen


module screenlayout(
    input clock_65mhz,	             // 65MHz clock
    input [10:0] hcount,             // horizontal index of current pixel (0..1023)
    input [9:0]  vcount,             // vertical index of current pixel (0..767)
    input display,
    input [16*8*5 - 1:0] messageout,  // outgoing message to display
    input [16*8*5 - 1:0] messagein,   // incoming message to display
    input [16*8 - 1:0] keyboard,      // last 16 characters entered on keyboard
    output [2:0] pixels	              // char display's pixel
    );

    // user 1 text start at ~107 (x-coord) ???????
    // user 2 text start at ~298 (x-coord) ????????


    // convert incoming message wires to arrays

    wire [16*8 - 1:0] messageoutarray[4:0];
    assign messageoutarray[0] = messageout[16*8*1 - 1 : 16*8*0];
    assign messageoutarray[1] = messageout[16*8*2 - 1 : 16*8*1];
    assign messageoutarray[2] = messageout[16*8*3 - 1 : 16*8*2];
    assign messageoutarray[3] = messageout[16*8*4 - 1 : 16*8*3];
    assign messageoutarray[4] = messageout[16*8*5 - 1 : 16*8*4];

    wire [16*8 - 1:0] messageinarray[4:0];
    assign messageinarray[0] = messagein[16*8*1 - 1 : 16*8*0];
    assign messageinarray[1] = messagein[16*8*2 - 1 : 16*8*1];
    assign messageinarray[2] = messagein[16*8*3 - 1 : 16*8*2];
    assign messageinarray[3] = messagein[16*8*4 - 1 : 16*8*3];
    assign messageinarray[4] = messagein[16*8*5 - 1 : 16*8*4];
    
    //////////  lay out all the text on the screen

    // headers: outgoing message on left side, incoming message on right side, user input at bottom


        wire [8*8-1:0] cstring_outgoing = "OUTGOING";
        wire [2:0]  cdpixel_outgoing;
        char_string_display cd_outgoing(clock_65mhz,hcount,vcount,
                                        cdpixel_outgoing, cstring_outgoing,
                                        11'd150, 10'd25);             // coordinates of string
        defparam cd_outgoing.NCHAR = 8;                               // number of characters in cstring
        defparam cd_outgoing.NCHAR_BITS = 4;                          // number of bits in NCHAR
    

        wire [8*8-1:0] cstring_incoming = "INCOMING";
        wire [2:0]  cdpixel_incoming;
        char_string_display cd_incoming(clock_65mhz,hcount,vcount,
                                        cdpixel_incoming, cstring_incoming,
                                        11'd550, 10'd25);
        defparam cd_incoming.NCHAR = 8;
        defparam cd_incoming.NCHAR_BITS = 4; 


        wire [11*8-1:0] cstring_input = "USER INPUT:";
        wire [2:0]  cdpixel_input;
        char_string_display cd_input(clock_65mhz,hcount,vcount,
                                     cdpixel_input, cstring_input,
                                     11'd200, 10'd650);
        defparam cd_input.NCHAR = 11;
        defparam cd_input.NCHAR_BITS = 4; 
    
    ////////////////////////////// outgoing message

        wire [16*8-1:0] cstring_out1 = messageoutarray[0];
        wire [2:0]  cdpixel_out1;
        char_string_display cd_out1(clock_65mhz,hcount,vcount,
                                    cdpixel_out1, cstring_out1,
                                    11'd150, 10'd25+1*50);
        defparam cd_out1.NCHAR = 16;
        defparam cd_out1.NCHAR_BITS = 5; 


        wire [16*8-1:0] cstring_out2 = messageoutarray[1];
        wire [2:0]  cdpixel_out2;
        char_string_display cd_out2(clock_65mhz,hcount,vcount,
                                    cdpixel_out2, cstring_out2,
                                    11'd150, 10'd25+2*50);
        defparam cd_out2.NCHAR = 16;
        defparam cd_out2.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_out3 = messageoutarray[2];
        wire [2:0]  cdpixel_out3;
        char_string_display cd_out3(clock_65mhz,hcount,vcount,
                                    cdpixel_out3, cstring_out3,
                                    11'd150, 10'd25+3*50);
        defparam cd_out3.NCHAR = 16;
        defparam cd_out3.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_out4 = messageoutarray[3];
        wire [2:0]  cdpixel_out4;
        char_string_display cd_out4(clock_65mhz,hcount,vcount,
                                   cdpixel_out4, cstring_out4,
                                   11'd150, 10'd25+4*50);
        defparam cd_out4.NCHAR = 16;
        defparam cd_out4.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_out5 = messageoutarray[4];
        wire [2:0]  cdpixel_out5;
        char_string_display cd_out5(clock_65mhz,hcount,vcount,
                                   cdpixel_out5, cstring_out5,
                                   11'd150, 10'd25+5*50);
        defparam cd_out5.NCHAR = 16;
        defparam cd_out5.NCHAR_BITS = 5;
    
    ///////////////////////////// incoming message

        wire [16*8-1:0] cstring_in1 = messageinarray[0];
        wire [2:0]  cdpixel_in1;
        char_string_display cd_in1(clock_65mhz,hcount,vcount,
                                   cdpixel_in1, cstring_in1,
                                   11'd550, 10'd25+1*50);
        defparam cd_in1.NCHAR = 16;
        defparam cd_in1.NCHAR_BITS = 5; 


        wire [16*8-1:0] cstring_in2 = messageinarray[1];
        wire [2:0]  cdpixel_in2;
        char_string_display cd_in2(clock_65mhz,hcount,vcount,
                                   cdpixel_in2, cstring_in2,
                                   11'd550, 10'd25+2*50);
        defparam cd_in2.NCHAR = 16;
        defparam cd_in2.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_in3 = messageinarray[2];
        wire [2:0]  cdpixel_in3;
        char_string_display cd_in3(clock_65mhz,hcount,vcount,
                                   cdpixel_in3, cstring_in3,
                                   11'd550, 10'd25+3*50);
        defparam cd_in3.NCHAR = 16;
        defparam cd_in3.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_in4 = messageinarray[3];
        wire [2:0]  cdpixel_in4;
        char_string_display cd_in4(clock_65mhz,hcount,vcount,
                                   cdpixel_in4, cstring_in4,
                                   11'd550, 10'd25+4*50);
        defparam cd_in4.NCHAR = 16;
        defparam cd_in4.NCHAR_BITS = 5;


        wire [16*8-1:0] cstring_in5 = messageinarray[4];
        wire [2:0]  cdpixel_in5;
        char_string_display cd_in5(clock_65mhz,hcount,vcount,
                                   cdpixel_in5, cstring_in5,
                                   11'd550, 10'd25+5*50);
        defparam cd_in5.NCHAR = 16;
        defparam cd_in5.NCHAR_BITS = 5;

    //////////// current keyboard input

        // display current user input in the red box
        wire [16*8-1:0] cstring = keyboard;
        wire [2:0]  cdpixel;
        char_string_display cd(clock_65mhz,hcount,vcount,
                               cdpixel,cstring,
                               11'd383,10'd650);
        defparam    cd.NCHAR = 16;
        defparam    cd.NCHAR_BITS = 4; 

    // display
    
    assign pixels = cdpixel_outgoing | cdpixel_incoming | cdpixel_input |
                    cdpixel_out1 | cdpixel_out2 | cdpixel_out3 | cdpixel_out4 | cdpixel_out5 |
                    cdpixel_in1 | cdpixel_in2 | cdpixel_in3 | cdpixel_in4 | cdpixel_in5 |
                    cdpixel
                    ;
endmodule
