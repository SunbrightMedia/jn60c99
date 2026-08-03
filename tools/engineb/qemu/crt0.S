/* crt0.S -- bare-metal ESP32-S3 (Xtensa LX7, windowed ABI) startup for the
 * QEMU instruction-count harness.  NO interrupt sources are enabled; the only
 * vectors that ever execute are the six window overflow/underflow handlers
 * (the canonical sequences from the Xtensa ISA reference / ESP-IDF
 * xtensa_vectors.S).  Every other vector funnels to _dead, which prints 'X',
 * stores EXCCAUSE at the bottom of DRAM (0x3FC80000) and spins, so a fault is
 * visible in the UART capture instead of a silent hang.
 *
 * Vector table layout (VECBASE-relative) is the ESP32 family's:
 *   0x000 WindowOverflow4    0x040 WindowUnderflow4
 *   0x080 WindowOverflow8    0x0C0 WindowUnderflow8
 *   0x100 WindowOverflow12   0x140 WindowUnderflow12
 *   0x180 Level2Int  0x1C0 Level3Int  0x200 Level4Int  0x240 Level5Int
 *   0x280 Debug      0x2C0 NMI        0x300 Kernel exc
 *   0x340 User exc   0x3C0 Double exc
 */

    .section .vectors, "ax"
    .global  _vector_table
_vector_table:

    .org 0x000                      /* WindowOverflow4 */
    s32e    a0, a5, -16
    s32e    a1, a5, -12
    s32e    a2, a5,  -8
    s32e    a3, a5,  -4
    rfwo

    .org 0x040                      /* WindowUnderflow4 */
    l32e    a0, a5, -16
    l32e    a1, a5, -12
    l32e    a2, a5,  -8
    l32e    a3, a5,  -4
    rfwu

    .org 0x080                      /* WindowOverflow8 */
    s32e    a0, a9, -16
    l32e    a0, a1, -12
    s32e    a1, a9, -12
    s32e    a2, a9,  -8
    s32e    a3, a9,  -4
    s32e    a4, a0, -32
    s32e    a5, a0, -28
    s32e    a6, a0, -24
    s32e    a7, a0, -20
    rfwo

    .org 0x0C0                      /* WindowUnderflow8 */
    l32e    a0, a9, -16
    l32e    a1, a9, -12
    l32e    a2, a9,  -8
    l32e    a7, a1, -12
    l32e    a3, a9,  -4
    l32e    a4, a7, -32
    l32e    a5, a7, -28
    l32e    a6, a7, -24
    l32e    a7, a7, -20
    rfwu

    .org 0x100                      /* WindowOverflow12 */
    s32e    a0,  a13, -16
    l32e    a0,  a1,  -12
    s32e    a1,  a13, -12
    s32e    a2,  a13,  -8
    s32e    a3,  a13,  -4
    s32e    a4,  a0,  -48
    s32e    a5,  a0,  -44
    s32e    a6,  a0,  -40
    s32e    a7,  a0,  -36
    s32e    a8,  a0,  -32
    s32e    a9,  a0,  -28
    s32e    a10, a0,  -24
    s32e    a11, a0,  -20
    rfwo

    .org 0x140                      /* WindowUnderflow12 */
    l32e    a0,  a13, -16
    l32e    a1,  a13, -12
    l32e    a2,  a13,  -8
    l32e    a11, a1,  -12
    l32e    a3,  a13,  -4
    l32e    a4,  a11, -48
    l32e    a5,  a11, -44
    l32e    a6,  a11, -40
    l32e    a7,  a11, -36
    l32e    a8,  a11, -32
    l32e    a9,  a11, -28
    l32e    a10, a11, -24
    l32e    a11, a11, -20
    rfwu

    .org 0x180
    j       _dead                   /* Level2 interrupt  -- none enabled */
    .org 0x1C0
    j       _dead                   /* Level3 interrupt */
    .org 0x200
    j       _dead                   /* Level4 interrupt */
    .org 0x240
    j       _dead                   /* Level5 interrupt */
    .org 0x280
    j       _dead                   /* Debug */
    .org 0x2C0
    j       _dead                   /* NMI */
    .org 0x300
    j       _dead                   /* Kernel exception */
    .org 0x340
    j       _dead                   /* User exception */
    .org 0x3C0
    j       _dead                   /* Double exception */

/* ------------------------------------------------------------------ start */
    .section .text.start, "ax"
    .global  _start
    .type    _start, @function
    .align   4
_start:
    movi    a0, 0                   /* backtrace terminator                  */

    movi    a2, 1                   /* live register window = frame 0 only   */
    wsr.windowstart a2
    movi    a2, 0
    wsr.windowbase  a2
    rsync

    movi    a2, 0x4002F             /* PS: WOE | UM | INTLEVEL=15            */
    wsr.ps  a2
    rsync

    movi    a2, _vector_table
    wsr.vecbase a2

    movi    a2, 0xFF                /* CPENABLE: FPU is coprocessor 0        */
    wsr.cpenable a2
    rsync

    movi    sp, _stack_top          /* a1 */

    /* zero .bss */
    movi    a4, _bss_start
    movi    a5, _bss_end
    movi    a6, 0
1:  bgeu    a4, a5, 2f
    s32i    a6, a4, 0
    addi    a4, a4, 4
    j       1b
2:
    call4   main
    /* main returned: park */
    j       _dead_quiet

/* Fault funnel: print 'X', store EXCCAUSE at 0x3FC80000, spin. */
    .global _dead
    .type   _dead, @function
    .align  4
_dead:
    movi    a2, 0x60000000          /* UART0 FIFO */
    movi    a3, 'X'
    s32i    a3, a2, 0
    rsr.exccause a3
    movi    a4, 0x3FC80000
    s32i    a3, a4, 0
_dead_quiet:
1:  j       1b
