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
//	1. Input Processing:
//	   a. Initialize GPIO pins for keypad input
//	   b. Enter main input loop
//	   c. Get keypad press and convert raw code to ASCII character
//	   d. If character is a digit or decimal point, add it to input buffer
//	   e. If character is 'E', convert buffer to number and push to stack
//	   f. If character is an operator, perform corresponding operation
//	   g. Echo each character to console
//	
//	2. Mathematical Operations (RPN):
//	   a. Addition (+): Pop two values, add them, push result
//	   b. Subtraction (-): Pop two values, subtract second from first, push result
//	   c. Multiplication (x): Pop two values, multiply them, push result
//	   d. Division (/): Pop two values, divide first by second, push result
//	   e. Handle errors: stack underflow, division by zero
//	
//*****************************************************************

// *******************************
//	Keyboard layout for reference
// -------------------------------
//	1    2    3     /
//	4    5    6     x
//	7    8    9     -
//	.    0    E     +
// *******************************

// To do 2 + 2 = 4. Type in 2, E, 2, E, +.
// Result should be 4.

#include "gpiomem.S"              // Include GPIO memory mapping definitions

.global _start      // Provide program starting address

_start:

    .EQU SYS_exit, 93           // Linux exit syscall number
    .EQU DATA_SZ, 8
    .EQU STACK_SZ, 100
    
    .text   // code section
        
    initializePins 		    // Macro: configure and map GPIO pins for keypad scanning
	LDR X1, =gpioRegAddr	// load gpio virtual address storage
	STR X9, [X1]			// saving virtual address into storage
    
    MOV X1, #DATA_SZ
    MOV X0, #STACK_SZ
    BL stackConstructor

    // Initialize calculator variables
    LDR X1, =input_buffer       // Load address of input buffer into X1
    MOV X0, #0                  // Set X0 to 0 (null terminator)
    STRB W0, [X1]               // Store null terminator at start of buffer
    
    LDR X1, =input_index        // Load address of input index into X1
    MOV X0, #0                  // Set X0 to 0
    STR X0, [X1]                // Initialize input index to 0

    // Main input loop: process keypad inputs
clac_loop:
	LDR X1, =gpioRegAddr	// load gpio virtual address storage
	LDR X9, [X1]
    MOV X0, #1 		            // Place 1 into X0 to indicate blocking mode for getKey
    BL getKey    	            // Call getKey: waits for a keypad press, returns raw code (1-16) in X0    

    // Convert raw keypad code (1-16) into its ASCII character from keyMap
    SUB X0, X0, #1   	        // Decrement X0 by 1 to convert to 0-based index (0-15)
    LDR X1, =keyMap             // Load address of keyMap table into X1
    ADD X1, X1, X0              // Add index offset to X1, pointing to the correct byte in keyMap
    LDRB W0, [X1]               // Load the ASCII byte at [X1] into W0 (the character)

    // Echo the character to the console 
    LDR X1, =char_buffer        // Load address of character buffer
    STRB W0, [X1]               // Store the character
    MOV W2, #0                  // Set W2 to 0 (null terminator)
    STRB W2, [X1, #1]           // Null-terminate the single character
    MOV X0, X1                  // Move buffer address to X0 for putstring
    BL putstring                // Call putstring to output the character
    
    // Store the character for processing
    LDR X1, =char_buffer        // Reload character buffer address
    LDRB W0, [X1]               // Load the character back into W0
    
    // Check if character is an operator or Enter
    CMP W0, #' '                // Compare with Enter key
    B.EQ process_enter          // Branch to process_enter if equal
    
    // Not an operator or Enter, must be a digit or decimal point - add to buffer
    LDR X1, =input_index        // Load address of input index
    LDR X2, [X1]                // Load current index value
    
    LDR X3, =input_buffer       // Load address of input buffer
    STRB W0, [X3, X2]           // Store character at buffer[index]
    
    ADD X2, X2, #1              // Increment index
    STR X2, [X1]                // Store updated index
    
    MOV W0, #0                  // Set W0 to 0 (null terminator)
    STRB W0, [X3, X2]           // Null-terminate the buffer
    
    B clac_loop                 // Branch back to main loop for next input

// Process Enter key - push number to stack
process_enter:
	SUB X2, X2, #1
    LDR X3, =input_buffer       // Load address of input buffer
    STRB W0, [X3, X2]           // Store character at buffer[index]

    CMP W0, #'+'                // Compare with addition operator
    B.EQ do_addition            // Branch to addition if equal
    CMP W0, #'-'                // Compare with subtraction operator
    B.EQ do_subtraction         // Branch to subtraction if equal
    CMP W0, #'x'                // Compare with multiplication operator
    B.EQ do_multiplication      // Branch to multiplication if equal
    CMP W0, #'/'                // Compare with division operator
    B.EQ do_division            // Branch to division if equal

    // Process Enter - convert buffer to number and push to stack
    LDR X0, =input_buffer       // Load address of input buffer
    LDR X1, [X0]                // Load first word of buffer to check if empty
    
    // Check if buffer is empty
    CMP X1, #0                  // Compare with 0
    B.EQ clac_loop              // If empty, branch back to input loop
    
    // Convert string to floating point
    //LDR X0, =input_buffer       // Load buffer address for conversion
    //BL putstring
    LDR X0, =input_buffer
    BL cstr2dfp                 // Call cstr2dfp to convert string to floating point
    
    // Push the converted number to stack
    BL push                     // Call push to add X0 to stack
    
    // Print the value
    //FMOV D0, D19                // Move value to D0 for printf
    //LDR X0, =fpFormat           // Load format string into X0
    //BL printf                   // Call printf with format in X0 and value in D0
        
    // Reset input buffer for next number
    LDR X1, =input_index        // Load address of input index
    MOV X0, #0                  // Set X0 to 0
    STR X0, [X1]                // Reset index to 0
    
    LDR X1, =input_buffer       // Load address of input buffer
    STRB W0, [X1]               // Reset buffer with null terminator
    
    B clac_loop                 // Branch back to input loop

// Addition operation
do_addition:
    // Pop first value
    BL pop                      // Call pop to get first value from stack
    
    FMOV D19, D0                 // Save first value in X19
    
    // Pop second value
    BL pop                      // Call pop to get second value
    
    FMOV D20, D0                 // Save second value in X20
    
    // Perform floating point addition directly
    FADD D0, D20, D19            // Add X19 to X20, store in X0
    
    // Push result back to stack
    BL push                     // Push result to stack
    
    // Display calculation
    LDR X0, =calc_msg           // Load "Calculation: " message
    BL putstring                // Print the message
    
    // Print first operand
    FMOV D0, D20                // Move first operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print operator
    LDR X0, =add_op             // Load addition operator string
    BL putstring                // Print the operator
    
    // Print second operand
    FMOV D0, D19                // Move second operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print equals
    LDR X0, =equals_msg         // Load equals message
    BL putstring                // Print equals
    
    // Print result
    BL pop                      // Pop the result we just pushed
    
    // Save result for re-pushing
    FMOV D21, D0                 // Save result in X21
    
    // Print the value
    FMOV D0, D21                // Move result to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Push result back to stack
    FMOV D0, D21                 // Restore result from X21
    BL push                     // Push it back to stack
    
    B clac_loop                 // Branch back to input loop
    
// Subtraction operation
do_subtraction:
    // Pop first value (subtrahend)
    BL pop                      // Call pop to get first value
    
    FMOV D19, D0                 // Save first value in X19
    
    // Pop second value (minuend)
    BL pop                      // Call pop to get second value
    
    FMOV D20, D0                 // Save second value in X20
    
    // Perform floating point subtraction directly
    FSUB D0, D20, D19            // Subtract X19 from X20, store in X0
    
    // Push result back to stack
    BL push                     // Push result to stack
    
    // Display calculation
    LDR X0, =calc_msg           // Load "Calculation: " message
    BL putstring                // Print the message
    
    // Print first operand
    FMOV D0, D20                // Move first operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print operator
    LDR X0, =sub_op             // Load subtraction operator string
    BL putstring                // Print the operator
    
    // Print second operand
    FMOV D0, D19                // Move second operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print equals
    LDR X0, =equals_msg         // Load equals message
    BL putstring                // Print equals
    
    // Print result
    BL pop                      // Pop the result we just pushed
    
    // Save result for re-pushing
    FMOV D21, D0                 // Save result in X21
    
    // Print the value
    FMOV D0, D21                // Move result to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Push result back to stack
    FMOV D0, D21                 // Restore result from X21
    BL push                     // Push it back to stack
    
    B clac_loop                 // Branch back to input loop
    
// Multiplication operation
do_multiplication:
    // Pop first value
    BL pop                      // Call pop to get first value
    
    FMOV D19, D0                 // Save first value in X19
    
    // Pop second value
    BL pop                      // Call pop to get second value
    
    FMOV D20, D0                 // Save second value in X20
    
    // Perform floating point multiplication directly
    FMUL D0, D20, D19            // Multiply X20 by X19, store in X0
    
    // Push result back to stack
    BL push                     // Push result to stack
    
    // Display calculation
    LDR X0, =calc_msg           // Load "Calculation: " message
    BL putstring                // Print the message
    
    // Print first operand
    FMOV D0, D20                // Move first operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print operator
    LDR X0, =mul_op             // Load multiplication operator string
    BL putstring                // Print the operator
    
    // Print second operand
    FMOV D0, D19                // Move second operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print equals
    LDR X0, =equals_msg         // Load equals message
    BL putstring                // Print equals
    
    // Print result
    BL pop                      // Pop the result we just pushed
    
    // Save result for re-pushing
    FMOV D21, D0                 // Save result in X21
    
    // Print the value
    FMOV D0, D21                // Move result to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Push result back to stack
    FMOV D0, D21                 // Restore result from X21
    BL push                     // Push it back to stack
    
    B clac_loop                 // Branch back to input loop
    
// Division operation
do_division:
    // Pop first value (divisor)
    BL pop                      // Call pop to get divisor
    
    FMOV D19, D0                 // Save divisor in X19
    
    // Check for division by zero
    FCMP D19, #0                 // Compare divisor with 0
    B.EQ division_by_zero       // If 0, branch to division by zero error
    
    // Pop second value (dividend)
    BL pop                      // Call pop to get dividend
    
    FMOV D20, D0                 // Save dividend in X20
    
    // Perform floating point division directly
    FDIV D0, D20, D19           // Divide X20 by X19, store in X0
    
    // Push result back to stack
    BL push                     // Push result to stack
    
    // Display calculation
    LDR X0, =calc_msg           // Load "Calculation: " message
    BL putstring                // Print the message
    
    // Print first operand
    FMOV D0, D20                // Move first operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print operator
    LDR X0, =div_op             // Load division operator string
    BL putstring                // Print the operator
    
    // Print second operand
    FMOV D0, D19                // Move second operand to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Print equals
    LDR X0, =equals_msg         // Load equals message
    BL putstring                // Print equals
    
    // Print result
    BL pop                      // Pop the result we just pushed
    
    // Save result for re-pushing
    FMOV D21, D0                 // Save result in X21
    
    // Print the value
    FMOV D0, D21                // Move result to D0
    LDR X0, =fpFormat           // Load format string into X0
    BL printf                   // Print using printf
    
    // Push result back to stack
    FMOV D0, D21                 // Restore result from X21
    BL push                     // Push it back to stack
    
    B clac_loop                 // Branch back to input loop

// Error handling for division by zero
division_by_zero:
    // Division by zero error
    LDR X0, =error_div_zero     // Load division by zero error message
    BL putstring                // Print the error message
    B clac_loop                 // Branch back to input loop

// Program termination
done:
    // Print a newline to separate input and termination
    LDR X0, =szNewline          // Load newline string
    BL putstring                // Print newline
    
    BL stackDestructor

	// terminate program
	MOV X0, #0			        // Set return code to 0 (success)
	MOV X8, #SYS_exit           // Set syscall number for exit
	SVC 0			            // Call Linux to exit
    
    // Data section - constant values and buffers
    .data	
keyMap:          .ascii "123/456x789-.0 +"   // Lookup table mapping 1-16 to ASCII chars
char_buffer:     .skip 2                     // Buffer for single character (char + null terminator)
input_buffer:    .skip 20                    // Buffer for collecting input digits
input_index:     .quad 0                     // Current index in input buffer
fpFormat:        .asciz "%.20f\n"            // Format string for printf
error_div_zero:  .asciz "Error: Division by zero\n" // Error message for division by zero
calc_msg:        .asciz "Calculation: "      // Prefix for calculation display
equals_msg:      .asciz " = "                // Equals sign for calculation display
stack_peek_msg:  .asciz "Pushed: "           // Message for pushed values
szNewline:       .asciz "\n"                 // Newline string
add_op:          .asciz " + "                // Addition operator
sub_op:          .asciz " - "                // Subtraction operator
mul_op:          .asciz " * "                // Multiplication operator
div_op:          .asciz " / "                // Division operator
gpioRegAddr: .quad 0

.end	// End of program
