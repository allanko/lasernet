`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: keam / allanko for 6.111 fa2016 - lasernet
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: mainfsm
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

// operates controller FSM and tracks go-back-n protocol

module mainfsm(
    input clk,
    input reset,
    input open,
    input packetsent,  // high for one cycle after a packet is transmitted
    input [31:0] ISN,			// initial sequence number to use
    input [31:0] SNmax, 		// largest address of data to send; ie the address of the last data packet
    input [15:0] window, // size of go-back-n window
    input readyin,
    input [31:0] ACKin,
    input [31:0] SEQin,
    input [8:0] flagsin,
    output reg readyout, 		// high for one cycle when you want to send a new packet
    output reg [31:0] ACKout,
    output reg [31:0] SEQout,
    output [8:0] flagsout,
    output reg [3:0] statedisplay // figure out how many bits you need for this
    );

    // read incoming flags
    wire flagsinACK ;
    assign flagsinACK = flagsin[4];

    wire flagsinSYN;
    assign flagsinSYN = flagsin[1];

    wire flagsinFIN;
    assign flagsinFIN = flagsin[0];

    reg FINreceived; // bookkeeps when you've received a FIN

    // wires for outgoing flags
    reg flagsoutACK;
    reg flagsoutSYN;
    reg flagsoutFIN;

    assign flagsout = {4'b0000, flagsoutACK, 2'b00, flagsoutSYN, flagsoutFIN};

    /////////////////// ESTABLISH STATES /////////////////////////////////////
    reg [3:0] state, nextstate;

    parameter S_PASSIVE_OPEN 		= 4'h0; // idle

    // opening a TCP connection

    parameter S_ACTIVE_OPEN			= 4'h1; // (initiating) - sending SYN
    parameter S_CONNECTED			= 4'h2; // (initiating) received SYN-ACK - sending ACK

    parameter S_ACTIVATED	 		= 4'h3; // (listening) - received SYN - sending SYN-ACK

    // transmitting packets

    parameter S_TRANSMITTING 		= 4'h4; // making the next packet to transmit
    parameter S_TRANSMIT_WAIT		= 4'h5; // waiting for packet to get transmitted

    // closing the TCP connection

    parameter S_FIN					= 4'h6; // no more data - transmitting FIN flags
    parameter S_FIN_WAIT 			= 4'h7; // waiting for fin packet to get transmitted


    ////////////////////////////////////////////////////////////////////////////

    // tracking important numbers
    reg [31:0] SN; 			// sequence number relative to ISN (SEQout = ISN + SN)
    reg [31:0] lastACK; 	// last acknowledgment received from other node
    reg [31:0] nextACK; 	// next acknowledgment to send to other node

    // state behavior
    always @(*) begin
    	case(state)
    	S_PASSIVE_OPEN : begin

    		statedisplay = S_PASSIVE_OPEN;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b0;
    		flagsoutFIN = 1'b0;
    		ACKout = 32'd0;
    		SEQout = ISN + SN;

    		nextstate = open ? S_ACTIVE_OPEN : 
    					(flagsinSYN & !flagsinACK) ? S_ACTIVATED :
    					S_PASSIVE_OPEN;

    	end

    	S_ACTIVE_OPEN : begin

    	    statedisplay = S_ACTIVE_OPEN;

    		flagsoutSYN = 1'b1;
    		flagsoutACK = 1'b0;
    		flagsoutFIN = 1'b0;
    		ACKout = 32'd0;
    		SEQout = ISN + SN;

    		nextstate = (flagsinSYN & flagsinACK & (ACKin == (ISN + 1))) ? S_CONNECTED : 
    					S_ACTIVE_OPEN;

    	end

    	S_CONNECTED : begin

    		statedisplay = S_CONNECTED;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b0;
    		ACKout = nextACK;
    		SEQout = ISN + SN;

    		nextstate = packetsent ? S_TRANSMITTING : 
    					S_CONNECTED;

    	end

    	S_ACTIVATED : begin

    		statedisplay = S_ACTIVATED;

    		flagsoutSYN = 1'b1;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b0;
    		ACKout = nextACK;
    		SEQout = ISN + SN;

    		nextstate = (!flagsinSYN & flagsinACK & (ACKin == (ISN + 1))) ? S_TRANSMITTING :
    					S_ACTIVATED;

    	end

    	S_TRANSMITTING : begin

    		statedisplay = S_TRANSMITTING;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b0;
    		ACKout = nextACK;
    		SEQout = ISN + SN;

    		nextstate = S_TRANSMIT_WAIT;

    	end

    	S_TRANSMIT_WAIT : begin

    		statedisplay = S_TRANSMIT_WAIT;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b0;
    		ACKout = nextACK;
    		SEQout = ISN + SN;

    		nextstate = (lastACK == ISN + SNmax + 32'd1) ? S_FIN : 
    					packetsent ? S_TRANSMITTING : 
    					S_TRANSMIT_WAIT;

    	end

    	S_FIN : begin

    		statedisplay = S_FIN;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b1;
    		ACKout = nextACK;
    		SEQout = ISN + SN;
    		nextstate = ((lastACK == ISN + SNmax + 32'd2) & FINreceived ) ? S_PASSIVE_OPEN :
    					S_FIN_WAIT;

    	end

    	S_FIN_WAIT : begin

    		statedisplay = S_FIN_WAIT;

    		flagsoutSYN = 1'b0;
    		flagsoutACK = 1'b1;
    		flagsoutFIN = 1'b1;
    		ACKout = nextACK;
    		SEQout = ISN + SN;

    		nextstate = packetsent ? S_FIN : 
    					S_FIN_WAIT;
    	end

    	default : nextstate = S_PASSIVE_OPEN;

    	endcase
    end


    // clocked state updates
    always @(posedge clk) begin
    	state <= reset ? S_PASSIVE_OPEN : nextstate;

    	case(nextstate)

    	S_PASSIVE_OPEN : begin

    		nextACK <= 32'd0;
    		SN <= 32'd0;
    		lastACK <= 32'd0;
    		readyout <= 1'b0;
    		FINreceived <= 1'b0;

    	end

    	S_ACTIVE_OPEN : begin

    		nextACK <= 32'd0;
    		SN <= 32'd0;
    		lastACK <= 32'd0;
    		readyout <= (nextstate != state) ? 1'b1 : 1'b0; 
    		FINreceived <= 1'b0;

    	end

    	S_CONNECTED : begin

    		nextACK <= (nextstate != state) ? SEQin + 32'd1 : // nextACK sampled upon entry 
    					nextACK;
    		SN <= 32'd0;
    		lastACK <= (nextstate != state) ? ACKin : // lastACK sampled upon entry
    					lastACK;

    		readyout <= (nextstate != state) ? 1'b1 : 1'b0;

    		FINreceived <= 1'b0;

    	end

    	S_ACTIVATED : begin

    		nextACK <= (nextstate != state) ? SEQin + 32'd1 : // nextACK sampled upon entry
    					nextACK;
    		SN <= 32'd0;
    		lastACK <= 32'd0;

    		readyout <= (nextstate != state) ? 1'b1 : 1'b0;

    		FINreceived <= 1'b0;

    	end

    	S_TRANSMITTING : begin

    		nextACK <= (nextstate != state) ? SEQin + 32'd1 : // nextACK sampled upon entry
    					nextACK;


    		SN <= ((nextstate != state) & (ISN + SN == ACKin + window)) ? ACKin - ISN : 
    			  ((nextstate != state) & (SN == SNmax)) ? ACKin - ISN : 
    			   (nextstate != state) ? SN + 1 : 
    			   SN;

    		lastACK <= (nextstate != state) ? ACKin : // lastACK sampled upon entry
    					lastACK;

    		readyout <= (nextstate != state) ? 1'b1 : 1'b0;

    		FINreceived <= ((nextstate != state) & flagsinFIN) ? 1'b1 : FINreceived; // on entry, check if FIN received

    	end

    	S_TRANSMIT_WAIT : begin

    		nextACK <= nextACK;
    		SN <= SN;
    		lastACK <= lastACK;
    		readyout <= 1'b0;
    		FINreceived <= FINreceived;

    	end

    	S_FIN : begin
    		nextACK <= (nextstate != state) ? SEQin + 32'd1 : 
    					nextACK;

    		SN <= SNmax + 32'd1;  // FIN packet has SN = 1 + maximum SNmax
    		lastACK <= (nextstate != state) ? ACKin : 
    					lastACK;

    		readyout <= (nextstate != state) ? 1'b1 : 1'b0;
    		FINreceived <= ((nextstate != state) & flagsinFIN) ? 1'b1 : FINreceived; // on entry, check if FIN received

    	end

    	S_FIN_WAIT : begin

    		nextACK <= nextACK;
    		SN <= SN;
    		lastACK <= lastACK;
    		readyout <= 1'b0;
    		FINreceived <= FINreceived;

    	end

    	default : begin

    		nextACK <= 32'd0;
    		SN <= 32'd0;
    		lastACK <= 32'd0;
    		readyout <= 1'b0;
    		FINreceived <= 1'b0;

    	end

    	endcase

    end




endmodule
