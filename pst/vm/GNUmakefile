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

SOURCE_DIRS=. compiler
SOURCES=$(foreach d,$(SOURCE_DIRS),$(wildcard $(d)/*.cpp))

OBJECT_DIRS=$(foreach d,$(SOURCE_DIRS),$(BUILD)/$(d))
OBJECTS=$(patsubst %.cpp,$(BUILD)/%.o,$(SOURCES))

DEPENDS=$(patsubst %.cpp,$(BUILD)/%.d,$(SOURCES))

LIBS   =

LIBS_DEPS =

DEFINITIONS= \
	$(BUILD)/Classes.def \
	$(BUILD)/AstNodeTypes.def \
	$(BUILD)/AstBindingTypes.def

all: $(DEFINITIONS) $(OBJECTS) $(BUILD)/bast $(BUILD)/bast-gdb.py

$(BUILD):
	mkdir -p $@

$(BUILD)/bast-gdb.py: | $(BUILD)
	cd $(BUILD) && ln -s ../../bast-gdb.py .

$(OBJECT_DIRS): | $(BUILD)
	mkdir -p $@

$(BUILD)/%.o: %.cpp $(BUILD)/%.d | $(OBJECT_DIRS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) $(DEPFLAGS) -o $@ -c $<

$(BUILD)/Classes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/* | $(BUILD)
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"ClassDefWriter writeToFile: '$(shell pwd)/$@'"

$(BUILD)/AstNodeTypes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/* | $(BUILD)
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"EnumDefWriter write: AstNodeTypes toFile: '$(shell pwd)/$@'"

$(BUILD)/AstBindingTypes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo ../kernel/* | $(BUILD)
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"EnumDefWriter write: AstBindingTypes toFile: '$(shell pwd)/$@'"

$(BUILD)/bast:: 3rdparty $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS) $(LIBS)

$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)

$(DEPENDS)::

include $(wildcard $(DEPENDS))

clean::
	rm -f $(OBJECTS) $(DEPENDS) $(BUILD)/bash

3rdparty::

#
# Definitions for OMR
#
INCLUDES += -Iomr/include_core \
	    -Iomr/jitbuilder/release/cpp/include
$(DEPENDS):: omr/jitbuilder/release/cpp/include/JitBuilder.hpp

LIBS += $(BUILD)/omr/jitbuilder/libjitbuilder.a

3rdparty:: $(BUILD)/omr/jitbuilder/libjitbuilder.a

$(BUILD)/omr:
	mkdir -p $@

$(BUILD)/omr/Makefile: | omr $(BUILD)/omr
	cd $(BUILD)/omr && cmake ../../../omr \
		-DCMAKE_BUILD_TYPE=Debug \
		-DOMR_COMPILER=ON \
		-DOMR_JITBUILDER=ON \
		-DOMR_JITBUILDER_TEST=OFF \
		-DOMR_TEST_COMPILER=OFF \
		-DOMR_GC=OFF

omr/jitbuilder/release/cpp/include/JitBuilder.hpp $(BUILD)/omr/jitbuilder/libjitbuilder.a: | $(BUILD)/omr/Makefile
	$(MAKE) -C $(BUILD)/omr

clean::
	if test -f $(BUILD)/omr/Makefile; then $(MAKE) -C $(BUILD)/omr clean; fi
