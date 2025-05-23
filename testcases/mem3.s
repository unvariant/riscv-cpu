    .global _start

_start:
    lui  a0, 1
    addi a1, zero, 0x333
    addi a3, a1,   0
    addi a4, zero, 7

    sw   a1, 0(a0)
    lw   a2, 0(a0)

    bne  a2, a3, failure

    addi a4, a4, 1
    nop
    nop
    nop

failure:
    addi a0, a0, 1