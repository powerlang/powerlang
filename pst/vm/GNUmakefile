#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#

HOST   := $(shell ./config.guess | cut -d '-' -f 1,3)
TARGET ?= $(HOST)
CFLAGS ?= -ggdb3 -O0 -Wextra -Wall -Werror
CXXFLAGS ?= $(CFLAGS) -std=c++11
DEPFLAGS ?= -MT $@ -MMD -MP -MF $(BUILD)/$*.d

#
# ===
#
BUILD = build/$(TARGET)

INCLUDES=-I.

SOURCES=$(wildcard *.cpp)
OBJECTS=$(patsubst %.cpp,$(BUILD)/%.o,$(SOURCES))
DEPENDS=$(patsubst %.cpp,$(BUILD)/%.d,$(SOURCES))

all: $(OBJECTS) $(BUILD)/s9

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.cpp $(BUILD)/%.d| $(BUILD)
	$(CXX) $(INCLUDES) $(CXXFLAGS) $(DEPFLAGS) -o $@ -c $<

$(BUILD)/s9: $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS)

$(DEPENDS):

include $(wildcard $(DEPENDS))

clean:
	rm -f $(OBJECTS) $(DEPENDS) $(BUILD)/s9