import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

import fuzz
from mips_assembler import MIPSAssembler

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
  'zero': 0,
  't0': 8,
  't1': 9,
  't2': 10,
  't3': 11,
  't4': 12,
}

@cocotb.test()
async def pipelined_cpu_basic_test(dut):
  assembler = MIPSAssembler()
  instructions = assembler.assemble([
    ['addi', '$t0', '$t0', '1'],
    ['addi', '$t0', '$t0', '2'],
    ['add', '$t1', '$t0', '$t0'],
    ['sub', '$t2', '$t0', '$t1'],
  ])
  await Timer(1)
  await load_program(dut, instructions)

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t0']].signed_integer == 1
  assert dut.cpu.pc.value == 4

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t0']].signed_integer == 3
  assert dut.cpu.pc.value == 8

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t0']].signed_integer == 3
  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t1']].signed_integer == 6

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t0']].signed_integer == 3
  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t1']].signed_integer == 6
  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t2']].signed_integer == -3

@cocotb.test()
async def pipelined_cpu_jump_test(dut):
  assembler = MIPSAssembler()
  instructions = assembler.assemble([
    ['addi', '$t0', '$t0', '1'],
    ['addi', '$t0', '$t0', '2'],
    ['j', '1'],
  ])
  await Timer(1)
  await load_program(dut, instructions)

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.pc.value == 4

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.pc.value == 8

  await tick(dut) # execute stage 1

  assert dut.cpu.r_q1_valid.value == 1
  assert dut.cpu.is_jump.value == 1

  await tick(dut) # execute stage 2

  assert dut.cpu.pc.value == 4

  await tick(dut) # execute stage 1
  await tick(dut) # execute stage 2
  await tick(dut) # execute stage 3
  await tick(dut) # execute stage 4
  await tick(dut) # execute stage 5

  assert dut.cpu.regs.data.value[REGISTER_INDEXES['t0']] == 5
