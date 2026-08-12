# THE FINAL GUIDE — the only status page that matters
(2026-08-12, Fable 5. USER-BINDING. Supersedes every other plan document for
sequencing. END_GOAL.md still outranks everything for WHAT; this file rules
HOW and WHAT ORDER.)

## How to report status (rules for every future session)

1. **Report ONLY the five tracks below, by letter, one line each.** Format:
   `A: DONE` or `A: 3/5 — <one sentence on what moved>`.
2. **No cycle counts in the headline.** Cycles go in data docs.
3. **Nothing is DONE until its gate has been seen red and then green.**
4. **If a track went BACKWARD, that line goes FIRST.**
5. Longest permitted status report: **ten lines.** The user has asked for
   fewer words. Deliver fewer words.

---

## ⚑ THE INVARIANT (USER-BINDING, 2026-08-12) — READ BEFORE ANY TRACK

The user's words: **the fork must be as IMMUTABLE as possible -- there is NO way
for the code to break under any circumstance, including stutters caused in any
way, including changing a bunch of parameters at once.**

This is END_GOAL item 4 made TESTABLE. It is not a sixth track; it is a
condition every track must satisfy, and a track step is not DONE until it does.

**THE INVARIANT, in one line: the audio block always completes on time, for
every input.** Not on average. In the WORST CASE.

Worst case means all of these at once: the most expensive patch (DELAY TYPE
2/3/5), full polyphony, a chord arriving on the same block as a program change,
and every parameter moving every block.

### The four rules that make it true

1. **NOTHING UNBOUNDED ON THE AUDIO PATH.** No allocation, no flash read, no
   lock, no blocking call, no loop whose trip count depends on input. Every one
   of these has already been found on this path at least once.
2. **ALL OTHER WORK IS INCREMENTAL AND CAPPED.** Recall, parameter refresh and
   note bursts get a FIXED budget of work per block and take more blocks when
   there is more to do. This is what C10 and C9 are for.
3. **THE OVERLOAD POLICY IS STATED, NOT ACCIDENTAL.** When more is asked than
   fits, the CHANGE ARRIVES LATER. The audio never breaks. **Latency degrades;
   continuity does not.** A dropped or delayed parameter update is acceptable; a
   gap in the audio is not, ever, for any reason.
4. **NO SILENT FAILURE.** Every refusal, every deferral, every queue that fills
   is COUNTED and reported. A system that copes quietly cannot be proven to
   cope.

### How it is proven -- not by listening

An adversarial STRESS GATE, and the standard is that it has been seen to FAIL
before it is believed: all 64 patches x worst-case polyphony x a program change
on every boundary x every parameter changing every block, with a hard
block-overrun counter that must read **0**. Anything above 0 is a defect against
this invariant, whatever it sounds like.

### What this changes about the tracks, stated now rather than discovered

- **B4 is not "about 5 % headroom".** It is worst-case headroom, measured on the
  most expensive patch, with everything else happening at the same time.
- **The 18 DELAY TYPE 2/3/5 patches VIOLATE this invariant today** (6,600-6,900
  cycles against 5,442). They are not a tuning item; they are the invariant's
  binding constraint on one board.
- **C9 and C10 are not conveniences.** They are how rules 2 and 3 are
  implemented.
- **A "usually fine" measurement is not evidence.** Every cycle figure in this
  file that came from one patch and one chord has to be re-taken against the
  worst case before it can support an invariant claim.

## THE FIVE TRACKS

### A. SOUND — the engine is audibly identical (END_GOAL 1, 6)
The DSP itself. Trunk bit-exact; fork held to the sonic gate at the DEVICE's
own configuration; the user's ear on WAVs is the final judge.

| step | state |
|---|---|
| A1 trunk bit-exact vs plugin, all 64 patches | **DONE** (certified, EXACTLY 0) |
| A2 fork passes sonic gate at trunk flags | **DONE** (3.17 dB control) |
| A3 fork gated at DEVICE config (wake masks, LFO free-run) | **DONE** (device_sonic.c, LFO fix PROVEN) |
| A4 user listens to fork WAVs A/B vs plugin renders and accepts | **NOT DONE — the only remaining judge** |

### B. FIT — 6 voices + full FX hold real time on two chips (END_GOAL 2, 3, 4)
| step | state |
|---|---|
| B1 chip A: 3 voices no FX | **DONE — FITS** (5,388 of 5,442, measured) |
| B2 chip B: 2 voices + FX | **DONE — FITS** (M1: 5,410 of 5,442, measured) |
| B3 chip B: 3 voices + FX | **NOT DONE — over by 691.** THE gap. One number. |
| B4 **WORST-CASE** headroom (see THE INVARIANT: worst patch, full polyphony, program change and parameter storm at once) | **NOT DONE, AND NOW BINDING.** M1's 105 underruns are GONE (burst off the audio path) but PLAY1 is 3-8 % over budget with two voices. |

B3 has two routes: find ~700 cycles on chip B (cycle hunt AGAINST THE REAL
INSTRUMENT, not the looped chord), or move one voice to chip A and accept 4+2
(chip A 4v measured OVER by 820 — so that route needs ~850 found on chip A
instead). Either way: ONE core, ONE number.

### C. INSTRUMENT — it plays like a synth, not a demo loop (END_GOAL 5)
Everything between MIDI-in and coefficients. All logic already exists PROVEN
on host; this track is wiring it to the device.

| step | state |
|---|---|
| C1 device recall design + cold gate | **DONE** (384 cases, 5 teeth) |
| C2 the three defects (warm, per-voice, publish) fixed + gated | **DONE** — 1,152 cases bit-identical at both flag sets, issues notes, runs sequences; ONE adversarial round survived (it found 3 more defects, all fixed and toothed). Round 2 did not run: session limit. |
| C3 recall running ON the board, burst off the audio path | **BUILT AND PROVEN ON SILICON** — 13 patches CRC-MATCH the host, 0 unmapped, 22 publishes, **underruns 0** (M1 had 105). ⚠ the burst is **1,992,935 cycles, 21x the plan** (`data/c3_silicon.md`), and it is now SPLIT AND ATTRIBUTED: voice coefs 1,082,812 · master coefs 121,213 · reseed+install+recall+notes 788,910. The voice half built ALL EIGHT voices for a two-voice chord. Previously scouted: Two real firmware links say recall as designed does NOT fit: `dram0_0_seg overflowed by 7,184 B`. Fits after the 32 KB `EBDEV_MISSLIST` diagnostic shrinks. Flash is a net WIN of 1.72 MB (recall retires the blob). ⚠ `ebdev_at` does NOT fold to 4 instructions in the real recall TUs — 900 out-of-line sites, 667 in `eb_master_coefs.c`. The burst is bigger than planned. |
| C4 note path + allocator on device (real note events, not snapshots) | **BUILT, UNPLAYED, AND NOW CHEAP** — eb_alloc + the port's note path are linked and in the image; no key has been pressed yet. A note used to pay the whole 1.99 M-cycle burst (8 ms, a click per key); it now rebuilds ONLY the voices the allocator names, proven BIT-IDENTICAL to the full build at both flag sets with two teeth. Expected ~135,000 cycles. |
| C5 MIDI in over UART — **the user plays it** | **BUILT, UNPLAYED** — UART1 31,250 on GPIO 18, `midi=0` so far |
| C6 encoders + LCD (8 params first, then all) | **NOT DONE** — but cycle-cheap: chip A core 0 has ~1,600 spare cycles/sample (`data/two_board_advantages.md`) |
| C7 preset storage (save/load without audio dropout) | **NOT DONE** — same spare core; the risk is flash-erase stalls, not cycles |
| C9 **EVERY parameter adjustable at once, in real time** (USER-BINDING, added 2026-08-12) | **NOT DONE — and it is a REQUIREMENT, not a nicety.** Today a single knob move costs the FULL burst (~2,000,000 cycles), because engine B HOISTS cell reads into a prepared coefficient struct and any change rebuilds the struct. |
| C10 chunked patch change (build spread over N blocks, one atomic publish) | **NOT DONE** — removes the program-change click without making the burst faster. |
| C8 the port's warm-recall bug fixed in src/ + warm gate in make verify | **1/2** — cell 91152 FIXED in src/chorus_recall.c with its own tooth, `make test` green, 0 of 384 cold cases changed. The warm gate is NOT yet in `make verify`. |

### D. LINK — two chips are one instrument (END_GOAL 2)
The only subsystem with zero code. Requirements already written
(DEVICE_RECALL.md §6).

| step | state |
|---|---|
| D1 shared sample clock + audio summing between boards | **NOT DONE — architecture DECIDED 2026-08-12** |
| D2 patch bytes + apply-at-index distribution, CRC handshake | **NOT DONE** |
| D3 global voice index (chip B builds voices 4..7, not 0..1) | **NOT DONE** |
| D4 one image flashed twice, role by strap pin | **NOT DONE** |

**D1 DECIDED (user, 2026-08-12): ONE DAC, chip A is the only clock.**
Chip A runs I2S0 as MASTER TX into the single audio board, and I2S1 as MASTER
RX from chip B. Chip B runs I2S as SLAVE TX and receives A's BCLK/LRCK, so it
has no clock and no DAC of its own. Drift between the chips is then impossible
BY CONSTRUCTION rather than corrected, and chip B gets its sample tick for
free. Three wires plus ground. **No MCLK is required anywhere**, which is what
settled it -- the user's board does not expose one and will not be changed.
Cost: chip B's audio arrives one block late, one pipeline stage, the same
trade the FX chain already pays. The ESP32-S3 has two I2S peripherals, so
chip A can run TX and RX at once (READ from the IDF, not yet executed).
Consequence for hardware: buy ONE audio board, not two -- which also removes
any analog mismatch between the two halves of a chord.

### E. REPEAT — the process survives to the JX-3P (END_GOAL 7)
| step | state |
|---|---|
| E1 method playbook current | **DONE** (40 defects, silicon sections, kept current BY RULE) |
| E2 workflows saved in repo | **DONE** (10 + the recall pair) |
| E3 end-to-end pipeline doc: ".vst3 in → two boards out", every step + gate | **NOT DONE** |
| E4 de-JUNO the tools (no needless hardcoded constants) | **NOT DONE — audit owed** |
| E5 proven by a second synth | **BLOCKED until A–D done** (until then, all repeatability claims are INFERRED) |

---

## C9 — THE PARAMETER REQUIREMENT, AND WHY THE PLUGIN IS NOT THE MODEL

**The user's requirement (2026-08-12):** as many parameters as you please, at
the same time, without overloading the CPU. Ideally the way the VST does it.

**How the VST does it, and why we cannot copy it.** The plugin has NO
coefficient build stage. Its per-parameter setters write a handful of cells and
its render loop READS THOSE CELLS EVERY SAMPLE. A knob move therefore costs
almost nothing -- and the per-sample cost is enormous, which is exactly the cost
this port cannot afford on a 240 MHz chip.

Engine B is fast BECAUSE it hoists those reads into `eb_render_coefs` /
`eb_master_coef` once. That hoist is the speed advantage and it is the whole
reason a knob move costs 2 M cycles today. Copying the plugin's structure would
trade a patch-change stall for a permanent 3-4x per-sample cost. It is the wrong
trade and must not be proposed again.

**The design that satisfies the requirement:** keep the hoist, make the refresh
INCREMENTAL. A parameter writes its cells, then refreshes ONLY the coefficient
fields that depend on those cells. This is the same move that already worked for
notes (`eb_recall_build_voices`, proven bit-identical with two teeth): a cutoff
knob is a few fields, not eight voices and the FX chain.

**The map is DERIVED, not written.** For each recall-applied parameter, perturb
it on the host, diff the resulting coefficient structs, record which fields
moved. That is a generated table with a gate, and the tooth is obvious: a
parameter whose map is short by one field must produce a coefficient set that
differs from the full build.

**⚠ THIS IS AN ITEM-7 TOOL.** The generator is pointed at a parameter list and a
coefficient struct; nothing about it is JUNO-specific. Hardcoding a JUNO
constant into it is a defect against END_GOAL item 7 in the same way a wrong
coefficient is a defect against item 1.

## THE ORDER (do not reorder without the user)

1. **C2 → C3** — finish recall fixes, put recall on the board, burst off the
   audio path. Fixes B4's clicks as a side effect.
2. **C4 → C5** — notes + MIDI. **First playable milestone: 2 voices + FX,
   played from a keyboard.** (User-chosen; explicitly NOT the goal, a step.)
3. **Re-measure the budget while it is being PLAYED.** This number replaces
   every cycle figure in the repo.
4. **B3** — the ~700-cycle hunt, against the real instrument.
5. **C10 then C9** — chunked patch change first (it removes the click and is
   small), then the per-parameter incremental refresh, which is what makes C6's
   encoders possible at all.
6. **C6, C7, C8** — controls, storage, the warm bug.
7. **D** — the link, second board, 6 voices. **END_GOAL 2/3/4 land here.**
8. **A4** — the user listens. **END_GOAL 1 lands here.**
9. **E3, E4** — write the pipeline doc, de-JUNO the tools.

## What the second board buys beyond cycles (`data/two_board_advantages.md`)
Chip A core 0 has ~1,600 spare cycles/sample MEASURED — the control surface is
nearly free. And 6 voices over 4 cores is **2.7× the compute per voice** of 8
over 2, so the second board is also how the fork can stop approximating:
`EB_HALF_OS_VCF`, `EB_DCO_WT` and `EB_CR_N=4` become reconsiderable. That is
END_GOAL item 1, not item 4.

## ⚠ EVERY CYCLE FIGURE IN THIS FILE IS DELAY TYPE 0 (`data/patch_dependent_fx.md`)
MEASURED 2026-08-12: patches with DELAY TYPE 2, 3 or 5 cost about **DOUBLE** --
~10,000 cycles against ~5,200 -- because those arms are a pitch-shifting delay
and the engine's largest FX module. **18 of 64 factory patches** use them. The
listen blob was built from patch 0, which is TYPE 0, so every number in track B
is the cheapest of three classes. A real-time budget must be met by the WORST
patch. This is now B's binding constraint, ahead of the 425-cycle gap.

## The three facts that must not be re-litigated
- **One chip cannot do it:** 6v+FX single-chip measured 10,479 = 1.93× over.
- **The split matters more than any lever:** wrong split costs 1,863 cycles.
- **Bursts, not averages, cause stuttering:** M1 fits and still clicks.
  Headroom is the finish line, not parity.
