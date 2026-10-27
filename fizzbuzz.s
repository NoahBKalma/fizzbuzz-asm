.text
.global _start

/* --- Reference ---
GLOBAL
w19 = current number (1-100)
w20 = constant for 10 (for modulo)

WRITE_NUM
w3 = argument to write_num to compute ascii num to print
w4 = write_num calculation scratch register
x5 = write_num print scratch register
x6 = num_buffer register
w7 = num_buffer length
*/

_start:
    mov w19, #1

loop:                                   // check every number, afterwards exit
    mov w3, w19
    mov w20, #10

    bl WRITE_NUM

    cmp w19, #99
    add w19, w19, #1
    b.le loop


    // --- Exit Syscall --- //
    mov x8, #0x5D
    mov x0, #0
    svc #0

/*

1:
        mov x8, #0x40                   // WRITE SYSCALL CODE
        mov x0, #1                      // write mode
        ldr x1, =fizz
        mov x2, #4
        svc #0

2:
        mov x8, #0x40                   // WRITE SYSCALL CODE
        mov x0, #1                      // write mode
        ldr x1, =buzz
        mov x2, #4
        svc #0
*/

WRITE_NUM:
        mov w4, w3                      // running value
        mov x5, #2
        mov w7, wzr
        ldr x6, =num_buffer
LOOP:
        udiv w9, w4, w20                // w9 = quotient = w4 / 10
        msub w3, w9, w20, w4            // w3 = w4 - (w9 * 10) = digit
        // now w3 has the lowest digit, convert to ascii
        add w3, w3, #'0'

        strb w3, [x6, x5]
        sub x5, x5, #1
        add w7, w7, #1

        mov w4, w9                      // next iteration divides the quotient

        cmp w4, wzr
        b.gt LOOP

        // write num_buffer and break after num_buffer is filled
        mov x8, #0x40                   // WRITE SYSCALL CODE
        mov x0, #1                      // write mode
        add x5, x5, #1                  // to get offset for buffer begin
        add x1, x6, x5                  // not ldr because x6 is already a mem value
        mov x2, x7
        svc #0

        mov x8, #0x40                   // WRITE SYSCALL CODE
        mov x0, #1                      // write mode
        ldr x1, =newline
        mov x2, #1
        svc #0


        ret


.data

    // both ascii length 4
    fizz: .ascii "Fizz"
    buzz: .ascii "Buzz"
    newline: .ascii "\n"

.bss
    num_buffer: .space 3                       // number in ascii, max 3 digits (100)

