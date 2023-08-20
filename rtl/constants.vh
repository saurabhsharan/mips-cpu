`ifndef _constants_vh_
`define _constants_vh_

// Note that the REGISTER_WIDTH is also assumed to be same as width for ALU inputs and outputs
`define REGISTER_WIDTH 32
`define REGISTER_WIDTH_RANGE = 31:0

`define REGISTER_ADDR_WIDTH 5
`define REGISTER_ADDR_WIDTH_RANGE = 4:0

`define MEM_WORD_WIDTH 32

`define MEM_ADDR_WIDTH 8

`define INSTRUCTION_WIDTH 32

`define MIPS_CONTROL_ALU_B_SOURCE__IMMEDIATE 2'b00
`define MIPS_CONTROL_ALU_B_SOURCE__REGISTER_OUTPUT_2 2'b01
`define MIPS_CONTROL_ALU_B_SOURCE__SHIFT_IMMEDIATE 2'b10

`define MIPS_CONTROL_REGISTER_WRITE_ADDRESS_SOURCE__D_REG 1
`define MIPS_CONTROL_REGISTER_WRITE_ADDRESS_SOURCE__T_REG 0

// Control signal format:
//   [25] = is_jump
//   [24] = is_branch
//   [23:19] = d_register_addr (only for R-format instructions)
//   [18:14] = t_register_addr
//   [13:9] = s_register_addr
//   [8] = register_write_address_source
//   [7] = register_write_data_source
//   [6] = register_write_enable
//   [5] = data_mem_write_enable
//   [4:2] = alu_ctrl;
//   [1:0] = alu_b_source;
`define MIPS_CONTROL_SIGNALS_WIDTH 26

`define MIPS_CONTROL_SIGNALS_ALU_B_SOURCE_BITS 1:0
`define MIPS_CONTROL_SIGNALS_ALU_CTRL_BITS 4:2
`define MIPS_CONTROL_SIGNALS_DATA_MEM_WRITE_ENABLE_BITS 5
`define MIPS_CONTROL_SIGNALS_REGISTER_WRITE_ENABLE_BITS 6
`define MIPS_CONTROL_SIGNALS_REGISTER_WRITE_DATA_SOURCE_BITS 7
`define MIPS_CONTROL_SIGNALS_REGISTER_WRITE_ADDRESS_SOURCE_BITS 8
`define MIPS_CONTROL_SIGNALS_S_REGISTER_ADDR_BITS 13:9
`define MIPS_CONTROL_SIGNALS_T_REGISTER_ADDR_BITS 18:14
`define MIPS_CONTROL_SIGNALS_D_REGISTER_ADDR_BITS 23:19
`define MIPS_CONTROL_SIGNALS_IS_BRANCH_BITS 24
`define MIPS_CONTROL_SIGNALS_IS_JUMP_BITS 25

`endif // _constants_vh_
