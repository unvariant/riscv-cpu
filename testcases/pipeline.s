    .global _start

_start:
    addi a0, zero, 1
    addi a1, a0,   0
    sub  a1, a1,   a1
    // addi a2, a1,   0
    // addi a1, a1, 1
    // addi a1, a1, 1
    // addi zero, zero, -1
    // addi a0,   zero, 0x1
    // addi a1,   a1,   -1
    
    // sub a1, a1, a1