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

	.text	// code section
	
	STR LR, [SP, #-16]!		// Store LR into stack

	MOV X6, #0				// Reset keyboard input value
	
	CMP X0, #0				// Check block mode
	B.EQ nonBlocking		// If 0, non-blocking, else blocking

blocking:
	readRowKeyboard pin4,  #1	// read and process input on pin 4
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	readRowKeyboard pin17, #1	// read and process input on pin 17
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	readRowKeyboard pin22, #1	// read and process input on pin 22
	ADD X6, X6, X5  //readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	readRowKeyboard pin27, #1	// read and process input on pin 27
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	MOV X0, X6		// Copy keyboard value into X0 for int2cstr call
	
	CMP X0, #0		// Compare return value to 0 (no input)
	B.EQ blocking	// If no keyboard input, loop until key press detected
	
	//MOV X2, #0			// Move immediate value 0 into X2
	//LDR X1, =szBuffer	// Load address of szBuffer
	//STR X2, [X1]		// Clear szBuffer
	//BL int2cstr			// branch link int2cstr, convert X0 to string and store in X1 string buffer

	//printLine szBuffer	// Print string buffer
	
	B end_getKey		// End getKey

nonBlocking:
	readRowKeyboard pin4,  #0	// read and process input on pin 4
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0 
	
	readRowKeyboard pin17, #0	// read and process input on pin 17
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	readRowKeyboard pin22, #0	// read and process input on pin 22
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	readRowKeyboard pin27, #0	// read and process input on pin 27
	ADD X6, X6, X5	//readRowKeyboard will store key value in X5, move to X6 to prepare for next call, add to account for 0
	
	MOV X0, X6			// Copy keyboard value into X0 for int2cstr call
	//MOV X2, #0			// Move immediate value 0 into X2
	//LDR X1, =szBuffer	// Load address of szBuffer
	//STR X2, [X1]		// Store 0 in szBuffer (clear buffer)
	//BL int2cstr			// call int2cstr: Convert int X0 to cstr and store in X1 string buffer
	
	//printLine szBuffer	// Print string buffer
	
	B end_getKey		// End getKey

end_getKey:
	LDR LR, [SP], #16   // Restore LR

	RET 	// return to caller

.data 	// data section
szBuffer: .skip 24			// String buffer to store converted keyboard value
szEOL: .asciz "\n"			// newline character


