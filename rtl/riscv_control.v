`default_nettype none

module riscv_control (
  input wire [31:0]instruction,
  // these are marked `reg` so I can assign to them from an always @(*) block
  output reg register_write_data_source,
  output reg register_write_address_source,
  output reg register_write_enable,
  output reg data_mem_write_enable,
  output reg alu_b_source,
  output reg [2:0]alu_ctrl,
  output reg is_branch,
  output reg [4:0]src_register_addr,
  output reg [4:0]dst_register_addr,
  output reg [4:0]r_register_addr,
  output reg [15:0]immediate
);
  wire [6:0] opcode = instruction[0:6];
  wire [2:0] funct3 = instruction[12:14];
  wire [6:0] funct7 = instruction[25:31];

  always @(*) begin
    src_register_addr = instruction[15:19];
    dst_register_addr = instruction[7:11];

    case (opcode)
      7'b0000011: begin
        case (funct3)
          // lw, I-type
          3'b010: begin
          end
        endcase
      end

      7'b0100011: begin
        case (funct3)
          // sw, S-type
          3'b010: begin
          end
        endcase
      end

      7'b0010011: begin
        case (funct3)
          // addi, I-type
          3'b000: begin
          end
        endcase
      end

      7'b0010011: begin
        case (funct7)
          // add, R-type
          7'b0000000: begin
          end

          // sub, R-type
          7'b0100000: begin
          end
        endcase
      end
    endcase
  end
endmodule
