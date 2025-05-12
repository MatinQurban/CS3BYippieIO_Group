// header from coding standard here, set tab to 4 spaces
.global _start // Provide program starting address

_start:
    .EQU SYS_exit, 93 // exit() supervisor call code
    .text // code section

    // terminate the program
    MOV X0, #0 // set return code to 0, all good
    MOV X8, #SYS_exit // set exit() supervisor call code
    SVC 0 // call Linux to exit
.data // data section
.end // end of program, optional but good pra
