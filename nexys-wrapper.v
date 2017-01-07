`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: labkit
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


module labkit(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   input PS2_CLK, PS2_DATA,
   output UART_RXD_OUT,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output VGA_HS, 
   output VGA_VS, 
   output[7:0] JA, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );

////////////////////////// SAMPLE CODE - DELETE THIS ///////////////////////////
//
//  remove these lines and insert your lab here

//    assign LED = SW;     
//    assign JA[7:0] = 8'b0;
//    assign LED16_R = BTNL;                  // left button -> red led
//    assign LED16_G = BTNC;                  // center button -> green led
//    assign LED16_B = BTNR;                  // right button -> blue led
//    assign LED17_R = BTNL;
//    assign LED17_G = BTNC;
//    assign LED17_B = BTNR; 



/////////////////////////// SETUP //////////////////////////////////////////////////

//////////// CLOCKS

// create 65mhz clock for xvga
wire clock_65mhz;    
wire locked;
clk_wiz_0 clock65(.clk_in1(CLK100MHZ), .clk_out_65mhz(clock_65mhz),
                  .reset(1'b0),.locked(locked));

// create system clock 
wire clocksys;
assign clocksys = clock_65mhz; // just clock everything at 65mhz

///////////// SWITCHES, BUTTONS, LEDS, DISPLAYS

//  instantiate 7-segment display  
wire [31:0] to_display;
wire [6:0] segments;
display_8hex display(.clk(clocksys),.data(to_display), .seg(segments), .strobe(AN));    
assign SEG[6:0] = segments;
assign SEG[7] = 1'b1;

// SW[15] for system reset
wire reset;
synchronize s1(.clock(clocksys),
                .in(SW[15]),.out(reset));

// SW[13] for toggling monitor display
wire screenmode;
synchronize s2(.clock(clocksys),
                .in(SW[13]),.out(screenmode));

// BTNC for opening a TCP connection
wire openTCP;
debounce db1(.reset(reset),.clock(clocksys),
              .noisy(BTNC),.clean(openTCP));


///////////////////// INSTANTIATE AND WIRE UP MODULES //////////////////////////

// instantiate main state machine

wire packetsent;            // goes high for a cycle when a packet is sent

wire incomingready;         // incoming packet is ready
wire [31:0] incomingACK;    // incoming acknowledgment number
wire [31:0] incomingSEQ;    // incoming sequence number
wire [8:0] incomingflags;   // incoming TCP flags

wire control;               // if high, sending control packets / if low, sending data

wire outgoingready;         // outgoing packet is ready
wire [31:0] outgoingACK;    // outgoing acknowledgment number
wire [31:0] outgoingSEQ;    // outgoing sequence number
wire [8:0] outgoingflags;   // outgoing TCP flags

wire [3:0] state;           // to display the current state

wire [31:0] ISN;            // first sequence number to use
assign ISN = 32'd0;         // PARAMETER

wire [31:0] SNmax;          // largest sequence number available in data

wire [15:0] windowsize;     // window size for go-back-n protocol
assign windowsize = 16'd3;  // PARAMETER

mainfsm statemachine(.clk(clocksys), .reset(reset), .open(openTCP), .packetsent(packetsent),
                      .ISN(ISN), .SNmax(SNmax),
                      .window(windowsize),
                      .readyin(incomingready), .ACKin(incomingACK), .SEQin(incomingSEQ), .flagsin(incomingflags),
                      .control(control),
                      .readyout(outgoingready), .ACKout(outgoingACK), .SEQout(outgoingSEQ), .flagsout(outgoingflags),
                      .statedisplay(state));

// display some important numbers to seven-segment display
assign to_display = {incomingACK[3:0], incomingSEQ[3:0], outgoingACK[3:0], outgoingSEQ[3:0], 12'h000, state};
assign LED[2:0] = {outgoingflags[4], outgoingflags[1], outgoingflags[0]};

// temp statements here - remove this section
assign packetsent = SW[14]; // simulate a packet being sent


assign incomingflags = {4'b0000, SW[2], 2'b00, SW[1], SW[0]}; // simulate incoming ack, syn, fin
assign incomingACK = {28'd0, SW[11:8]};
assign incomingSEQ = {28'd0, SW[7:4]};

assign SNmax = 32'hA; // set SNmax to 10

///////////////////////////  XVGA DISPLAY ////////////////////////////////////////
 

//  generate basic XVGA video signals
wire [10:0] hcount;
wire [9:0]  vcount;
wire hsync,vsync,blank;
xvga xvga1(clock_65mhz,hcount,vcount,hsync,vsync,blank);
 
wire [2:0] sample_pixels;
wire dis;
interface face( .clock_65mhz(clock_65mhz),
                .hcount(hcount),
                .vcount(vcount),
                .display(dis),
                .pixels(sample_pixels) );
                    
//  red text box for displaying user input  
wire [23:0] paddle_pixel;
blob #(.WIDTH(800),.HEIGHT(128),.COLOR(24'hFF_00_00))   // red!
     paddle1(.x(11'd100),.y(10'd600),.hcount(hcount),.vcount(vcount),
             .pixel(paddle_pixel));

// user input display module: sample string in middle of red text box
reg [16*8-1:0] cstring;
wire [2:0]  cdpixel;
char_string_display cd(clock_65mhz,hcount,vcount,
              cdpixel,cstring,11'd383,10'd650);
defparam    cd.NCHAR = 16;
defparam    cd.NCHAR_BITS = 4; 

 
/////////////////////////////////////////////////// keyboard input
wire [7:0] ascii;
wire       char_rdy;       
ps2_ascii_input kbd(clock_65mhz, reset, PS2_CLK, 
           PS2_DATA, ascii, char_rdy);
           
reg [3:0] count = 15;
reg [7:0] last_ascii;

//  assign cstring = {8{last_ascii}}; -- KEYBOARD INPUT
reg [8*8-1:0] cstring_bram_temp,cstring_bram;
reg [13:0] next_write_addr = 14'b0, last_trans_addr = 14'b0;
reg update;

reg [3:0] push_count = 4'b0;

always @(posedge clock_65mhz) begin
    count <= reset ? 15 : (char_rdy ? count-1 : count);
    last_ascii <= char_rdy ? ascii : last_ascii;
end
    
always @(posedge clock_65mhz) begin
    cstring[7:0] <= (count==0) ? last_ascii : cstring[7:0];
    cstring[7+'o10:'o10] <= (count==1) ? last_ascii: cstring[7+'o10:'o10];
    cstring[7+'o20:'o20] <= (count==2) ? last_ascii: cstring[7+'o20:'o20];
    cstring[7+'o30:'o30] <= (count==3) ? last_ascii: cstring[7+'o30:'o30];
    cstring[7+'o40:'o40] <= (count==4) ? last_ascii: cstring[7+'o40:'o40];
    cstring[7+'o50:'o50] <= (count==5) ? last_ascii: cstring[7+'o50:'o50];
    cstring[7+'o60:'o60] <= (count==6) ? last_ascii: cstring[7+'o60:'o60];
    cstring[7+'o70:'o70] <= (count==7) ? last_ascii: cstring[7+'o70:'o70];

    cstring[7+'o100:'o100] <= (count==8) ? last_ascii: cstring[7+'o100:'o100];
    cstring[7+'o110:'o110] <= (count==9) ? last_ascii: cstring[7+'o110:'o110];
    cstring[7+'o120:'o120] <= (count==10) ? last_ascii: cstring[7+'o120:'o120];
    cstring[7+'o130:'o130] <= (count==11) ? last_ascii: cstring[7+'o130:'o130];
    cstring[7+'o140:'o140] <= (count==12) ? last_ascii: cstring[7+'o140:'o140];
    cstring[7+'o150:'o150] <= (count==13) ? last_ascii: cstring[7+'o150:'o150];
    cstring[7+'o160:'o160] <= (count==14) ? last_ascii: cstring[7+'o160:'o160];
    cstring[7+'o170:'o170] <= (count==15) ? last_ascii: cstring[7+'o170:'o170];
    
end

/////////////////////////////////////// white border around screen
wire [2:0] white_outline_pixels;
assign white_outline_pixels = (hcount==0 | hcount==1023 | vcount==0 | vcount==767) ? 7 : 0;


/////////////////////////////////////// output to vga

// screenmode is a switch that selects what to show on the screen

reg [2:0] rgb;
reg b,hs,vs;
always @(posedge clock_65mhz) begin
  hs <= hsync;
  vs <= vsync;
  b <= blank;
  if (screenmode == 1'b1) begin
    // 1 pixel outline of visible area (white)
    rgb <= white_outline_pixels;
  end 
  else begin
     // default: text
   rgb <=  sample_pixels |
           cdpixel |
           white_outline_pixels ;
  end
end

assign VGA_R = {4{rgb[2]}} | paddle_pixel[23:16];
assign VGA_G = {4{rgb[1]}} | paddle_pixel[15:8];
assign VGA_B = {4{rgb[0]}} | paddle_pixel[7:0];

assign VGA_HS = ~hs;
assign VGA_VS = ~vs;





endmodule
