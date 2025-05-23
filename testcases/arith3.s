    .global _start

_start:
    addi a1, a1, 10
    addi a2, a2, 640
    call mul
    j end
    
mul:
    addi    a2,zero,0
    beq     a0,zero,done

loop:
    slli    a3,a0,0x1f
    srai    a3,a3,0x1f
    and     a3,a3,a1
    add     a2,a3,a2
    srli    a0,a0,0x1
    slli    a1,a1,0x1
    bne     a0,zero,loop

done:
    addi    a0,a2,0
    jalr    zero,0(ra)

end: