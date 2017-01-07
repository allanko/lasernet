`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2016 09:59:05 AM
// Design Name: 
// Module Name: interface
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


module interface(
    input clock_65mhz,	 // 65MHz clock
    input [10:0] hcount, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount, // vertical index of current pixel (0..767)
    input display,
    output [2:0] pixels	 // char display's pixel
        );
    // user 1 text srtart at ~107 (x-coord)
    // user 2 text start at ~298 (x-coord)
    
    //  get ready for a bunch of sample texts
        wire [6*8-1:0] cstring_a1 = "User1:";
        wire [2:0]  cdpixel_a1;
        char_string_display cd_a1(clock_65mhz,hcount,vcount,
                 cdpixel_a1,cstring_a1,11'd150,10'd25);
        defparam cd_a1.NCHAR = 6;
        defparam cd_a1.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [6*8-1:0] cstring_a2 = "User2:";
        wire [2:0]  cdpixel_a2;
        char_string_display cd_a2(clock_65mhz,hcount,vcount,
                 cdpixel_a2,cstring_a2,11'd550,10'd25+50);
        defparam cd_a2.NCHAR = 6;
        defparam cd_a2.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a3 = "User1: 3AAA5678";
        wire [2:0]  cdpixel_a3;
        char_string_display cd_a3(clock_65mhz,hcount,vcount,
                 cdpixel_a3,cstring_a3,11'd150,10'd25+2*50);
        defparam cd_a3.NCHAR = 15;
        defparam cd_a3.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a4 = "User2: 4AAA5678";
        wire [2:0]  cdpixel_a4;
        char_string_display cd_a4(clock_65mhz,hcount,vcount,
                 cdpixel_a4,cstring_a4,11'd550,10'd25+50*3);
        defparam cd_a4.NCHAR = 15;
        defparam cd_a4.NCHAR_BITS = 4; // number of bits in NCHAR
        
        wire [15*8-1:0] cstring_a5 = "User1: 5AAA5678";
        wire [2:0]  cdpixel_a5;
        char_string_display cd_a5(clock_65mhz,hcount,vcount,
                 cdpixel_a5,cstring_a5,11'd150,10'd25+50*4);
        defparam cd_a5.NCHAR = 15;
        defparam cd_a5.NCHAR_BITS = 4; // number of bits in NCHAR
        
        wire [15*8-1:0] cstring_a6 = "User2: 6AAA5678";
        wire [2:0]  cdpixel_a6;
        char_string_display cd_a6(clock_65mhz,hcount,vcount,
                 cdpixel_a6,cstring_a6,11'd550,10'd25+50*5);
        defparam cd_a6.NCHAR = 15;
        defparam cd_a6.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a7 = "User1: 7AAA5678";
        wire [2:0]  cdpixel_a7;
        char_string_display cd_a7(clock_65mhz,hcount,vcount,
                 cdpixel_a7,cstring_a7,11'd150,10'd25+50*6);
        defparam cd_a7.NCHAR = 15;
        defparam cd_a7.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a8 = "User2: 8AAA5678";
        wire [2:0]  cdpixel_a8;
        char_string_display cd_a8(clock_65mhz,hcount,vcount,
                 cdpixel_a8,cstring_a8,11'd550,10'd25+50*7);
        defparam cd_a8.NCHAR = 15;
        defparam cd_a8.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a9 = "User1: 9AAA5678";
        wire [2:0]  cdpixel_a9;
        char_string_display cd_a9(clock_65mhz,hcount,vcount,
                 cdpixel_a9,cstring_a9,11'd150,10'd25+50*8);
        defparam cd_a9.NCHAR = 15;
        defparam cd_a9.NCHAR_BITS = 4; // number of bits in NCHAR
        
        wire [15*8-1:0] cstring_a10 = "User2: 10AA5678";
        wire [2:0]  cdpixel_a10;
        char_string_display cd_a10(clock_65mhz,hcount,vcount,
                 cdpixel_a10,cstring_a10,11'd550,10'd25+50*9);
        defparam cd_a10.NCHAR = 15;
        defparam cd_a10.NCHAR_BITS = 4; // number of bits in NCHAR
    
        wire [15*8-1:0] cstring_a11 = "User1: 11AA5678";
        wire [2:0]  cdpixel_a11;
        char_string_display cd_a11(clock_65mhz,hcount,vcount,
                 cdpixel_a11,cstring_a11,11'd150,10'd25+50*10);
        defparam cd_a11.NCHAR = 15;
        defparam cd_a11.NCHAR_BITS = 4; // number of bits in NCHAR
     
        wire [15*8-1:0] cstring_a12 = "User2: 12AA5678";
        wire [2:0]  cdpixel_a12;
        char_string_display cd_a12(clock_65mhz,hcount,vcount,
                     cdpixel_a12,cstring_a12,11'd550,10'd25+50*11);
        defparam cd_a12.NCHAR = 15;
        defparam cd_a12.NCHAR_BITS = 4; // number of bits in NCHAR
        
        wire [11*8-1:0] cstring_b1 = "User Input:";
        wire [2:0]  cdpixel_b1;
        char_string_display cd_b1(clock_65mhz,hcount,vcount,
                                cdpixel_b1,cstring_b1,11'd200,10'd650);
        defparam cd_b1.NCHAR = 11;
        defparam cd_b1.NCHAR_BITS = 4; // number of bits in 
    
    
    reg [3:0] count;
    always @(posedge clock_65mhz) begin
        if (count!=12) begin
            if (display) count <= count+1;
        end
//        case (count)
//            4'd1: begin
//                pixels <= cdpixel_a1 
//                              | cdpixel_b1;
//            end
//            4'd2: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 
//                              | cdpixel_b1;
//            end
//            4'd3: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 
//                              | cdpixel_b1;
//            end
//            4'd4: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 
//                              | cdpixel_b1;
//            end
//            4'd5: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
                             
//                              | cdpixel_b1;
                
//            end
//            4'd6: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 
//                              | cdpixel_b1;
//            end
//            4'd7: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 
//                              | cdpixel_b1;
//            end
//            4'd8: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 
//                              | cdpixel_b1;
//            end
//            4'd9: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 | cdpixel_a9 
//                              | cdpixel_b1;
                
//            end
//            4'd10: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 | cdpixel_a9 | cdpixel_a10
//                              | cdpixel_b1;
//            end
//            4'd11: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 | cdpixel_a9 | cdpixel_a10
//                              | cdpixel_a11 
//                              | cdpixel_b1;
//            end
//            4'd1: begin
//                pixels <= cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
//                              | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 | cdpixel_a9 | cdpixel_a10
//                              | cdpixel_a11 | cdpixel_a12 
//                              | cdpixel_b1;
//            end
//        endcase
    end
    
    assign pixels = cdpixel_a1 | cdpixel_a2 | cdpixel_a3 | cdpixel_a4 | cdpixel_a5
                  | cdpixel_a6 | cdpixel_a7 | cdpixel_a8 | cdpixel_a9 | cdpixel_a10
                  | cdpixel_a11 | cdpixel_a12 
                  | cdpixel_b1;
endmodule
