/* link.ld -- bare-metal ESP32-S3 layout for the QEMU instruction harness.
 *
 * QEMU (Espressif esp_develop_9.2.2) models these as two SEPARATE RAM blocks
 * (verified with `info mtree`, 2026-08-03):
 *   esp32s3.iram  0x40370000..0x403EFFFF  (512 KB)  -- code
 *   esp32s3.dram  0x3FC80000..0x3FDEFFFF  (1.44 MB) -- data
 * The DRAM block is larger than the real chip's; the harness states in its
 * report which allocations would not fit real internal SRAM.
 *
 * 0x3FC80000..0x3FC80FFF is reserved for the fault funnel's EXCCAUSE drop.
 * VECBASE requires 1 KB alignment; the vectors sit at the IRAM origin.
 */
ENTRY(_start)

MEMORY
{
  iram (RX) : ORIGIN = 0x40370000, LENGTH = 0x80000
  dram (RW) : ORIGIN = 0x3FC81000, LENGTH = 0x16E000
}

SECTIONS
{
  .vectors : {
    KEEP(*(.vectors))
  } > iram

  .text : {
    /* Xtensa l32r reaches BACKWARD only: each file's literal pool must be
     * placed before its code, which the single-glob pattern guarantees
     * (sections are emitted per input file in the pattern's listed order). */
    *(.literal.start .text.start)
    *(.literal .text .literal.* .text.*)
  } > iram

  .rodata : {
    . = ALIGN(16);
    *(.rodata)
    *(.rodata.*)
    *(.srodata .srodata.*)
  } > dram

  .data : {
    . = ALIGN(16);
    *(.data .data.*)
    *(.sdata .sdata.*)
  } > dram

  .bss (NOLOAD) : {
    . = ALIGN(16);
    _bss_start = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    . = ALIGN(16);
    _bss_end = .;
  } > dram

  /* 64 KB stack at the top of DRAM, descending */
  _stack_top = ORIGIN(dram) + LENGTH(dram);
  ASSERT(_bss_end + 0x10000 < _stack_top, "DRAM overflow: data + 64K stack")
}
