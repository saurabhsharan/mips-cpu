`default_nettype none

module control (
  input wire [31:0]instruction,
  // these are marked `reg` so I can assign to them from an always @(*) block
  output reg register_write_data_source,
  output reg register_write_address_source,
  output reg register_write_enable,
  output reg data_mem_write_enable,
  output reg alu_b_source,
  output reg [2:0]alu_ctrl,
  output reg is_branch
);
  always @(*) begin
    register_write_data_source = 0;
    register_write_address_source = 0;
    register_write_enable = 0;
    data_mem_write_enable = 0;
    alu_b_source = 0;
    alu_ctrl = 0;
    is_branch = 0;

    case (instruction[31:26])
      // R-format
      6'b000000: begin
        alu_b_source = 1;
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
        alu_b_source = 1;
        is_branch = 1;
      end
    endcase
  end
endmodule