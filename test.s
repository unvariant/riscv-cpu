    .global _start

    .equ WIDTH, 64
    .equ HEIGHT, 48

_start:
    addi a0, zero, 0
    addi a7, zero, 7
    addi a6, zero, 6
    addi a5, zero, 5
    addi a4, zero, 4

// ensure sb works properly
    // sb   a7, 0(zero)
    // sb   a6, 1(zero)
    // sb   a5, 2(zero)
    // sb   a4, 3(zero)

    addi a0, zero, -1
    sw   a0, 0(zero)
    nop
    sb   a6, 1(zero)
    nop
    lb   a0, 1(zero)
    nop
stop:
    beq  a0, a0, stop

    lui  a2, 0x04050
    ori  a2, a2,   0x607
    lw   a1, 0(zero)
    bne  a1, a2,   sb_test_failed

    ori  a0, a0,   1 << 0

sb_test_failed:

// ensure lh works properly
    lh   a1, 0(zero)
    lh   a3, 2(zero)
    slli a3, a3,   16
    or   a1, a1,   a3
    bne  a1, a2,   lh_test_failed

    ori  a0, a0,   1 << 1

lh_test_failed:

// ensure lb works properly
    lb   a1, 0(zero)
    lb   a3, 1(zero)
    slli a3, a3,   8
    or   a1, a1,   a3
    lb   a3, 2(zero)
    slli a3, a3,   16
    or   a1, a1,   a3
    lb   a3, 3(zero)
    slli a3, a3,   24
    or   a1, a1,   a3
    bne  a1, a2,   lb_test_failed

    ori  a0, a0,   1 << 2

lb_test_failed:

// ensure lw works properly
    lw   a1, 0(zero)
    bne  a1, a2,   lw_test_failed

    ori  a0, a0,   1 << 3

lw_test_failed:

// ensure sw only writes 1 word of memory
    lw   a1, 4(zero)
    bne  a1, zero, sw_only_writes_word_failed

    ori  a0, a0,   1 << 4

sw_only_writes_word_failed:

loop:
    beq  a0, a0,   loop

    addi a1, zero, 4 * WIDTH * HEIGHT / 32
    addi a3, zero, 750 - 1

render:
    addi a0, zero, 0
    addi a2, zero, WIDTH * HEIGHT / 32

copy:
    lw   a4, 0(a1)
    sw   a4, 0(a0)
    addi a0, a0,   4
    addi a1, a1,   4
    addi a2, a2,   -1
    bne  a2, zero, copy

    // 100 MHZ -> 15 fps
    // 100 * 1000 * 1000 / (0x330 << 10) = 14.96 fps
    addi a5, zero, 0x330
    slli a5, a5,   10
delay:
    addi a5, a5, -1
    bne  a5, zero, delay

    addi a3, a3,   -1
    bne  a3, zero, render

halt:
    beq  a0, a0,   halt