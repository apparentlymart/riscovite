
# Target configuration
BOARD=beaglewire

# Build, test, and upload tools
YOSYS=yosys
NEXTPNR=nextpnr-ice40
ICEPACK=icepack
ICETIME=icetime
ICEPROG=iceprog
IVERILOG=iverilog
VVP=vvp

# Derived settings
PCF=boards/$(BOARD).pcf
TOP_V=boards/$(BOARD).v
NEXTPNR_PREPACK_PY=boards/$(BOARD).nextpnr-prepack.py
CORE_V=$(shell find core -name "*.v")
TESTBENCH_V=$(shell find test -name "*_tb.v")
BIN_FILE=build/$(BOARD).bin
TIMING_REPORT_FILE=build/$(BOARD).timing.txt
BLIF_FILE=build/$(BOARD).blif
JSON_FILE=build/$(BOARD).json
ASC_FILE=build/$(BOARD).asc
YOSYS_LOG_FILE=build/$(BOARD).log
TESTBENCH_EXE=$(patsubst test/%_tb.v,build/%_tb,$(TESTBENCH_V))
TESTBENCH_VCD=$(patsubst test/%_tb.v,build/%_tb.vcd,$(TESTBENCH_V))
SCHEMATIC_FILE=build/$(BOARD).dot
SCHEMATIC_IMAGE_FILE=build/$(BOARD).png

include boards/$(BOARD).mk

all: $(BIN_FILE) $(TIMING_REPORT_FILE)

$(BLIF_FILE): $(TOP_V) $(CORE_V)
	$(YOSYS) -ql $@.log -p 'synth_ice40 -top top -blif $@' $^

$(JSON_FILE): $(TOP_V) $(CORE_V)
	$(YOSYS) -ql $@.log -p 'synth_ice40 -top top -json $@' $^

$(SCHEMATIC_FILE): $(CORE_V)
	$(YOSYS) -ql $@.log -p 'hierarchy -check -top main; proc; flatten; opt; show -prefix $(patsubst %.dot,%,$@) -format dot' $^

$(SCHEMATIC_IMAGE_FILE): $(SCHEMATIC_FILE)
	dot -Tpng -o$@ $<

$(ASC_FILE): $(PCF) $(JSON_FILE) $(NEXTPNR_PREPACK_PY)
	$(NEXTPNR) --$(DEVICE) $(if $(PACKAGE),--package $(PACKAGE)) $(if $(FREQ),--freq $(FREQ)) --pre-pack=$(NEXTPNR_PREPACK_PY) --json $(JSON_FILE) --pcf $(PCF) --asc $@

$(BIN_FILE): $(ASC_FILE)
	$(ICEPACK) $< $@

$(TIMING_REPORT_FILE): $(ASC_FILE)
	$(ICETIME) $(if $(FREQ),-c $(FREQ)) -d $(DEVICE) -mtr $@ $<

build/%_tb: test/%_tb.v $(CORE_V)
	$(IVERILOG) -g2005 -D 'DUMP_FILENAME="$@.vcd"' -I core -o $@ $<

build/%_tb.vcd: build/%_tb
	vvp -N $< +vcd=$@

bin: $(BIN_FILE)

timing: $(TIMING_REPORT_FILE)

test: $(TESTBENCH_VCD)

schematic: $(SCHEMATIC_IMAGE_FILE)

program: $(BIN_FILE)
	$(ICEPROG) $<

gtkwave: build/$(TESTBENCH)_tb.vcd
	gtkwave build/$(TESTBENCH)_tb.vcd test/$(TESTBENCH)_tb.gtkw

settings:
	@echo Core Modules: $(CORE_V)
	@echo Board-specific Top Module: $(TOP_V)
	@echo Board-specific Constraints File: $(PCF)

clean:
	rm -f build/$(BOARD).* build/*_tb build/*_tb.vcd

.PHONY: all bin clean gtkwave program schematic settings test timing
