//*****************************************************************
//  Sean Viravouth, Matin Qurbanzadeh
//  CS3B - Yippie IO: Part 5 - calculator
//  05/13/2025
//
//	This program will take two numbers from the keyboard and do math
//	operations on them. It can add, subtract, multiply, and divide. 
// 	The calculation will use reverse polish notation. Reverse polish
//	notation is where you plug in both numbers first, and then the 
//	operation.
//	
//	Example: 3 6 +, 9 3 *
//
//	Pseudocode / Algorithm:
//	1. Initialize GPIO pins for keypad input
//	2. Enter main input loop:
//	   a. Wait for keypad press and get the raw code (1-16)
//	   b. Convert raw code to corresponding ASCII character using keyMap
//	   c. If character is 'E' (Enter), exit the loop
//	   d. Otherwise, echo the character to console
//	   e. Return to beginning of loop for next input
//	3. Print a newline character
//	4. Terminate the program with exit code 0
//*****************************************************************

// *******************************
//	Keyboard layout for reference
// -------------------------------
//	1    2    3     /
//	4    5    6     x
//	7    8    9     -
//	.    0    E     +
// *******************************

// do to 2 + 2 = 4. Type in 2, enter, 2, enter, +, enter.
// result should be 4.

#include "gpiomem.S"

.global _start // Provide program starting address

_start:	// program start

    .EQU SYS_exit, 93	// Linux exit syscall number
    
    .text	// code section
        
    initializePins 		// Macro: configure and map GPIO pins for keypad scanning

    // Main input loop: keep reading until Enter ('E') is pressed
clac_loop:
    MOV   X0, #1 		// Place 1 into X0 to indicate blocking mode for getKey
    BL    getKey    	// Call getKey: waits for a keypad press, returns raw code (1-16) in X0

    // Convert raw keypad code (1-16) into its ASCII character from keyMap
    SUB   X0, X0, #1   	// Decrement X0 by 1 to convert to 0-based index (0-15)
    LDR   X1, =keyMap   // Load address of keyMap table into X1
    ADD   X1, X1, X0    // Add index offset to X1, pointing to the correct byte in keyMap
    LDRB  W0, [X1]      // Load the ASCII byte at [X1] into W0 (the character)

    // If the character is 'E' (Enter), break out of loop
    CMP   W0, #'E'      // Compare W0 to ASCII 'E'
    B.EQ  done          // If equal, branch to done

    // Echo the character to the console using putstring
    LDR   X2, =szBuffer	// Load address of temporary buffer szBuffer into X2
    STRB  W0, [X2]      // Store the character byte at szBuffer[0]
    MOV   W3, #0        // Prepare zero for null terminator
    STRB  W3, [X2, #1]  // Store null terminator at szBuffer[1]
    MOV   X0, X2        // Move buffer address into X0 for putstring argument
    BL    putstring     // Call putstring to print the single-character string
    
    B clac_loop         // Branch back to start of loop for next keypress

done:
    // Print a newline to separate input and termination
    LDR   X0, =szNewline      // Load address of newline string
    BL    putstring           // Print newline

	// terminate program
	MOV X0, #0			// set return code to 0, all good
	MOV X8, #SYS_exit   // set exit() supervistor call code
	SVC 0			    // call linux to exit
    
    .data	// data section
keyMap:    .ascii "123/456x789-.0E+"	// Lookup table mapping 1-16 to ASCII chars
szBuffer:  .skip 2                  	// 2-byte buffer: [char, '\0'] for putstring
szNewline: .asciz "\n"            		// Null-terminated newline string

.end	// end of program
