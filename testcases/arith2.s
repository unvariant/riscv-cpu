    .global _start

_start:
    addi a0, zero, 0x157
    addi a1, zero, 0x176
    addi a2, zero, 0x23
    addi a3, zero, 0x101

    nop
    nop
    nop
    nop

    add a1, a2, a3
    add a1, a1, a1
    add a1, a1, a1
    add a1, a1, a1
    add a1, a1, a1