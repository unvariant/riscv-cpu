    .global _start

_start:
    lui  a0, 1
    addi a1, zero, 0x333
    addi a3, a1,   0

    sw   a1, 0(a0)
    lw   a2, 0(a0)
    beq  a2, a3, working

    addi a4, zero, 1

working: