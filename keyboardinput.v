`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// allanko and keam for 6.111 fall 2016 - lasernet 
///////////////////////////////////////////////////////////////////////////////// 

//// bumping the last sixteen characters to the outgoing message block //////////

module keyboardexport(
    input clock_65mhz, 
    input reset,
    input ps2_clock,
    input ps2_data,
    output reg [16*8 - 1:0] cstring  // outgoing message
    );

 
    wire [7:0] ascii;
    wire       char_rdy;     

    ps2_ascii_input kbd(clock_65mhz, reset, 
                        ps2_clock, ps2_data, 
                        ascii, char_rdy);
               
    reg [3:0] count = 15;
    reg [7:0] last_ascii;

    always @(posedge clock_65mhz) begin

        count <= reset ? 15 : (char_rdy ? count-1 : count);
        last_ascii <= char_rdy ? ascii : last_ascii;

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

endmodule



/////////////////////// keyboard input ////////////////////////////////////
module ps2_ascii_input(clock_27mhz, reset, clock, data, ascii, ascii_ready);

   // INPUTS:
   //
   //   clock_27mhz   - master clock
   //   reset         - active high
   //   clock         - ps2 interface clock
   //   data          - ps2 interface data
   //
   // OUTPUTS:
   //
   //   ascii         - 8 bit ascii code for current character
   //   ascii_ready   - one clock cycle pulse indicating new char received
   //
   //
   // Author: C. Terman / I. Chuang
   // Date: 24-Oct-05
   // module to generate ascii code for keyboard input
   // this is module works synchronously with the system clock

   input clock_27mhz;
   input reset; 	 // Active high asynchronous reset
   input clock; 	 // PS/2 clock
   input data;  	 // PS/2 data
   output [7:0] ascii;   // ascii code (1 character)
   output ascii_ready;	 // ascii ready (one clock_27mhz cycle active high)

   reg [7:0]   ascii_val;	// internal combinatorial ascii decoded value
   reg [7:0]   lastkey;		// last keycode
   reg [7:0]   curkey;		// current keycode
   reg [7:0]   ascii;		// ascii output (latched & synchronous)
   reg 	       ascii_ready;	// synchronous one-cycle ready flag

   // get keycodes

   wire        fifo_rd;		// keyboard read request
   wire [7:0]  fifo_data;	// keyboard data
   wire        fifo_empty;	// flag: no keyboard data
   wire        fifo_overflow;	// keyboard data overflow

   ps2 myps2(reset, clock_27mhz, clock, data, fifo_rd, fifo_data, 
	     fifo_empty,fifo_overflow);

   assign      fifo_rd = ~fifo_empty;	// continous read
   reg 	       key_ready;

   always @(posedge clock_27mhz)
     begin

	// get key if ready

	curkey <= ~fifo_empty ? fifo_data : curkey;
	lastkey <= ~fifo_empty ? curkey : lastkey;
	key_ready  <= ~fifo_empty;

	// raise ascii_ready for last key which was read

	ascii_ready <= key_ready & ~(curkey[7]|lastkey[7]);
	ascii <=  (key_ready & ~(curkey[7]|lastkey[7])) ? ascii_val : ascii;

     end

   always @(curkey) begin //convert PS/2 keyboard make code ==> ascii code
     case (curkey)	
       8'h1C: ascii_val = 8'h41;		//A
       8'h32: ascii_val = 8'h42;		//B
       8'h21: ascii_val = 8'h43;		//C
       8'h23: ascii_val = 8'h44;		//D
       8'h24: ascii_val = 8'h45;		//E
       8'h2B: ascii_val = 8'h46;		//F
       8'h34: ascii_val = 8'h47;		//G
       8'h33: ascii_val = 8'h48;		//H
       8'h43: ascii_val = 8'h49;		//I
       8'h3B: ascii_val = 8'h4A;		//J
       8'h42: ascii_val = 8'h4B;		//K
       8'h4B: ascii_val = 8'h4C;		//L
       8'h3A: ascii_val = 8'h4D;		//M
       8'h31: ascii_val = 8'h4E;		//N
       8'h44: ascii_val = 8'h4F;		//O
       8'h4D: ascii_val = 8'h50;		//P
       8'h15: ascii_val = 8'h51;		//Q
       8'h2D: ascii_val = 8'h52;		//R
       8'h1B: ascii_val = 8'h53;		//S
       8'h2C: ascii_val = 8'h54;		//T
       8'h3C: ascii_val = 8'h55;		//U
       8'h2A: ascii_val = 8'h56;		//V
       8'h1D: ascii_val = 8'h57;		//W
       8'h22: ascii_val = 8'h58;		//X
       8'h35: ascii_val = 8'h59;		//Y
       8'h1A: ascii_val = 8'h5A;		//Z
       
       8'h45: ascii_val = 8'h30;		//0
       8'h16: ascii_val = 8'h31;		//1
       8'h1E: ascii_val = 8'h32;		//2
       8'h26: ascii_val = 8'h33;		//3
       8'h25: ascii_val = 8'h34;		//4
       8'h2E: ascii_val = 8'h35;		//5
       8'h36: ascii_val = 8'h36;		//6
       8'h3D: ascii_val = 8'h37;		//7
       8'h3E: ascii_val = 8'h38;		//8
       8'h46: ascii_val = 8'h39;		//9
       
       8'h0E: ascii_val = 8'h60;		// `
       8'h4E: ascii_val = 8'h2D;		// -
       8'h55: ascii_val = 8'h3D;		// =
       8'h5C: ascii_val = 8'h5C;		// \
       8'h29: ascii_val = 8'h20;		// (space)
       8'h54: ascii_val = 8'h5B;		// [
       8'h5B: ascii_val = 8'h5D;		// ] 
       8'h4C: ascii_val = 8'h3B;		// ;
       8'h52: ascii_val = 8'h27;		// '
       8'h41: ascii_val = 8'h2C;		// ,
       8'h49: ascii_val = 8'h2E;		// .
       8'h4A: ascii_val = 8'h2F;		// /
       
       8'h5A: ascii_val = 8'h0D;		// enter (CR)
       8'h66: ascii_val = 8'h08;		// backspace
       
       //  8'hF0: ascii_val = 8'hF0;		// BREAK CODE
       
       default: ascii_val = 8'h23;		// #
     endcase
   end
endmodule // ps2toascii

/////////////////////////////////////////////////////////////////////////////
// new synchronous ps2 keyboard driver, with built-in fifo, from Chris Terman

module ps2(reset, clock_27mhz, ps2c, ps2d, fifo_rd, fifo_data, 
	   fifo_empty,fifo_overflow);

   input clock_27mhz,reset;
   input ps2c;			// ps2 clock
   input ps2d;			// ps2 data
   input fifo_rd;		// fifo read request (active high)
   output [7:0] fifo_data;	// fifo data output
   output 	fifo_empty;	// fifo empty (active high)
   output 	fifo_overflow;	// fifo overflow - too much kbd input

  reg [3:0] count;      // count incoming data bits
  reg [9:0] shift;      // accumulate incoming data bits

  reg [7:0] fifo[7:0];   // 8 element data fifo
  reg fifo_overflow;
  reg [2:0] wptr,rptr;   // fifo write and read pointers

  wire [2:0] wptr_inc = wptr + 1;

  assign fifo_empty = (wptr == rptr);
  assign fifo_data = fifo[rptr];

  // synchronize PS2 clock to local clock and look for falling edge
  reg [2:0] ps2c_sync;
  always @ (posedge clock_27mhz) ps2c_sync <= {ps2c_sync[1:0],ps2c};
  wire sample = ps2c_sync[2] & ~ps2c_sync[1];

  always @ (posedge clock_27mhz) begin
    if (reset) begin
      count <= 0;
      wptr <= 0;
      rptr <= 0;
      fifo_overflow <= 0;
    end
    else if (sample) begin
           // order of arrival: 0,8 bits of data (LSB first),odd parity,1
           if (count==10) begin
              // just received what should be the stop bit
              if (shift[0]==0 && ps2d==1 && (^shift[9:1])==1) begin
		 fifo[wptr] <= shift[8:1];
		 wptr <= wptr_inc;
		 fifo_overflow <= fifo_overflow | (wptr_inc == rptr);
              end
              count <= 0;
	   end else begin
              shift <= {ps2d,shift[9:1]};
              count <= count + 1;
	   end
         end
    // bump read pointer if we're done with current value.
    // Read also resets the overflow indicator
    if (fifo_rd && !fifo_empty) begin
      rptr <= rptr + 1;
      fifo_overflow <= 0;
    end
  end

endmodule