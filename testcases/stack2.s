    .global _start

    .balign 0x1000

_start:
    lui sp, 0x10
    call main
    j end

main:
    addi sp, sp, -32
    sw   ra, 0(sp)

    addi a0, zero, 0

    call other
    call other
    call other
    call other

    lw   ra, 0(sp)
    addi sp, sp, 32
    ret

other:
    addi sp, sp, -32
    sw   ra, 0(sp)
    
    call addone

    lw   ra, 0(sp)
    addi sp, sp, 32
    ret

addone:
    addi sp, sp, -32
    sw   ra, 0(sp)
    
    addi a0, a0, 1

    lw   ra, 0(sp)
    addi sp, sp, 32
    ret

end: