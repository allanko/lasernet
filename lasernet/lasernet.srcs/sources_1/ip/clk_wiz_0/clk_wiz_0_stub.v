// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.3 (win64) Build 1682563 Mon Oct 10 19:07:27 MDT 2016
// Date        : Sat Jan 07 14:03:16 2017
// Host        : allanko running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/Allan/Documents/MIT/FALL 2016/6.111/final
//               project/lasernet/lasernet.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v}
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_out_65mhz, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out_65mhz,reset,locked,clk_in1" */;
  output clk_out_65mhz;
  input reset;
  output locked;
  input clk_in1;
endmodule
