from mips_common import MIPS_OP_CODES, MIPS_REGISTERS, MIPS_FUNCTION_CODES, to_twos_complement

class MIPSAssembler:
  def __init__(self):
    self.instruction_set = {
      "addi": self.addi,
      "add": self.add,
      "sub": self.sub,
      "sll": self.sll,
      "lw": self.lw,
      "sw": self.sw,
      "beq": self.beq,
    }

  def addi(self, instruction):
    # addi $rt, $rs, imm
    opcode = MIPS_OP_CODES['addi']
    rt = MIPS_REGISTERS[instruction[1][1:]]
    rs = MIPS_REGISTERS[instruction[2][1:]]
    immediate = to_twos_complement(int(instruction[3]), 16)
    return opcode + rs + rt + immediate

  def add(self, instruction):
    # add $rd, $rs, $rt
    opcode = MIPS_OP_CODES['add']
    rd = MIPS_REGISTERS[instruction[1][1:]]
    rs = MIPS_REGISTERS[instruction[2][1:]]
    rt = MIPS_REGISTERS[instruction[3][1:]]
    shamt = '00000'
    funct = MIPS_FUNCTION_CODES['add']
    return opcode + rs + rt + rd + shamt + funct

  def sub(self, instruction):
    # sub $rd, $rs, $rt
    opcode = MIPS_OP_CODES['sub']
    rd = MIPS_REGISTERS[instruction[1][1:]]
    rs = MIPS_REGISTERS[instruction[2][1:]]
    rt = MIPS_REGISTERS[instruction[3][1:]]
    shamt = '00000'
    funct = MIPS_FUNCTION_CODES['sub']
    return opcode + rs + rt + rd + shamt + funct

  def sll(self, instruction):
    # sll $rd, $rt, shamt
    opcode = MIPS_OP_CODES['sll']
    rs = '000000' # always 0 for sll
    rt = MIPS_REGISTERS[instruction[2][1:]]
    rd = MIPS_REGISTERS[instruction[1][1:]]
    # Note that shamt is NOT 2's complement encoded since it can't be negative
    shamt = format(int(instruction[3]) & 0x1F, '05b')
    funct = MIPS_FUNCTION_CODES['sll']
    return opcode + rs + rt + rd + shamt + funct

  def parse_offset_base(self, offset_base_str):
    offset_base = offset_base_str.split('(')
    offset = format(int(offset_base[0]) & 0xFFFF, '016b')
    base = MIPS_REGISTERS[offset_base[1][1:-1]]
    return offset, base

  def lw(self, instruction):
    opcode = MIPS_OP_CODES['lw']
    rt = MIPS_REGISTERS[instruction[1][1:]]
    offset, base = self.parse_offset_base(instruction[2])
    return opcode + base + rt + offset

  def sw(self, instruction):
    opcode = MIPS_OP_CODES['sw']
    rt = MIPS_REGISTERS[instruction[1][1:]]
    offset, base = self.parse_offset_base(instruction[2])
    return opcode + base + rt + offset

  def beq(self, instruction):
    opcode = MIPS_OP_CODES['beq']
    rt = MIPS_REGISTERS[instruction[1][1:]]
    rs = MIPS_REGISTERS[instruction[2][1:]]
    offset = to_twos_complement(int(instruction[3]), 16)
    return opcode + rs + rt + offset

  # Add more instruction encoding functions here
  def assemble(self, instructions):
    binary_output = []
    for instruction in instructions:
      opcode = instruction[0]
      if opcode in self.instruction_set:
        binary_output.append(self.instruction_set[opcode](instruction))
      else:
        print(f"Error: Unsupported instruction {opcode}")
        return None
    return binary_output

  def save_to_file(self, binary_output, filename):
    with open(filename, 'w') as f:
      for line in binary_output:
        words = [line[i:i+8] for i in range(0, len(line), 8)]
        little_endian_word = ' '.join(words[::-1])
        # formatted = ' '.join([line[i:i+8] for i in range(0, len(line), 8)])
        f.write(little_endian_word + ' ')

  def read_from_file(self, filename):
    instructions = []
    with open(filename, 'r') as f:
      lines = f.readlines()
      for line in lines:
        if len(line.strip()) == 0:
          continue
        if line.strip()[0] == '#':
          continue
        instruction = line.strip().replace(',', '').split()
        instructions.append(instruction)
    return instructions


if __name__ == "__main__":
  assembler = MIPSAssembler()

  instructions = assembler.read_from_file('basic_mips.s')
  binary_output = assembler.assemble(instructions)
  assembler.save_to_file(binary_output, "output.txt")

