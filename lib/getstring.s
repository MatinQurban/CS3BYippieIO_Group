//*****************************************************************************
//getstring
//  Function getstring: Will read a string of characters up to a specified length
//  from the console and save it in a specified buffer as a C-String (i.e. null
//  terminated).
//  
//  X0: Points to the first byte of the buffer to receive the string. This must
//      be preserved (i.e. X0 should still point to the buffer when this function
//      returns).
//  X1: The maximum length of the buffer pointed to by X0 (note this length
//      should account for the null termination of the read string (i.e. C-String)
//  LR: Must contain the return address (automatic when BL
//      is used for the call)
//  All AAPCS mandated registers are preserved.
//*****************************************************************************
.global getstring // Provide program starting address

getstring:
    .EQU SYS_exit, 93 // exit() supervisor call code
    .text // code section
	MOV X7, LR			// Store return address
	SUB X4, X1, #1		// Save the last char for a null character		
	MOV X3, X0			// Save string buffer address
	MOV X5, #0			// This is our char count and lcv
readStrLoop:	
		// READ INPUT AND PLACE INSIDE BUFFER
	MOV X0, #0		// file descriptor for SYS_READ INPUT (Keyboard)
	LDR X1, =czBuffer	//	read() needs buffer pointer in X1
	MOV X2, #1		// read() needs max read char count in X2
	MOV X8, #63		// Linus call SYS_READ() system call number
	SVC 0 			// call Linux to read the string	
	ADD X5, X5, #1	// increment lcv char count
	LDR W1, [X1]	// Load value of char into W reg
		// CHECK LCV : 
	CMP W1, #'\n' // if it’s a new line character, that means we have reached the end of the input. We should end loop and output
	B.EQ readStrLoopEnd	// end loop and print

	CMP X5, X4	 	// compare the amount of chars read and the length of string array
	B.GE readStrLoop	// if the length of the string has surpassed the end of our buffer stop adding to the buffer but continue reading to clear console
	STRB W1, [X3], #1	// Store char in string array, increment string pointer	
	B readStrLoop	// Loop to read next char
readStrLoopEnd:
	MOV X1, #0			// putstring needs null terminated string
	STRB W1, [X3]		// Store null character at the end of our string

	MOV LR, X7		// Return address back to lr
    RET		// return to caller
.data // data section
	czBuffer:	.skip 	64
.end // end of program, optional but good pra
