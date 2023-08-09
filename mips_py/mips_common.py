MIPS_OP_CODES = {
  'lw': '100011',
  'sw': '101011',
  'addi': '001000',
  'beq': '000100',

  # all R-type instructions have opcode 0
  'add': '000000',
  'sub': '000000',
  'sll': '000000',
  # 'or': '000000',
}

MIPS_FUNCTION_CODES = {
  'add': '100000',
  'sub': '100010',
  'or': '100101',
  'sll': '000000',
}

MIPS_REGISTERS = {
  't0': '01000',
  't1': '01001',
  't2': '01010',
  't3': '01011',
  't4': '01100',
}

def to_twos_complement(value, bits):
  # Calculate the range based on bits
  max_value = (1 << (bits - 1)) - 1
  min_value = -(1 << (bits - 1))

  # Check if the value is within range
  if value < min_value or value > max_value:
      raise ValueError(f"Value {value} cannot be represented in {bits} bits using two's complement.")

  # If positive or zero, just return the binary representation
  if value >= 0:
      return format(value, f'0{bits}b')

  # If negative, compute the 2's complement
  value = abs(value)
  value = value ^ ((1 << bits) - 1)  # invert all bits
  value += 1  # add 1
  return format(value & ((1 << bits) - 1), f'0{bits}b')  # mask to the desired width and return
