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
| B4 real headroom (~5 %+ margin, so bursts don't click) | **NOT DONE** (M1 clicks: 105 underruns from one 29 KB burst) |

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
| C2 the three defects (warm, per-voice, publish) fixed + gated | **IN FLIGHT** (workflow running; per-voice = 12 storage cells measured; port's own warm bug found: cell 91152) |
| C3 recall running ON the board, burst off the audio path | **NOT DONE** (publish contract is the mechanism; load_coefs() is its first user — this also fixes B4's clicks) |
| C4 note path + allocator on device (real note events, not snapshots) | **NOT DONE** |
| C5 MIDI in over UART — **the user plays it** | **NOT DONE** |
| C6 encoders + LCD (8 params first, then all) | **NOT DONE** |
| C7 preset storage (save/load without audio dropout) | **NOT DONE** |
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

## THE ORDER (do not reorder without the user)

1. **C2 → C3** — finish recall fixes, put recall on the board, burst off the
   audio path. Fixes B4's clicks as a side effect.
2. **C4 → C5** — notes + MIDI. **First playable milestone: 2 voices + FX,
   played from a keyboard.** (User-chosen; explicitly NOT the goal, a step.)
3. **Re-measure the budget while it is being PLAYED.** This number replaces
   every cycle figure in the repo.
4. **B3** — the ~700-cycle hunt, against the real instrument.
5. **C6, C7, C8** — controls, storage, the warm bug.
6. **D** — the link, second board, 6 voices. **END_GOAL 2/3/4 land here.**
7. **A4** — the user listens. **END_GOAL 1 lands here.**
8. **E3, E4** — write the pipeline doc, de-JUNO the tools.

## The three facts that must not be re-litigated
- **One chip cannot do it:** 6v+FX single-chip measured 10,479 = 1.93× over.
- **The split matters more than any lever:** wrong split costs 1,863 cycles.
- **Bursts, not averages, cause stuttering:** M1 fits and still clicks.
  Headroom is the finish line, not parity.
