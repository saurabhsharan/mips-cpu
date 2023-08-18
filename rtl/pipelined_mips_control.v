`default_nettype none

`include "constants.vh"

module pipelined_mips_control (
  input wire [31:0] i_instruction,
  output wire [`MIPS_CONTROL_SIGNALS_WIDTH-1:0] o_control_signals
);
  // these are marked `reg` so I can assign to them from an always @(*) block
  reg register_write_data_source;
  reg register_write_address_source;
  reg register_write_enable;
  reg data_mem_write_enable;
  reg [1:0]alu_b_source;
  reg [2:0]alu_ctrl;
  reg is_branch;
  reg is_jump;
  reg [4:0]s_register_addr;
  reg [4:0]d_register_addr;
  reg [4:0]t_register_addr;

  always @(*) begin
    register_write_data_source = 0;
    register_write_address_source = 0;
    register_write_enable = 0;
    data_mem_write_enable = 0;
    alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__IMMEDIATE;
    alu_ctrl = 0;
    is_branch = 0;
    is_jump = 0;

    s_register_addr = i_instruction[25:21]; // read register from instruction to register file
    t_register_addr = i_instruction[20:16]; // write register from instruction to register file
    d_register_addr = i_instruction[15:11]; // only for R-format instructions

    case (i_instruction[31:26])
      // R-format
      6'b000000: begin
        alu_b_source = `MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2;
        register_write_enable = 1;
        register_write_address_source = 1;

        case (i_instruction[5:0])
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
            s_register_addr = i_instruction[20:16];
            d_register_addr = i_instruction[15:11];
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

      // j
      6'b000010: begin
        is_jump = 1;
      end
    endcase
  end

  assign o_control_signals = { is_jump, is_branch, d_register_addr, t_register_addr, s_register_addr, register_write_address_source, register_write_data_source, register_write_enable, data_mem_write_enable, alu_ctrl, alu_b_source };
endmodule
