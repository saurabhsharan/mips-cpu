`default_nettype none

module data_mem (
  input wire clk,
  input wire clk_enable,
  input wire [7:0]r_address,
  input wire [7:0]w_address,
  input wire [31:0]w_data,
  input wire w_enable,
  output wire [31:0]o_data
);
  reg [31:0] data[0:255];

  integer i;
  initial begin
    for (i=0; i<256; i=i+1)
      data[i] <= 0;
  end

  assign o_data = data[r_address];

  always @(posedge clk) begin
    if (clk_enable) begin
      if (w_enable)
        data[w_address] <= w_data;
    end
  end
endmodule
