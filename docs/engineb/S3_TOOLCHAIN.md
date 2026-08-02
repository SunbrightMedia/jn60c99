# ESP32-S3 TOOLCHAIN — installed, and the first real S3 number

    /root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin/
    xtensa-esp32s3-elf-gcc   (crosstool-NG esp-16.1.0, GCC 16.1.0)

`install.sh` exits 1 on a later step, but the compiler is present and works.
Add the directory to PATH.

Engine B modules can now be counted on the true target ISA from the first line
of code. This closes the largest process error of the JUNO-60 port, which was
that every performance decision for weeks used models that silicon later showed
to be optimistic by 6x.

## First measurement: the PORT's voice_render, built for the S3

`-O2 -ffp-contract=off -fno-strict-aliasing`, STATIC instruction counts:

| target | instructions |
|---|---|
| Cortex-M7 | 3,491 |
| **ESP32-S3** | **4,345** (+24%) |

Instruction census on the S3:

| count | instruction | meaning |
|---|---|---|
| 842 | `lsi` | load float |
| 624 | `mul.s` | float multiply |
| 438 | `add.s` | float add |
| 313 | `ssi` | store float |
| 276 | `wfr` | move integer register to float register |
| 210 | `l32i` | load integer |
| 203 | `s32i` | store integer |
| 128 | `call8` | function call (windowed ABI) |

Two facts fall out, and both support the engine B design:

1. **842 loads + 313 stores = 1,155 float memory operations.** The host
   instrumentation measured **1,155 memory accesses per voice per sample**. Two
   independent methods, on two different instruction sets, give the same number.
   The flat 12 MB array forces almost every access to become a real load or
   store, and the compiler removes nearly none of it.
2. **276 `wfr` instructions.** These move a value from an integer register to a
   float register. They exist because the code reads floats out of a byte array
   through casts. A struct with typed fields does not produce them.

The S3 is the tighter target and the port is 24% worse there than on the M7.
Engine B must not repeat the layout that causes this.
