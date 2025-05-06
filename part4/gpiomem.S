//*****************************************************************
//  Sean Viravouth, Matin Qurban
//  CS3B - Yippie IO: Part 4 - Keypad input detection
//  05/06/2025
//
//	This file contains a set of macros that will help with detecting
//	keypad input. Each macro has its own unique function set that are
//	used for specific tasks.
//
//	List of macros:
//	- mapMem 			- written by author
//	- nanoSleep 		- written by author
//	- GPIODirectionOut 	- written by author
//	- GPIODirectionIn 	- written by us
//	- GPIOTurnOn 		- written by author
//	- GPIOTurnOff 		- written by author
// 	- GPIOReadPin 		- written by us
//	- waitPinOff 		- written by us
//	- readRowKeyboard 	- written by us
//*****************************************************************

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

//*****************************************************************
//  Macro:       GPIODirectionIn
//  Description: Configure the specified GPIO pin as an input by
//               clearing its 3-bit function select field.
//  Registers used:
//    X0 - mask for clearing bits
//    X1 - current value of the function select register
//    X2 - offset to the function select register for this pin
//    X3 - address/shift helper from pin table
//    X9 - base address of mapped GPIO registers
//
//  Pseudocode / Algorithm:
//    1. X2 = offset field from pin table
//    2. W1 = X9 + X2]              // read current FSEL register
//    3. X3 = pin table address + 4	// point to shift amount
//    4. W3 = X3]                   // load shift amount
//    5. X0 = 0b111 << W3          	// build mask for 3 bits
//    6. X1 = W1 & ~X0              // clear those 3 bits
//    7. [X9 + X2 = X1              // write back to FSEL register
//*****************************************************************
.macro  GPIODirectionIn   pin
	LDR	X2, =\pin		// offset of select register
	LDR	W2, [X2]		// load the value
    LDR	W1, [X9, X2]    // address of register
	LDR	X3, =\pin		// address of pin table
	ADD	X3, X3, #4		// load amount to shift from table
	LDR	W3, [X3]		// load value of shift amt
	MOV	X0, #0b111		// mask to clear 3 bits
	LSL	X0, X0, X3		// shift into position
	BIC	X1, X1, X0		// clear the three bits
	STR	W1, [X9, X2]    // save it to register to do work   
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

//*****************************************************************
//  Macro:  GPIOReadPin
//  Arguments:
//    col 		- symbol for pin info table entry
//    row 		- string label for the corresponding row
//    boolBlock - boolean flag (non-zero to block until pin goes low)
//
//  Description:
//  Reads the specified GPIO input pin, and if it is high:
//  	- Prints 0-16 depending on keyboard input
//  	- Optionally blocks (waits) until the pin goes low if boolBlock != 0
//
//  Pseudocode / Algorithm:
//    1. addr = X9 + 0x34              	// compute GPLEV register address
//    2. reg  = [addr]                  // read GPIO level bits
//    3. shift = load_shift(col)       	// load pins bit position from table
//    4. mask = 1 << shift             	// create bit mask for this pin
//    5. if (reg & mask) == mask then   // pin is high
//	  6. move address of row and col
//	  7. add the offsets to position the row and col
//	  8. load the values
//	  9. compute row * col
//	  10. if pin is low, return 0
//    11. end macro
//*****************************************************************
.macro GPIOReadPin col, row, boolBlock
	MOV	X2, X9			// address of gpio regs
	ADD	X2, X2, #0x34 	// offset to GPLEV regiser
	LDR W2, [X2]		// read level bits
	MOV	X0, #1			// 1 bit to shift into pos
	LDR	X3, =\col		// base of pin info table
	ADD	X3, X3, #8    	// add offset for shift amt
	LDR	W3, [X3]        // load shift from table
	LSL	X0, X0, X3		// do the shift
	AND X1, X2, X0		// test bit in level register
	CMP X1, X0			// compare X1 - X0
	B.NE 1f				// if not equal, pin is low
		
	MOV X0, \boolBlock	// mov boolBlock value into X0
	CMP X0, #0			// compare it with 0
	B.EQ 2f				// if 0, then don't block
	
	MOV W0, \row		// move address of row
	MOV W1, \col		// move address of col
	
	ADD X0, X0, #12		// add offset to position row value
	ADD X1, X1, #12		// add offset to position col value
	
	LDR W0, [X0]		// load value of row
	LDR W1, [X1]		// load value of col
		
	SMULL X0, W0, W1	// return value = col * row
	
	waitPinOff \col		// block until pin goes low

1:
	MOV X0, #0			// return 0 if there is no keyboard input

2:
.endm

//*****************************************************************
//  Macro:       waitPinOff
//  Argument:    pin - pin info table entry symbol
//
//  Description: Poll until the specified GPIO input pin reads low,
//               with a short initial delay before polling.
//
//  Pseudocode / Algorithm:
//    1. loop:
//         a. read GPIO level register
//         b. compute mask for the pin bit
//         c. if (level & mask) != mask then exit loop
//         d. else repeat loop
//*****************************************************************
.macro waitPinOff pin

waitPinOffLoop\@:
	MOV	X2, X9			// address of gpio regs
	ADD	X2, X2, #0x34 	// off to set reg
	LDR W2, [X2]		// read levels
	MOV	X0, #1  		// 1 bit to shift into pos
	LDR	X3, =\pin		// base of pin info table
	ADD	X3, X3, #8    	// add offset for shift amt
	LDR	W3, [X3]        // load shift from table
	LSL	X0, X0, X3		// do the shift
	AND X1, X2, X0		// isolate pin's bit
	CMP X1, X0			// check if the pin bit is set
	B.EQ waitPinOffLoop\@	// loop if it's set
.endm

//*****************************************************************
//  Macro:       readRowKeyboard
//  Argument:    pin - pin info table entry symbol
//
//  Description: Enable a keyboard column pin, read all row inputs,
//               then disable the column.
//
//  Pseudocode / Algorithm:
//    1. set column pin high
//    2. for each row (col1 - col4): call GPIOReadPin to read state
//    3. wait a short time
//    4. set column pin low
//*****************************************************************
.macro readRowKeyboard pin, boolBlock
    GPIOTurnOn    \pin           	// set column pin high
    GPIOReadPin   col1, \pin, #1 	// read input on row 1
    GPIOReadPin   col2, \pin, #1 	// read input on row 2
    GPIOReadPin   col3, \pin, #1 	// read input on row 3
    GPIOReadPin   col4, \pin, #1 	// read input on row 4
    nanoSleep                    	// short delay
    GPIOTurnOff   \pin           	// set column pin low
.endm

//*****************************************************************
//  Macro:       initializePins
//  Argument:    pin - pin info table entry symbol
//				 col - col info
//
//  Description: initialize pins and cols to be inputs and/or outputs
//
//  Pseudocode / Algorithm:
//    1. initialize pins
//	  2. initalize cols
//*****************************************************************
.macro initializePins

    GPIODirectionOut pin4   // Set GPIO4 as output
    GPIODirectionOut pin17  // Set GPIO17 as output
    GPIODirectionOut pin27 	// Set GPIO27 as output
    GPIODirectionOut pin22  // Set GPIO22 as output

    GPIODirectionIn col1   	// Set GPIO for keyboard column 1 as input
    GPIODirectionIn col2   	// Set GPIO for keyboard column 2 as input
    GPIODirectionIn col3   	// Set GPIO for keyboard column 3 as input
    GPIODirectionIn col4   	// Set GPIO for keyboard column 4 as input

.endm

.data
szNewLine: .asciz "\n"
timespecsec:   .dword   0
timespecnano:  .dword   100000000
devmem:	       .asciz  "/dev/gpiomem"
//devmem:	   .asciz  "/dev/mem"
memOpnErr:     .asciz  "Failed to open /dev/mem\n"
memOpnsz:      .word  .-memOpnErr 
memMapErr:     .asciz  "Failed to map memory\n"
memMapsz:      .word  .-memMapErr 
			   .align  4 // relign after strings
gpioaddr:      .dword   0x0	// mem address of gpio registers
//gpioaddr:    .dword   0xFE200000	// mem address of gpio registers

offsetgplev0: .word 52	// base address for GPLEV0

szPinOn:	.asciz "Keypress detected: "
szPinOff:	.asciz "Off "

// OUTPUT PINS
pin4:	   .word   0   // offset to select register
	       .word   12  // bit offset in select register
	       .word   4   // bit offset in set & clr register
	       .word   1

pin17:	   .word   4   // offset to select register
	       .word   21  // bit offset in select register
	       .word   17  // bit offset in set & clr register
	       .word   2
	       
pin22:	   .word   8   // offset to select register
	       .word   6   // bit offset in select register
	       .word   22  // bit offset in set & clr register
	       .word   3
	       	       
pin27:	   .word   8   // offset to select register
	       .word   21  // bit offset in select register
	       .word   27  // bit offset in set & clr register
	       .word   4
	      

// INPUT PINS	       
col1:	   .word   4   	// offset to select register
	       .word   24  	// bit offset in select register
	       .word   18  	// bit offset in set & clr register
	       .word   1
	       
col2:	   .word   8   	// offset to select register
	       .word   9  	// bit offset in select register
	       .word   23   // bit offset in set & clr register (figure this out later)
	       .word   2
	       
col3:	   .word   8   	// offset to select register
	       .word   12  	// bit offset in select register
	       .word   24  	// bit offset in set & clr register
		   .word   3
       
col4:	   .word   8   	// offset to select register
	       .word   15  	// bit offset in select register
	       .word   25  	// bit offset in set & clr register
	       .word   4

.text
