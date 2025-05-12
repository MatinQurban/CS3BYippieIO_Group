// Matin Qurbanzadeh
// CS3B - lab5-3 - String to Integer Conversion
// 3/1/2025
// Converts a C-String representing a signed integer to a 64-bit integer value
// Algorithm/Pseudocode:
//    Input: X0 points to a null-terminated C-string representing a signed integer
//    Processing:
//       1. Check if string starts with '-' to determine sign
//       2. Initialize result to 0
//       3. For each digit in string:
//          a. Multiply result by 10
//          b. Add current digit value
//          c. Check for overflow
//       4. Apply sign to result
//    Output: X0 contains the 64-bit integer result, or 0 if overflow occurred
// header from coding standard here, set tab to 4 spaces
//*****************************************************************************
// Function cstr2int: Provided a pointer to a C-String representing a valid 
//                    signed integer, converts it to a quad integer. 
//                    If under/overflow occurs, then the overflow flag must be set
//                    and a value of 0 returned.
//
// X0: Must point to a null terminated string that is a valid signed 64 bit decimal number
// X0: signed quad result
// LR: Contains the return address (automatic when BL is used)
// Registers X0 - X8 are modified and not preserved
//*****************************************************************************
.global cstr2int // Provide program starting address

cstr2int:
    .EQU SYS_exit, 93 // exit() supervisor call code
    .text // code section
	STP X29, X30, [SP, #-16]!  // Experimenting with sp and pair from class, Save frame pointer and link register
    MOV X29, SP         // Set frame pointer, points to the frame inside the current stack address
    
	LDR     X1, =szMaxPositive    // "9223372036854775807"
	LDR X2, [X0]
	LDR X1, [X1]
	CMP X1, X2
	B.EQ largestPos

	LDR     X1, =szMaxNegative	  // "-9223372036854775808"
	LDR X2, [X0]
	LDR X1, [X1]
	CMP X1, X2
	B.EQ largestNeg	

    MOV X1, X0          // X1 = pointer to string
    MOV X0, #0          // X0 = result (initialize to 0)
    MOV X2, #0          // X2 = sign flag (0 = positive, 1 = negative)
    
    LDRB W3, [X1]        // Load first character
    CMP W3, #'-'        // Check if negative
    B.NE szPositive      // Branch if not negative
    
    MOV X2, #1          // Set sign flag to negative
    ADD X1, X1, #1      // Move to next character
    
szPositive:
    MOV X4, #10         // X4 = multiplier (10)
    MOV X5, #0          // X5 = current character
    MOV X7, #0x7FFFFFFFFFFFFFFF // Max positive value
    
szLoop:
    LDRB W5, [X1], #1   // Load character and increment pointer
    CMP W5, #0          // Check for null terminator
    B.EQ szDone         // If null, we're done
    
    SUB W5, W5, #'0'    // Convert ASCII to numeric value
    
    // Check if the character is a valid digit (0-9)
    CMP  W5, #0          // Check if less than '0'
    B.LT szOverflow      // If less than 0, invalid
    CMP W5, #9           // Check if greater than '9'
    B.GT szOverflow      // If greater than 9, invalid
    
    // result = result * 10
    SMULL  X6, W0, W4    // X6 = X0 * 10, and set the signs
    CMP  X6, X0          // Check for overflow (result * 10 < result)
    B.LT szOverflow      // If overflow, branch to overflow handler
    MOV X0, X6           // Update result
    
// This line causes errors, comment out for now
    // Check if adding the digit would cause overflow
    //CMP X2, #1           // Check if number is negative
    //B.EQ szNegCheck      // Branch to negative check

    // Check for positive overflow
    SUB X6, X7, X0       // X6 = MAX_INT - result
    CMP X6, X5           // Compare with digit we're about to add
    B.LT szOverflow      // If digit > (MAX_INT - result), overflow
    B szAddDigit         // Skip negative check
    
szNegCheck:
    // For negative numbers, we need to check differently
    CMP X0, #0x8000000000000000 // Check against min negative value
    B.GE  szOverflow     // If greater/equal, potential overflow
    
szAddDigit:
    ADD X0, X0, X5       // Add digit to result
    B szLoop     	     // Process next character
    
szDone:
    // Apply sign
    CMP X2, #1           // Check if negative
    B.NE szReturn        // If not negative, we're done
    
    // Negate the result for negative numbers
    NEG X0, X0           // X0 = -X0
   	B szReturn			 // After negating, done
largestPos:
    MOV     X0, #0x7FFFFFFFFFFFFFFF
    RET

largestNeg:
    MOV     X0, #0x8000000000000000
    RET
 
szReturn:
    LDP X29, X30, [SP], #16  // Restore frame pointer and link register pair from stack, and increment stack to remove pancake
    RET                      // Return to caller
    
szOverflow:
    // Set overflow flag and return 0
    MOV     X0, #0          // Set result to 0
    CMN     X0, #1          // Set overflow flag (compare negative)
    LDP     X29, X30, [SP], #16  // Restore frame pointer and link register
    RET                     // Return to caller
.data // data section
szMaxPositive:  .asciz "9223372036854775807"
szMaxNegative:  .asciz "-9223372036854775808"
.end // end of program, optional but good pra
