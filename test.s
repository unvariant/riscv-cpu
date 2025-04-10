    .global _start

    .equ WIDTH, 64
    .equ HEIGHT, 48

_start:
    addi a0, zero, 7
    add  a0, a0,   a0
    nop
    nop
    nop
    nop
    nop
    beq  a0, a0, _start
    
    addi a0, zero, 256
    addi a1, zero, -1
    sw   a1, 0(a0)
loop:
    beq  a0, a0, loop
    
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