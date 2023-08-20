`default_nettype none

`include "constants.vh"

// ctrl signals from figure 5.14 in DD&CA2e by Harris
module alu (
  input wire [(`REGISTER_WIDTH-1):0]a,
  input wire [(`REGISTER_WIDTH-1):0]b,
  input wire [2:0]ctrl,
  output reg [(`REGISTER_WIDTH-1):0]result
);
  always @(*) begin
    case (ctrl)
      3'b000: result = a & b;
      3'b001: result = a | b;
      3'b010: result = a + b;
      3'b011: result = a << b;
      3'b100: result = a & ~b;
      3'b101: result = a | ~b;
      3'b110: result = a - b;
      3'b111: result = 0; // TODO, something about sign bit from subtraction?
    endcase
  end
endmodule
