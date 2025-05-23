    .global _start

_start:
    lui     a0,0x9
    addi    a0,a0,-464
    sub     sp,sp,a0
    addi    a0,zero,0
    addi    s2,zero,460
    addi    s3,zero,620
    addi    s0,a0,0
    addi    s1,zero,-20
    addi    s1,s1,20
    addi    a0,sp,12
    addi    a3,zero,1
    addi    a1,s0,0
    addi    a2,s1,0
    auipc   ra,0x0