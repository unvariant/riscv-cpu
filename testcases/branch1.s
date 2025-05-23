    .global _start

_start:
    addi a5, a5, 1
    beq zero, zero, next
    addi a0, zero, 1
next:
    addi a1, zero, 1