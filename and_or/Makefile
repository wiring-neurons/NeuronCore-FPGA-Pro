# Define project-specific variables
TOP=or_and
PCF_FILE=pin
BOARD_FREQ=12
CPU_FREQ=20
FPGA_VARIANT=up5k
FPGA_PACKAGE=sg48
VERILOG_FILE= or_and.v

clean:
	rm -rf $(TOP).blif $(TOP).asc $(TOP).bin $(TOP).json $(TOP).timings

run:
	rm -rf $(TOP).blif $(TOP).asc $(TOP).bin $(TOP).json $(TOP).timings

	yosys -DCPU_FREQ=$(CPU_FREQ) -q -p "synth_ice40 -abc9 -device u -dsp -top $(TOP) -json $(TOP).json" $(VERILOG_FILE)
	nextpnr-ice40 --force --json $(TOP).json --pcf $(PCF_FILE).pcf --asc $(TOP).asc --freq $(BOARD_FREQ) --$(FPGA_VARIANT) --package $(FPGA_PACKAGE) --opt-timing
	icetime -p $(PCF_FILE).pcf -P $(FPGA_PACKAGE) -r $(TOP).timings -d $(FPGA_VARIANT) -t $(TOP).asc
	icepack -s $(TOP).asc $(TOP).bin
	
burn:
	sudo make flash	
	
flash:
	iceprog $(TOP).bin

serial:
	sudo python3 /home/neuroncore/NeuronCore-FPGA-Pro/neuroncore_serial.py
