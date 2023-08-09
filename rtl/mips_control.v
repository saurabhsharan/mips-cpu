`default_nettype none

`include "constants.vh"

module mips_control (
  input wire [31:0]instruction,
  // these are marked `reg` so I can assign to them from an always @(*) block
  output reg register_write_data_source,
  output reg register_write_address_source,
  output reg register_write_enable,
  output reg data_mem_write_enable,
  output reg [1:0]alu_b_source,
  output reg [2:0]alu_ctrl,
  output reg is_branch,
  output reg [4:0]src_register_addr,
  output reg [4:0]dst_register_addr,
  output reg [4:0]r_register_addr,
  output reg [15:0]immediate,
  output reg [4:0]shift_amt
);
  always @(*) begin
    register_write_data_source = 0;
    register_write_address_source = 0;
    register_write_enable = 0;
    data_mem_write_enable = 0;
    alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__IMMEDIATE;
    alu_ctrl = 0;
    is_branch = 0;

  // decode the instruction to get operands
    src_register_addr = instruction[25:21]; // read register from instruction to register file
    dst_register_addr = instruction[20:16]; // write register from instruction to register file
    r_register_addr = instruction[15:11]; // only for R-format instructions
    immediate = instruction[15:0];
    shift_amt = instruction[10:6]; // only for shift instructions with immediates, e.g. sll, sra

    case (instruction[31:26])
      // R-format
      6'b000000: begin
        alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2;
        register_write_enable = 1;
        register_write_address_source = 1;

        case (instruction[5:0])
          // add
          6'b100000: alu_ctrl = 3'b010;
          // and
          6'b100100: alu_ctrl = 3'b000;
          // or
          6'b100101: alu_ctrl = 3'b001;
          // sub
          6'b100010: alu_ctrl = 3'b110;
          // sll
          6'b000000: begin
            src_register_addr = instruction[20:16];
            dst_register_addr = instruction[15:11];
            alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__SHIFT_IMMEDIATE;
            alu_ctrl = 3'b011;
          end
        endcase
      end

      // lw
      6'b100011: begin
        register_write_data_source = 1;
        register_write_enable = 1;
      end

      // sw
      6'b101011: begin
        data_mem_write_enable = 1;
      end

      // addi
      6'b001000: begin
        register_write_enable = 1;
        alu_ctrl = 3'b010;
      end

      // andi
      6'b001100: begin
        register_write_enable = 1;
        alu_ctrl = 3'b000;
      end

      // beq
      6'b000100: begin
        alu_ctrl = 3'b110; // subtraction
        alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2;
        is_branch = 1;
      end
    endcase
  end
endmodule
