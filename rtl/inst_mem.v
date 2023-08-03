module inst_mem(
  input wire [7:0]i_address,
  output wire [31:0]instruction);

  reg [7:0] data[0:255];

  integer i;
  initial begin
    data[0] = 8'b00000011;
    data[1] = 8'b00000000;
    data[2] = 8'b00001000;
    data[3] = 8'b00100001;

    data[4] = 8'b11111111;
    data[5] = 8'b00000000;
    data[6] = 8'b00101001;
    data[7] = 8'b00100001;

    data[8] = 8'b00000000;
    data[9] = 8'b00000000;
    data[10] = 8'b00101000;
    data[11] = 8'b10101101;

    for (i=12; i<256; i=i+1)
      data[i] <= 0;
  end

  // `i_address_base` is so that if `i_address` refers to a byte that is in the middle of a instruction, we correctly return the entire instruction
  wire [7:0] i_address_base;
  assign i_address_base = i_address & 8'b11111100;
  assign instruction = {data[i_address_base+3], data[i_address_base+2], data[i_address_base+1], data[i_address_base]};
endmodule
