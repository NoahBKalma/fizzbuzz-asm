# FizzBuzz in AArch64 Assembly

Prints FizzBuzz for 1 through 100 in AArch64 Linux assembly, one entry per line. It uses raw syscalls only, with no libc.

Example output:

```
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
...
```

## Build and run

Requires an AArch64 Linux machine (or VM) with the GNU toolchain.

```sh
as -o fizzbuzz.o fizzbuzz.s
ld -o fizzbuzz fizzbuzz.o
./fizzbuzz
```

## How it works

- **Check divisibility:** `MAIN_LOOP` computes `n mod 3` and `n mod 5` with `udiv` + `msub`.
- **Build the word:** On a match, "Fizz" and/or "Buzz" is copied into `fizzbuzz_buffer`. The write pointer (x7) advances by 4 after Fizz, so a number divisible by both becomes "FizzBuzz". The buffer length is tracked in w6.
- **Print a word:** If w6 is nonzero, the buffer is written with one `write` syscall, followed by a separate newline write.
- **Print a number:** If w6 is zero, `WRITE_NUM` splits the number into digits (`udiv` by 10, `msub` for the remainder), converts each to ASCII (+`'0'`), and fills `num_buffer` from the right. It then writes only the used part of the buffer, followed by a newline.
- **Loop and exit:** `cmp` runs before the increment, so 100 is printed before the loop falls through to the exit syscall.

## Important registers

### Global

| Register | Purpose |
|----------|---------|
| w19 | current number (1-100) |
| w20 | constant 10 (for digit extraction) |
| w21 | constant 3 (for Fizz check) |
| w22 | constant 5 (for Buzz check) |

### MAIN_LOOP

| Register | Purpose |
|----------|---------|
| w3 | argument passed to `WRITE_NUM` |
| w4 | result of modulo |
| w5 | scratch (quotient) |
| w6 | fizzbuzz buffer length |
| x7 | write pointer into `fizzbuzz_buffer` |
| x9 | address of the "Fizz" / "Buzz" string |
| w11 | scratch string register |

### WRITE_NUM

| Register | Purpose |
|----------|---------|
| w3 | number argument, then the current digit |
| w4 | running value being divided |
| w9 | quotient |
| x5 | index into `num_buffer` (counts down from 2) |
| x6 | address of `num_buffer` |
| w7 | digit count (length to print) |

`WRITE_NUM` reuses w4-w7 from `MAIN_LOOP`. This is safe because `MAIN_LOOP` resets w6 and x7 at the top of every iteration.

## Notes

- `num_buffer` is 3 bytes, enough for the largest number (100).
- `fizzbuzz_buffer` is 8 bytes, enough for "FizzBuzz".
- "Fizz" and "Buzz" are each loaded and stored as 4 bytes (`w11`).
- Syscalls used: `write` (0x40) and `exit` (0x5D).