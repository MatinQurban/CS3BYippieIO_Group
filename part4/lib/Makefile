# Saddleback CS3B Makefile Template
#   A basic, extensible template to easily assemble and link a set of assembly
#   source files into a single executable, or to archive them into a library.
# Authors: Kaveh Zare, modified by Matthew Reese
# Last Modified: 2/12/2025

EXE := genLib.a  # Executable name

ASFLAGS := -g  # Flags for `as`; -g for debug symbols
LDFLAGS :=     # Flags for `ld`

LIBS :=                  # Library files to link in the final build step
SRCS := $(wildcard *.s)  # Source files; Matches all files in directory with `.s` extension
OBJS := $(SRCS:.s=.o)    # Object files; Substitutes `.s` for `.o` for all sources (ex: "lab7-3.s" -> "lab7-3.o")

# Default target
# As the first target in the file, is used when `make` is run without args
all: $(EXE)


# "Cleaning"
# Deletes all object files and the executable.
#   `-f` to suppress warning when said files do not exist
clean:
	rm -f $(OBJS) $(EXE)


# Create executable (or library archive)
# Rule to link all object (.o) files together with `ld`
$(EXE): $(OBJS) $(LIBS)
	###ld $(LDFLAGS)-o $(EXE) $^ $(LIBS)
	ar -cvq $@ $^


# Pattern-matching rule to assemble each source (.s) files with `as`
#   Any required *.o file, as are in the rule above, are created via
#   the rule below, substituting the file name in for the `%` symbol
%.o: %.s
	as $(ASFLAGS) -o $@ $<


# Make normally assumes that any target is a filename. `PHONY` is here
# to convey that "all", "clean" should not be considered files.
.PHONY: all clean
