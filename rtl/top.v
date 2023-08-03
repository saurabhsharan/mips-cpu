module top(
  input wire clk
);
  wire [31:0] mem_read_data;
  wire [7:0] mem_read_address;
  wire [7:0] mem_write_address;
  wire [31:0] mem_write_data;
  wire mem_write_enable;

  cpu cpu(
    .clk (clk),
    .mem_read_data (mem_read_data),
    .mem_read_address (mem_read_address),
    .mem_write_address (mem_write_address),
    .mem_write_data (mem_write_data),
    .mem_write_enable (mem_write_enable)
  );

  data_mem dmem(
    .clk (clk),
    .r_address (mem_read_address),
    .w_address (mem_write_address),
    .w_data (mem_write_data),
    .w_enable (mem_write_enable),
    .o_data (mem_read_data)
  );
endmodule
