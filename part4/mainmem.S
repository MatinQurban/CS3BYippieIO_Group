//
// Assembler program to flash three LEDs connnected to the
// Raspberry Pi GPIO port using direct memory access.
//
// W6 - loop variable to flash lights 10 times
//

#include "gpiomem.S"

.global _start	            // Provide program starting address
_start: mapMem
        nanoSleep

        GPIODirectionOut pin4
        GPIODirectionOut pin17
        GPIODirectionOut pin27
        GPIODirectionOut pin22
        
        GPIODirectionIn col1
        GPIODirectionIn col2	
        GPIODirectionIn col3
        GPIODirectionIn col4

        // setup a loop counter for 10 iterations
        mov W6, #10000
        
        MOV X10, X9
        
        ADD X10, X10, #0x34
        
        GPIOTurnOn pin4
        GPIOTurnOn pin17
        GPIOTurnOn pin22
        GPIOTurnOn pin27

loop:   
        GPIOReadPin   col1
        GPIOReadPin   col2
        GPIOReadPin   col3
        GPIOReadPin   col4
        GPIOReadPin   pin4
        GPIOReadPin   pin17
        GPIOReadPin   pin22
        GPIOReadPin   pin27
		nanoSleep
        LDR X0, =szNewLine
        BL putstring

        GPIOReadPin   col1
        GPIOReadPin   col2
        GPIOReadPin   col3
        GPIOReadPin   col4
        GPIOReadPin   pin4
        GPIOReadPin   pin17
        GPIOReadPin   pin22
        GPIOReadPin   pin27
        nanoSleep
        LDR X0, =szNewLine
        BL putstring

        GPIOReadPin   col1
        GPIOReadPin   col2
        GPIOReadPin   col3
        GPIOReadPin   col4
        GPIOReadPin   pin4
        GPIOReadPin   pin17
        GPIOReadPin   pin22
        GPIOReadPin   pin27
        nanoSleep
        LDR X0, =szNewLine
        BL putstring

        GPIOReadPin   col1
        GPIOReadPin   col2
        GPIOReadPin   col3
        GPIOReadPin   col4
        GPIOReadPin   pin4
        GPIOReadPin   pin17
        GPIOReadPin   pin22
        GPIOReadPin   pin27
        nanoSleep
        LDR X0, =szNewLine
        BL putstring
brk1:
        //decrement loop counter and see if we loop
        subs    W6, W6, #1      // Subtract 1 from loop register setting status register
        b.ne     loop        // If we haven't counted down to 0 then loop

_end:   mov     X0, #0      // Use 0 return code
        mov     X8, #__NR_exit
        svc     0           // Linus command to terminate program

.data 
szNewLine: .asciz "\n"
