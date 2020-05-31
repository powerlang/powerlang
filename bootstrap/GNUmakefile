
all: pharo-ui bootstrap.image

pharo pharo-ui Pharo.image:
	curl https://get.pharo.org/64/80+vm | bash

bootstrap.image: pharo Pharo.image src scripts/bootstrap-setup.st
	./pharo Pharo.image scripts/bootstrap-setup.st
	@echo ""
	@echo "To open Pharo bootstrap image run:"
	@echo ""
	@echo "    ./pharo-ui bootstrap.image"
	@echo ""

test: bootstrap.image pharo
	./pharo $< test --junit-xml-output Powerlang-Tests
	mkdir -p test-reports
	mv Powerlang-Tests-Test.xml test-reports

clean:
	rm -rf Pharo* pharo* bootstrap.image icon-packs
