`default_nettype none

// Most of this is using recommendations from: https://zipcpu.com/blog/2017/06/02/generating-timing.html

module clock_div(
  input wire clk,
  output reg clk_enable
);
  reg [22:0] counter;

  always @(posedge clk) begin
    counter <= counter + 1'b1;
    clk_enable <= (counter == {23{1'b1}});
  end
endmodule
