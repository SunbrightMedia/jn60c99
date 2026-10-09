# Teensy 4.1 bring-up

First-hardware firmware for the JUNO-60 C99 port. It answers the only two
questions that cannot be answered off the device, and deliberately nothing else.

| | question | how |
|---|---|---|
| 1 | Is the engine bit-exact on real Cortex-M7? | replays `tests/teensy_golden.h`, prints 8 FNV-1a-64 hashes |
| 2 | What does a sample really cost? | DWT cycle counter, cycles/sample vs the budget for the actual clock |

**No audio hardware is needed.** No codec, no DAC, no audio shield, no audio
library. A bare Teensy 4.1 and a USB cable are enough — both answers arrive over
Serial. Sound comes after correctness and cost.

## Hardware requirement (measured, not assumed)

**Both PSRAM pads must be populated: 2 × 8 MB = 16 MB.** The engine state is a
single ~10.5 MB span (highest touched offset 11,026,432 — `docs/ARM_MEASURED.md`
§2), so one 8 MB chip cannot hold it. The firmware checks
`external_psram_size` and refuses to run with a clear message rather than
failing mysteriously.

Everything else fits comfortably: 373.6 KiB of engine text against 8 MB flash,
and the whole audio path needs **584 bytes of stack** (measured with
`-fstack-usage`).

## Build

```
cd teensy
pio run -t upload
pio device monitor -b 115200
```

Arduino IDE alternative: open `juno60_teensy.cpp` as a sketch, add `../src/*.c`,
`../gui/juno_bridge.c` and `../tests/test_teensy_golden.c` to the project, set
Tools ▸ CPU Speed to **816 MHz**, and add the `build_flags` from
`platformio.ini` — in particular `-ffp-contract=off`, `-Dmain=juno_golden_main`
and the two `--wrap` flags. Arduino IDE makes per-project flags awkward;
PlatformIO is much less painful here.

## The four flags that matter

- **`-ffp-contract=off`** — load-bearing. The reference is x86 SSE2, which has no
  FMA. FPv5 does. Without this the compiler fuses `a*b+c` into a single
  rounding and the port silently diverges. `tests/test_fma_canary.c` catches it.
- **`-Wl,--wrap=calloc` / `--wrap=free`** — routes the engine's one large
  allocation into PSRAM via `extmem_malloc`, with no change to engine source.
  Small allocations still go to the normal heap.
- **`-Dmain=juno_golden_main`** — lets the device run *the same*
  `tests/test_teensy_golden.c` as the host gate, instead of a reimplementation
  that would drift out of sync.
- **`board_build.f_cpu = 816000000L`** — a stock Teensyduino clock option, not a
  hack. 1.7× the Daisy's 480 MHz, and the single biggest lever available. If the
  board is unstable or hot, drop to 600 MHz; the firmware reads the budget from
  `F_CPU_ACTUAL`, so its verdict stays honest either way.

## Reading the output

**Section 1 — bit-exactness.** `ALL 8/8 BIT-EXACT` means the engine reproduces
the plugin on real M7 silicon and every optimisation in `docs/ARM_MEASURED.md`
§5 is unlocked. Anything else: **do not tune anything.** Check, in order,
(a) `-ffp-contract=off` really applied, (b) `FPSCR.FZ` set before the first
render, (c) the libm multilib. (c) is unlikely — `expf` was proven bit-identical
between glibc and newlib's Cortex-M7 build over 32,000,423 inputs
(`tools/embed/libm_expf_ab.sh`), and `fmodf` is exact by IEEE-754 — but confirm.

**Section 2 — cost.** Expect the cost to be **nearly flat in polyphony**: the
plugin renders all 8 voices every sample by design, so an idle voice costs
almost as much as a sounding one. On x86 that is 14,273 cycles/sample at 0
voices vs 14,576 at 8. These DWT numbers replace every off-device ESTIMATE in
`docs/ARM_MEASURED.md` §4 — including the x86↔M7 IPC ratio, which is the largest
unknown in the whole embedded plan.

## What this firmware is not

It does not produce audio, take MIDI in, or drive a codec. Those are
straightforward once §1 and §2 are answered, and pointless before — an engine
that is not bit-exact or not real-time is not worth wiring to a DAC.

## Honest status

Everything in this directory is **written but never executed** — no board has
been attached. The engine compiles clean for bare-metal Cortex-M7 and is proven
bit-exact on 32-bit ARM under emulation (`tools/embed/arm_golden.sh`, 8/8), but
`juno60_teensy.cpp` itself has never been built against Teensyduino, so expect
to fix small integration details (header paths, `printf`-to-Serial routing,
`extmem_malloc` availability on your core version) on first flash. The
measurements it takes are the deliverable; the firmware is the instrument.
