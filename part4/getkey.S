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
//	
//  Pseudocode / Algorithm (based off the authors implementation):
//   1. mapMem         map GPIO peripheral into user space
//   2. nanoSleep      short delay after mapping
//   3. Configure pins: call initalizePins macro
//   4.   readRowKeyboard pin4
//        readRowKeyboard pin17
//        readRowKeyboard pin22
//        readRowKeyboard pin27
//   5. _end:
//        MOV  X0, #0
//        MOV  X8, #__NR_exit
//        SVC  #0 
//*****************************************************************

#include "gpiomem.S"	// include macros inside gpiomem.s

.global getKey	    // Provide program starting address

getKey: mapMem		// dev/gpiomem into user space
        nanoSleep	// short delay to ensure mapping is ready
	
	CMP X0, #0
	B.EQ nonBlocking
	
blocking:
	readRowKeyboard pin4,  #1	// read and process input on pin 4
	readRowKeyboard pin17, #1	// read and process input on pin 17
	readRowKeyboard pin22, #1	// read and process input on pin 22
	readRowKeyboard pin27, #1	// read and process input on pin 27
	
	B end_getKey
	
nonBlocking:
	readRowKeyboard pin4,  #0	// read and process input on pin 4
	readRowKeyboard pin17, #0	// read and process input on pin 17
	readRowKeyboard pin22, #0	// read and process input on pin 22
	readRowKeyboard pin27, #0	// read and process input on pin 27
	
	b end_getKey
       
end_getKey:
	RET 	// return to caller
