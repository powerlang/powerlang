#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#

HOST   := $(shell ./config.guess | cut -d '-' -f 1,3)
TARGET ?= $(HOST)
CFLAGS ?= -ggdb3 -O0 -Wextra -Wall -Werror
CXXFLAGS ?= $(CFLAGS) -std=c++11

#
# ===
#
BUILD = build/$(TARGET)

INCLUDES=-I.

SOURCES=$(wildcard *.cpp)
OBJECTS=$(patsubst %.cpp,$(BUILD)/%.o,$(SOURCES))

all: $(OBJECTS) $(BUILD)/s9

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.cpp $(BUILD)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ -c $<

$(BUILD)/s9: $(OBJECTS)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ $(OBJECTS)

clean:
	rm -f $(OBJECTS) $(BUILD)/s9