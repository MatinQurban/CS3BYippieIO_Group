// Matin Qurbanzadeh
// CS3B - lab4-1 - putstring
// 02/07/2025
// Uses a supervisor (system) call to output a string to the console.
//
// Algorithm/Pseudocode:
//  1. Save the return address in X3 (since LR will be modified when calling to another funciton).
//  2. Call String_length to determine the length of the string in X1.
//  3. Adjust the string pointer (X0) to point back to the original start.
//  4. Set up parameters for the Linux `write` syscall.
//  5. Make the system call to print the string.
//  6. Restore LR and return to caller.

  //*****************************************************************************
  //putstring
  //  Function putstring: Provided a pointer to a null terminated string in
  //  X0, will output the string on the console
  //
  //  X0: Must point to a null terminated string
  //  LR: Must contain the return address (automatic when BL
  //      is used for the call)
  //  All registers except   X0, X1, X2, X3, and X8 are preserved
  //*****************************************************************************

.global putstring // Provide program starting address

putstring:

    .text // code section
		MOV X3, LR // Copy the return address into X3, because we are going to change LR
		MOV X8, X0 // Copy address of string
		// X0 -> string ptr, X1 -> string length, LR -> return to this point
		BL String_length // Returns the length of the string and stores it in X1

		// At this point, X1 has our string length, X0 holds the address to our string
	
		// Linux system call to print, X0 -> Linux parameter write where, X1 -> ptr to string, X2 -> String length, X8 -> linux call command
		// ERROR CHECK: X0 gets modified in String_length function, need to reset it to original ptr
		// Error with this line:	SUB X0, X0, X1 // Does this work? Just decrement ptr by string length to get back to first char
 		MOV X2, X1     // length of output string, determined from String_length
		MOV X1, X8	   // Move pointer to string into X1 for system call parameter
		MOV X0, #1     // 1 = STDout
 		MOV X8, #64    // Linux write system call
	    SVC 0          // Call Linux to output the string
		
		// Return to function call
		MOV LR, X3 		// Return original LR back to prepare for return call
		RET				// Return to where this function was called		
.data // data section
.end // end of program, optional but good pra
