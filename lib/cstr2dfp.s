//*****************************************************************************
// Function cstr2dfp: Provided a pointer to a C-String representing a valid 
//                    floating point number, converts it to a double floating
//                    point value. 
//
// X0: Must point to a null terminated string that is a valid signed floating
//     point number.
// D0: signed double floating point result
// LR: Contains the return address (automatic when BL is used)
// Registers X0 - X8 are modified and not preserved
//*****************************************************************************
.global cstr2dfp // Provide program starting address

cstr2dfp:
.EQU SYS_exit, 93 // exit() supervisor call code
.text // code section
	MOV X7, #0		// X7 will serve as our negflag register, set to 0
	MOV X1, #0		// Move immediate value 0 into X1
	SCVTF D0, X1		// D0, our return register, will also serve as our accumulator, initialize to 0.
	
	LDRB W1, [X0], #1	// X1 will hold the char representation of our current digit
	CMP X1, #'-'		// Check if the first char is a negative sign
	B.NE convertStart	// If not negative, continue to string parse
	MOV X7, #1			// If negative, raise negative flag
	LDRB W1, [X0], #1	// Increment current char to point to the first digit

convertStart:
	MOV X2, #10			// X2 will serve as our multiplier
	SCVTF D2, X2			// Convert multiplier to fp
	MOV X4, #10			// X4 will represent the place we place our fractional digit
	SCVTF D3, X4			// Convert place to fp
	MOV X3, #'0'		// X3 will be our reference char register
wholeNumLoop: // this loop will behave exactly like our cstr2int function

	SUB X1, X1, X3		// Value = char - ascii(0) 
	SCVTF D1, X1			// Move value to D register to prepare for accumulate
	FADD D0, D0, D1		// Add value to the accumulator

	// Loop variable portion: check end conditions, update pointer, update accumulator place
	LDRB W1, [X0], #1	// Update to next char
	CMP W1, #0			// Check if null (end of string)
	B.EQ endParse		// If null, we're done converting, return.
	CMP W1, #'.'		// Check if period (end of whole number)
	B.EQ fractionLoop	// If period, start parsing as a fraction instead of whole num
	
	FMUL D0, D0, D2		// multiply by 10 to shift digits place
	B wholeNumLoop		// Loop

fractionLoop: // this loop will divide the value before adding it to our accumulator
	LDRB W1, [X0], #1	// Update pointer 
	CMP W1, #0			// Check if null (end of string)
	B.EQ endParse		// If null, we're done converting, return.

	SUB X1, X1, X3		// Digit = char - ascii(0)
	SCVTF D1, X1			// Convert digit to fp
	FDIV D1, D1, D2		// Value = digit / place
	FADD D0, D0, D1		// Add decimal value to accumulator
	
	FMUL D2, D2, D3		// Shift digit place multiplier
	B fractionLoop		// loop
    
endParse:
	CMP X7, #0			// Check our neg flag
	B.EQ returnC2FP		// if it is not raised, return from function
	FNEG D0, D0			// Negate the return value since negative flag was raised
returnC2FP:
	RET		// Return to caller
.data // data section
.end // end of program, optional but good pra
