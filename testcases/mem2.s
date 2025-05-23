    .global _start

// Tests that memory loads and stores work properly.
// Sets 1 debug led per test. A passing test should have
// 5 leds on.

_start:
    lui  t0, 1
    addi a0, zero, 0
    addi a7, zero, 7
    addi a6, zero, 6
    addi a5, zero, 5
    addi a4, zero, 4

// ensure sb works properly
    sb   a7, 0(t0)
    sb   a6, 1(t0)
    sb   a5, 2(t0)
    sb   a4, 3(t0)

    lui  a2, 0x04050
    ori  a2, a2,   0x607
    lw   a1, 0(t0)
    bne  a1, a2,   sb_test_failed

    ori  a0, a0,   1 << 0

sb_test_failed:

// ensure lh works properly
    lh   a1, 0(t0)
    lh   a3, 2(t0)
    slli a3, a3,   16
    or   a1, a1,   a3
    bne  a1, a2,   lh_test_failed

    ori  a0, a0,   1 << 1

lh_test_failed:

// ensure lb works properly
    lb   a1, 0(t0)
    lb   a3, 1(t0)
    slli a3, a3,   8
    or   a1, a1,   a3
    lb   a3, 2(t0)
    slli a3, a3,   16
    or   a1, a1,   a3
    lb   a3, 3(t0)
    slli a3, a3,   24
    or   a1, a1,   a3
    bne  a1, a2,   lb_test_failed

    ori  a0, a0,   1 << 2

lb_test_failed:

// ensure lw works properly
    lw   a1, 0(t0)
    bne  a1, a2,   lw_test_failed

    ori  a0, a0,   1 << 3

lw_test_failed:

// ensure sw only writes 1 word of memory
    lw   a1, 4(t0)
    bne  a1, zero, sw_only_writes_word_failed

    ori  a0, a0,   1 << 4

sw_only_writes_word_failed: