    .global _start

_start:
    addi a5, a5, 1
    beq zero, zero, next
    nop
    nop
    nop
    nop
    nop
    addi a0, zero, 1
next: