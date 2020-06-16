#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#
BOOTSTRAP=../bootstrap

HOST   := $(shell ../config.guess | cut -d '-' -f 1,3)
TARGET ?= $(HOST)
CFLAGS ?= -ggdb3 -O0 -Wextra -Wall -Werror
CXXFLAGS ?= $(CFLAGS) -std=c++17
DEPFLAGS ?= -MT $@ -MMD -MP -MF $(BUILD)/$*.d

EXE ?= $(shell cat $(BOOTSTRAP)/specs/current)
#
# ===
#
BUILD ?= ../build/$(TARGET)

INCLUDES=-I. -I$(BUILD)

SOURCE_DIRS=.
SOURCES=$(foreach d,$(SOURCE_DIRS),$(wildcard $(d)/*.cpp))

OBJECT_DIRS=$(foreach d,$(SOURCE_DIRS),$(BUILD)/$(d))
OBJECTS=$(patsubst %.cpp,$(BUILD)/%.o,$(SOURCES))

DEPENDS=$(patsubst %.cpp,$(BUILD)/%.d,$(SOURCES))

LIBS   =

LIBS_DEPS =

DEFINITIONS=

all: $(DEFINITIONS) $(OBJECTS) $(BUILD)/$(EXE)

$(BUILD):
	mkdir -p $@

$(OBJECT_DIRS): | $(BUILD)
	mkdir -p $@

$(BUILD)/%.o: %.cpp $(BUILD)/%.d | $(OBJECT_DIRS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) $(DEPFLAGS) -o $@ -c $<

$(BUILD)/$(EXE):: $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS) $(LIBS)

$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)

$(DEPENDS)::

include $(wildcard $(DEPENDS))

clean::
	rm -f $(OBJECTS) $(DEPENDS) $(BUILD)/$(EXE)
