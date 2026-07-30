# Daisy Seed — experimental bring-up and instrumentation

Firmware to answer one question with measurements instead of arithmetic: **can a
Daisy Seed run 8 voices of the bit-exact JUNO-60 port in real time, and if not,
why not and by how much?**

**It plays.** Flash it, plug audio out into anything, and it self-plays through
the 8 factory patches embedded in `tests/teensy_golden.h` — an 8-note chord (all
eight voices at once) then an arpeggio, cycling patches. **No MIDI keyboard, no
audio shield, no extra wiring**: the Daisy Seed's codec is on-board.

Before it starts playing it runs four silent measurement passes over USB serial,
so one flash gives you both the numbers and the sound. You need nothing but a
Daisy Seed, a USB cable, and something to listen on.

**Voice count: always 8.** All eight free-run every sample — that is what the
plugin does and it is not configurable without breaking bit-exactness. Whether
all 8 *sustain* in real time here is the open question, and E2/E5 answer it.

## Status: builds and links, never run on hardware

Unlike `teensy/`, this was **compiled and linked here** against real libDaisy,
and both post-link assertions pass:

```
build exit=0
  build/voice_render.o:  0 fused ops
  build/master_render.o: 0 fused ops
OK: no FMA -- bit-exactness preserved
OK: Reset_Handler -> main, and main survived the link

           SRAM:      288480 B       512 KB     55.02%
         ITCMRAM:           0 B        64 KB      0.00%
          SDRAM:      13568 KB        64 MB     20.70%
      QSPIFLASH:      501392 B      7936 KB      6.17%
```

It has still never executed on silicon, so expect runtime surprises. But it is a
flashable `.bin`, the memory map fits with room to spare, and the two things that
would silently destroy the experiment are asserted at build time.

## Build

```
git clone --recursive https://github.com/electro-smith/libDaisy
make -C libDaisy
cd daisy && make LIBDAISY_DIR=../../libDaisy && make check
```

`--recursive` matters: the ST HAL is a submodule and the build fails cryptically
without it. Then flash with `make program-dfu` (hold BOOT, tap RESET) and open a
serial monitor at any baud.

**`make check` is not optional.** It runs the two assertions below, and both
guard failures that produce a clean `exit 0` and a dead board.

## The four things that will bite you

**1. `-ffp-contract=off` — libDaisy does not set it.** `core/Makefile` sets
`-mcpu`, `-mfpu`, `-O2`, `-std=gnu11` and no fp-contract flag at all, so GCC
falls back to its default of `fast` and *will* fuse `a*b+c` into a single-rounded
`VFMA`. The reference is x86 SSE2, which has no FMA. That is a silent divergence
on every patch. `make check-fpcontract` disassembles the two hot render objects
and fails if any fused op appears.

**2. Never put `-Dmain=...` in `C_DEFS`.** libDaisy's `core/Makefile:53` compiles
its *own* `startup_stm32h750xx.c` as part of your project, so a global
`-Dmain=juno_golden_main` rewrites the startup's call to `main()`.
`Reset_Handler` then branches straight into the golden-corpus driver, your real
`main()` becomes unreferenced, and `--gc-sections` deletes it along with
everything it touched — **with a clean exit 0**. On hardware that boots with no
`hw.Init()`, hence no SDRAM clock and no logger, and dies silently.

This actually happened during development and nothing in the build output hinted
at it; it was caught by disassembling `Reset_Handler` and finding
`bl <juno_golden_main>`. The renames now live inside `golden_shim.c`, scoped to
one translation unit, and `make verify-entry` asserts that the reset vector
reaches `main` on every build.

**3. Benchmark buffers must be `volatile`.** The first E4 filled a plain array
with `memset(,1,)`; GCC then knew every word was `0x01010101`, constant-folded
the whole accumulation, dropped the loads, and garbage-collected the array out of
the binary — while the benchmark still printed a plausible number. Both buffers
are now `volatile`, filled from a runtime-seeded PRNG, with results stored to a
`volatile` sink. Verify placement by symbol address, not by reading the log:
`g_axi_buf` must be at `0x24xxxxxx` (AXI SRAM) and `g_sdr_buf` at `0xC0xxxxxx`
(SDRAM). If they are both in SDRAM, E4 is comparing SDRAM to itself.

**4. `APP_TYPE = BOOT_QSPI` is mandatory.** The engine is ~500 KB and the H750
has only 128 KB of internal flash. `BOOT_NONE` cannot link. This needs the Daisy
bootloader flashed once (`make program-boot`).

## The five experiments

| | measures | why it matters |
|---|---|---|
| **E1** | golden corpus, 8 scenarios | is the engine bit-exact on real M7 silicon? everything else is moot if not |
| **E2** | DWT cycles/sample at 0/1/2/4/8 voices | the headline number; replaces every estimate in `docs/ARM_MEASURED.md` §4 |
| **E3** | same workload, D-cache on vs off | how much of the cost is SDRAM latency rather than compute? |
| **E4** | 256 KB walk in SDRAM vs AXI SRAM, sequential and scattered | what would relocating hot state into internal RAM buy? |
| **E5** | **live audio** — self-playing, worst-case block cycles, overrun count | the answer by ear *and* by number |

E3 and E4 exist because `docs/ARM_MEASURED.md` §4 estimates cost purely from
instruction counts and implicitly assumes memory is free. It is not. The engine's
state is a single ~10.5 MB span that must live in SDRAM, its per-sample working
set is ~416 KB of random access (§2), and the Cortex-M7 L1 D-cache is 16 KB —
a >25x oversubscription. SDRAM latency could plausibly dominate everything the
instruction count predicts, so it gets measured rather than argued about.

## Sample rates

The corpus runs at **44100** and the live audio path would run at **48000**.
That is not a contradiction: E1–E4 never touch the audio peripheral, they render
into RAM and hash. libDaisy's `SaiHandle::Config::SampleRate` offers only
8/16/32/48/96 kHz — there is no 44.1 — and 48000 is inside the port's proven rate
contract (44100/48000/88200/96000/192000), so live audio is fine at 48 kHz.

## Reading E1's verdict

`ALL 8/8 BIT-EXACT` unlocks everything else. Anything else: **do not tune
anything.** Check in order — (a) did `-ffp-contract=off` reach the compiler
(`make check-fpcontract`), (b) is `FPSCR.FZ` set before the first render,
(c) libm. (c) is unlikely: `expf` was proven bit-identical between glibc and
newlib's Cortex-M7 multilib over 32,000,423 inputs
(`tools/embed/libm_expf_ab.sh`), and `fmodf` is exact by IEEE-754.

## E5, and reading the real-time verdict

After the silent passes, `start_playing()` warms up (see below), starts the
codec, and the main loop prints once a second:

```
patch 3/8 'bass_low'  worst 4820 cyc/block (48% of budget)  overruns 0/1000
```

- **`overruns 0/N` and under 100%** → it keeps up. That is 8 voices bit-exact in
  real time on a Daisy.
- **Steady overruns** → it does not, and the percentage tells you by how much.
- Expect **one** overrun per patch change: a full recall costs far more than one
  block, so it is applied at a block boundary and produces a single audible
  click, exactly as switching patches on the real thing does. The peak resets
  each second so that one block does not poison the reading forever.

Three implementation notes that matter:

- **`size` is not frames.** libDaisy's interleaved callback passes the *total*
  sample count (L and R separately — `InternalCallback` steps `i += 2`), while
  `juno_gui_render` takes frames. Passing `size` straight through renders twice
  the buffer and corrupts memory past the end. It is `size / 2`.
- **4-second warm-up before audio starts.** All 8 DCOs boot phase-aligned, which
  makes the first note of a UNISON patch peak ~2× hot and read several times
  darker until the per-voice CONDITION scatter decorrelates them
  (`docs/COLDSTART_UNISON_FINDING.md`). That is 4 s of real DSP, so first sound
  is not instant.
- **`OUT_TRIM 0.45`** is a delivery-only output trim, the same role the webapp's
  MONITOR fader plays. The engine's master stage ends in `2*(sat*1.0)` and can
  legitimately exceed ±1.0, which a codec would clip. It touches no coefficient.

## What this is not

No MIDI input yet — it self-plays instead. The Daisy's micro-USB is taken by the
serial log, so MIDI would mean UART MIDI (a DIN socket and two resistors) or
moving the log off USB. Small follow-up, deliberately not in the way of the first
flash.

## Bootloader must be v6.0 or newer

`DaisySeed::Init` (`src/daisy_seed.cpp:113-131`) skips **both** `sdram_handle.Init()`
and — via `syscfg.skip_clocks` — `System::ConfigureClocks()/ConfigureMpu()`
(`src/sys/system.cpp:220-224`) when the bootloader predates v6.0 *and* the app
does not run from internal flash. This firmware is `BOOT_QSPI`, so it always runs
from QSPI and always trips that condition on an old bootloader.

The result would be a 13 MB `DSY_SDRAM_BSS` pool in un-clocked memory: the
`memset` in `__wrap_calloc` faults or silently writes garbage, and with no MPU
programming `0xC0000000` falls back to non-cacheable Device memory, so E3/E4 would
measure nonsense even if it survived.

The firmware checks `System::GetBootloaderVersion()` and
`System::GetProgramMemoryRegion()` at startup and **halts with an explanation**
rather than failing in a way that looks like a port defect. Fix is
`make program-boot`, then reflash the app.
