
all: pharo-ui bootstrap.image

include GNUmakefile.local

pharo pharo-ui Pharo.image:
	curl https://get.pharo.org/64/80+vm | bash

bootstrap.image: pharo Pharo.image src
	./pharo Pharo.image save bootstrap
ifdef MACHINEARITHMETIC_DIR
	./pharo $@ eval --save "(IceRepositoryCreator new location: '$(MACHINEARITHMETIC_DIR)/' asFileReference; createRepository) register" || rm $@
	./pharo $@ metacello install tonel://$(MACHINEARITHMETIC_DIR)/ BaselineOfMachineArithmetic || rm $@
endif
ifdef ARCHC_DIR
	./pharo $@ eval --save "(IceRepositoryCreator new location: '$(ARCHC_DIR)/' asFileReference; createRepository) register" || rm $@
	./pharo $@ eval --save "Metacello new baseline: 'ArchC'; repository: 'tonel://$(ARCHC_DIR)/src'; onConflictUseLoaded; load." || rm $@
endif
	./pharo $@ eval --save "(IceRepositoryCreator new location: '..' asFileReference; createRepository) register"
	./pharo $@ eval --save "Metacello new baseline: 'Powerlang'; repository: 'tonel://./src'; onConflictUseLoaded; load." || rm $@
	./pharo $@ eval --save "SystemWindow closeTopWindow. GTPlayground openContents: 'README.md' asFileReference contents withSqueakLineEndings"
	@echo ""
	@echo "To open Pharo bootstrap image run:"
	@echo ""
	@echo "    ./pharo-ui bootstrap.image"
	@echo ""

test: bootstrap.image pharo specs/current
	./pharo $< test --fail-on-failure --junit-xml-output Powerlang-Tests
	mkdir -p test-reports
	mv Powerlang-Tests-Test.xml test-reports

specs/current: specs/bee-dmr
	echo "bee-dmr" > specs/current

specs/bee-dmr:
	git clone git@github.com:powerlang/bee-dmr.git specs/bee-dmr || git clone https://github.com/powerlang/bee-dmr.git specs/bee-dmr

clean:
	rm -f bootstrap.image bootstrap.changes

mrproper: clean
	rm -rf Pharo* pharo* icon-packs

GNUmakefile.local:
		@echo "# Local tunables. There's no need to change anything," >> $@
		@echo "# suitable defaults are provided." >> $@
		@echo "" >> $@
		@echo "# To load MachineArithmetic from local directory, set MACHINEARITHMETIC_DIR" >> $@
		@echo "# variable to directory where MachineArithmetic is cloned. If unset (default)" >> $@
		@echo "# it will be fetched by Metacello as defined in src/BaselineOfPowerlang/BaselineOfPowerlang.class.st" >> $@
		@echo "# MACHINEARITHMETIC_DIR=../../MachineArithmetic" >> $@
		@echo "" >> $@
		@echo "# To load Pharo-ArchC from local directory, set ARCHC_DIR" >> $@
		@echo "# variable to directory where Pharo-ArchC is cloned. If unset (default)" >> $@
		@echo "# it will be fetched by Metacello as defined in src/BaselineOfPowerlang/BaselineOfPowerlang.class.st" >> $@
		@echo "# ARCHC_DIR=../../ArchC" >> $@
		@echo "" >> $@
