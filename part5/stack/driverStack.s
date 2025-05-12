// Name: Sean W., Matin Q.
// CS3B: Group Project YippieIO 5 - Stack Driver
//
// **************************** Stack Driver ****************************  
// This program will dynamically allocate space for a stack, push 
// floating-point values onto it, pop values off the stack, pseudo-clear
// the stack by resetting the stack pointer, and finally free the 
// allocated memory for the stack.
// **********************************************************************
//  
// -------- Algorithm --------  
// Call constructor with element count and data size  
// Push two values (1.5, 2.25) onto the stack  
// Pop one value off the stack (verify correct order and value)  
// Clear the stack by resetting stack_ptr to base_ptr  
// Call destructor to free heap memory  
// End.

.global _start // Provide program starting address

_start:
.EQU SYS_exit, 93 // exit() supervisor call code
.EQU DATA_SZ, 8		// size of data members to be pushed onto stack
.EQU STACK_SZ, 100	// total number of data members allowed on stack
    .text // code section

    MOV X0, #STACK_SZ             // size
    MOV X1, #DATA_SZ              // data_size (double)
    BL stackConstructor           // call constructor
// Push values
	LDR X0, =dVal1				  // Load address of value 1
	LDR D0, [X0]				  // Load value of address into D0
	BL stackPush				  // Call stack push

	LDR X0, =dVal2				  // Load address of value 2
	LDR D0, [X0]				  // Load value of address into D0
	BL stackPush				  // Call stack push
// Pop Values
	BL pop		// Call pop
	LDR X0, =formattingString	  // Load address of formatting string in X0
	BL printf	// Printf to output the value we just pushed

	BL pop		// Call pop
	LDR X0, =formattingString	  // Load address of formatting string in X0
	BL printf	// printf

	BL stackDestructor			  // call destructor

    // terminate the program
    MOV X0, #0 // set return code to 0, all good
    MOV X8, #SYS_exit // set exit() supervisor call code
    SVC 0 // call Linux to exit
.data // data section
szPopERR:	.asciz	"Stack empty: Pop Failed!"
szPushErr:	.asciz	"Stack full: Push failed!"
dVal1:		.double 12.5
dVal2:		.double 2.0
formattingString:    .asciz        "%.20f\n"    // For printf
.end // end of program, optional but good pra
