SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/registers.v $(PWD)/cpu.v $(PWD)/alu.v $(PWD)/data_mem.v $(PWD)/inst_mem.v $(PWD)/control.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = cpu

# MODULE is the basename of the Python test file
MODULE = test_cpu

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

