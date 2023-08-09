To run cocotb tests: \
`cd mips_py && make -f Makefile.cocotb`

To run testbench: \
`cd test` \
`iverilog -o alu_tb ../rtl/alu.v alu_tb.v` \
`vvp alu_tb`

To view high-level CPU wiring, start interactive `yosys` session: \
`read_verilog rtl/*.v` \
`hierarchy -check -top cpu` \
`cd cpu` \
`show -stretch -colors 3` \
Then convert .dot to .pdf (outside of yosys session): \
`dot -Tpdf ~/.yosys_show.dot -o cpu.pdf`

To get timing information: \
`yosys -ql cpu-icefpga.yslog -p 'synth_ice40 -top cpu -json cpu-icefpga.json' rtl/*.v` \
`nextpnr-ice40 -ql cpu-icefpga.nplog --pcf-allow-unconstrained --up5k --package sg48 --freq 12 --asc cpu-icefpga.asc --pcf icebreaker.pcf --json cpu-icefpga.json` \
`icetime -d up5k -c 12 -mtr cpu-icefpga.rpt cpu-icefpga.asc`
