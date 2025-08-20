DEVICE = up5k
PACKAGE = sg48
TOP = OLED
PCF_FILE = constraints.pcf
VERILOG_FILES = OLED.v I2C.v

YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack

all: $(TOP).bin

$(TOP).json: $(VERILOG_FILES)
	$(YOSYS) -p "read_verilog $(VERILOG_FILES); synth_ice40 -abc9 -device u -top $(TOP) -json $@"

$(TOP).asc: $(TOP).json $(PCF_FILE)
	$(NEXTPNR) --force --json $< --pcf $(PCF_FILE) --asc $@ \
	--$(DEVICE) --package $(PACKAGE) --opt-timing -q

$(TOP).bin: $(TOP).asc
	$(ICEPACK) $< $@

flash: $(TOP).bin
	iceprog $<

clean:
	rm -f *.json *.asc *.bin *.timings

.PHONY: all flash clean
