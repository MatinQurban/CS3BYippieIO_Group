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
//        subs W6, W6, #1
//        b.ne  loop
//   6. _end:
//        MOV  X0, #0
//        MOV  X8, #__NR_exit
//        SVC  #0 
//*****************************************************************

#include "gpiomem.S"	// include macros inside gpiomem.s

.global _start	    // Provide program starting address

_start: mapMem		// dev/gpiomem into user space
        nanoSleep	// short delay to ensure mapping is ready

    GPIODirectionOut pin4   // Set GPIO4 as output
    GPIODirectionOut pin17  // Set GPIO17 as output
    GPIODirectionOut pin27  // Set GPIO27 as output
    GPIODirectionOut pin22  // Set GPIO22 as output

    GPIODirectionIn col1   	// Set GPIO for keyboard column 1 as input
    GPIODirectionIn col2   	// Set GPIO for keyboard column 2 as input
    GPIODirectionIn col3   	// Set GPIO for keyboard column 3 as input
    GPIODirectionIn col4   	// Set GPIO for keyboard column 4 as input

    // Initialize loop counter
    MOV W6, #10000         	// Load immediate 10000 into W6 for iteration count
       
loop:                         
    readRowKeyboard pin4 	// Read and process input on pin4
    readRowKeyboard pin17   // Read and process input on pin17
    readRowKeyboard pin22   // Read and process input on pin22
    readRowKeyboard pin27   // Read and process input on pin27

    SUBS W6, W6, #1      	// Decrement W6; update condition flags
    B.NE loop            	// If W6 != 0, branch back to loop

_end:                      
    MOV X0, #0          	// Set exit code 0 in X0
    MOV X8, #__NR_exit  	// Load exit syscall number into X8
    SVC #0               	// Trigger syscall to terminate program
