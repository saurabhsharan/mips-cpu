import random

MIPS_OP_CODES = {
  'lw': '100011',
  'sw': '101011',
  'addi': '001000',
  'add': '000000',
  'sub': '000000',
  # 'or': '000000',
}

MIPS_FUNCTION_CODES = {
  'add': '100000',
  'sub': '100010',
  'or': '100101',
}

MIPS_REGISTERS = {
  't0': '01000',
  't1': '01001',
  't2': '01010',
  't3': '01011',
  't4': '01100'
}

class MipsCPUModel:
  def __init__(self):
    self.registers = {}
    for r in MIPS_REGISTERS:
      self.registers[r] = 0
    self.data_mem = [0] * 256

  def exec_instruction(self, instruction):
    if instruction[0] == 'lw':
      r1, r2 = instruction[1], instruction[2]
      self.registers[r2] = self.data_mem[self.registers[r1]]
    if instruction[0] == 'sw':
      r1, r2 = instruction[1], instruction[2]
      self.data_mem[self.registers[r1]] = self.registers[r2]
    if instruction[0] == 'add':
      r1, r2, r3 = instruction[1], instruction[2], instruction[3]
      self.registers[r3] = self.registers[r1] + self.registers[r2]
    if instruction[0] == 'sub':
      r1, r2, r3 = instruction[1], instruction[2], instruction[3]
      self.registers[r3] = self.registers[r1] - self.registers[r2]
    if instruction[0] == 'addi':
      r1, r2, immed = instruction[1], instruction[2], instruction[3]
      self.registers[r2] = self.registers[r1] + immed

  @classmethod
  def encode_instruction(cls, instruction):
    op = instruction[0]
    if op in ['lw', 'sw']:
      r1, r2 = instruction[1], instruction[2]
      return MIPS_OP_CODES[op] + MIPS_REGISTERS[r1] + MIPS_REGISTERS[r2] + ('0' * 16)
    if op == 'addi':
      r1, r2, immed = instruction[1], instruction[2], instruction[3]
      return MIPS_OP_CODES[op] + MIPS_REGISTERS[r1] + MIPS_REGISTERS[r2] + '{0:016b}'.format(immed)
    if op in ['add', 'sub', 'or']:
      r1, r2, r3 = instruction[1], instruction[2], instruction[3]
      return MIPS_OP_CODES[op] + MIPS_REGISTERS[r1] + MIPS_REGISTERS[r2] + MIPS_REGISTERS[r3] + '00000' + MIPS_FUNCTION_CODES[op]

  @classmethod
  def generate_random_instruction(cls):
    op = random.choice(list(MIPS_OP_CODES.keys()))
    r1 = random.choice(list(MIPS_REGISTERS.keys()))
    r2 = random.choice(list(MIPS_REGISTERS.keys()))
    r3 = random.choice(list(MIPS_REGISTERS.keys()))
    immed = random.randint(0, 10)
    if op in ['lw', 'sw']:
      return [op, r1, r2]
    if op == 'addi':
      return [op, r1, r2, immed]
    if op in ['add', 'sub', 'or']:
      return [op, r1, r2, r3]

  @classmethod
  def is_trivial(cls, instructions):
    model = cls()
    for instr in instructions:
      model.exec_instruction(instr)
    for v in model.registers.values():
      if v != 0:
        return False
    for v in model.data_mem:
      if v != 0:
        return False
    return True

