`default_nettype none

module cpu(input wire clk);
  reg [7:0]pc;
  initial begin
    pc = 0;
  end
  always @(posedge clk) begin
    if (is_branch && (alu_result == 0))
      pc <= pc + 4 + (immediate * 4);
    else
      pc <= pc+4;
  end

  wire [31:0] instruction;
  inst_mem imem(.i_address(pc), .instruction(instruction));

  wire register_write_data_source, register_write_enable, data_mem_write_enable, alu_b_source, register_write_address_source, is_branch;
  wire [2:0] alu_ctrl;
  wire [4:0] s_register_addr;
  wire [4:0] t_register_addr;
  wire [4:0] d_register_addr;
  wire [15:0] immediate;
  control ctl(.instruction(instruction),
              .register_write_data_source(register_write_data_source),
              .register_write_enable(register_write_enable),
              .register_write_address_source(register_write_address_source),
              .data_mem_write_enable(data_mem_write_enable),
              .alu_b_source(alu_b_source),
              .alu_ctrl(alu_ctrl),
              .is_branch(is_branch),
              .src_register_addr(s_register_addr),
              .dst_register_addr(t_register_addr),
              .r_register_addr(d_register_addr),
              .immediate(immediate));

  wire [31:0] register_read_out1;
  wire [31:0] register_read_out2;

  // Controlled by `register_write_data_source` control signal
  wire [31:0] memory_read_output_to_register_write_data; // wire of data from memory to register write
  wire [31:0] alu_result;
  wire [31:0] register_write_data = register_write_data_source ? memory_read_output_to_register_write_data : alu_result;

  wire [31:0] alu_b_input = alu_b_source ? register_read_out2 : immediate;

  wire [4:0] register_write_address = register_write_address_source ? d_register_addr : t_register_addr;

  registers regs(.clk(clk),
                 .r_address1(s_register_addr), .r_address2(t_register_addr),
                 .w_address(register_write_address), .w_data(register_write_data), .w_enable(register_write_enable),
                 .o_data1(register_read_out1), .o_data2(register_read_out2));

  alu alu(.a(register_read_out1), .b(alu_b_input), .ctrl(alu_ctrl), .result(alu_result));

  data_mem dmem(.clk(clk),
                .r_address(register_read_out1), .w_address(register_read_out1), .w_data(register_read_out2), .w_enable(data_mem_write_enable),
                .o_data(memory_read_output_to_register_write_data));
endmodule
