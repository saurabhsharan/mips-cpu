`default_nettype none

`include "constants.vh"

module single_cycle_cpu(
  input wire clk, 
  input wire clk_enable,
  input wire [31:0] mem_read_data,
  output wire [7:0] mem_read_address,
  output wire [7:0] mem_write_address,
  output wire [31:0] mem_write_data,
  output wire mem_write_enable,
  output wire [7:0] pc_out
);
  reg [7:0]pc;
  initial begin
    pc = 0;
  end
  always @(posedge clk) begin
    if (clk_enable) begin
      if (is_branch && (alu_result == 0))
        pc <= pc + 4 + (immediate * 4);
      else if (is_jump)
        pc <= (jump_imm_addr[7:0] << 2);
      else
        pc <= pc+4;
    end
  end

  wire [31:0] instruction;
  inst_mem imem(.i_address(pc), .instruction(instruction));

  wire register_write_data_source, register_write_enable, data_mem_write_enable, register_write_address_source, is_branch, is_jump;
  wire [2:0] alu_ctrl;
  wire [1:0] alu_b_source;
  wire [4:0] s_register_addr;
  wire [4:0] t_register_addr;
  wire [4:0] d_register_addr;
  wire [15:0] immediate;
  wire [4:0] shift_amt;
  wire [25:0] jump_imm_addr;
  single_cycle_mips_control ctl(.instruction(instruction),
                   .register_write_data_source(register_write_data_source),
                   .register_write_enable(register_write_enable),
                   .register_write_address_source(register_write_address_source),
                   .data_mem_write_enable(data_mem_write_enable),
                   .alu_b_source(alu_b_source),
                   .alu_ctrl(alu_ctrl),
                   .is_branch(is_branch),
                   .is_jump(is_jump),
                   .src_register_addr(s_register_addr),
                   .dst_register_addr(t_register_addr),
                   .r_register_addr(d_register_addr),
                   .immediate(immediate),
                   .shift_amt(shift_amt),
                   .jump_imm_addr(jump_imm_addr));

  wire [31:0] register_read_out1;
  wire [31:0] register_read_out2;

  wire [31:0] alu_result;
  wire [31:0] register_write_data = register_write_data_source ? mem_read_data : alu_result;

  reg [31:0] alu_b_input;
  always @(*) begin
    case (alu_b_source)
      `MIPS_CONTROL_ALU_B_SOURCE__IMMEDIATE: alu_b_input = immediate;
      `MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2: alu_b_input = register_read_out2;
      `MIPS_CONTROL_ALU_B_SOURCE__SHIFT_IMMEDIATE: alu_b_input = shift_amt;
      default: alu_b_input = immediate;
    endcase
  end

  wire [4:0] register_write_address = register_write_address_source ? d_register_addr : t_register_addr;

  registers regs(.clk(clk), .clk_enable(clk_enable),
                 .r_address1(s_register_addr), .r_address2(t_register_addr),
                 .w_address(register_write_address), .w_data(register_write_data), .w_enable(register_write_enable),
                 .o_data1(register_read_out1), .o_data2(register_read_out2));

  alu alu(.a(register_read_out1), .b(alu_b_input), .ctrl(alu_ctrl), .result(alu_result));

  assign mem_read_address = register_read_out1;
  assign mem_write_address = register_read_out1;
  assign mem_write_data = register_read_out2;
  assign mem_write_enable = data_mem_write_enable;

  assign pc_out = pc;
endmodule
