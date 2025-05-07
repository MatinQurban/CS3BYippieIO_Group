//*****************************************************************
//  Sean Viravouth, Matin Qurban
//  CS3B - Yippie IO: Part 4 - Keypad input detection
//  05/06/2025
//
//  Description:
//   This program will require a keypad plugged in to the RPI
//	 GPIO pins and will detect if theres input. If there is, then
//	 it will display which row and which column it detects the high
//	 input. There will be two versions, a blocked and a nonblocked.
//
//  Pseudocode / Algorithm (based off the authors implementation):
//   1. mapMem         map GPIO peripheral into user space
//   2. nanoSleep      short delay after mapping
//   3. Configure pins: call initalizePins macro
//   4.   readRowKeyboard pin4
//        readRowKeyboard pin17
//        readRowKeyboard pin22
//        readRowKeyboard pin27
//   5. return to caller
//*****************************************************************

#include "gpiomem.S"	// include macros inside gpiomem.s

.macro    printLine        stringBuff
// Prints stringBuff followed by newline
        LDR X0, =\stringBuff    // Load address of string buffer
        BL putstring            // print string to console
        LDR X0, =szEOL            // Load address of EOL
        BL putstring 
.endm

.global getKey	    // Provide program starting address

getKey:
	
	CMP X0, #0
	B.EQ nonBlocking
	
blocking:
	readRowKeyboard pin4,  #1	// read and process input on pin 4
	readRowKeyboard pin17, #1	// read and process input on pin 17
	readRowKeyboard pin22, #1	// read and process input on pin 22
	readRowKeyboard pin27, #1	// read and process input on pin 27
	
	LDR X1, =szBuffer
	BL int2cstr
	
	printLine szBuffer
	
	B end_getKey
	
nonBlocking:
	readRowKeyboard pin4,  #0	// read and process input on pin 4
	readRowKeyboard pin17, #0	// read and process input on pin 17
	readRowKeyboard pin22, #0	// read and process input on pin 22
	readRowKeyboard pin27, #0	// read and process input on pin 27
	
	LDR X1, =szBuffer
	BL int2cstr
	
	printLine szBuffer
	
	B end_getKey
       
end_getKey:
	RET 	// return to caller

.data 	// data section
szBuffer: .skip 24
szEOL: .asciz "\n"
