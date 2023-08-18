`default_nettype none

`include "constants.vh"

module pipelined_cpu(
  input wire clk, 
  input wire clk_enable,
  input wire [31:0] i_mem_read_data,
  output wire [7:0] o_mem_read_address,
  output wire [7:0] o_mem_write_address,
  output wire [31:0] o_mem_write_data,
  output wire o_mem_write_enable,
  output wire [7:0] pc_out
);
  // Main CPU program counter
  reg [7:0]pc;
  reg r_pc_valid;
  initial begin
    pc = 0;
    r_pc_valid = 1;
  end

  // Wires that cross between stages:
  // Wires to carry register write data between stage 5 and stage 2
  wire w_register_write_enable;
  wire [`REGISTER_WIDTH-1:0] w_register_write_data;
  wire [`REGISTER_ADDR_WIDTH-1:0] w_register_write_addr;



  // Stage 1: Instruction Fetch

  // Define output registers for this stage
  reg [31:0] r_instruction_q1;
  reg r_q1_valid;
  initial begin
    r_instruction_q1 = 0;
    r_q1_valid = 0;
  end

  // Perform (asynchronous) instruction fetch from instruction memory
  wire [31:0] w_imem_instruction;
  inst_mem imem(.i_address(pc), .instruction(w_imem_instruction));

  // Write to pipeline stage output registers
  always @(posedge clk) begin
    if (clk_enable) begin
      if (r_pc_valid) begin
        r_instruction_q1 <= w_imem_instruction;
        // Note how r_q1_valid is effectively a shift register following r_pc_valid, which makes sense since r_pc_valid tells us whether the current program counter *input* is valid, which then needs to be forwarded so the next stage knows the instruction *output* is valid
        r_q1_valid <= 1;
        r_pc_valid <= 0;
      end else if (r_q4_valid) begin
        r_q1_valid <= 0;
        r_pc_valid <= 1;
        pc <= pc + 4;
      end else begin
        r_pc_valid <= 0;
        r_q1_valid <= 0;
      end
    end
  end



  // Stage 2: Instruction Decode + Register File

  // Define output registers for this stage
  reg r_q2_valid;
  reg [`REGISTER_WIDTH-1:0] r_reg1_readout_q2;
  reg [`REGISTER_WIDTH-1:0] r_reg2_readout_q2;
  reg [15:0] r_immediate_q2;
  reg [(`MIPS_CONTROL_SIGNALS_WIDTH-1):0] r_control_signals_q2;
  initial begin
    r_q2_valid = 0;
  end

  // Extract/decode control signals from instruction
  wire [`MIPS_CONTROL_SIGNALS_WIDTH-1:0] w_control_signals;
  pipelined_mips_control mips_ctrl(.i_instruction(r_instruction_q1), 
                                   .o_control_signals(w_control_signals));

  // Perform register read
  // TODO: change this to just `assign` and infer the wire width
  wire [`REGISTER_ADDR_WIDTH-1:0] w_s_reg_addr = w_control_signals[`MIPS_CONTROL_SIGNALS_S_REGISTER_ADDR_BITS];
  wire [`REGISTER_ADDR_WIDTH-1:0] w_t_reg_addr = w_control_signals[`MIPS_CONTROL_SIGNALS_T_REGISTER_ADDR_BITS];
  wire [31:0] w_reg1_readout;
  wire [31:0] w_reg2_readout;
  // Note that we can't just decide whether to enable/disable the entire register file based on r_q1_valid since the 5th stage might be writing to register file even if no read from immediate previous stage output
  registers regs(.clk(clk), .clk_enable(clk_enable),
                 .r_address1(w_s_reg_addr), .r_address2(w_t_reg_addr),
                 .w_address(w_register_write_addr), .w_data(w_register_write_data), .w_enable(w_register_write_enable),
                 .o_data1(w_reg1_readout), .o_data2(w_reg2_readout));

  // Write to pipeline stage output registers
  always @(posedge clk) begin
    if (clk_enable) begin
      if (r_q1_valid) begin
        r_reg1_readout_q2 <= w_reg1_readout;
        r_reg2_readout_q2 <= w_reg2_readout;
        r_immediate_q2 <= r_instruction_q1[15:0];
        r_control_signals_q2 <= w_control_signals;
      end

      r_q2_valid <= r_q1_valid;
    end
  end



  // Stage 3: Execution

  // Define output registers for this stage
  reg r_q3_valid;
  reg [31:0] r_alu_result_q3;
  reg [(`MIPS_CONTROL_SIGNALS_WIDTH-1):0] r_control_signals_q3;
  reg [`REGISTER_WIDTH-1:0] r_reg1_readout_q3;
  reg [`REGISTER_WIDTH-1:0] r_reg2_readout_q3;

  // Extract control signals
  wire [1:0] w_alu_b_source = r_control_signals_q2[`MIPS_CONTROL_SIGNALS_ALU_B_SOURCE_BITS];
  wire [2:0] w_alu_ctrl = r_control_signals_q2[`MIPS_CONTROL_SIGNALS_ALU_CTRL_BITS];

  // Use control signals to determine alu b input
  reg [31:0] r_alu_b_input;
  always @(*) begin
    case (w_alu_b_source)
      `MIPS_CONTROL_ALU_B_SOURCE__IMMEDIATE: r_alu_b_input = r_immediate_q2;
      `MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2: r_alu_b_input = r_reg2_readout_q2;
      `MIPS_CONTROL_ALU_B_SOURCE__SHIFT_IMMEDIATE: r_alu_b_input = r_immediate_q2;
      default: r_alu_b_input = r_immediate_q2;
    endcase
  end

  // Perform ALU operation
  wire [31:0] w_alu_result;
  alu alu(.a(r_reg1_readout_q2), .b(r_alu_b_input), .ctrl(w_alu_ctrl), .result(w_alu_result));

  // Write to pipeline stage output registers
  always @(posedge clk) begin
    if (clk_enable) begin
      if (r_q2_valid) begin
        r_alu_result_q3 <= w_alu_result;

        // Copy previous signals/register data
        r_control_signals_q3 <= r_control_signals_q2;
        r_reg1_readout_q3 <= r_reg1_readout_q2;
        r_reg2_readout_q3 <= r_reg2_readout_q2;
      end

      r_q3_valid <= r_q2_valid;
    end
  end



  // Stage 4: Memory

  // Define output registers for this stage
  reg r_q4_valid;
  reg [(`MIPS_CONTROL_SIGNALS_WIDTH-1):0] r_control_signals_q4;
  reg [31:0] r_alu_result_q4;
  reg r_data_mem_readout_q4;
  reg [`REGISTER_WIDTH-1:0] r_reg1_readout_q4;
  reg [`REGISTER_WIDTH-1:0] r_reg2_readout_q4;
  initial begin
    r_q4_valid = 0;
  end

  // Assign correct values to external data memory pins
  assign o_mem_read_address = r_reg1_readout_q3;
  assign o_mem_write_address = r_reg1_readout_q3;
  assign o_mem_write_data = r_reg2_readout_q3;
  assign o_mem_write_enable = r_control_signals_q3[`MIPS_CONTROL_SIGNALS_DATA_MEM_WRITE_ENABLE_BITS] && r_q3_valid;

  // Write to pipeline stage output registers
  always @(posedge clk) begin
    if (clk_enable) begin
      if (r_q3_valid) begin
        r_data_mem_readout_q4 <= i_mem_read_data;

        r_control_signals_q4 <= r_control_signals_q3;
        r_alu_result_q4 <= r_alu_result_q3;

        r_reg1_readout_q4 <= r_reg1_readout_q3;
        r_reg2_readout_q4 <= r_reg2_readout_q3;
      end

      r_q4_valid <= r_q3_valid;
    end
  end



  // Stage 5: Register Write

  // No output registers for this stage

  // Extract control signals and assign correct values to register write ports
  assign w_register_write_enable = r_q4_valid && r_control_signals_q4[`MIPS_CONTROL_SIGNALS_REGISTER_WRITE_ENABLE_BITS];

  wire w_register_write_data_source = r_control_signals_q4[`MIPS_CONTROL_SIGNALS_REGISTER_WRITE_DATA_SOURCE_BITS];
  assign w_register_write_data = w_register_write_data_source ? r_data_mem_readout_q4 : r_alu_result_q4;

  wire w_register_write_address_source = r_control_signals_q4[`MIPS_CONTROL_SIGNALS_REGISTER_WRITE_ADDRESS_SOURCE_BITS];
  assign w_register_write_addr = w_register_write_address_source ? r_control_signals_q4[`MIPS_CONTROL_SIGNALS_D_REGISTER_ADDR_BITS] : r_control_signals_q4[`MIPS_CONTROL_SIGNALS_T_REGISTER_ADDR_BITS];
endmodule
