import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

import fuzz

async def tick(dut):
  await Timer(1)
  dut.clk.value = 0
  await Timer(1)
  dut.clk.value = 1
  await Timer(1)

async def load_program(dut, instrs):
  # Reset all state
  dut.cpu.pc.value = 0
  for i in range(256):
    dut.dmem.data[i].value = 0
    dut.cpu.imem.data[i].value = 0
  for i in range(32):
    dut.cpu.regs.data[i].value = 0

  # Load program
  for i in range(len(instrs)):
    instr_str = instrs[i].replace("_", "")
    b1, b2, b3, b4 = BinaryValue(), BinaryValue(), BinaryValue(), BinaryValue()
    # use little-endian format (same as Apple and DD&CA2e)
    b1.binstr = instr_str[-8:]
    b2.binstr = instr_str[-16:-8]
    b3.binstr = instr_str[-24:-16]
    b4.binstr = instr_str[-32:-24]
    dut.cpu.imem.data[(4*i)].value = b1.integer
    dut.cpu.imem.data[(4*i)+1].value = b2.integer
    dut.cpu.imem.data[(4*i)+2].value = b3.integer
    dut.cpu.imem.data[(4*i)+3].value = b4.integer

  # Commit all writes
  await Timer(1)

REGISTER_INDEXES = {
  't0': 8,
  't1': 9,
  't2': 10,
  't3': 11,
  't4': 12,
}

# @cocotb.test()
# async def fuzz_debug_test(dut):
#   instrs = [['lw', 't2', 't4'], ['addi', 't3', 't3', 10], ['sw', 't1', 't3'], ['lw', 't1', 't3'], ['lw', 't3', 't2']]
#   encoded_instrs = [fuzz.encode_instruction(i) for i in instrs]
#   model = fuzz.CPUModel()
#   await Timer(1)
#   await load_program(dut, encoded_instrs)
#   for i in range(len(instrs)):
#     print(instrs[i])
#     print(encoded_instrs[i])
#     model.exec_instruction(instrs[i])
#     await tick(dut)
#     for ri in REGISTER_INDEXES:
#       assert dut.regs.data.value[REGISTER_INDEXES[ri]] == model.registers[ri], 'assertion failed for ' + ri
#   # print(model.registers)
#   for ri in REGISTER_INDEXES:
#     assert dut.regs.data.value[REGISTER_INDEXES[ri]] == model.registers[ri], 'assertion failed for ' + ri

@cocotb.test()
async def fuzz_test(dut):
  count = 0
  cpu_model_cls = fuzz.MipsCPUModel
  while count < 10:
    instrs = []
    for i in range(10):
      instrs.append(cpu_model_cls.generate_random_instruction())
    if cpu_model_cls.is_trivial(instrs):
      continue
    encoded_instrs = [cpu_model_cls.encode_instruction(i) for i in instrs]
    # print(instrs)
    model = cpu_model_cls()
    await Timer(1)
    await load_program(dut, encoded_instrs)
    for i in range(len(instrs)):
      model.exec_instruction(instrs[i])
      await tick(dut)
    for ri in REGISTER_INDEXES:
      assert dut.cpu.regs.data.value[REGISTER_INDEXES[ri]].signed_integer == model.registers[ri]
    count += 1

@cocotb.test()
async def cpu_beq_test(dut):
  instrs = [
            "001000_01000_01000_0000000000000001", # addi $t0, $t0, 1
            "000100_01000_01001_1111111111111110", # beq $t0, $t1, -2   this should always be skipped
            "000100_01001_01001_1111111111111101", # beq $t1, $t1, -3
            # "000000_01000_01001_01010_00000_100101", # or $t2, $t1, $t0
           ]
  await Timer(1)
  await load_program(dut, instrs)
  await tick(dut) # first addi
  await tick(dut) # skipped beq
  await tick(dut) # beq
  await tick(dut) # second addi
  await tick(dut) # skipped beq
  await tick(dut) # beq
  await tick(dut) # third addi
  assert dut.cpu.regs.data.value[8] == 3

@cocotb.test()
async def cpu_basic_test3(dut):
  instrs = [
            "001000_01000_01000_0000000000000001", # addi $t0, $t0, 1
            "001000_01001_01001_0000000000000010", # addi $t1, $t1, 2
            "000000_01001_01000_01010_00000_100010", # sub $t2, $t1, $t0 d = s - t    t2 = t1 - t0
           ]
  await Timer(1)
  await load_program(dut, instrs)
  for _ in range(len(instrs)):
    await tick(dut)
  assert dut.cpu.regs.data.value[10] == 1

@cocotb.test()
async def cpu_basic_test2(dut):
  instrs = [
            "001000_01000_01000_0000000000000001", # addi $t0, $t0, 1
            "100011_01000_01001_0000000000000000", # lw $t1, $t0
            "001000_01001_01001_0000000000000011", # addi $t1, $t1, 3
            "101011_01000_01001_0000000000000000", # sw $t1, t0
            "001000_01001_01001_0000000000000100", # addi $t1, $t1, 4
            "000000_01000_01001_01010_00000_100000", # add $t2, $t0, $t1
           ]
  await Timer(1)
  await load_program(dut, instrs)
  for _ in range(len(instrs)):
    await tick(dut)
  assert dut.dmem.data.value[1] == 3
  assert dut.cpu.regs.data.value[8] == 1
  assert dut.cpu.regs.data.value[9] == 7
  assert dut.cpu.regs.data.value[10] == 8

@cocotb.test()
async def cpu_basic_test(dut):
  instrs = ["100011_01000_01001_0000000000000000", # lw $t1, $t0
            "001000_01001_01001_0000000000000011", # addi $t1, $t1, 3
            "101011_01000_01001_0000000000000000"] # sw $t1, t0
  await Timer(1)
  await load_program(dut, instrs)

  assert dut.cpu.s_register_addr.value == 8, "Expected 5, got %r" % dut.s_register_addr.value
  await tick(dut) # execute lw

  assert dut.cpu.pc.value == 4
  assert dut.cpu.s_register_addr.value == 9
  assert dut.cpu.register_read_out1.value == 0
  assert dut.cpu.immediate.value == 3
  assert dut.cpu.alu_result.value == 3
  assert dut.cpu.t_register_addr.value == 9
  assert dut.cpu.register_write_data_source.value == 0
  assert dut.cpu.register_write_data.value == 3
  assert dut.cpu.register_write_enable.value == 1
  await tick(dut) # execute addi
  assert dut.cpu.regs.data.value[9] == 3

  await tick(dut) # execute sw
  assert dut.dmem.data.value[0] == 3
