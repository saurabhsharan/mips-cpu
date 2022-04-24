module alu_tb;
  reg [31:0]a;
  reg [31:0]b;
  reg [2:0]ctrl;
  wire [31:0]result;
  alu alu1(.a(a), .b(b), .ctrl(ctrl), .result(result));

  initial begin
    a = 3;
    b = 4;
    ctrl = 3'b010;

    #1 $display("result=%d", result);
    $finish;
  end
endmodule