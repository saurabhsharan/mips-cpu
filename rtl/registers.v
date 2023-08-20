`default_nettype none

`include "constants.vh"

// 32 32-bit register file. 
// * Async reads and sync writes.
// * 2 read ports and 1 write port.
module registers(
  input wire clk,
  input wire clk_enable,
  input wire [(`REGISTER_ADDR_WIDTH-1):0]r_address1,
  input wire [(`REGISTER_ADDR_WIDTH-1):0]r_address2,
  input wire [(`REGISTER_ADDR_WIDTH-1):0]w_address,
  input wire [(`REGISTER_WIDTH-1):0]w_data,
  input wire w_enable,
  output wire [(`REGISTER_WIDTH-1):0]o_data1,
  output wire [(`REGISTER_WIDTH-1):0]o_data2);

  reg [(`REGISTER_WIDTH-1):0] data[0:31];

  integer i;
  initial begin
    for (i=0; i<32; i=i+1)
      data[i] = 0;
  end

  assign o_data1 = data[r_address1];
  assign o_data2 = data[r_address2];

  always @(posedge clk) begin
    if (clk_enable) begin
      if (w_enable && w_address != 0)
        data[w_address] <= w_data;
    end
  end
endmodule
