module serial_tx 
    ////////////////////////////////////////////////
    // 
    // CLK_PER_BIT is used to set the baud rate
    // 65mhz/4800
    // baud Rates (bits/sec)
    //    4800      --   13541.667
    //    9600      --   67708.833
    //    14400     --   4513.888
    //    19200     --   3385.416
    //    57600     --   1128.472
    //    115200    --   564.236
    //    128000    --   507.8125
    //
    ////////////////////////////////////////////////

    #(parameter CLK_PER_BIT = 13540,
      parameter PKT_LENGTH = 32)
    (input clk,
    input rst,
    input [PKT_LENGTH-1:0] data,
    input new_data,
    output tx,
    output busy,
    output done
    );
 
    // clog2 is 'ceiling of log base 2' which gives you the number of bits needed to store a value
    parameter CTR_SIZE = $clog2(CLK_PER_BIT); //needs to be at least ceil(log2 of clocks cyless per bit)
    
    localparam STATE_SIZE = 2;
    localparam IDLE = 2'd0,
    START_BIT = 2'd1,
    DATA = 2'd2,
    STOP_BIT = 2'd3;
    
    reg [CTR_SIZE-1:0] ctr_d, ctr_q;
    reg [13:0] bit_ctr_d, bit_ctr_q;
    reg [PKT_LENGTH-1:0] data_d, data_q;
    reg [STATE_SIZE-1:0] state_d, state_q = IDLE;
    reg tx_d, tx_q;
    reg busy_d, busy_q;
    reg done_d, done_q;
    
    assign tx = tx_q;
    assign busy = busy_q;
    assign done = done_q;
    
    always @(*) begin
    ctr_d = ctr_q;
    bit_ctr_d = bit_ctr_q;
    data_d = data_q;
    state_d = state_q;
    busy_d = busy_q;
    done_d = done_q;
    
    case (state_q)
      IDLE: begin
          busy_d = 1'b0;
          tx_d = 1'b0;
          bit_ctr_d = 14'b0;
          ctr_d = 1'b0;
          done_d = 1'b0;
          if (new_data) begin
            data_d = data;
            state_d = START_BIT;
            busy_d = 1'b1;
        end
      end
      START_BIT: begin
        busy_d = 1'b1;
        ctr_d = ctr_q + 1'b1;
        tx_d = 1'b1;
        done_d = 1'b0;
        if (ctr_q == CLK_PER_BIT - 1) begin
          ctr_d = 1'b0;
          state_d = DATA;
        end
      end
      DATA: begin
        busy_d = 1'b1;
        tx_d = data_q[bit_ctr_q];
        ctr_d = ctr_q + 1'b1;
        done_d = 1'b0;
        if (ctr_q == CLK_PER_BIT - 1) begin
          ctr_d = 1'b0;
          bit_ctr_d = bit_ctr_q + 1'b1;
          if (bit_ctr_q == PKT_LENGTH-1) begin /////////
            state_d = STOP_BIT;
          end
        end
      end
      STOP_BIT: begin
        busy_d = 1'b1;
        tx_d = 1'b0;
        ctr_d = ctr_q + 1'b1;
        done_d = 1'b1;
        if (ctr_q == CLK_PER_BIT - 1) begin
          state_d = IDLE;
        end
      end
      default: begin
        state_d = IDLE;
      end
    endcase
    end
    
    always @(posedge clk) begin
        if (rst) begin
          state_q <= IDLE;
          tx_q <= 1'b0;

          data_q <= 0;
          bit_ctr_q <= 0;
          ctr_q <= 0;
          busy_q <= 0;
          done_q <= 0;
          
        end else begin
          state_q <= state_d;
          tx_q <= tx_d;

          data_q <= data_d;
          bit_ctr_q <= bit_ctr_d;
          ctr_q <= ctr_d;
          busy_q <= busy_d;
          done_q <= done_d;
        end
        

    end
    
endmodule