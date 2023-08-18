PROJ = icetop

RTL_DIR := $(PWD)/rtl

VERILOG_SOURCES += $(RTL_DIR)/registers.v $(RTL_DIR)/single_cycle_cpu.v $(RTL_DIR)/pipelined_cpu.v $(RTL_DIR)/alu.v $(RTL_DIR)/ice_mem.v $(RTL_DIR)/inst_mem.v $(RTL_DIR)/single_cycle_mips_control.v $(RTL_DIR)/pipelined_mips_control.v $(RTL_DIR)/ice_top.v $(RTL_DIR)/clock_div.v

all: $(PROJ).rpt $(PROJ).bin

$(PROJ).json: $(VERILOG_SOURCES) i1.mem
	yosys -ql $(PROJ).yslog -p 'synth_ice40 -top icetop -json $@' $(VERILOG_SOURCES)

$(PROJ).asc: $(PROJ).json icebreaker.pcf
	nextpnr-ice40 -ql $(PROJ).nplog --up5k --package sg48 --freq 12 --asc $@ --pcf icebreaker.pcf --json $<

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

$(PROJ).rpt: $(PROJ).asc
	icetime -d up5k -c 12 -mtr $@ $<

$(PROJ)_tb: $(PROJ)_tb.v $(PROJ).v
	iverilog -o $@ $^

$(PROJ)_tb.vcd: $(PROJ)_tb
	vvp -N $< +vcd=$@

$(PROJ)_syn.v: $(PROJ).json
	yosys -p 'read_json $^; write_verilog $@'

$(PROJ)_syntb: $(PROJ)_tb.v $(PROJ)_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

$(PROJ)_syntb.vcd: $(PROJ)_syntb
	vvp -N $< +vcd=$@

i1.mem: mips_py/basic_mips.s
	cd mips_py && python3 mips_assembler.py
	cp mips_py/output.txt i1.mem

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).yslog $(PROJ).nplog $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin
	rm -f $(PROJ)_tb $(PROJ)_tb.vcd $(PROJ)_syn.v $(PROJ)_syntb $(PROJ)_syntb.vcd
	rm -f i1.mem

.SECONDARY:
.PHONY: all prog clean
