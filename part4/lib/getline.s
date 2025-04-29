//*****************************************************************************
// Name: Matin Qurbanzadeh
// CS3B - LAB7-2 - getline function
// Date last modified: 03/28/25
//
//
// Algorithm/Pseudocode:
//    1. Initialize stack pointer for the buffer and set up counters.  
//    2. Enter a loop to read one byte at a time from the file descriptor.  
//       - If the character read is '\n', exit the loop.  
//       - If 0 bytes are read, assume EOF and exit the loop.  
//       - If max buffer length is reached, stop reading.  
//    3. Append the character to the user buffer.  
//    4. Repeat until a stopping condition is met.  
//    5. Append a null terminator to the buffer.  
//    6. Return the number of bytes read and string buffer.
//
// Registers Used:
//    - X0: File descriptor (input) / Number of bytes read (output)
//    - X1: Buffer pointer (must be preserved)
//    - X2: Maximum buffer length
//    - X3: Counter for bytes read
//    - X4: Maximum length tracker
//    - X8: System call number (SYS_READ)
//*****************************************************************************
// Function getline:  Provided a file descriptor, max characters to read count, 
//                    and a pointer to a buffer large enought to hold that max,
//                    return the number of characters read (including '\n') and
//                    a line from the file stored in the buffer as a C-String
//                    (excluding any '\n').
//
//  X0: Must be a file descriptor for a file successfully opened for read
//      access by the caller. On return from the function, X0 should hold the
//      number bytes read, including the '\n' if it was encountered.
//  X1: Points to the first byte of the buffer to receive the line. This must
//      be preserved (i.e. X1 should still point to the buffer when this function
//      returns).
//  X2: The maximum length of the buffer pointed to by X1 (note this length
//      should account for the null termination of the read line (i.e. C-String)
//  LR: Must contain the return address (automatic when BL
//      is used for the call)
//  Registers X0 - X8 are modified and not preserved
//*****************************************************************************


.global getline // Provide program starting address

getline:
    .EQU SYS_exit, 93 // exit() supervisor call code
    .text // code section
	// Save loop variables into registers and return pointers into stack
	SUB X2, X2, #1	// Account for null character placement at the end in max length
	STR X1, [SP, #-16]!	// Save string buffer into new stack allocation
	MOV X4, X2		// Save length of buffer into X4
	MOV X3, #0		// Initialize how many chars we have read (LCV)
	MOV X5, X0		// Save file descriptor in x5
	//	LDR X2, =wFD	// Load address to store file descriptor
	//STR W0, [X2]	// Store file descriptor into address
	// Read from file using SYS_READ()
readLineLoop:
	CMP X3, X4			// Compare the number of bytes read to the maximum buffer length
	B.EQ readLineEnd	// If we have reached the maximum length, stop reading

	// SYS_READ() 63:  X0 = fileDesc , X1 = destination , X2 = read count
	//	LDR X0, =wFD		// Read needs file descriptor in X0
	//	LDRB W0, [X0]		// Store file descriptor value
	MOV X0, X5			// Read needs file descriptor in X0
	LDR X1, =czBuffer	// Read needs destination address in X1
	MOV X2, #1			// Read needs how many to read
	MOV X8, #63			// SYS_READ() system number
	SVC 0				// Supervisor call

	// Check char and append into user buffer	
	LDRB W1, [X1]		// Load first byte of X1 into W1 to account for leftover data in surrounding addresses
	CMP X0, #0			// Check if we read more than 0 characters
	B.EQ getLineReturn	// If we have read 0 bytes, we have reached end of file
	CMP W1, #'\n'		// Compare the read char with newline
	B.EQ readLineEnd	// If it's a newline, stop reading. Jump to end sequence

	// Now that we have read the char, append it to our string
	LDR X2, [SP]		// Load string buffer address
	ADD X2, X2, X3		// Move pointer to next open position
	STRB W1, [X2], #1	// Store char byte into pointer, increment pointer
	ADD X3, X3, #1		// Add 1 to our total amount of read chars
 	B readLineLoop		// Read next byte, loop.

readLineEnd:
	// At this point we have encountered an end or there is only one spot left in our buffer
	// Append null character and return
	MOV X0, #0			// Copy null into register
	LDR X2, [SP]		// Load string buffer address
	ADD X2, X2, X3		// Move pointer to next open position
	STRB W0, [X2]		// Store null into final position of string buffer
	ADD X3, X3, #1		// Add 1 to our total amount of read chars

getLineReturn:
	// Set up variables for return
	LDR X1, [SP], #16	// Deallocate stack and load string buffer into X1 for return
	MOV X0, X3			// Move number of bytes read into X0 to prepare for return
	
	RET 				// Return to caller	
.data // data section	
	wFD:		.skip 4 // 4 bytes to store file descriptor
	czBuffer:	.byte // char buffer to read single byte into
.end // end of program, optional but good pra
