import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def registers_initialize_test(dut):
  # Verify that all 32 registers are initialized to 0
  await Timer(1)
  for i in range(32):
    assert dut.data.value[i] == 0

@cocotb.test()
async def registers_basic_read_write(dut):
  await Timer(1)

  # Write 5 to register 3
  dut.w_address.value = 3
  dut.w_data.value = 5
  dut.w_enable.value = 1
  # Pulse clock to trigger write
  dut.clk.value = 0
  await Timer(1)
  dut.clk.value = 1
  await Timer(1)

  # Verify that register 3 has value 5
  dut.r_address.value = 3
  dut.w_enable.value = 0
  await Timer(1)
  assert dut.r_data.value == 5

  # make sure all the other registers are still 0
  for i in range(32):
    if i == 3: continue
    assert dut.data.value[i] == 0, "Register %r had value %r" % (i, dut.data.value[i])
