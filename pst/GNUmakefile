#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
BOOTSTRAP=../bootstrap

all: \
	vm kernel.bsl \
	mintest_ret_self.bsl  \
	mintest_3_plus_4_a.bsl \
	mintest_3_plus_4_b.bsl \
	mintest_3_plus_4_c.bsl \
	mintest_3_plus_4_d.bsl \


kernel.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"KernelSegmentBuilder new genesis; writeToFile: '$(shell pwd)/$@'"

mintest_3_plus_4_a.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"MinimalTestSegmentBuilder new method: 'evaluate ^3+4'; build; writeToFile: '$(shell pwd)/$@'"

mintest_3_plus_4_b.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"MinimalTestSegmentBuilder new method: 'evaluate ^self add: 4'; method: 'add: what ^3 + what'; build; writeToFile: '$(shell pwd)/$@'"

mintest_3_plus_4_c.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"MinimalTestSegmentBuilder new method: 'evaluate ^self add: 3'; method: 'add: what ^what + 4'; build; writeToFile: '$(shell pwd)/$@'"

mintest_3_plus_4_d.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"MinimalTestSegmentBuilder new method: 'evaluate ^self add: 4 to: 3'; method: 'add: b to: a ^a + b'; build; writeToFile: '$(shell pwd)/$@'"


mintest_ret_self.bsl: $(BOOTSTRAP)/bootstrap.image kernel kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"MinimalTestSegmentBuilder new method: 'evaluate ^ self'; build; writeToFile: '$(shell pwd)/$@'"


$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)

.PHONY: vm
vm:
	$(MAKE) -C vm

.PHONY: clean

clean:
	$(MAKE) -C vm clean
	$(MAKE) -C $(BOOTSTRAP) clean
	rm -f kernel.bsl mintest_*.bsl
