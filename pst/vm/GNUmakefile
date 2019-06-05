#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#

INCLUDES=-I.

CFLAGS=-std=c++11 -ggdb3 -O0 -Wextra -Wall -Werror $(INCLUDES)
CXXFLAGS=$(CFLAGS)

SOURCES=$(wildcard *.cpp)
OBJECTS=$(patsubst %.cpp,%.o,$(SOURCES))

all: $(OBJECTS) s9

s9: $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJECTS)

clean:
	rm $(OBJECTS) s9