# ARM bring-up, measured — correcting the Teensy/Daisy record

*2026-07-29. Everything here was executed today in this container. Labels are
strict: **PROVEN** = ran and produced this output; **MEASURED** = counted from a
real artifact; **ESTIMATE** = arithmetic on measured inputs, clearly derived.
Reproduce with `tools/embed/arm_golden.sh` and `tools/embed/state_footprint.c`.*

## 0. The correction I owe

Early in the project the engine was described as Teensy-capable. That claim was
never *measured* — it rested on `tests/teensy_golden.h` and
`tests/test_teensy_golden.c` existing in the tree. Both were generated on x86 and
compiled and run on x86 with plain `cc`. There is no `arm-none-eabi` build, no
PlatformIO project, no CMake target anywhere in the repo. **The name "teensy" on
those files was aspiration, not evidence.**

`docs/DAISY_FEASIBILITY.md` (earlier today) then over-corrected in the other
direction: it treated the *allocation* size (12 MB) as the memory requirement and
assumed x86-equal IPC. Both were wrong, in opposite directions.

Nothing regressed. The engine did not get slower. The claim was untested, and now
it is tested.

## 1. PROVEN: the arithmetic is bit-exact on ARM

`tools/embed/arm_golden.sh`, run today:

```
1/3  x86-64 control                     ALL OK: 8/8 golden scenarios bit-exact
2/3  ARM32 hard-float under qemu-user   ALL OK: 8/8 golden scenarios bit-exact
3/3  bare-metal Cortex-M7 compile       engine text: 373.6 KiB
```

All eight FNV-1a-64 output hashes are **identical** between x86-64/SSE2 and
32-bit ARM/VFPv4 hard-float. That covers libm behaviour, denormal handling,
double-vs-float promotion, structure packing and 32-bit pointer width across the
full render path — recall, 8-voice allocation, note lifecycle, FX, master.

This was the single assumption every hardware plan rested on, it had never been
run, and it took under an hour. **It passes.**

The whole engine also compiles clean for the real bare-metal target
(`-mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb`): 373.6 KiB of text,
no host-only constructs.

**One real defect surfaced** (MEASURED, not yet fixed): `src/master_render.c:861`
and `:2352` chase a pointer through `*(_QWORD *)(a1 + 136)` — an 8-byte load cast
to a pointer. On a 32-bit target this only works because little-endian truncation
happens to keep the low word. It produces correct results today (hence 8/8) but
it is luck, not design, and it should be narrowed to a pointer-width load before
anyone trusts it on hardware.

## 2. MEASURED: the memory requirement is ~1.1 MB, not 12 MB

`tools/embed/state_footprint.c` serves the engine's single `calloc(1, 12 MB)`
from an `mmap(PROT_NONE)` region and records every page the engine faults on, so
**reads count, not just writes**. Page granularity 4 KiB (over-estimates, which
is the safe direction).

```
A. create + apply patch 0          2629 / 3072 pages = 10516 KiB
B. HOT: one patch, 8 voices, 2 s    293 / 3072 pages =  1172 KiB
C. all 64 patches                  2545 / 3072 pages = 10180 KiB
```

The 10.5 MB is **init-time constants written once across every FX variant's
region**. What a steady-state audio callback actually touches is phase B:

```
[        0 ..     86016)     84 KiB   8 voice states (8 x 10512)   random access
[    90112 ..    159744)     68 KiB   shared / aux                 random access
[  1843200 ..   2256896)    404 KiB   FX line                      sequential
[  3940352 ..   4300800)    352 KiB   FX line                      sequential
[ 10756096 ..  11026432)    264 KiB   master + FX coefficients     random access
                          --------
                           1172 KiB   total hot set, one patch
```

**~416 KiB is random-access** (voices + master) and belongs in fast RAM;
**~756 KiB is sequential circular delay/reverb lines**, which are exactly what
external SDRAM behind a D-cache is good at.

Consequences:

- **Daisy Seed**: 416 KiB fits the H750's 512 KiB AXI SRAM / 128 KiB DTCM budget
  with placement care; the lines and the full 12 MB span sit in the 64 MB SDRAM.
  **Memory is a non-issue.**
- **Teensy 4.1**: 416 KiB fits the 512 KiB FlexRAM DTCM. The 12 MB span needs
  external PSRAM — one 8 MB chip is not enough, so **both** PSRAM pads must be
  populated (16 MB). That is two solderable chips, not a redesign.

## 3. MEASURED: instruction counts — ARM is *denser* than x86

Static counts from `objdump` of the same source at `-O2 -ffp-contract=off`.
`juno_voice_render` is straight-line, so static ≈ dynamic per call.

| function | x86-64 SSE2 | ARM32 VFPv4 | Cortex-M7 Thumb-2 |
|---|---|---|---|
| `juno_voice_render` | 4,439 | 3,407 | 3,518 |
| `juno_master_render` | 5,768 | 4,544 | 4,774 |
| `juno_triangle` | 97 | 40 | 40 |

Per sample (8 voice calls + 1 master + ~104 triangle calls):

```
x86-64  : 8*4439 + 5768 + 104*97 = 51,368 instructions
Cortex-M7: 8*3518 + 4774 + 104*40 = 37,078 instructions      (0.72x)
```

**The M7 issues 28% fewer instructions for identical work** — 32 VFP registers
and 3-operand encoding remove the register shuffling SSE2 needs. Every previous
estimate assumed ARM would need *more*.

## 4. ESTIMATE: the cycle budget, honestly

Measured on x86: **14,500 cycles/sample** for 8 voices (2.80 GHz Xeon, 44.1 kHz).

The M7 is in-order dual-issue; the Xeon is 4-wide out-of-order. On straight-line
FP code with dependency chains, published M7 IPC for this shape is ~0.8–1.2
against a Xeon's effective ~2.5.

```
M7 cycles/sample = 14,500 x 0.72 x (2.5 / IPC_M7)
  IPC 1.2 -> 21,800      IPC 1.0 -> 26,100      IPC 0.8 -> 32,700
```

against the budgets (cycles/sample = clock / rate):

| target | budget | 8 voices bit-exact |
|---|---|---|
| Daisy H750 @ 480 MHz, 48 kHz | 10,000 | **2.2–3.3x over** |
| Daisy H750 @ 480 MHz, 44.1 kHz | 10,884 | 2.0–3.0x over |
| Teensy 4.1 @ 600 MHz, 44.1 kHz | 13,605 | 1.6–2.4x over |
| **Teensy 4.1 @ 816 MHz**, 44.1 kHz | **18,507** | **1.2–1.8x over** |

816 MHz is a stock, menu-selectable Teensyduino clock, not a hack.

**So the Teensy-vs-Daisy question has a real answer: Teensy 4.1 is 1.25x the
Daisy's clock stock and 1.7x overclocked. That is the entire difference, and it
is why the original Teensy instinct was closer to right.** The Daisy's advantage
is memory (64 MB SDRAM, no soldering); the Teensy's is clock. For *this* engine,
which is CPU-bound and — per §2 — barely memory-bound at all, clock wins.

## 4b. MEASURED: the bare-metal bring-up risks, all four closed

Everything a hardware port can fail on *before* it gets to cycle counts. All
measured today from the real Cortex-M7 objects.

**Link surface — 9 external symbols.** Everything the engine needs from outside
itself:

```
libm   : expf, fmodf
heap   : calloc, malloc, free        (create-time only; NONE in the audio path)
string : memcpy, memmove, memset, strcmp
helpers: __aeabi_d2lz, __aeabi_ldivmod   (1 call each: double->int64, int64 div)
```

**Zero soft-float helpers.** No `__aeabi_dadd/dsub/dmul/fadd/…` anywhere, so
every floating-point operation is hardware VFP. On a target without an FPU this
list would be hundreds of entries long.

**Stack — 584 bytes for the entire audio path.**

```
juno_driver_render_voices  200      juno_master_render   112
juno_driver_render_sample  136      juno_triangle         16
juno_voice_render          120      ---- audio path      584 bytes
```

(`juno_gui_warmup` has a 4,120-byte frame, but it is one-time setup, not the
callback.) Nothing here strains a default stack, let alone DTCM.

**libm bit-exactness — the one real risk, and it is closed.** The engine calls
libm inside the per-sample path: `fmodf` (24 sites) and `expf`
(`voice_render.c:776`, `:1239`). `arm_golden.sh` proves the engine against
**glibc**; a Teensy links **newlib**. Different implementation, possible ULP
differences, and one differing bit propagates through the filter state.

- `fmodf` is safe **by construction**: IEEE-754 defines `fmod` as an *exact*
  operation — the result is exactly representable, there is no rounding — so
  every conforming implementation returns identical bits.
- `expf` is **not** exactly specified, so it had to be tested.
  `tools/embed/libm_expf_ab.sh` lifts `expf` out of the toolchain's
  `thumb/v7e-m+dp/hard/libm.a` — the exact Cortex-M7 hard-float multilib a
  Teensy links — renames the symbol, links it beside glibc's in one armhf
  binary, and compares raw bit patterns on identical inputs.

```
compared 32000423 inputs
RESULT: glibc expf == newlib expf, BIT-IDENTICAL on all 32000423
```

Domain covered: `[-120,120]` at 1e-5 steps, exact integers `[-200,200]`,
exponent-stepped bit patterns from 2^-30 to 2^7 (both signs), and the
zero/subnormal/overflow-knee/infinity edges. **PROVEN.** Both libms now derive
`expf` from ARM's optimized-routines, which is why they agree.

## 5. Why a voice costs 3,518 instructions, and the fast way down

A hand-written Juno voice is 100–300 instructions/sample. Ours is 3,518 because
it is a transcription of MSVC's output for a desktop plugin: every shadow copy,
every per-sample recomputation of a value that only changes when a parameter
changes. On desktop that is free. It is the entire overhead here.

**The lever that is both large and provably bit-exact: block-level
loop-invariant hoisting.** If an expression is computed every sample from inputs
that do not change within the block, computing it once per block and reusing it
is *bit-identical by construction* — not an approximation, not a tolerance.
And the plugin itself already renders whole blocks (`docs/RENDER_LOOP_LOG.md`:
voices render whole-block via pool items), so block structure is native.

This is incremental and self-checking: hoist one expression, run `make verify` +
`arm_golden.sh`; red means you were wrong, green means you were right. No
research task, no derivation, no covenant risk. Contrast with A4
(idle-voice fast-forward) from `DAISY_FEASIBILITY.md`, which is **not**
bit-exact — `phase += inc` N times differs from `phase + N*inc` in float — and
so cannot be gated the same way.

Ordered by value per hour:

| step | expected | why it is safe |
|---|---|---|
| **ITCM/DTCM placement** | large (this is the difference between ~1 IPC and fetch stalls) | placement cannot change arithmetic |
| **block-level hoisting** | the big one; targets the 76% of instructions in voice_render | bit-identical by construction, gated |
| **`juno_triangle` branch-free** | ~11% of all instructions, 8 branches/call, 104 calls/sample | exhaustive input sweep vs the original |
| **hardware FTZ bit** | 2.4% | it *is* the plugin's FTZ semantics, in silicon |

## 6. What I would actually do, in order

1. ✅ **Done, no hardware:** ARM bit-exactness (8/8), real memory footprint,
   M7 compile, instruction counts, link surface, stack depth, libm parity.
2. ✅ **Done:** the two `_QWORD` pointer chases in `master_render.c` (§1) now read
   at pointer width. `make test` 29/29, `arm_golden.sh` 8/8 on both legs with
   hashes unchanged, clean `-Wall -Wextra` on x86 and Cortex-M7.
3. ⏳ **Needs a board — firmware is written, in `teensy/`.** `juno60_teensy.cpp`
   + `platformio.ini` + `README.md`: PSRAM via `-Wl,--wrap=calloc`, `FPSCR.FZ`
   set, and it runs `tests/test_teensy_golden.c` itself (via
   `-Dmain=juno_golden_main`) so the device executes the same code as the host
   gate. Needs **no audio hardware** — a bare Teensy 4.1 and USB serial. Prints
   the 8 hashes and DWT cycles/sample at 0/1/2/4/8 voices.
4. **Then** decide polyphony from real numbers and spend the hoisting effort
   where the profiler points.

Step 3 is one session once a board is in hand. Nothing here is weeks.

**Status of `teensy/`, stated plainly: written, never executed.** No board has
been attached, and `juno60_teensy.cpp` has never been compiled against
Teensyduino — expect to fix small integration details (header paths,
`printf`-to-Serial routing, `extmem_malloc` on your core version) on first
flash. The engine underneath it *is* proven: bare-metal M7 compile is clean and
ARM32 is bit-exact 8/8. The firmware is the instrument; the measurements are the
deliverable.

## 7. What is still honestly unknown

- **Real M7 cycles.** §4 is arithmetic on measured instruction counts, not a
  measurement. Only the device settles it; step 3 does that in an afternoon.
- **How much block-hoisting actually recovers.** Unknown until profiled. The
  upper bound is large; the realised number is not predictable from here.
- **Daisy at 8 voices bit-exact looks out of reach at 480 MHz** on every branch
  of the estimate, and no honest cut in this document closes a 2–3x gap. Reduced
  polyphony or the Teensy's clock does.
- qemu-user proves *semantics*, not *timing*; it is not cycle-accurate and was
  never used as one here.
