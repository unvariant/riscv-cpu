SECTIONS {
    .initram (0x00000000) : {
        *(.initram)
    }
    .text    (0x10000000) : {
        *(.entry)
        *(.text.*)
    }
    .rodata       : { *(.rodata.*) }
    .eh_frame_hdr : { *(.eh_frame_hdr) }
    .eh_frame     : { *(.eh_frame) }
}