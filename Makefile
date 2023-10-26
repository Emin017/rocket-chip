base_dir=$(abspath ./)

CHISEL_VERSION=3.6.0
MODEL ?= TestHarness
PROJECT ?= freechips.rocketchip.system
CFG_PROJECT ?= $(PROJECT)
CONFIG ?= $(CFG_PROJECT).DefaultConfig
MILL ?= mill

COLOR_RED := $(shell echo "\033[1;31m")
COLOR_END := $(shell echo "\033[0m")

TOPNAME = Rocket
VSRC = $(shell find ./out/emulator/ -name "*.sv")
VSRC += $(shell find ./out/emulator/ -name "*.v")
CSRC = $(shell find ./out/emulator/ -name "*.cc")
CSRC += $(shell find ./sim/ -name "*.cc")

VERILATOR_FLAGS = --cc --exe --build -O2 -trace \
		  --timescale-override 1ns/1ps \
		  --sv --vpi -j 0 --top $(TOPNAME) \
		  --Mdir $(abspath ./build)

# Set the RISCV variable to the path where you install riscv-gnu-toolchain !!!
ifeq ($(wildcard $(RISCV)/include),)
$(error $(COLOR_RED)Set the proper RISCV variable first !!!$(COLOR_END))
else
$(info RISCV variable path : $(abspath $(RISCV)))
endif

INC_PATH = -I$(abspath ./rocket-tools/riscv-isa-sim) \
	   -I$(abspath ./rocket-tools/riscv-isa-sim/build) \
	   -I$(abspath ./build) \
	   -I$(abspath $(RISCV)/include)

CFLAGS = $(INC_PATH) -fPIE -Wno-format -Werror  
LIBS = -L$(abspath ./rocket-tools/riscv-isa-sim/build) -lfesvr

verilog:
	cd $(base_dir) && $(MILL) emulator[freechips.rocketchip.system.TestHarness,$(CONFIG)].mfccompiler.compile

idea:
	mill -i mill.idea.GenIdea/idea

bsp:
	mill mill.bsp.BSP/install

tags:
	ctags -R --fields=+nS $(VSRC) $(CSRC)
	cscope -Rbkq $(VSRC) $(CSRC)

sim:
	mkdir -p build
	verilator $(VERILATOR_FLAGS) -CFLAGS "$(CFLAGS)" -LDFLAGS "$(LIBS)" $(VSRC) $(CSRC)

run:
	./build/V$(TOPNAME)

obj_clean:
	rm -rf obj_dir/ build/

tags_clean:
	rm -rf tags cscope.out cscope.in.out cscope.po.out

clean: obj_clean
	rm -rf out/

.PHONY: run sim verilog obj_clean tags_clean clean
