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
   inout [7:0] JA, 
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

// BTNL for saving keyboard data to outgoing message block
wire save;
debounce db2(.reset(reset),.clock(clocksys),
              .noisy(BTNL),.clean(save));


///////////////////// INSTANTIATE AND WIRE UP MODULES //////////////////////////

//////////////////////////// MAIN STATE MACHINE

wire packetsent;            // goes high for a cycle when a packet is finished sending

wire incomingready;         // incoming packet is ready
wire [31:0] incomingACK;    // incoming acknowledgment number
wire [31:0] incomingSEQ;    // incoming sequence number
wire [8:0] incomingflags;   // incoming TCP flags

wire outgoingready;         // outgoing packet is ready
wire [31:0] outgoingACK;    // outgoing acknowledgment number
wire [31:0] outgoingSEQ;    // outgoing sequence number
wire [8:0] outgoingflags;   // outgoing TCP flags

wire [3:0] state;           // to display the current state

wire [31:0] ISN;            // first sequence number to use
assign ISN = 32'd0;         // PARAMETER

wire [31:0] SNmax;          // largest sequence number available in data; equal to # of packets in message
assign SNmax = 32'h5;       // PARAMETER

wire [15:0] windowsize;     // window size for go-back-n protocol
assign windowsize = 16'd2;  // PARAMETER

mainfsm statemachine(.clk(clocksys), .reset(reset), .open(openTCP), .packetsent(packetsent),
                      .ISN(ISN), .SNmax(SNmax),
                      .window(windowsize),
                      .readyin(incomingready), .ACKin(incomingACK), .SEQin(incomingSEQ), .flagsin(incomingflags),
                      .readyout(outgoingready), .ACKout(outgoingACK), .SEQout(outgoingSEQ), .flagsout(outgoingflags),
                      .statedisplay(state));

//// memory blocks for holding incoming and outgoing messages
//// each packet is 16 characters, can store/display 5 packets at a time

wire [16*8*5 - 1 : 0] outgoing; // outgoing message
wire [16*8*5 - 1 : 0] incoming; // incoming message

/////////////////////////// KEYBOARD INPUT

wire [16*8 - 1 : 0] currentkeyboard;

keyboardexport kbdexport1(.clock_65mhz(clock_65mhz), .reset(reset),
                          .ps2_clock(PS2_CLK), .ps2_data(PS2_DATA),
                          .cstring(currentkeyboard),
                          .save(save), .messageout(outgoing)
                          );

///////////////////////// PACKET GENERATOR AND CHECKSUM

wire [32*9 - 1 : 0] outgoingpacket;
wire readytotransmit;

makepacket packetgen(.clk(clocksys), .reset(reset), 
                      .ISN(ISN), .readyin(outgoingready),
                      .window(windowsize),
                      .seq(outgoingSEQ),.ack(outgoingACK), .flags(outgoingflags),
                      .message(outgoing),
                      .packet(outgoingpacket),.readyout(readytotransmit));

//////////////////////// PACKET RECEIVER AND CHECKSUM
wire [32*9 - 1 :0] incomingpacket;  // incoming packet received from photodiode
wire readyfromlaserinput;           // goes high when a new packet is fully received from photodiode

receivepacket packetrcv(.clk(clocksys), .reset(reset),
                          .ready(readyfromlaserinput),
                          .ISN(ISN),
                          .packet(incomingpacket),
                          .seq(incomingSEQ),.ack(incomingACK),.flags(incomingflags),
                          .message(incoming));

//////////////////////// LASER OUTPUT AND PHOTODIODE INPUT


wire laser_out;
wire busy;

assign JA[0] = laser_out;
assign LED[12] = busy;
assign LED[13] = laser_out;

serial_tx stx(.clk(clocksys),
        .rst(reset),
        .data(outgoingpacket),        // outgoing data packet
        .new_data(readytotransmit),   // goes high when new packet available to transmit
        .tx(laser_out),               // laser signal output to JA[0] 
        .busy(busy),                  // high when transmitting a message, low when not
        .done(packetsent));           // high for one cycle after completing transmission
defparam stx.CLK_PER_BIT = 13540;
defparam stx.PKT_LENGTH = 32*9;  

serial_rx srx(.clk(clocksys),
        .rst(reset),
        .rx(~JA[1]),                      // incoming photodiode signal on JA[1]
        .data(incomingpacket),            // incoming data packet
        .new_data(readyfromlaserinput));  // high for one cycle when new packet available
defparam srx.CLK_PER_BIT = 13540;
defparam srx.PKT_LENGTH = 32*9;


////////////////////////// workspace

// display some important numbers to seven-segment display
assign to_display = {incomingACK[3:0], incomingSEQ[3:0], outgoingACK[3:0], outgoingSEQ[3:0], 12'h000, state};
assign LED[2:0] = {outgoingflags[4], outgoingflags[1], outgoingflags[0]};


// temp statements here - remove this section
// assign packetsent = SW[14]; // simulate a packet being sent

// assign incomingflags = {4'b0000, SW[2], 2'b00, SW[1], SW[0]}; // simulate incoming ack, syn, fin
// assign incomingACK = {28'd0, SW[11:8]};
// assign incomingSEQ = {28'd0, SW[7:4]};



///////////////////////////  XVGA DISPLAY ////////////////////////////////////////
 
//  generate basic XVGA video signals
wire [10:0] hcount;
wire [9:0]  vcount;
wire hsync,vsync,blank;
xvga xvga1(clock_65mhz,hcount,vcount,hsync,vsync,blank);
 
wire [2:0] sample_pixels;
wire dis;
screenlayout face( .clock_65mhz(clock_65mhz),
                .hcount(hcount), .vcount(vcount),
                .display(dis),
                .messageout(outgoing), .messagein(incoming),
                .keyboard(currentkeyboard),
                .pixels(sample_pixels) );
                    
//  red text box for displaying user input  
wire [23:0] paddle_pixel;
blob #(.WIDTH(800),.HEIGHT(128),.COLOR(24'hFF_00_00))   // red!
     paddle1(.x(11'd100),.y(10'd600),.hcount(hcount),.vcount(vcount),
             .pixel(paddle_pixel));

//  white border around screen
wire [2:0] white_outline_pixels;
assign white_outline_pixels = (hcount==0 | hcount==1023 | vcount==0 | vcount==767) ? 7 : 0;


/////// output to vga

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
           white_outline_pixels ;
  end
end

assign VGA_R = {4{rgb[2]}} | paddle_pixel[23:16];
assign VGA_G = {4{rgb[1]}} | paddle_pixel[15:8];
assign VGA_B = {4{rgb[0]}} | paddle_pixel[7:0];

assign VGA_HS = ~hs;
assign VGA_VS = ~vs;





endmodule
