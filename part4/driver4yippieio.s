// Sean Viravouth, Matin Qurbanzadeh
//  CS3B - Yippie IO: Part 4 - Driver for getkey
//	05/06/2025

// Desc: This program will use call get key and print the 
//		 value of the key pressed (1-16) in both blocking
//		 and non-blocking modes

// Algo:
//		Prompt user for blocking mode
//		Start getKey loop
//		Print resluting key


.global _start	// Provide program starting address

_start:	// program start
	
		MOV W6, #100		// Load immediate 100 into W6 for iteration count
loopBlocking:
		MOV X0, #1			// getKey uses X0 to denote blocking or nonblocking
		BL getKey 			// Call getKey, returns value 0-16 in X0
		
		SUBS W6, W6, #1		// Decrement W6; update condition flags
		B.NE loop			// If W6 != 0, branch back to loop
		
		Mov W6, #100		// Load immediate 100 into W6 for iteration count
loopNonBlocking:
		MOV X0, #0			// getKey uses X0 for blocking mode
		BL getKey			// Call getKey, returns value 0-16 in X0

// Terminate program
		MOV X0, #0		// Set exit code 0 in X0
		MOV X8, #93		// SYS_CALL number 93 for exit
		SVC 0			// Linux supervisor call to terminate program
.data
