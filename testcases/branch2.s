    .global _start

_start:
    addi a0, zero, 0

    addi a5, zero, -1
    addi a6, zero, 0

    blt  a5, a6, lt_works
    addi a0, a0, 1 << 0
lt_works:

    bge  a6, a5, ge_works
    addi a0, a0, 1 << 1
ge_works:

    bltu a6, a5, ltu_works
    addi a0, a0, 1 << 2
ltu_works:

    bgeu a5, a6, geu_works
    addi a0, a0, 1 << 3
geu_works:

    bne  a6, a5, ne_works
    addi a0, a0, 1 << 4
ne_works:

    addi a5, zero, -1
    addi a6, zero, -1
    beq  a5, a6, eq_works
    addi a0, a0, 1 << 5
eq_works: