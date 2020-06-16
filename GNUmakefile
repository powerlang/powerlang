#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
HOST   := $(shell ./config.guess | cut -d '-' -f 1,3)
TARGET ?= $(HOST)
BUILD  ?= build/$(TARGET)

BASEADDR= 16r1FF10000
KERNEL  = $(BUILD)/$(shell cat bootstrap/specs/current).bsl
LAUNCHER= $(BUILD)/$(shell cat bootstrap/specs/current)

all: $(KERNEL) $(LAUNCHER)
	@echo
	@echo "Build output is in"
	@echo "    $(BUILD)"
	@echo

$(KERNEL): bootstrap/bootstrap.image bootstrap/pharo bootstrap/specs/$(shell cat bootstrap/specs/current)/Kernel/* | $(BUILD)
	cd bootstrap && ./pharo bootstrap.image eval \
		"SmalltalkBootstrapper fromSpec build writer base: $(BASEADDR); writeToFile:'$(shell pwd)/$@'"

$(LAUNCHER):
	$(MAKE) HOST=$(HOST) BUILD=$(shell realpath $(BUILD)) -C launcher

bootstrap/bootstrap.image bootstrap/pharo:
	$(MAKE) -C bootstrap


$(BUILD):
	mkdir -p $@