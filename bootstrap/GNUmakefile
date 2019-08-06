
all: pharo-ui bootstrap.image

pharo pharo-ui Pharo.image:
	curl https://get.pharo.org/70+vm | bash

bootstrap.image: pharo Pharo.image src scripts/bootstrap-setup.st
	./pharo Pharo.image scripts/bootstrap-setup.st
	@echo ""
	@echo "To open Pharo bootstrap image run:"
	@echo ""
	@echo "    ./pharo-ui bootstrap.image"
	@echo ""

clean:
	rm -rf Pharo* pharo* bootstrap.image icon-packs
