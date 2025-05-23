    .global _start

_start:
    addi a0, zero, 0
    call add_one
    beq zero, zero, done

add_one:
    addi a0, a0, 1
    ret

done: