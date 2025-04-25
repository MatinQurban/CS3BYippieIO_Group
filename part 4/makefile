FLASHOBJS = main.o
FLASHMEMOBJS = mainmem.o

ASFLAGS := -g  # Flags for as; -g for debug symbols

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif
LSTFLGS =


all: flash flashmem

%.o : %.S
	gcc $(DEBUGFLGS) $(LSTFLGS) -c -g $< -o $@

%.o : %.s
	as $(DEBUGFLGS) $(LSTFLGS) $< -o $@

flash: $(FLASHOBJS)
	ld -o flash $(FLASHOBJS)

flashmem: $(FLASHMEMOBJS)
	ld -o flashmem $(FLASHMEMOBJS)

#%.o: %.s
    #as $(ASFLAGS) -o $@ $<
