import random

OP_CODES = {
  'lw': '100011',
  'sw': '101011',
  'addi': '001000',
  'add': '000000',
  # 'or': '000000',
}
REGISTERS = {
  't0': '01000',
  't1': '01001',
  't2': '01010',
  't3': '01011',
  't4': '01100'
}

class CPUModel:
  def __init__(self):
    self.registers = {}
    for r in REGISTERS:
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
    if instruction[0] == 'addi':
      r1, r2, immed = instruction[1], instruction[2], instruction[3]
      self.registers[r2] = self.registers[r1] + immed

def encode_instruction(instruction):
  op = instruction[0]
  if op in ['lw', 'sw']:
    r1, r2 = instruction[1], instruction[2]
    return OP_CODES[op] + REGISTERS[r1] + REGISTERS[r2] + ('0' * 16)
  if op == 'addi':
    r1, r2, immed = instruction[1], instruction[2], instruction[3]
    return OP_CODES[op] + REGISTERS[r1] + REGISTERS[r2] + '{0:016b}'.format(immed)
  if op == 'add':
    r1, r2, r3 = instruction[1], instruction[2], instruction[3]
    return OP_CODES[op] + REGISTERS[r1] + REGISTERS[r2] + REGISTERS[r3] + '00000' + '100000'

def generate_random_instruction():
  op = random.choice(list(OP_CODES.keys()))
  r1 = random.choice(list(REGISTERS.keys()))
  r2 = random.choice(list(REGISTERS.keys()))
  r3 = random.choice(list(REGISTERS.keys()))
  immed = random.randint(0, 10)
  if op in ['lw', 'sw']:
    return [op, r1, r2]
  if op == 'addi':
    return [op, r1, r2, immed]
  if op == 'add':
    return [op, r1, r2, r3]
  elif op == 'or':
    return [op, r1, r2, r3]
    return OP_CODES[op] + REGISTERS[r1] + REGISTERS[r2] + REGISTERS[r3] + '00000' + '100101'

def is_trivial(instructions):
  model = CPUModel()
  for instr in instructions:
    model.exec_instruction(instr)
  for v in model.registers.values():
    if v != 0:
      return False
  for v in model.data_mem:
    if v != 0:
      return False
  return True

# model = CPUModel()
# for i in range(5):
#   i1 = generate_random_instruction()
#   print(i1)
#   print(encode_instruction(i1))
#   model.exec_instruction(i1)
# print(model.registers)
# print(model.data_mem)