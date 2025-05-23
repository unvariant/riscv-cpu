    .global _start

_start:
    lui  sp, 0x10
    addi a0, zero, 0
    addi s0, zero, 0
    addi s1, zero, 0
    addi a1, zero, 620
    addi a2, zero, 320
    addi a3, zero, 0
loop1:
    addi s0, a0, 0
    call sub
    addi a0, s0, 0
    call sub
    addi a0, s0, 1
    call sub

loop2:
    addi s1, s1, 1
    call sub
    bltu s1, a2, loop2

    addi a0, s0, 2
    bltu s0, a1, loop1
    j end

sub:
    addi sp, sp, -32
    sw   ra, 0(sp)
    addi a3, a3, 1
    lw   ra, 0(sp)
    addi sp, sp, 32
    ret

end: