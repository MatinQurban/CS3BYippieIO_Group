// Various macros to access the GPIO pins
// on the Raspberry Pi.
//
// X9 - memory map address.
//

#include "fileio.S"

.equ	pagelen, 4096
.equ	setregoffset, 28
.equ    clrregoffset, 40
.equ	PROT_READ, 1
.equ	PROT_WRITE, 2
.equ	MAP_SHARED, 1

// Macro to map memory for GPIO Registers
.macro mapMem
	openFile	devmem, O_RDWR // open /dev/mem
	ADDS		X4, XZR, X0	// fd for memmap
	// check for error and print error msg if necessary
	B.PL		1f  // pos number file opened ok
	MOV		X1, #1  // stdout
	LDR		X2, =memOpnsz	// Error msg
	LDR		W2, [X2]
	writeFile	X1, memOpnErr, X2 // print the error
	B		_end

// Setup can call the mmap2 Linux service
1:	ldr		X5, =gpioaddr	// address we want / 4096
	ldr		X5, [X5]	// load the address
	mov		X1, #pagelen	// size of mem we want
	mov		X2, #(PROT_READ + PROT_WRITE) // mem protection options
	mov		X3, #MAP_SHARED	// mem share options
	mov		X0, #0		// let linux choose a virtual address
	mov		X8, #__NR_mmap	// mmap service num
	svc		0		// call service
	ADDS		X9, XZR, X0	// keep the returned virtual address
	// check for error and print error msg if necessary
	B.PL		2f  // pos number file opened ok
	MOV		X1, #1  // stdout
	LDR		X2, =memMapsz	// Error msg
	LDR		W2, [X2]
	writeFile	X1, memMapErr, X2 // print the error
	B		_end
2:
.endm

// Macro nanoSleep to sleep .1 second
// Calls Linux nanosleep entry point which is function 162.
// Pass a reference to a timespec in both X0 and X1
// First is input time to sleep in seconds and nanoseconds.
// Second is time left to sleep if interrupted (which we ignore)
.macro  nanoSleep
        ldr         X0, =timespecsec
        ldr         X1, =timespecsec
        mov         X8, #__NR_nanosleep
        svc         0
.endm
.macro  GPIODirectionOut   pin
	ldr	X2, =\pin	// offset of select register
	ldr	W2, [X2]	// load the value
        ldr	W1, [X9, X2]    // address of register
	ldr	X3, =\pin	// address of pin table
	add	X3, X3, #4	// load amount to shift from table
	ldr	W3, [X3]	// load value of shift amt
	mov	X0, #0b111	// mask to clear 3 bits
	lsl	X0, X0, X3	// shift into position
	bic	X1, X1, X0	// clear the three bits
	mov	X0, #1		// 1 bit to shift into pos
	lsl	X0, X0, X3	// shift by amount from table
	orr	X1, X1, X0	// set the bit
	str	W1, [X9, X2]    // save it to register to do work   
.endm

.macro  GPIODirectionIn   pin
	ldr	X2, =\pin	// offset of select register
	ldr	W2, [X2]	// load the value
        ldr	W1, [X9, X2]    // address of register
	ldr	X3, =\pin	// address of pin table
	add	X3, X3, #4	// load amount to shift from table
	ldr	W3, [X3]	// load value of shift amt
	mov	X0, #0b111	// mask to clear 3 bits
	lsl	X0, X0, X3	// shift into position
	bic	X1, X1, X0	// clear the three bits
	//mov	X0, #0		// 0 bit to shift into pos
	//lsl	X0, X0, X3	// shift by amount from table
	//orr	X1, X1, X0	// set the bit
	str	W1, [X9, X2]    // save it to register to do work   
.endm

.macro  GPIOTurnOn   pin, value
	mov	X2, X9		// address of gpio regs
	add	X2, X2, #setregoffset // off to set reg
	mov	X0, #1		// 1 bit to shift into pos
	ldr	X3, =\pin	// base of pin info table
	add	X3, X3, #8	// add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3	// do the shift
	str	W0, [X2]	// write to the register
.endm

.macro  GPIOTurnOff   pin, value
	mov	X2, X9		// address of gpio regs
	add	X2, X2, #clrregoffset // off set of clr reg
	mov	X0, #1		// 1 bit to shift into pos
	ldr	X3, =\pin	// base of pin info table
	add	X3, X3, #8    // add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3	// do the shift
	str	W0, [X2]	// write to the register
.endm

.macro GPIOReadPin pin
	mov	X2, X9			// address of gpio regs
	add	X2, X2, #0x34 	// off to set reg
	LDR W2, [X2]
	mov	X0, #1			// 1 bit to shift into pos
	ldr	X3, =\pin		// base of pin info table
	add	X3, X3, #8    	// add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3		// do the shift
	AND X1, X2, X0
	CMP X1, X0
	B.NE 1f
	LDR X0, =\pin
	ADD X0, X0, #12
	BL putstring
	LDR X0, =szPinOn
	BL putstring
	B 2f
1:
	LDR X0, =\pin
	ADD X0, X0, #12
	BL putstring
	LDR X0, =szPinOff
	BL putstring
	
	waitPinOff \pin
2:
.endm

.macro waitPinOff pin
waitPinOffLoop:
	mov	X2, X9			// address of gpio regs
	add	X2, X2, #0x34 	// off to set reg
	LDR W2, [X2]
	mov	X0, #0			// 0 bit to shift into pos
	ldr	X3, =\pin		// base of pin info table
	add	X3, X3, #8    	// add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3		// do the shift
	AND X1, X2, X0
	CMP X1, X0
	B.NE waitPinOffLoop
.endm

.macro readRowKeyboard pin

		GPIOTurnOn \pin
        GPIOReadPin   col1
        GPIOReadPin   col2
        GPIOReadPin   col3
        GPIOReadPin   col4
		nanoSleep
        LDR X0, =szNewLine
        BL putstring
        GPIOTurnOff \pin

.endm

.data
szNewLine: .asciz "\n"
timespecsec:   .dword   0
timespecnano:  .dword   100000000
devmem:	       .asciz  "/dev/gpiomem"
//devmem:	       .asciz  "/dev/mem"
memOpnErr:     .asciz  "Failed to open /dev/mem\n"
memOpnsz:      .word  .-memOpnErr 
memMapErr:     .asciz  "Failed to map memory\n"
memMapsz:      .word  .-memMapErr 
	       .align  4 // relign after strings
gpioaddr:      .dword   0x0	// mem address of gpio registers
//gpioaddr:      .dword   0xFE200000	// mem address of gpio registers

offsetgplev0: .word 52	// base address for GPLEV0

szPinOn:	.asciz "On "
szPinOff:	.asciz "Off "

// OUTPUT PINS
pin4:	   .word   0   // offset to select register
	       .word   12  // bit offset in select register
	       .word   4  // bit offset in set & clr register
	       .asciz  "4 "

pin17:	   .word   4   // offset to select register
	       .word   21  // bit offset in select register
	       .word   17  // bit offset in set & clr register
	       .asciz  "17 "
	       
pin22:	   .word   8   // offset to select register
	       .word   6  // bit offset in select register
	       .word   22  // bit offset in set & clr register
	       .asciz  "22 "
	       	       
pin27:	   .word   8   // offset to select register
	       .word   21  // bit offset in select register
	       .word   27  // bit offset in set & clr register
	       .asciz  "27 "
	      

// INPUT PINS	       
col1:	   .word   4   	// offset to select register
	       .word   24  	// bit offset in select register
	       .word   18  	// bit offset in set & clr register
	       .asciz  "18 "
	       
col2:	   .word   8   	// offset to select register
	       .word   9  	// bit offset in select register
	       .word   23   	// bit offset in set & clr register (figure this out later)
	       .asciz  "23 "
	       
col3:	   .word   8   	// offset to select register
	       .word   12  	// bit offset in select register
	       .word   24  	// bit offset in set & clr register
		   .asciz  "24 "
       
col4:	   .word   8   	// offset to select register
	       .word   15  	// bit offset in select register
	       .word   25  	// bit offset in set & clr register
	       .asciz  "25 "

.text
