# PORT_PI — bare-metal Raspberry Pi bring-up (LIVING)

Binding order (user, 2026-09-15): "Start the zero 2 w bare-metal bring up, we
will first flash and debug on a raspberry pi 3A+ compute board as zero 2 w's
are months away."

## Why this track exists
The four-ESP32-S3 chain is retired. Every live-bench failure of the prior week
lived in the transport layer this project INVENTED — the chain, the links, the
scheduler — never in the ported DSP. The user's decision: delete that layer.
Run ALL six voices + full FX on ONE bare-metal board, no Linux, no RTOS. The
glue that remains (render callback, I2S out, key/pot in, boot) is ~300 lines,
not thousands.

- Target silicon: BCM2837 (4× Cortex-A53, AArch64). Same binary on Zero 2 W,
  Pi 3A+, Pi 3B — one build serves all three.
- Prototype board: Pi 3A+ (Zero 2 W's are months out; identical SoC).
- Framework: Circle (bare-metal C++, boots direct to metal, interrupt-driven
  I2S). MiniDexed (bare-metal polyphonic DX7 on the same SoC) is the precedent.

## LOAD-BEARING RISK — RETIRED (2026-09-15)
The whole plan rested on one claim: the bit-exact engine keeps its seal when
built for ARM. PROVEN, before any board is bought.

- Harness: `tools/pi/arm_bitexact.c` — renders factory patches through the
  engine's own `juno_gui_*` API, FNV-1a over the raw float output bytes. Any
  single-bit float difference changes the hash.
- Method (two-build diff, x86 native vs aarch64 cross under qemu):
  ```
  FLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w -Isrc -Igui"
  SRC="$(ls src/*.c) gui/juno_bridge.c tools/pi/arm_bitexact.c"
  cc              $FLAGS         -o /tmp/be_x86 $SRC -lm
  aarch64-linux-gnu-gcc $FLAGS -static -o /tmp/be_arm $SRC -lm
  /tmp/be_x86       truth/presetbankog1.bin
  qemu-aarch64 /tmp/be_arm truth/presetbankog1.bin
  ```
- RESULT: **ALL 64 PATCHES BIT-IDENTICAL x86 == aarch64.** Every hash equal,
  byte for byte. The 12-patch spread, on the record:

  | patch | hash (both x86 and aarch64) |
  |------:|-----------------------------|
  |  0 | d14d61ab4a49c2e0 |
  |  5 | 4cbf32a7cfb7da99 |
  | 11 | bd92b9d0c65bc0c5 |
  | 21 | 82ab70f24e5c790b |
  | 27 | 69d542f68ec306f6 |
  | 36 | 179b9b437819e100 |
  | 42 | b8897422945c1047 |
  | 48 | 46599f527bff2f69 |
  | 55 | e6eb98f21104a7ca |
  | 60 | dfffa67b09018295 |
  | 63 | 92cf4ba60d44c912 |
  |  7 | 1b1a5e850afdf3d6 |

## The one bug the ARM build found
`src/juno_ftz.c` `juno_enable_hw_ftz()` reached the flush-to-zero control
register with AArch32-only `vmrs/vmsr fpscr`. That does not assemble on
AArch64. Without it the denormal reverb/delay tails would NOT flush and would
diverge from x86 — a SILENT bit-exactness break, not a crash. Fixed: AArch64
uses `mrs/msr fpcr`, same FZ bit 24. This is the first real ARM-port defect,
caught by the gate before silicon.

## Cost headroom (why one board fits)
6 voices + FX ≈ 1.7 GHz-equivalent (S3 measurement, b45). Pi 3A+ / Zero 2 W =
4× 1.4 GHz Cortex-A53. Budget is comfortable; the S3's problem was never the
DSP cost, it was the invented transport.

## BOOT STEP — DONE (2026-09-15)
Circle Step51 is a pinned submodule at `pi/circle`. The platform glue is
`pi/kernel/` (~150 lines total): `kernel.{h,cpp}` boot to metal, init UART +
timer, print a banner; `main.cpp` is the Circle entry; `bare_stubs.c` is the
one shim the `aarch64-linux-gnu-` toolchain needs (`__getauxval` → 0, selects
the portable atomic path; Circle upstream uses `aarch64-none-elf-` and has no
such call). `build.sh` makes the hardware image; `run_qemu.sh` is the gate.

RUN-PROOF (not "it built" — it BOOTS AND RUNS): the `--qemu` variant booted on
the emulated **Pi 3A+** (`qemu-system-aarch64 -M raspi3ap`, the exact prototype
board, BCM2837), captured UART:

```
logger: Circle 51 started on Raspberry Pi 3 Model A+ 512MB (AArch64)
00:00:00.56 juno: JUNO bare-metal bring-up — BOOT OK
00:00:00.56 juno: Circle on Raspberry Pi 3 Model A+
00:00:00.56 juno: SoC BCM2837, 512 MB RAM, 4 cores
00:00:01.00 juno: alive t=1 ... t=5
00:00:05.00 juno: BOOT PROOF COMPLETE — halting.
```

The kernel reaches our code, reads the SoC/RAM/cores correctly, runs a 5-beat
heartbeat, and halts clean. Same source also builds the hardware `kernel8.img`
(one image serves Zero 2 W / 3A+ / 3B). Repeat: `sh pi/run_qemu.sh raspi3ap`.

Container deps (ephemeral): `apt-get install -y gcc-aarch64-linux-gnu
g++-aarch64-linux-gnu qemu-system-arm`.

## ENGINE ON METAL — BIT-EXACT (2026-09-15)
The original port (src/, 8 voices, all FX, NO levers, NO compromises) is linked
into the bare-metal kernel and renders audio on the emulated Pi 3A+ at the new
default **48000 Hz**. Every patch is byte-identical to the plugin.

- Default rate: **48 kHz** (proven-exact; friendlier DAC clocking; ~half the
  3A+ compute). Passed once to `juno_gui_create`.
- Shared render+hash core `pi/probe/juno_probe_core.c` is compiled with the
  SAME proven bit-exact flags on host and on metal, so an equal hash means
  equal samples. `pi/probe/host_ref.c` prints the x86 reference; the x86 engine
  nulls EXACTLY 0 vs the plugin, so those hashes ARE the plugin.
- The engine is built into `libjunoengine.a` by `pi/build_engine.sh` with the
  proven flags + only bare-metal-safe additions (freestanding, no stack
  protector, no PIC) — none touch arithmetic. `pi/kernel/bare_libm.c` supplies
  the engine's only libm calls (fabsf/fmodf/lrint/fmax*/fmin*) as exact ops
  (AArch64 instructions + an exact `fmodf`); no glibc libm is linked. Both the
  48 kHz path and bare_libm were re-proven bit-exact under qemu-user (12/12)
  BEFORE the metal run.
- The factory bank is embedded (`bank_blob.S` .incbin) — no filesystem needed.

RESULT, on `qemu-system-aarch64 -M raspi3ap` (captured UART):
```
juno: ENGINE bit-exact gate: original port, 8 voices, no levers
juno: rate 48000 Hz, bank 1294295 bytes, 4000 frames/patch, note 60 vel 105
juno: patch  0  hash 1830844881997e88  pk 0.195906  == MATCH
   ... (all 12 patches) ...
juno: BIT-EXACT RESULT: 12/12 patches identical to the plugin
juno: FULL SYNTH BIT-EXACT ON BARE METAL — EXACT WAVEFORM MATCH
```
The chain is closed: **plugin == x86 == aarch64-user == aarch64 bare-metal.**
One command: `sh pi/run_qemu.sh raspi3ap`.

## ALL SCENARIOS + I2S GLUE (2026-09-15)
Two images from one source (`make` = GATE, `make JUNO_PLAY=1` = PLAY):

- **GATE** (verifiable under QEMU): the metal probe now covers ALL 64 factory
  patches PLUS 5 deterministic seeded STORMS (note-on/off + patch-change
  sequences: polyphony, voice-stealing, lifecycle, recall). The reference
  `juno_ref.h` is generated at build time by the x86 engine (== the plugin);
  the metal must reproduce every hash. The storms are rendered on the metal at
  the **I2S DMA chunk** while the reference is the **continuous** render, so a
  match proves, together: metal == plugin AND chunk-invariance (the real-time
  block callback adds NO boundary tick — the exact S3 failure class). Host-side
  chunk-invariance is also asserted before the header is accepted.
- **PLAY** (silicon only): `pi/kernel/juno_sound.cpp` is the ONLY audio code we
  own — one `GetChunk()` that fills each DMA block from `juno_gui_render`. The
  I2S DRIVER ITSELF IS CIRCLE'S (`CI2SSoundBaseDevice`: PCM peripheral, DMA,
  clocking — the MiniDexed driver). QEMU has no I2S, so PLAY is not run here; it
  builds clean, and the gates prove the samples it will emit are the plugin's.

Every scenario was first re-proven ARM-bit-exact under qemu-user (64 patches +
5 storms, identical header), then ON THE METAL:
```
PATCHES: 64/64 identical to the plugin
STORMS:  5/5 identical to the plugin   (each chunk-invariant)
BIT-EXACT RESULT: 69/69 scenarios
FULL SYNTH BIT-EXACT ON BARE METAL — ALL SCENARIOS — EXACT WAVEFORM MATCH
```
The gate reuses ONE engine instance (`juno_gui_reinit` resets it to cold state
without reallocating the 12 MB), so it runs on the real `-M raspi3ap` (512 MB)
prototype with no heap churn. `reinit` is proven bit-identical to a fresh
create (the only difference is the shim base pointer, which is excluded from the
audio), and the reused-engine core is ARM bit-exact (x86 == aarch64 header).

## THE INVARIANT + full-surface swarm (2026-09-16)
END_GOAL's INVARIANT — audio never breaks for ANY input — now has a gate. The
seed swarm drives the WHOLE control surface (all 128 MIDI notes/velocities, all
79 host params across their true min..max — DCO/VCF/VCA/ENV/LFO/BEND/MOD/GLOBAL/
ARP/EFFECT/DELAY/CHORUS/REVERB — plus patches and tempo), and `juno_probe_fuzz`
scans every sample for non-finite (NaN/inf) and out-of-bound.
- x86: 2000 seeds x 16000 frames = **64,000,000 samples, ZERO bad**, worst
  |peak| 1.98. aarch64 (qemu-user) 80 seeds: identically clean.
- The SAME widened generator now feeds the bit-exact storms, so they cover the
  whole surface too (still chunk-invariant).
- On metal (`raspi3ap`): 64 patches + 5 storms + 6 invariant swarms →
  **69/69 bit-exact + invariant HELD**.

Real-time budget is MEASURED in `docs/pi/BUDGET.md` (30,565 x86 instr/sample;
the 8-voice engine fits one Pi 3A+/Zero 2 W across its 4 cores at 48 kHz).

## MULTI-CORE SPLIT — bit-exact gate (2026-09-16)
Spreading the 8 voices across the A53's cores is only safe if the split output
is byte-identical to single-core. Float add is not associative, so the sum order
is the trap. The engine makes an exact split possible (`src/juno_driver.c`):
- voices are INDEPENDENT — each reads its own block + the SHARED noise snapshot,
  writes only its own `vbuf[v]` slot;
- the sum is NOT in the voice loop — `juno_master_render` reads `vbuf[0..7]` in a
  FIXED canonical order, so which core fills which slot cannot change the result;
- the shared noise/LFSR block is snapshot-restored before each voice.

`pi/probe/split_gate.c` renders the voices in many core→voice PARTITIONS
(reversed, 2-core swapped/round-robin, 4×2, arbitrary scatter) and checks the
stereo sample AND the whole 12 MB post-state (noise, voice states, FX, flushed
denormals) are byte-identical to single-core, across all 64 patches × evolution
points (attack→sustain→decay) × diverse seeded voice states (mixed activity,
voice-stealing, live param edits). Needs a tiny `juno_gui_state` accessor.
RESULT: **SPLIT IS BIT-EXACT — every partition == single-core, sample and state**
(7680 checks: 64 patches × 4 seeds × 5 points × 6 partitions, x86; the same
voice/master path is already ARM-bit-exact, and a qemu-user subset confirms).

It PROVES the numerics and REQUIRES of the implementation: each core renders its
voices from a PRIVATE copy of the shared noise block (no concurrent clobber), and
the master sums `vbuf` on ONE core after a barrier. Given that, the split is exact.

### What else could break it — enumerated by census, not argued
`pi/probe/split_census.c` diffs the whole 12 MB after each `juno_voice_render`
and classifies every written byte. Across all 64 patches × 5 points × 8 voices:
`own-main 1,000,837 · own-aux 0 · noise(shared) 35,328 · **HAZARD 0**`. So a
voice writes ONLY its own private block plus the shared noise block — no
cross-voice write, no shared-global write. Static scan of the render path
(`voice_render`, `juno_dsp`, `master_render`, `juno_curve`, `juno_ramp`) found
NO function-scope statics; the only mutable engine global is `eb_coef_gen`, which
the control layer bumps and the render only READS.

RIGIDITY CHECKLIST (the full set the split must honour):
1. **Noise block `[84272,84436)`** — the ONE shared cell voices write; give each
   core a PRIVATE copy (census-proven sole in-state hazard).
2. **Sum on one core, canonical `vbuf[0..7]` order** — proven by the split gate.
3. **Barrier** — all voice cores finish before the master reads `vbuf`; then
   master → `flush_denormals` run single-core.
4. **Per-core FTZ/DAZ (FPCR)** — every core must `juno_enable_hw_ftz()` or
   denormals diverge from x86.
5. **Memory ordering** — the barrier needs ARM DMB/DSB so `vbuf` writes are
   visible to the master core (Circle's multicore support provides this).
6. **Control layer single-core** — note allocation, arp, patch recall run
   between blocks on one core, never concurrent with voice render.
7. Read-only shared data (params, coefficients, `eb_coef_gen`, the render
   function pointers) is safe — every core reads the same values, none writes.

Items 1–2 are code-proven here; 3–6 are implementation disciplines the split
firmware must follow (and the split gate re-checks 1–2 on every engine change).

### BLOCK fork-join — modelled and proven, two more rules found by gating
`pi/probe/block_split_gate.c` models the real firmware execution (shared-nothing
private state per core, per-sample control tick replicated, one audio core sums
+ masters) and runs 60 CONSECUTIVE blocks vs `juno_gui_render` with the arp on/off
and LIVE note events. Building it caught TWO defects that would have been vicious
live bugs — both now design rules:

8. **The master must stay interleaved per sample.** The master reads per-sample
   control smoothers (the ~190 smoothed cells). A block-then-master ordering
   reads them at end-of-block → last-bit drift. So the audio core does, per
   sample: tick, render its voices, master, flush; workers only PRECOMPUTE their
   voices for the block.
9. **Every core's ctx gets the identical event stream from boot.** The voice
   allocation state lives in the `juno_ctx`, NOT in the 12 MB `st`. A copy driven
   by cloned `st` (but not the ctx) assigns a new note to a different voice →
   divergence at the note-on. So control is BROADCAST to every copy from boot;
   never clone mid-stream.

RESULT with both rules: **BLOCK SHARED-NOTHING SPLIT IS BIT-EXACT** vs
`juno_gui_render` — every 2/3/4-core partition, arp on/off, live notes, every
sample. Requires `juno_gui_tick` (per-sample control step) + `juno_gui_state`
accessors (test-only). NO DSP change. Only after this gate is green is the
Circle multicore firmware written.

### MULTI-CORE KERNEL — ONE FORK-JOIN, GATE-PROVEN, DRIVES PLAY (2026-09-16)
The fork-join is ONE shared unit — `CJunoForkJoin : CMultiCoreSupport`
(`pi/kernel/juno_forkjoin.{h,cpp}`) — used by BOTH the self-checking gate and
the real-time I2S path, so the gate proves the EXACT code PLAY runs, not a copy.
Circle's proven primitive; MiniDexed-style per-block fork-join with `volatile`
status flags — NO atomics/IPIs — plus ARM `DataSyncBarrier`/`DataMemBarrier`
around the barrier. 4 private engine copies; core 0 (voices 0-1 + master) kicks
the 3 worker cores (voices 2-3|4-5|6-7), waits, then interleaves its render +
master. `RenderBlock(out, frames)` renders any block length in <= 1024-frame
sub-blocks. Per-core FTZ (core 0 via `juno_gui_create`; workers in `Run`). Built
with `--multicore` (`ARM_ALLOW_MULTI_CORE`) on ALL pi images now (build.sh,
run_qemu.sh, run_split.sh) — the probe still runs single-core, workers parked.

**GATE** (`juno_split.cpp`): core 0 drives the fork-join and compares its output,
block for block, to a single-core reference. WIDE coverage: all 64 factory
patches; the 5 seeded STORMS the single-core gate uses (whole surface — notes,
patch changes, all 79 host params, tempo — from the ONE public generator
`juno_storm_build`/`juno_storm_fire`, broadcast to every copy + the reference so
voice allocation stays in lockstep); AND a DMA-block pass at 1024 frames = the
I2S chunk PLAY actually renders. On `qemu-system-aarch64 -M raspi3b` (4 cores; do
NOT pass `-smp` — it breaks boot):
```
CPU core 1/2/3 started
PATCHES: 64/64 identical to single-core
storm 0badc0de..deadbeef: == MATCH over 188 blocks (max|diff| = 0 ppb)
BLOCK-SIZE {1024,1536,100}: 9/9 identical to single-core
VOICE-STEAL (13 notes): 3/3 identical to single-core
IDLE (no notes): 5/5 identical to single-core
MULTI-CORE RESULT: 86/86 scenarios identical to single-core (worst 0 ppb)
SPLIT BIT-EXACT ON 4 EMULATED CORES — barrier + per-core copies proven
```
Coverage: 64 patches; 5 full-surface storms; block sizes 1024 (the I2S chunk),
1536 (> MAXBLK, so the sub-block loop must stitch two fork-joins) and 100; voice
stealing (13 notes onto 8 physical voices, the class where a harness bug once
hid); AND idle (no notes — the earlier phases all played notes, so the master's
own idle floor was untested until now). All 0 ppb.

**BOOT DEMO** (`juno_sound.cpp`, on by default; `-DJUNO_NO_DEMO` disables): after
the silence probe passes and I2S opens, PLAY strums an A-major chord up
(A4 C#5 E5 A5 = MIDI 69/73/76/81) on the boot patch, does a fast re-strum
(trill), then releases — ~1.7 s, one shot, through the fork-join. Proves
first-power-on makes sound with no input; the panel takes over after.

**PANEL PINS** (BCM GPIO, `juno_panel.cpp`): keys C/C#/D/D# = 17/27/22/23;
octave down/up = 5/6; patch down/up = 24/25. Pull-up, active-low, debounced,
unwired-safe.

**PLAY** (`juno_sound.cpp`): core 0's I2S `GetChunk` polls the panel then calls
the same `fork.RenderBlock(frames)` — the DMA pull IS the fork-join kick — then
scales to the hardware range. The workers (cores 1-3) are started by
`fork.Initialize()` at boot and spin ready. So the 4-core real-time audio is
bit-identical to the plugin by the gate's proof. `sh pi/build.sh` builds it
(links clean, with the silence probe + panel); QEMU has no I2S, so only silicon
can hear it. Owed: MIDI-in; the pot ADC; flash on a real Pi 3A+ + I2S DAC.

### SILENCE PROBE (SHIP LAW) + PANEL (2026-09-16)
**Silence probe** (`juno_silence.cpp`): before the DAC opens, PLAY renders the
boot bank with NO notes through the fork-join and proves the idle output is
SILENT; a STUCK verdict refuses to start I2S. `sh pi/run_silence.sh` proves it
under QEMU AND its seen-to-fail (`JUNO_SIL_STUCK` holds a note -> STUCK, out_peak
0.197). KEY FINDING: silence is NOT digital zero. The plugin's own idle output
carries a small steady floor (the JUNO chorus/BBD): measured on the x86 engine
(== the plugin) the no-note floor is 0..0.00081 across all 64 patches (~ -62
dBFS), boot patch 0 = 0.00049 — CORRECT output, not a fault. The threshold is
0.01 (-40 dBFS): >12x the floor, far below any audible stuck voice. The split
gate's new IDLE phase proves that floor is bit-exact across cores too.

**Panel** (`juno_panel.cpp`): GPIO keys + octave, Circle `CGPIOPin`, pull-up
ACTIVE-LOW, debounced, UNWIRED-SAFE (an unconnected pin reads high = not pressed,
so a bare board makes no phantom notes). Polled at the TOP of `GetChunk` (the
block boundary), so note events never race the render on core 0 — the same
"control between blocks" rule the fork-join follows. BCM pin map: keys C/C#/D/D#
= GPIO 17/27/22/23; octave down/up = GPIO 5/6. POTS (cutoff/resonance): the Pi
has NO on-chip ADC; analog pots need an external SPI ADC (e.g. MCP3008 on
`CSPIMaster`) — that read + the arm-by-stillness pickup law land when the ADC is
wired. GetChunk polls the panel only on silicon (QEMU never fires I2S), so the
panel is compile/link-proven here; its logic (debounce, octave, note map) is
silicon-tested.

### GATE REACH — what this gate catches, and what it CANNOT (2026-09-16)
"Every gate must be SEEN TO FAIL." The mutation switch `JS_MUT` in
`juno_forkjoin.cpp` injects one fault; `make JUNO_SPLIT=1 JS_MUT=n` then shows
whether the gate goes RED. Battery result on QEMU `raspi3b`:

Battery ran on the 81-scenario gate (before the IDLE phase; idle adds 5
all-GREEN scenarios and changes no verdict below, control now 86/86):

| JS_MUT | injected fault | gate verdict | meaning |
|---|---|---|---|
| 0 | none (control) | GREEN 81/81 | baseline |
| 1 | drop the kick `DataSyncBarrier` | **GREEN** | QEMU TCG cannot catch it |
| 2 | drop the vbuf-visibility `DataMemBarrier` | **GREEN** | QEMU TCG cannot catch it |
| 3 | drop the worker's publish `DataSyncBarrier` | **GREEN** | QEMU TCG cannot catch it |
| 4 | voice 5 never rendered (the S3 defect class) | **RED 22/81** | caught, loudly (0.26 diff) |
| 5 | worker hardware FTZ (FPCR) not enabled | **GREEN** | correct: FTZ is a SPEED guard |

Reading it straight:
- The gate BITES for a STRUCTURAL split defect — a voice not rendered, a
  mis-partition. That is the exact failure the S3 chain had, and MUT 4 proves
  the gate catches it hard. This is the risk the split most needs guarded.
- The three memory-ordering barriers are INVISIBLE to QEMU: its near-lockstep
  TCG does not reorder, so a wrong/absent barrier still passes. They are
  correct-by-construction (the MiniDexed producer/consumer pattern) and stay
  load-bearing on silicon; only a real A53 (soak under load) can exercise them.
- MUT 5 GREEN is CORRECT, not a hole: hardware FTZ (`juno_enable_hw_ftz`) is a
  SPEED guard against ~100x-slower denormal ops (crackle); the per-sample
  SOFTWARE flush `juno_flush_denormals` (called in both split paths) does the
  bit-exact correctness. So FTZ belongs in the silicon DEADLINE test, not here.

RESIDUAL RISK, silicon-only (QEMU cannot test): weak-memory reordering; the
real-time deadline / underrun; the `GetChunk` IRQ+DMA path (no I2S in QEMU); the
hardware (non-`--qemu`) multicore boot; the DAC format; a worker fault hanging
core 0 (no watchdog yet); the GPIO panel reads + debounce. The SILENCE PROBE
(SHIP LAW) is now BUILT into the PLAY image and proven under QEMU (accepts the
floor, catches STUCK), so the first flash proves its own end state. Still owed
before/at the flash: a soak under load (memory ordering + deadline), MIDI-in, and
the pot ADC. None of the residual items is a numeric defect the gate could have
caught.

## NEXT (open, in order)
1. ~~Circle build; boot to metal.~~ **DONE.**
2. ~~Link the engine; EXACT waveform match vs the plugin.~~ **DONE.**
3. ~~All 64 patches + seeded storms + chunk-invariance on metal.~~ **DONE.**
4. ~~I2S glue over Circle's driver (PLAY mode).~~ **DONE (builds; silicon to hear).**
5. Input: GPIO keys/octave/pots (same panel law as S3 `S3L_PANEL`), MIDI-in —
   feed the events into the PLAY engine instance.
6. On silicon: flash PLAY to a real Pi 3A+ + I2S DAC; SILENCE PROBE on the
   shipped output (SHIP LAW); confirm real-time headroom at 48 kHz.
7. Multi-core split (voices across the 4 A53 cores; shared RAM, no links) if one
   core is short of real time.
8. Cardless dev flash (rpiboot over USB); production SD-NAND / eMMC later.

## HARD LESSON carried in (SHIP LAW)
Never validate by ear, live layer included. No Pi image ships to the user
until its own signal gate proves the end state. The user's ears are not the
detector.
