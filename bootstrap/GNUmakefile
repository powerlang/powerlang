
all: pharo-ui bootstrap.image

pharo pharo-ui Pharo.image:
	curl https://get.pharo.org/64/80+vm | bash

bootstrap.image: pharo Pharo.image src
	./pharo Pharo.image save bootstrap
	./pharo $@ metacello install tonel://./src BaselineOfPowerlang
	./pharo $@ eval --save "(IceRepositoryCreator new location: '..' asFileReference; createRepository) register"
	./pharo $@ eval --save "SystemWindow closeTopWindow. GTPlayground openContents: 'README.md' asFileReference contents withSqueakLineEndings"
	@echo ""
	@echo "To open Pharo bootstrap image run:"
	@echo ""
	@echo "    ./pharo-ui bootstrap.image"
	@echo ""

test: bootstrap.image pharo
	./pharo $< test --junit-xml-output Powerlang-Tests
	mkdir -p test-reports
	mv Powerlang-Tests-Test.xml test-reports

bee-dmr: specs/bee-dmr
	echo "bee-dmr" >specs/current

specs/bee-dmr:
	git clone git@github.com:powerlang/bee-dmr.git specs/bee-dmr || git clone https://github.com/powerlang/bee-dmr.git specs/bee-dmr

clean:
	rm -rf Pharo* pharo* bootstrap.image icon-packs
