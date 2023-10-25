base_dir=$(abspath ./)

CHISEL_VERSION=3.6.0
MODEL ?= TestHarness
PROJECT ?= freechips.rocketchip.system
CFG_PROJECT ?= $(PROJECT)
CONFIG ?= $(CFG_PROJECT).DefaultConfig
MILL ?= mill

verilog:
	cd $(base_dir) && $(MILL) emulator[freechips.rocketchip.system.TestHarness,$(CONFIG)].mfccompiler.compile

idea:
	mill -i mill.idea.GenIdea/idea

bsp:
	mill mill.bsp.BSP/install

clean:
	rm -rf out/
