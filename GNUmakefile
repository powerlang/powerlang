#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
HOST   := $(shell uname -m)-$(shell uname -s | tr A-Z a-z)
TARGET ?= $(HOST)
BUILD  ?= build/$(TARGET)

BASEADDR= 16r1FF10000
KERNEL  = $(BUILD)/$(shell cat bootstrap/specs/current || echo 'bee-dmr').bsl
LAUNCHER= $(BUILD)/$(shell cat bootstrap/specs/current || echo 'bee-dmr')

all: $(LAUNCHER) $(KERNEL) 
	@echo
	@echo "Build output is in"
	@echo "    $(BUILD)"
	@echo

$(KERNEL): bootstrap/specs/current bootstrap/bootstrap.image bootstrap/pharo | $(BUILD)
	cd bootstrap && ./pharo bootstrap.image eval \
		"KernelSegmentBuilder new initialize64BitImage generateModule bootstrapModule fillClasses nativizeForDMR addGenesisObjects writer base: $(BASEADDR); writeToFile:'../$(BUILD)/$@'"

$(LAUNCHER): bootstrap/specs/current $(BUILD)/Makefile
	make -C $(BUILD)

$(BUILD)/Makefile: launcher/CMakeLists.txt | $(BUILD)
	cd $(BUILD) && cmake $(realpath launcher/ --relative-to=$(BUILD)) -DCMAKE_BUILD_TYPE=Debug

bootstrap/specs/current:
	$(MAKE) -C bootstrap specs/current

bootstrap/bootstrap.image bootstrap/pharo:
	$(MAKE) -C bootstrap

test:
	make -C bootstrap test

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)
	make -C bootstrap clean

mrproper: clean
	make -C bootstrap mrproper
