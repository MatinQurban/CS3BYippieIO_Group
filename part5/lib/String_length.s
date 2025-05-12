// Matin Qurbanzadeh
// CS3B - lab4-1 - String_length
// 02/07/2025
// Computes the length of a null-terminated string.
//
// Algorithm/Pseudocode:
//  1. Initialize X1 (dwStrLen) to 0.
//  2. Load the first byte of the string into W2 (current character).
//  3. Compare the byte with null terminator (0).
//  4. If null, exit loop. Otherwise:
//      a) Increment X0 (string pointer) to point to the next character.
//      b) Increment X1 (string length) to count the character.
//      c) Repeat until null terminator is found.
//  5. Return length in X1.

  //*****************************************************************************
  //String_length
  //  Function String_length: Provided a pointer to a null terminated string in
  //  X0, will return the string's length in X0
  //
  //  X0: Must point to a null terminated string
  //  LR: Must contain the return address (automatic when BL
  //      is used for the call)
  //  All registers except   X0, X1, and X2 are preserved
  //*****************************************************************************

.global String_length // Provide program starting address

String_length:
    .text // code section
		MOV X1, #0			// Start with Str_length = 0
		SL_loop:
			LDRB W2, [X0], 1     // Load the value of the first byte at the starting address of String into W1, POST INCREMENT PTR
			CMP W2, #0	    	 // Compare the byte value with 0 (the ascii number for null)
			B.EQ SL_loopend 	 // If the current char is null, we are at the end of the string. End loop

			ADD X1, X1, #1 		// Increment string length
			B SL_loop 		// Loop

		SL_loopend:
    	// terminate the program (Return to function call)
		RET					// Return to function
	
.data // data section
.end // end of program, optional but good pra
