    .global _start

_start:
    addi zero, zero, -1

    addi a1,   zero, 0x777
    addi a1,   a1,   -1

    addi t0, zero, 1
    addi t1, zero, 2
    addi t2, zero, 3
    addi t3, zero, 4

    sub  a1,   a1,   a1
    ori  a1,   a1,   0x137

    ori  x31,  zero, 0x111
    add  x2,   x2,   x31
    lui  x31,  0xdead

    addi a2,   zero, -1

    auipc x30, 0xfeed

    addi a3, zero, 0x1ff
    lui  x16, 0x12345
    xor  x16, x16, x2
    and  x31, x30, x31
    sub  x25, x24, x31
    xor  x25, x25, x31
    xor  x31, x16, x31
    xor  x25, x30, x25