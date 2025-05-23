    .global _start

_start:
    addi a0, zero, 1
    slli a0, a0, 31
    srai a0, a0, 31