module inst_mem(
  input wire [7:0]i_address,
  output wire [31:0]instruction);

  reg [7:0] data[0:255];

  integer i;
  initial begin
    for (i=0; i<256; i=i+1)
      data[i] <= 0;
  end

  wire [7:0] i_address_base;
  assign i_address_base = i_address & 8'b11111100;
  assign instruction = {data[i_address_base+3], data[i_address_base+2], data[i_address_base+1], data[i_address_base]};
endmodule