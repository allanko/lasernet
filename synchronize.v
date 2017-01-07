// pulse synchronizer

module synchronize #(parameter NSYNC = 2)  // number of sync flops.  must be >= 2
                   (input clock,in,
                    output reg out);

  reg [NSYNC-2:0] sync;

  always @ (posedge clock) begin
  	{out,sync} <= {sync[NSYNC-2:0],in};
  end
  
endmodule
