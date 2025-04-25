//*****************************************************************
// 	Sean Viravouth
// 	CS3B - lab4-1 - string_length function
// 	02/08/2025
//
// String_length
//  Function String_length: Provided a pointer to a null terminated string in
//  X0, will return the string's length in X0
//
//  X0: Must point to a null terminated string
//  LR: Must contain the return address (automatic when BL
//      is used for the call)
//
//  All registers except   X0, X1, and X2 are preserved
//
//	Pseudocode / Algorithm:
//	- Initialize length counter to 0
//	- enter loop
//	- load the byte at address X0 + X1 
//	- compare W2 with 0, the null terminator
//	- if the string is null, then jump to done
//	- if not, then increment the length counter
// 	- repeat until W2 hits 0
// 	- when done, store the length in X0 and return
//*****************************************************************

.global String_length		// provide program starting address

String_length:

	.EQU SYS_exit, 93		// exit () supervisor call code
	
	.text	// code section

    MOV X1, #0              // Initialize length counter to 0

	loop:
		//LDRB W2, [X0, X1]	// Load the byte at address (X0 + X1) into W2
		
		LDRB W2, [X0], #1   // post increment X0 to point to next char
		
		CMP W2, #0        	// Compare W2 with 0 (null character)
		B.EQ done           // If it is null, the string has ended
		ADD X1, X1, #1      // Increment the length counter
		B loop              // Repeat the loop

	done:
		MOV X0, X1          // store the length in X0
		RET                 // Return to the caller
	
.end // end of String_length function
