# Daisy Seed feasibility report — JUNO-60 C99 port on the Electrosmith Daisy

> **⚠ SUPERSEDED IN PART — read `docs/ARM_MEASURED.md` first.** Later the same
> day the ARM work was actually *executed*, and it corrects two claims below:
> (1) the 12 MB is an **allocation**, not a working set — the hot set is
> **1.14 MB/patch**, of which only ~416 KiB is random-access, so memory is not
> the constraint this report treats it as; (2) ARM is **denser** than x86 for
> this code (M7 issues 28% fewer instructions/sample), not more expensive.
> The golden corpus is now **PROVEN 8/8 bit-exact on 32-bit ARM**, and the whole
> engine compiles for bare-metal Cortex-M7. §7 step 2 below is **done**.
> `ARM_MEASURED.md` also replaces this report's A4 (idle-voice fast-forward)
> with block-level loop-invariant hoisting, which unlike A4 *is* bit-exact.

*2026-07-29. Every number in this report is measured in this repo unless explicitly
labelled ESTIMATE. Benchmarks: `/tmp/bench2.c` pattern (in-repo engine via
`juno_gui_*`), gprof over the same run. Nothing here has executed on ARM yet —
that is finding #1.*

## 1. Executive verdict

| Question | Answer |
|---|---|
| Does the code port to Daisy? | **Yes, trivially.** Plain C99, no dependencies, no malloc in the audio path, one malloc total. The WASM build already proves the engine is bit-portable off x86-native (wasm_golden 8/8). |
| Does the 12 MB state fit? | **Yes.** Daisy has 64 MB SDRAM. The hot per-voice region is 84 KB and fits the H750's 128 KB DTCM. |
| Does the 442 KB of code+tables fit? | **Yes**, in the 8 MB QSPI flash (not the 128 KB internal flash — QSPI bootloader required). |
| Does it hit real time, **bit-exact**, 8 voices, today? | **No — ~1.5× over budget**, and the reason is structural, not sloppy code. |
| Can it hit real time bit-exact after the safe optimisations below? | **4–6 sounding voices: yes (ESTIMATE, good confidence). All 8 sounding simultaneously: borderline — plan for no.** |
| Can the Daisy do a full 8-voice JUNO-60? | **Yes — as a reference-validated native engine (Track B), which is exactly what Roland themselves did.** The bit-exact port is the golden oracle that makes that engine honest. |

## 2. The measured numbers

x86 Xeon @ 2.80 GHz, 44.1 kHz, `-O2 -ffp-contract=off`, factory patches 0/2/20:

```
cycles/sample     0 voices   1 voice   4 voices   8 voices
patch 0             14,273    14,315     14,251     14,576
patch 2             13,702    13,600     14,194     14,866
patch 20            14,850    14,433     14,499     15,342
```

**The cost is flat in polyphony.** All 8 voices free-run continuously — DCOs and
LFOs keep integrating even in silence, exactly as the analogue original's
oscillators never stop. (This same free-running is what fixed the cold-start
unison bug: the voices *must* keep running to decorrelate.)

gprof attribution of that fixed cost:

```
 83.9%  juno_voice_render     8 calls per sample, always     ≈ 1,497 cyc/voice/sample
  5.6%  juno_master_render    per sample                     ┐
  4.7%  juno_triangle         104 calls per sample           ├ non-voice floor ≈ 2,295 cyc/sample
  2.4%  juno_flush_denormals  per sample                     ┘
```

Target budgets (cycles per sample = clock / sample rate):

```
Daisy H750  @ 480 MHz, 48 kHz   : 10,000     (48 kHz is the Daisy codec's native rate,
Daisy H750  @ 480 MHz, 44.1 kHz : 10,884      and inside our proven rate contract)
Teensy 4.1  @ 600 MHz, 44.1 kHz : 13,605
```

So today's engine needs ~14,500 against a 10,000 budget **before** accounting for
any x86-vs-M7 IPC gap: **≥1.5× over.** (The Xeon is out-of-order and 3–4-wide; the
M7 is in-order dual-issue. The gap on this straight-line float code is the biggest
unknown and can only be measured on the device.)

## 3. Why it costs this much — and why "Roland did it in 2015" is the wrong yardstick

It is the right challenge and the honest answer makes the project make sense:

1. **We did not port an algorithm; we ported a proof.** `voice_render.c` is a
   bit-exact transcription of what MSVC emitted for the desktop plugin — 2,163
   lines of straight-line code per voice per sample, shadow-copy chains and all.
   The bit-exactness covenant forbids every classical optimisation: no
   restructuring, no reassociation, no FMA, no fixed-point, no SIMD, no
   "same-sounding" shortcuts. That is *the whole point* of this repo: it is the
   ground truth machine.
2. **Roland had none of these constraints.** The Boutique runs Roland's own ACB
   engine — their source, restructured and tuned for their chosen DSP platform,
   free to use any precision and any trick, and validated by its authors' ears
   and tests. And it is a **4-voice** instrument; the 8-voice engine we carry is
   the *desktop plugin's* configuration, written for machines with unlimited RAM
   and gigahertz to burn (12 MB of state says so).
3. **So the correct reading of "Roland did 4 voices on 2015 hardware" is:** the
   Daisy can absolutely run a full JUNO-60 — *written the way Roland wrote
   theirs.* What strains the Daisy is not the synth; it is replaying another
   compiler's output under oath. The oath is ours, chosen deliberately, and §6
   is how we cash it in rather than pay it forever.

## 4. Track A — the bit-exact engine on Daisy, with every safe cut applied

Ordered by value per risk. "Gate" = how we prove it changed nothing.

| Cut | Saving | Sound risk | Gate |
|---|---|---|---|
| **A1. Hardware FTZ instead of `juno_flush_denormals`** — the M7 FPU has an FZ bit that flushes subnormals exactly as x86 FTZ/DAZ does; set FPSCR once, delete the per-sample scan | 2.4% | none (it *is* the plugin's semantics, in silicon) | teensy_golden 8/8 on device |
| **A2. Memory placement** — hot code (voice 20.5 KB + master 26.7 KB ≈ 47 KB) into the 64 KB ITCM; the 84 KB of per-voice state into the 128 KB DTCM; FX delay lines stay in SDRAM behind the D-cache | large but unquantifiable off-device (ESTIMATE: this is the difference between ~1 IPC and cache-miss stalls) | none | bit-exactness is placement-invariant; teensy_golden |
| **A3. `juno_triangle` as bit-proven LUT** — 302 M calls, 104/sample | ≤4.7% | none if the table reproduces every output bit over the full input domain | exhaustive input sweep vs the original function, then teensy_golden |
| **A4. Idle-voice fast-forward** — a gated-off, fully-decayed voice contributes zero *now*; its only future-relevant state is free-running phase, which advances by a fixed per-sample increment and can be fast-forwarded analytically on re-gate (`phase += n·inc mod span`) | up to ~75% of voice cost **when voices are idle**; **zero when all 8 sound** | none *if* the phase-advance law is proven closed-form per free-running integrator (a real derivation task — the LFSR noise and LFO need the same treatment) | new A/B: idle N samples with skip vs without, full-state diff must be 0 for every N |
| A5. 32 kHz operation | 1.33× flat | out of the proven 4-rate contract; every rate-armed coefficient must be re-derived | recall_exhaustive at 32 kHz |
| ~~A6. doubles → floats~~ | ~~up to 2× on 73 sites~~ | **NOT bit-exact** — the binary's arithmetic uses doubles where it uses doubles. Track B only. | — |

**Arithmetic after A1–A4** (ESTIMATE): non-voice floor ~1,900 + ~1,400 per
*sounding* voice. At 48 kHz against 10,000: **5 sounding voices fit; 8 need
~13,100 — still ~30% over at x86-equal IPC, worse with any IPC gap.**

**Track A verdict: a bit-exact Daisy Juno with 4–6 voice polyphony is a
realistic goal. A bit-exact 8-voices-all-sounding Daisy Juno is not, at 480 MHz,
and no honest cut on this list changes that.** (Note the actual JU-06A hardware
is 4-voice; a 5–6 voice bit-exact unit already exceeds the machine Roland sells.)

## 5. Memory map (Daisy H750)

| Region | Size | Contents |
|---|---|---|
| ITCM | 64 KB | voice_render + master_render + driver (~47 KB hot code) |
| DTCM | 128 KB | 8 × 10,512 B voice states (84 KB) + stack |
| AXI SRAM | 512 KB | curve/arp tables (125 KB + 83 KB) copied from flash at boot |
| SDRAM | 64 MB | the 12 MB engine state (FX/delay/reverb lines), D-cached |
| QSPI flash | 8 MB | code + `teensy_golden.h` corpus + factory bank |

## 6. Track B — the engine Roland would build, certified by ours

Restructure freely — circular buffers, floats, SIMD-free clean C, voices that
sleep — and hold it to the bit-exact port as a **golden reference** instead of to
an oath:

1. Port each module natively (oscillator, filter, envelopes, chorus, delay,
   reverb) with idiomatic DSP.
2. Gate each module against the bit-exact port with a *tolerance* A/B
   (e.g. ≤ −120 dBFS error over the golden corpus + fuzz seeds), tightening or
   loosening per module deliberately, in a ledger, exactly like PROVENANCE.tsv.
3. Full-patch A/Bs over all 128 patches reuse the existing verify machinery
   wholesale — only the comparator changes from `==` to `|err| < ε`.

This is the configuration where **8 voices on the Daisy is comfortable**
(ESTIMATE: a native Juno voice is 100–300 cycles/sample; 8 voices + FX lands
well under half the budget). It is also, structurally, what the Boutique is: the
same algorithm, rebuilt for the platform — except ours ships with a
machine-checkable certificate that no Juno clone has ever had. **The expensive
thing this project built is exactly the thing that makes the fast thing honest.**

## 7. First-hardware checklist (do these in order, before optimising anything)

1. QSPI bootloader; libDaisy audio callback → `juno_gui_render`; state in SDRAM.
2. **Run `tests/test_teensy_golden` on the device.** It has never executed on
   ARM. 8/8 = the engine is bit-exact on M7 and everything above is unlocked;
   any mismatch = stop and root-cause (fmod/libm or FZ-mode semantics first).
3. Profile with the DWT cycle counter per function — replaces every ESTIMATE
   above, especially the IPC gap.
4. Apply A1→A4 in order, re-running the golden corpus after each.
5. Decide Track A polyphony honestly from the on-device numbers, or fork Track B.

## 8. Honest unknowns

- **Nothing has ever run on ARM.** WASM golden 8/8 is strong evidence the
  arithmetic is portable (same discipline: IEEE, no FMA, FTZ shim), but the M7
  is a new compiler + new libm. Step 2 above settles it in minutes.
- The x86↔M7 IPC ratio on this code is unmeasured; every "over budget" figure
  above assumes parity, which favours the Daisy.
- A4's fast-forward laws (DCO phase, LFO, noise LFSR) are underived; A4 is a
  research task with a provable answer, not a knob.
- The Daisy's own overhead (audio callback, USB/MIDI service) takes a few
  percent of the budget; not yet in the arithmetic.
