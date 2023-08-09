module alu_tb;
  reg [31:0]a;
  reg [31:0]b;
  reg [2:0]ctrl;
  wire [31:0]result;
  alu alu1(.a(a), .b(b), .ctrl(ctrl), .result(result));

  initial begin
    a = 2;
    b = 1;
    ctrl = 3'b011;

    $dumpfile("alu_tb.dmp");
    $dumpvars;

    #1 $display("result=%d", result);
    $finish;
  end
endmodule
