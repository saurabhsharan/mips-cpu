`default_nettype none

// 32 32-bit register file. 
// * Async reads and sync writes.
// * 2 read ports and 1 write port.
module registers(
  input wire clk,
  input wire [4:0]r_address1,
  input wire [4:0]r_address2,
  input wire [4:0]w_address,
  input wire [31:0]w_data,
  input wire w_enable,
  output wire [31:0]o_data1,
  output wire [31:0]o_data2);

  reg [31:0] data[0:31];

  integer i;
  initial begin
    for (i=0; i<32; i=i+1)
      data[i] <= 0;
  end

  assign o_data1 = data[r_address1];
  assign o_data2 = data[r_address2];

  always @(posedge clk) begin
    if (w_enable)
      data[w_address] <= w_data;
  end
endmodule
