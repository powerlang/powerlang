#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
BOOTSTRAP=../../bootstrap

HOST   := $(shell ./config.guess | cut -d '-' -f 1,3)
TARGET ?= $(HOST)
CFLAGS ?= -ggdb3 -O0 -Wextra -Wall -Werror
CXXFLAGS ?= $(CFLAGS) -std=c++17
DEPFLAGS ?= -MT $@ -MMD -MP -MF $(BUILD)/$*.d

#
# ===
#
BUILD = build/$(TARGET)

INCLUDES=-I. -I$(BUILD)

SOURCES=$(wildcard *.cpp)
OBJECTS=$(patsubst %.cpp,$(BUILD)/%.o,$(SOURCES))
DEPENDS=$(patsubst %.cpp,$(BUILD)/%.d,$(SOURCES))
LIBS   =

DEFINITIONS= \
	$(BUILD)/Classes.def \
	$(BUILD)/AstNodeTypes.def \
	$(BUILD)/AstBindingTypes.def

all: $(DEFINITIONS) $(OBJECTS) $(BUILD)/s9

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.cpp $(BUILD)/%.d| $(BUILD)
	$(CXX) $(INCLUDES) $(CXXFLAGS) $(DEPFLAGS) -o $@ -c $<

$(BUILD)/Classes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"ClassDefWriter writeToFile: '$(shell pwd)/$@'"

$(BUILD)/AstNodeTypes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"EnumDefWriter write: AstNodeTypes toFile: '$(shell pwd)/$@'"

$(BUILD)/AstBindingTypes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/*
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"EnumDefWriter write: AstBindingTypes toFile: '$(shell pwd)/$@'"

$(BUILD)/s9:: $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS) $(LIBS)

$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)

$(DEPENDS):

include $(wildcard $(DEPENDS))

clean::
	rm -f $(OBJECTS) $(DEPENDS) $(BUILD)/s9

#
# Definitions for OMR
#
INCLUDES +=         -Iomr/jitbuilder/release/cpp/include \
	    -I$(BUILD)omr/jitbuilder/release/cpp/include

LIBS += $(BUILD)/omr/jitbuilder/libjitbuilder.a

$(BUILD)/s9:: $(BUILD)/omr/jitbuilder/libjitbuilder.a

$(BUILD)/omr:
	mkdir -p $@

$(BUILD)/omr/Makefile: | omr $(BUILD)/omr
	cmake -S omr -B $(BUILD)/omr \
		-DOMR_COMPILER=ON \
		-DOMR_JITBUILDER=ON \
		-DOMR_JITBUILDER_TEST=OFF \
		-DOMR_TEST_COMPILER=OFF \
		-DOMR_GC=OFF

$(BUILD)/omr/jitbuilder/libjitbuilder.a: $(BUILD)/omr/Makefile
	$(MAKE) -C $(BUILD)/omr

clean::
	if test -f $(BUILD)/omr/Makefile; then $(MAKE) -C $(BUILD)/omr clean; fi
