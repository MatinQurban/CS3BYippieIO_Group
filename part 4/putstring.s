//*****************************************************************
// 	Sean Viravouth
// 	CS3B - lab4-1 - putstring function
// 	02/08/2025
//
//putstring
//  Function putstring: Provided a pointer to a null terminated string in
//  X0, will output the string on the console
//
//  X0: Must point to a null terminated string
//  LR: Must contain the return address (automatic when BL
//      is used for the call)
//  All registers except   X0, X1, X2, X3, and X8 are preserved
//
//	Pseudocode / Algorithm:
//	- save pointer to string
//  - save pointer to address
//	- call String_length to get string length
// 	- store pointer to string in X1
//	- store length of string in X2
//	- call linux to write string
//	- Return to caller
//*****************************************************************

.global putstring		// provide program starting address

putstring:

	.EQU SYS_write, 64	   // write() supervisor call code
	.EQU STDOUT,    1	   // standard output
	
	.text	// code section
	
	MOV X8, X0			// save pointer to the string in X8
	MOV X3, LR			// save pointer address in X3
	
	BL String_length	// call String_length to get string length
	
	MOV X1, X8			// store pointer in X1
	MOV X2, X0			// store length of string in X2
	
	// write
	MOV X0, #STDOUT		// stdout
	MOV X8, #SYS_write	// call linux to write
	SVC 0				// call linux to print string
	
	MOV LR, X3			// moves the saved return address into LR
	RET					// return to caller
	
.end // end of putstring function
