SIM ?= icarus
TOPLEVEL_LANG ?= verilog
RTL_DIR := $(PWD)/../rtl

VERILOG_SOURCES += $(RTL_DIR)/registers.v $(RTL_DIR)/cpu.v $(RTL_DIR)/alu.v $(RTL_DIR)/data_mem.v $(RTL_DIR)/inst_mem.v $(RTL_DIR)/control.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = cpu

# MODULE is the basename of the Python test file
MODULE = test_cpu

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

