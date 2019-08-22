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

all: $(OBJECTS) $(BUILD)/s9

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.cpp $(BUILD)/%.d| $(BUILD)
	$(CXX) $(INCLUDES) $(CXXFLAGS) $(DEPFLAGS) -o $@ -c $<

$(BUILD)/Classes.def: $(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo
	cd $(BOOTSTRAP) && ./pharo bootstrap.image eval \
		"ClassDefWriter writeToFile: '$(shell pwd)/$@'"

$(BUILD)/s9: $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS)

$(BOOTSTRAP)/bootstrap.image $(BOOTSTRAP)/pharo:
	$(MAKE) -C $(BOOTSTRAP)
	
$(DEPENDS):

include $(wildcard $(DEPENDS))

clean:
	rm -f $(OBJECTS) $(DEPENDS) $(BUILD)/s9
	