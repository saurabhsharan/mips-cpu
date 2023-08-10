`default_nettype none

// The last address (8'b11111111) is for I/O
module icemem(
  input wire clk,
  input wire clk_enable,
  input wire [7:0] read_address,
  input wire [7:0] write_address,
  input wire [31:0] write_data,
  input wire write_enable,
  output wire [31:0] output_data,
  output wire LED1,
  output wire LED2,
  output wire LED3,
  output wire LED4,
  output wire LED5
);
  reg [31:0] data[0:255];

  integer i;
  initial begin
    for (i=0; i<255; i=i+1)
      data[i] <= 0;
    // data[255] <= 32'h0000001F;
  end

  assign output_data = data[read_address];

  assign LED1 = data[8'b11111111][0];
  assign LED2 = data[8'b11111111][1];
  assign LED3 = data[8'b11111111][2];
  assign LED4 = data[8'b11111111][3];
  assign LED5 = data[8'b11111111][4];

  always @(posedge clk) begin
    if (clk_enable) begin
      if (write_enable)
        data[write_address] <= write_data;
    end
  end
endmodule
