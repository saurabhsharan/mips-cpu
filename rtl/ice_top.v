`default_nettype none

module icetop(
  input CLK,
  output LED1, LED2, LED3, LED4, LED5,
);
  wire [31:0] mem_read_data;
  wire [7:0] mem_read_address;
  wire [7:0] mem_write_address;
  wire [31:0] mem_write_data;
  wire mem_write_enable;

  wire clk_enable;

  clock_div cdiv(
    .clk (CLK),
    .clk_enable (clk_enable),
  );

  pipelined_cpu cpu(
    .clk (CLK),
    .clk_enable (clk_enable),
    .i_mem_read_data (mem_read_data),
    .o_mem_read_address (mem_read_address),
    .o_mem_write_address (mem_write_address),
    .o_mem_write_data (mem_write_data),
    .o_mem_write_enable (mem_write_enable)
  );

  icemem icem(
    .clk (CLK),
    .clk_enable (clk_enable),
    .read_address (mem_read_address),
    .write_address (mem_write_address),
    .write_data (mem_write_data),
    .write_enable (mem_write_enable),
    .output_data (mem_read_data),
    .LED1 (LED1),
    .LED2 (LED2),
    .LED3 (LED3),
    .LED4 (LED4),
    .LED5 (LED5),
  );
endmodule
