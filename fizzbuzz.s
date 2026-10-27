.text
.global _start

/* --- Reference ---
GLOBAL
w19 = current number (1-100)
w20 = constant 10 (for modulo)
w21 = constant 3 (for modulo)
w22 = constant 5 (for modulo)

MAIN_LOOP
w3 = argument to write_num to compute ascii num to print
w4 = result of modulo
w5 = scratch calculation register
w6 = fizzbuzz buffer length
x7 = fizzbuzz buffer
x9 = address of fizz/buzz
w11 = scratch string register (w because 4 bytes)

WRITE_NUM
w3 = argument to write_num to compute ascii num to print
w4 = write_num running number
w9 = write_num quotient
x5 = write_num print scratch register
x6 = num_buffer register
w7 = num_buffer length
*/

_start:
    mov w19, #1
    mov w20, #10
    mov w21, #3
    mov w22, #5

MAIN_LOOP:                          // check every number, afterwards exit
    mov w6, wzr
    ldr x7, =fizzbuzz_buffer        // get address of fizzbuzz (every time because it is used as pointer)

    // fizz branch
    udiv w5, w19, w21               // w5 = w19 / 3
    msub w4, w5, w21, w19           // w3 = w19 - (w5 * 3) = modulo 3
    
    cmp w4, #0
    b.ne 1f

    ldr x9, =fizz                   // get address of fizz
    ldr w11, [x9]                   // load "Fizz" into w11
    str w11, [x7], #4               // put fizz into the fizzbuzz buffer and advance 4 (prepare for buzz)
    add w6, w6, #4
1:
    // buzz branch
    udiv w5, w19, w22                // w5 = w19 / 5
    msub w4, w5, w22, w19           // w3 = w19 - (w5 * 5) = modulo 5

    cmp w4, #0
    b.ne 2f

    // Add Buzz
    ldr x9, =buzz                   // get address of buzz
    ldr w11, [x9]                   // load "Buzz" into w11
    str w11, [x7]               // put buzz into the fizzbuzz buffer
    add w6, w6, #4

2:
    cmp w6, #0
    b.ne 3f

    // write num branch
    mov w3, w19
    bl WRITE_NUM
    b 99f

3:
    // fizzbuzz branch
    mov x8, #0x40                   // WRITE SYSCALL CODE
    mov x0, #1                      // write mode
    ldr x1, =fizzbuzz_buffer
    mov x2, x6
    svc #0

    mov x8, #0x40                   // WRITE SYSCALL CODE
    mov x0, #1                      // write mode
    ldr x1, =newline
    mov x2, #1
    svc #0

    b 99f

99:
    cmp w19, #99
    add w19, w19, #1
    b.le MAIN_LOOP

    // --- Exit Syscall --- //
    mov x8, #0x5D
    mov x0, #0
    svc #0

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
    fizzbuzz_buffer: .space 8                 // can have fizz, buzz, or fizzbuzz

