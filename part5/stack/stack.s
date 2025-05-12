.data
STACK_BASE_PTR:		.quad 0	// base_ptr for stack
STACK_STACK_PTR:	.quad 0	// stack_ptr for element placement in stack
STACK_DATA_SIZE:	.quad 0	// size of data members in stack
STACK_TOTAL_LEN:	.quad 0	// total length of stack
STACK_TOTAL_SIZE:	.quad 0	// total size of stack (data * len)


.text
// ****************** HELPER FUNCTION : stackConstructor ********************
//	Description: dynamically allocates memory for a new stack
//	Function Definition: Stack* stackConstructor(int size, int data_size)
//	Parameters:
//		X0: size (number of elements)
//		X1: data_size (size of each element in bytes)
//	Return:
//		X0: pointer to base of allocated stack memory (base_ptr = stack_ptr)
//	Algorithm:
//		- Multiply size * data_size to get total size in bytes
//		- Call malloc(total size) to allocate memory
//		- Set base_ptr = malloc result
//		- Set stack_ptr = base_ptr
//		- Return base_ptr
//	Note:
//		This function calls malloc, which may overwrite: 
//		X0, X1, X8, X9, X10, X11, X12, X13, X16, X17, LR, and others
//		The caller must save necessary registers if needed before calling.

.global stackConstructor
stackConstructor:
    STR LR, [SP, #-16]!       // Save LR
	LDR X2, =STACK_TOTAL_LEN	// Load address of stack length
	STR X1, [X2]			  // Store size into variable stack_length
	LDR X2, =STACK_DATA_SIZE	// Load address of stack data size
	STR X0, [X1]			  // Store data size into variable data_size

    MUL X2, X0, X1            // X2 = size * data_size
	LDR X1, =STACK_TOTAL_SIZE 	// Load address of stack total size
	STR X2, [X1]			  // Store calculated total size into variable total_size

    MOV X0, X2                // Set malloc parameter to X0
    BL malloc                 // Call malloc(total_size), result in X0

	LDR X1, =STACK_BASE_PTR	  // Load address of stack base pointer
	STR X0, [X1]			  // Store stack PTR into variable base ptr
	LDR X1, =STACK_STACK_PTR  // Load address of stackptr
	STR X0, [X1]			  // Store heap address as our current elem ptr

	LDR LR, [SP], #16         // Restore LR
    RET                       // Return to caller



// ****************** HELPER FUNCTION : stackDestructor ********************
//	Description: Frees memory allocated for a stack
//	Function Definition: void stackDestructor()
//	Parameters:
//		None
//	Return:
//		None
//	Algorithm:
//		- Call free(base_ptr) to deallocate stack memory
//	Note:
//		This function calls free, which may overwrite: 
//		X0, X1, X3, X4, X5, X6, X7, X8, X12, X13, X16, X17, and others
//		The caller must save necessary registers if needed before calling.
.global stackDestructor
stackDestructor:
	STR LR, [SP, #-16]!   // Save LR

	LDR X0, =STACK_BASE_PTR	// load address of base ptr
	LDR X0, [X0]		  // load value of base ptr
	BL free               // Call free with base_ptr in X0

	LDR LR, [SP], #16     // Restore LR
	RET                   // Return to caller


// ****************** STACK FUNCTION : stackPush ********************
//	Description: Pushes a double value onto the stack if space is available
//	Function Definition: bool stackPush(Stack* stack, double value)
//	Parameters:
//		X0: Pointer to Stack object
//		D0: Value to push (double)
//	Return:
//		W0: 0 if stack is full (push failed), 1 if push succeeded
//	Algorithm:
//		- Calculate full_size = base_ptr + total_size
//		- If stack_ptr == full_size, return 0
//		- Else:
//			- Store value at stack_ptr
//			- Increment stack_ptr by data_size
//			- Return 1
.global stackPush
stackPush:
	STR LR, [SP, #-16]!         // Save LR

	// X0 contains Stack* pointer

	// Load base_ptr and total_size
	LDR X1, =STACK_BASE_PTR    // X1 = base_ptr
	LDR X1, [X1]			   // Load value into X1
	LDR X2, =STACK_TOTAL_SIZE  // X2 = total_size
	LDR X2, [X2]			   // Load value into X2
	ADD X3, X1, X2                   // X3 = full_size (end of stack)

	// Load stack_ptr
	LDR X4, =STACK_STACK_PTR   // X4 = stack_ptr
	LDR X4, [X4]			   // Load value into X4

	// Check if stack_ptr == full_size
	CMP X3, X4
	B.EQ stackPush_Fail              // if full, branch to fail

	// Store the double value at stack_ptr
	STR D0, [X4]

	// Increment stack_ptr by data_size
	LDR X4, =STACK_STACK_PTR   // X4 = stack_ptr
	LDR X4, [X4]			   // Load value into X4
	LDR X5, =STACK_DATA_SIZE  // X5 = data_size
	LDR X5, [X5]				// Load value into X5
	ADD X4, X4, X5				// New stackptr = current sp + data_size
	
	LDR X1, =STACK_STACK_PTR	// Load address of stackptr
	STR X4, [X1]        // Update stack_ptr

	// Return 1 (success)
	MOV W0, #1			// Move immediate value1 to return reg
	B stackPush_End		// End

stackPush_Fail:
	MOV W0, #0			// If stackptr == full_size, return 0

stackPush_End:
	LDR LR, [SP], #16
	RET



// ****************** STACK METHOD : pop ********************
// Description:
//     Removes and returns the top element of the stack.
// Function Definition:
//     double pop()
// Return:
//     D0: double value popped from the stack
// Algorithm:
//     - If stack_ptr == base_ptr, stack is empty
//         - Return value at stack_ptr (undefined behavior)
//     - Else
//         - Decrement stack_ptr by data_size
//         - Return value at stack_ptr

.global pop              // Make the pop function globally accessible

pop:
    STR LR, [SP, #-16]!      // Push Link Register onto stack to preserve return address

    LDR X1, =STACK_BASE_PTR  // Load address of STACK_BASE_PTR into X1
    LDR X1, [X1]             // Dereference address to get value of base_ptr into X1

    LDR X2, =STACK_STACK_PTR // Load address of STACK_STACK_PTR into X2
    LDR X2, [X2]             // Dereference to get value of stack_ptr into X2

    LDR X3, =STACK_DATA_SIZE // Load address of STACK_DATA_SIZE into X3
    LDR X3, [X3]             // Dereference to get value of data_size into X3

    CMP X1, X2               // Compare base_ptr (X1) and stack_ptr (X2)
    B.EQ return_undefined    // If stack is empty (equal), skip decrement

    SUB X2, X2, X3           // Decrement stack_ptr by data_size (pop)

    LDR X4, =STACK_STACK_PTR // Load address of STACK_STACK_PTR into X4
    STR X2, [X4]             // Store updated stack_ptr back into memory

return_undefined:
    LDR D0, [X2]             // Load 64-bit double value from stack_ptr into D0 (return value)

    LDR LR, [SP], #16        // Restore Link Register from stack
    RET                      // Return to caller





// ****************** STACK METHOD : delete ********************
// Description:
//     Pseudo-clears the stack by resetting stack_ptr to base_ptr.
// Function Definition:
//     void delete()
// Parameters:
//     None (uses global stack data)
// Algorithm:
//     - Load base_ptr
//     - Store it into stack_ptr to "clear" the stack (logical reset)

.global delete           // Make the delete function globally accessible

delete:
    STR LR, [SP, #-16]!      // Push Link Register onto stack to preserve return address

    LDR X0, =STACK_BASE_PTR  // Load address of STACK_BASE_PTR into X0
    LDR X1, [X0]             // Load base_ptr value from memory into X1

    LDR X0, =STACK_STACK_PTR // Load address of STACK_STACK_PTR into X0
    STR X1, [X0]             // Store base_ptr into stack_ptr (reset stack)

    LDR LR, [SP], #16        // Restore Link Register from stack
    RET                      // Return to caller

.end // end of program, optional but good pra
