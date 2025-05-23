    .global _start

_start:
    lui sp, 0x10
    call main
    j end

main:
    addi sp, sp, -32
    sw   ra, 0(sp)
    lw   ra, 0(sp)
    addi sp, sp, 32
    nop
    nop
    nop
    nop

end: