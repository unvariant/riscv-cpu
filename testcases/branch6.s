    .global _start

_start:
    lui sp, 0x10
    call main
    j end

main:
    addi sp, sp, -32
    sw   ra, 0(sp)

    addi a0, zero, 10
    addi a1, zero, 10
    addi s0, zero, 0

loop1:
    addi s1, zero, 0
loop2:
    call sub
    addi s1, s1, 1
    bltu s1, a1, loop2
    addi s0, s0, 1
    bltu s0, a1, loop1

    lw   ra, 0(sp)
    addi sp, sp, 32
    ret

sub:
    addi sp, sp, -32
    sw   ra, 0(sp)
    call other
    lw   ra, 0(sp)
    add  sp, sp, 32
    ret

other:
    addi sp, sp, -32
    sw   ra, 0(sp)
    lw   ra, 0(sp)
    add  sp, sp, 32
    ret

end: