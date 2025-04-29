# Saddleback CS3B Makefile Template
#   A simple, extensible template to easily assemble and link a set of assembly
#   source files into a single executable, or to archive them into a library.
#
# Usage:
#   Run `make` to build the EXE target, and `make clean` to remove objects and executables
#
#   To create a library archive, see instructions under the EXE target rule on uncommenting a line,
#   and also change the value of EXE appropriately.
#   For using a library archive, specify the archive's path in the LIBS variable
#
# Authors: Kaveh Zare, modified and documented by Matthew Reese
# Last Modified: 2/12/2025

EXE := flashmem  # Executable name
#      ^^^^^^--- Change this to the name of the lab executable / library archive

ASFLAGS := -g  # Flags for `as`; -g for debug symbols
LDFLAGS :=     # Flags for `ld`

LIBS := lib/genLib.a                # Library files to link in the final build step
SRCS := $(wildcard *.s *.S)  # Source files; Matches all files in directory with `.s` extension
OBJS := $(patsubst %.s,%.o,$(patsubst %.S,%.o,$(SRCS)))   # Object files; Substitutes `.s` for `.o` for all sources (ex: "lab7-3.s" -> "lab7-3.o")

FLASHOBJS = main.o
FLASHMEMOBJS = mainmem.o

# Default target
# As the first target in the file, is used when `make` is run without args
all: flash flashmem


# "Cleaning"
# Deletes all object files and the executable.
#   `-f` to suppress warning when said files do not exist
clean:
	rm -f $(OBJS) $(EXE)


# Create executable (or library archive)
# Rule to link all object (.o) files together with `ld`
$(EXE): $(OBJS) $(LIBS)
	ld $(LDFLAGS)-o $(EXE) $^ $(LIBS)
	#ar -cvq $@ $^
#   ^^^^^^^^^----- Uncomment the line above if you want to create a static library archive
#                  and comment the line above it to not build an executable

# Pattern-matching rule to assemble each source (.s) files with `as`
#   Any required *.o file, as are in the rule above, are created via
#   the rule below, substituting the file name in for the `%` symbol
%.o: %.s
	as $(ASFLAGS) -o $@ $<

%.o: %.S
	gcc $(ASFLAGS) -c $< -o $@

# Make normally assumes that any target is a filename. `PHONY` is here
# to convey that "all", "clean" should not be considered files.
.PHONY: all clean
