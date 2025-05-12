// Matin Qurbanzadeh
// CS3B - lab4-1 putstring function
// 04/03/2024
// outputs a C-string to a file descriptor

.global fputstring // Provide program starting address

  //*****************************************************************************
  //fputstring
  //  Function fputstring: Provided a pointer to a null terminated string in
  //  X0, and file descriptor in X1, will output the string to the specified file.
  //  It calls helper function String_length which is in the same source file.
  //
  //  X0: Must point to a null terminated string
  //  X1: Must contain a file descriptor
  //  LR: Must contain the return address (automatic when BL
  //      is used for the call)
  //  All registers except   X0, X1, X2, X3, X4, and X8 are preserved
  //*****************************************************************************
fputstring:

    // constants
    .EQU STDOUT,     1      // file descriptor for standard out/console
    .EQU SYS_write, 64      // write() supervisor call code

    .text  // code section

    // Call String_length to get the string length; it modifies X0, X1, and X2
    // -> save LR in X3, X0 in X4, and X1 in X5 before the branch 
    MOV X3, LR              // save LR in X3
    MOV X4, X0              // save X0 in X4
    MOV X5, X1				// save X1 in X5
	BL String_length        // get the string length, returned in X0
    
    MOV LR, X3              // restore LR
    // return if it's a null string i.e. length (X0)  is zero
    CMP X0, #0              // compare returned length to zero
    B.EQ done               // branch to done if length is zero

    // Setup the parameters to print then call Linux to do it
    // put the length in X2 where the SVC wants it
    MOV X2, X0              // put length returned from String_length into X2
    // put the string pointer in X1 where the SVC wants it
    MOV X1, X4              // restore original string saved in X4 to X1
    MOV X0, X5		         // set output file descriptor to the file descriptor passed in
    MOV X8, #SYS_write      // Linux write system call code
    SVC 0                   // call linux to output the string

done:
    RET                     // return to caller











  //*****************************************************************************
  //String_length - helper function
  //  Function String_length: Provided a pointer to a null terminated string in
  //  X0, will return the string's length in X0
  //
  //  X0: Must point to a null terminated string
  //  LR: Must contain the return address (automatic when BL
  //      is used for the call)
  //  All registers except   X0, X1, X2 are preserved
  //*****************************************************************************
String_length:

    .text  // code section

    // X0 is input string pointer
    // W1 is current character
    // X2 is counter

    MOV X2, #0  // initialize counter to zero
    // do
do:
    LDRB W1, [X0], #1       // read current char, post increment X0 char pointer

    CMP W1, #0              // check if the current char is null
    B.EQ endDo              // end loop if the char is a null
    ADD X2, X2, #1          // count this char
    B do                    // continue the loop

endDo:
    MOV X0, X2              // save the count in X0

    RET                     // return to caller

.end  // end of program, optional but good practice
