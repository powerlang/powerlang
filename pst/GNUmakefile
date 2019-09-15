#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
BOOTSTRAP=../bootstrap

all: kernel.bsl vm

kernel.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"KernelSegmentBuilder new genesis; writeToFile: '$(shell pwd)/$@'"

$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)

.PHONY: vm
vm:
	$(MAKE) -C vm
