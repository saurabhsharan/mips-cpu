from mips_common import MIPS_OP_CODES, MIPS_REGISTERS

class MIPSAssembler:
  def __init__(self):
    self.instruction_set = {
      "addi": self.addi,
      "sw": self.sw,
      "beq": self.beq,
      # Add more instruction handlers here
    }

  def addi(self, instruction):
    opcode = MIPS_OP_CODES['addi']
    # rs = format(int(instruction[1][1:]), '05b')  # source register
    # rt = format(int(instruction[2][1:]), '05b')  # target register
    rs = MIPS_REGISTERS[instruction[1][1:]]
    rt = MIPS_REGISTERS[instruction[2][1:]]
    immediate = format(int(instruction[3]), '016b')
    return opcode + rs + rt + immediate

  def parse_offset_base(self, offset_base_str):
    offset_base = offset_base_str.split('(')
    offset = format(int(offset_base[0]) & 0xFFFF, '016b')
    base = format(int(offset_base[1][1:-1]), '05b')
    return offset, base

  def sw(self, instruction):
    opcode = MIPS_OP_CODES['sw']
    rt = MIPS_REGISTERS[instruction[1][1:]]
    offset, base = self.parse_offset_base(instruction[2])
    return opcode + base + rt + offset

  def beq(self, instruction):
    opcode = MIPS_OP_CODES['beq']
    rs = MIPS_REGISTERS[instruction[1][1:]]
    rt = MIPS_REGISTERS[instruction[2][1:]]
    offset = format(int(instruction[3]) & 0xFFFF, '016b')
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

