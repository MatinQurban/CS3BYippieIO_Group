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
//   3. Configure pins:
//        GPIODirectionOut pin4, pin17, pin27, pin22
//        GPIODirectionIn col1, col2, col3, col4
//   4. MOV W6, #10000 set up loop counter
//   5. loop:
//        readRowKeyboard pin4
//        readRowKeyboard pin17
//        readRowKeyboard pin22
//        readRowKeyboard pin27
//        SUBS W6, W6, #1
//        B.NE  loop
//   6. _end:
//        MOV  X0, #0
//        MOV  X8, #__NR_exit
//        SVC  #0 
//*****************************************************************

#include "gpiomem.S"	// include macros inside gpiomem.s

.global getKey	    // Provide program starting address

getKey: mapMem		// dev/gpiomem into user space
        nanoSleep	// short delay to ensure mapping is ready

	initializePins	// initialize the pins
	
	readRowKeyboard pin4	// read and process input on pin 4
	readRowKeyboard pin17	// read and process input on pin 17
	readRowKeyboard pin22	// read and process input on pin 22
	readRowKeyboard pin27	// read and process input on pin 27
       
_end:                      
    MOV X0, #0          	// Set exit code 0 in X0
    MOV X8, #__NR_exit  	// Load exit syscall number into X8
    SVC #0               	// Trigger syscall to terminate program
