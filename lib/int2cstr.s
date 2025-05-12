//*****************************************************************************
// Function int2cstr: Provided a signed integer, will convert it to a C-String 
//                    stored stored in memory pointed to by a provided pointer
//                    that must be large enough to hold the converted value. 
//                    Usually a string of 21 bytes is more than sufficient to allow  
//                    for a sign as well as the largest possible value a word could be.
//
// X0: Contains the binary (signed) value to be converted to a C-String
// X1: Must point to address large enough to hold the converted value.
// LR: Contains the return address (automatic when BL is used)
// Registers X0 - X8 are modified and not preserved.global _start 

// Provide program starting address
.global int2cstr
int2cstr:
    .EQU SYS_exit, 93 // exit() supervisor call code
    .text // code section
		MOV X7, LR 			// Copy the return address into X3, because we are going to change LR
		MOV X5, #0			// This will serve as our string count
		LDR X3, =negFlag	// Load address of negFlag
		MOV X2, #0			// Reset negFlag
		STR X2, [X3]		// Reset negFlag

		// STEP 0: Negative check
		CMP X0, #0			// Compare X0 to 0	

		B.GE _digitSep		// If greater/equal to 0 (positive), skip negation
		MOV W2, #'-'		// Else, move immediate value of '-' negative sign
		STRB W2, [X1], #1	// Store negative sign into first pos of strzbuffer and increment X1 
		MOV X5, #1			// String count is one now that there is a negative sign
		NEG X0, X0			// Negate the binary signed value inside X0
		LDR X3, =negFlag	// Load negFlag address
		MOV X2, #1			// Move nonzero value into w2
		STR X2, [X3]		// Store nonzero value in negFlag

		
		// Continue on to parsing the value
		// We need to separate the individual digits, using base 10 manipulation
		_digitSep:		
			MOV X3, #10			// register for division and mult
			UDIV X2, X0, X3		// Signed integer division: Number ÷ 10. Store in X2
			
			//Get the remainder: Dividend - (Quotient * 10) 
			MUL X3, X2, X3		// Result of above SDIV times 10, store product in X3
			SUB X4, X0, X3		// X4 = X0 - X3 -> X4 = Dividend - (Quotient * 10), store result in X4
			
			// VARIABLE CHECK -> X0: Value before SDIV, X1: address to place next digit inside digits array, X2: X0 without the last digit, X3: X2*10, X4: remainder

			// Now we need to store the remainder and update Dividend
			ADD W4, W4, #'0' 	// Convert the remainder from a digit to it's ascii value
			STRB W4, [X1], #1	// X4 -> X1 (Next open position of digits array) and increment pointer
			MOV X0, X2			// Update dividend to reflect capture of last digit	
			ADD X5, X5, #1		// Increment count
			// end condition: if the result of SDIV is 0, exit loop and begin output
			CMP X2, #0			// compare quotient(X2) to 0
			B.NE _digitSep		// if nonzero quotient, loop

		// At this point rgiDigits holds each individual digit, but in reverse order, we need to swap the order
		// Reverse the order of digits
   		SUB X1, X1, X5			// Move back the first position of the string buffer
   		MOV X6, X1				// Save starting position of X1 
	   	SUB X5, X5, #1			// X5 goes to null, one before null is last char
		ADD X2, X1, X5          // X2 points to the end of the string
		
		// Check and account for sign
		LDR X8, =negFlag		// Load address of negFlag
		LDR X8, [X8]			// Load value of negFlag into X8
		CMP X8, #0				// Compare negflag to 0
		B.EQ _reverse			// If negflag is nonzero, skip next step
		ADD X1, X1, #1			// Move string pointer one forward to account for sign
    	_reverse:
			CMP X1, X2          // Compare front and back pointers
    		B.GE _addNull       // If they meet or cross, stop swapping

    		LDRB W3, [X1]       // Load front character
    		LDRB W4, [X2]       // Load back character
    		STRB W4, [X1]       // Store back character at front
    		STRB W3, [X2]       // Store front character at back

    		ADD X1, X1, #1      // Move front pointer forward
    		SUB X2, X2, #1      // Move back pointer backward

    		B _reverse          // Repeat until condition met
		_addNull:			
			ADD X5, X5, #2		// Point to after the last char (+1 to negate previous x5 sub, +1 to account for sign)
			MOV X1, X6		    // Reset pointer to start of string
        	ADD X1, X1, X5      // Move to the null-termination position
        	MOV W3, #0          // Null character
        	STRB W3, [X1]       // Store null terminator
    

		MOV X0, X6			    // Load string address into X0	
		MOV LR, X7			    // Return original LR to prepare for return call
    	RET                     // Return to caller

.data // data section
	negFlag: 	.byte 	1
.end // end of program, optional but good pra
