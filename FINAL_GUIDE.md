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

### THE HEALTH LINE -- any issue must be OBVIOUS IMMEDIATELY (user, 2026-08-12)

Verbatim: **"whatever process we use to test the fork should make it VERY clear
if there is ANY issue RIGHT away."**

The flaw in the firmware as it stands is not that it lacks detectors -- it has
several -- it is that it prints TWELVE NUMBERS and leaves a human to notice. A
person reading a scrolling log is not a detector.

**THE RULE: one verdict line. It reads `HEALTH: OK` or it names the FIRST
fault, and once it has named one it NEVER READS OK AGAIN.**

A latch, not a level. An instrument that broke for one block an hour ago and
recovered is still an instrument that broke, and a report that heals itself
hides exactly the intermittent fault that is hardest to find.

What it latches, each with the counter that already exists or is owed:

| fault | detector | state |
|---|---|---|
| block overran its deadline | wall-clock per block vs the block period | OWED |
| audio underrun / DMA starved | `un=` | EXISTS |
| a cell access fell off the map | `EBDEV_S.miss`, mutes | EXISTS |
| a publish was refused | `dev_pub_refused` | EXISTS |
| a note was dropped | `notes_dropped` | EXISTS |
| a delay ring length moved | `dev_check_rings` | EXISTS |
| coefficients disagree with the host | CRC vs answer key -- **1 patch checked, 64 owed** | PARTIAL |
| a sample was NaN, Inf, or ran away in DC | — | OWED |
| a parameter update was dropped rather than delayed | — | OWED (needs C9) |

**AND EVERY DETECTOR MUST HAVE BEEN SEEN TO FIRE.** A health line that has never
gone red is not evidence of health; it is an untested detector, which is
playbook defect 1 and the oldest rule in this project. Each row above needs a
tooth that provokes it on purpose.

### How it is proven -- not by listening

An adversarial STRESS GATE, and the standard is that it has been seen to FAIL
before it is believed: all 64 patches x worst-case polyphony x a program change
on every boundary x every parameter changing every block, with a hard
block-overrun counter that must read **0**. Anything above 0 is a defect against
this invariant, whatever it sounds like.

### What this changes about the tracks, stated now rather than discovered

- **B4 is not "about 5 % headroom".** It is worst-case headroom, measured on the
  most expensive patch, with everything else happening at the same time.
- **The 18 DELAY TYPE 2/3/5 patches VIOLATE this invariant today** (~10,700
  cycles against 5,442, board-measured, data/patch_dependent_fx.md). They are
  not a tuning item; they are the invariant's binding constraint on one board.
  CORRECTED 2026-08-17: this line read "6,600-6,900", which is the TWO-VOICE
  CORE figure (2 x 3,394, the 0xd0 gap) and not the delay-patch cost at all --
  it understated the gap by 3.6x and a headroom plan was sized off it. See
  docs/engineb/M2_WORST_CASE.md.
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
| A2 fork passes sonic gate at trunk flags | **RE-OPENED 2026-08-17** — the 3.17 dB figure is SHIP minus the control-rate flags, not today's build; at the real SHIP flags the gate reads 5.79 dB worst band. Inside the LAST_MILE acceptance rule (~6.34), outside the 1.0 screening bound. Needs the user's FIXED acceptance number (SONIC_BOUND_SETTLED.md) |
| A3 fork gated at DEVICE config (wake masks, LFO free-run) | **DONE** (device_sonic.c, LFO fix PROVEN) |
| A4 user listens to fork WAVs A/B vs plugin renders and accepts | **NOT DONE — the only remaining judge** |

### B. FIT — 6 voices + full FX hold real time on two chips (END_GOAL 2, 3, 4)
| step | state |
|---|---|
| B1 chip A: 3 voices no FX | **DONE — FITS** (5,388 of 5,442, measured) |
| B2 chip B: 2 voices + FX | **DONE — FITS** (M1: 5,410 of 5,442, measured) |
| B3 chip B: 3 voices + FX | **NOT DONE — over by 691.** THE gap. One number. |
| B4 **WORST-CASE** headroom (see THE INVARIANT: worst patch, full polyphony, program change and parameter storm at once) | **DETECTOR DONE AND SEEN TO FIRE** (`B4: ovr=late/miss`). **VERDICT NOT DONE**, two named causes: (1) the patch-change burst misses 1-4 blocks per step — O2 is the fix, acceptance test: miss MUST NOT increment across a program change; (2) delay patches 5/16/21/49 read 6,526-6,821 vs budget 5,442 at split 7 — O4 is the fix. Key regenerated 2026-08-18, CRC MATCH all patches, cost quotable. Full evidence: data/b6_split_sweep.md (supersedes b4/b5 where they disagree). |

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
| C11 **ONE INTERNAL EVENT API — the boundary every input crosses** (USER-BINDING, 2026-08-12) | **NOT DONE.** Keybed, panel, DIN, USB all submit events through one small header. Nothing else may reach the engine. |
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

## C11 — THE INTERNAL EVENT API (USER-BINDING, 2026-08-12)

**The rule: inside the box, nothing speaks MIDI.** MIDI is a wire protocol for
other people's equipment. Used internally it only costs: a 7-bit CC cannot reach
half of an 8-bit parameter's values, a DIN byte stream is 31,250 bits/second
between two chips on the same board, and a stuck note is far harder to find in a
byte stream than in a function call.

**Every input source converts into ONE event API:**

    juno_event_note_on (source, note, velocity)
    juno_event_note_off(source, note)
    juno_event_param   (source, param_id, value_0_255)

    keybed --+
    panel ---+--> events --> allocator / incremental recall
    DIN in --+
    USB -----+

This already half-exists and has already paid for itself: `s3_midi_event()` is
the single note entry, so the UART and USB parsers CANNOT disagree about
velocity policy. Two entry points deciding separately is how the assigner-mode
defect survived for months (docs/ASSIGNER_MODE_FINDING.md). The PARAMETER side
needs the same treatment, which is C9.

**EVERY EVENT CARRIES A SOURCE TAG.** One byte: keybed, panel, DIN, USB. It
costs nothing and it is what lets the health line say WHICH input caused a
fault instead of only that one occurred.

### Why this is what makes THE INVARIANT hold for hardware nobody has built yet

The API is a BOUNDARY, and the boundary is where the cap lives. Anything behind
it -- including a board a user solders in later -- may only SUBMIT. It never
renders, never touches the cell array, never blocks, never allocates. So a
misbehaving add-on cannot break the audio: it can only fill a bounded queue, and
a full queue means its events land LATE. Latency degrades, continuity does not.
That is rule 3, extended to code that does not exist yet.

**A user connection point, in two levels, and only the first is committed:**

  1. **SOFTWARE** -- the public header above. Costs nothing extra: the keybed
     and the panel need it regardless. **This is the one to build.**
  2. **HARDWARE** -- a physical header carrying the same events over I2C or
     UART, so an add-on needs no firmware change. A LATER and SEPARATE
     decision: a bus other people's boards sit on must tolerate a device that
     floods it or holds a line low, and that is a new class of work.

**⚠ ITEM-7 TOOL.** A keybed sends notes and an encoder sends parameter values on
ANY synth. This header carries straight to the JX-3P. Nothing in it may be
JUNO-specific -- `param_id` is an index into a per-synth table, never a JUNO
constant.

## THE ORDER — relabeled O1..O6 / F1..F3 (user request, 2026-08-18)

O = the remaining BUILD steps. F = the FINAL acceptance steps, which only the
user or a full-system gate can close. This is a RENAME of the remaining order,
not a resequence; the old track letters stay valid for status lines and are
cross-referenced. Done and retired from the old list: recall on the board
(C2→C3), notes + MIDI built (C4→C5), the played-budget re-measure (b4-b6 data).

| label | was | what | state |
|---|---|---|---|
| **O1** | C11 | the internal event API — the boundary O2/O3 live behind | **DONE 2026-08-18** — gated (7 queue teeth + 3 structural teeth, all caught) AND FIELD-PROVEN (b7_o1o2_field.md): 313 human key events, sub=del=314, ref=0, torn=0, hi=3 of 63. Refusals and torn publishes now latch HEALTH red. Param events queue and count (`par=`) until O3. |
| **O2** | C10 | chunked patch change — THE fix for B4's counted misses | **BUILT, GATED, ATTRIBUTED, BLOCKED ON THE NOTE BURST** (b8_robot_attribution.md). Misses nowname their step: `O2m: rs=9 in=0 rc=0 nt=1 cf=8 ck=0` — install, port recall and check NEVER overran in ~190 builds. But the run found a bigger threat: **a NOTE burst is 1.06-1.27 M cycles (4.4-5.3 ms of a 5.8 ms block), 7.9x the ~135,000 C4 planned and 1.6x core 0's whole slack** — and it is UNCHUNKED. Every block carrying one runs late; the cf=8 misses are O2 steps landing on blocks already over. **NEXT: chunk the note burst with the same eb_recall_chunk_* machine (2-4 steps, not 15) BEFORE tuning O2's reseed.** |
| **O3** | C9 | per-parameter incremental refresh (derived field map) | NOT DONE |
| **O4** | B3/B4 | worst-case headroom CLOSED: measure the prologue, explain the delay arm's +1,45x, then pick the lever (chain split across cores vs arm hunt) | OPEN — b6_split_sweep.md is the evidence base |
| **O5** | C6/C7/C8 | encoders + LCD, preset storage, warm gate into make verify | NOT DONE |
| **O6** | D1-D4 | the two-chip link — 6 voices, one instrument | NOT DONE (D1 architecture decided) |
| **F1** | B4 verdict | the full stress gate green: worst patch x full polyphony x program change x parameter storm, miss=0, every detector seen to fire | NOT DONE |
| **F2** | A4 | the user listens to the WAV pairs and gives the FIXED acceptance number, then accepts | NOT DONE — the only remaining judge |
| **F3** | E3/E4 | pipeline doc ".vst3 in → two boards out" + de-JUNO audit (E5 then unblocks) | NOT DONE |

Rule unchanged: do not reorder without the user. O1 before O2/O3 because it is
their boundary; O4 needs O2 (the burst misses are half of B4's red); O6 needs
O4's number; F1 needs O1-O6; F2/F3 close the project.

### O-step briefings — what the executor must know, with sources

**O1 (event API):** full spec in the C11 section below — three calls, source
tag mandatory, bounded queue, submit-only boundary. Half exists:
`s3_midi_event()` in juno_s3_listen.c is the note side. Item-7 rule: no JUNO
constants in the header.

**O2 (chunked patch change):** the burst is 2.02-2.26 M cycles, split MEASURED
on the BURST/RECALL lines: voice coefs ~1.12 M, master coefs ~0.13 M, reseed
~0.44 M, install ~0.17 M, port recall ~0.24 M, notes ~0.02 M. Budget rule 2:
fixed work per block, more blocks when more to do; publish stays ATOMIC
(the eb_recall.c generation/shadow-bank machinery already provides this — do
not invent a second publish path). EB_RECALL_FX_PIPE ordering constraint is
load-bearing (main/CMakeLists.txt comment). ACCEPTANCE: `B4:` miss does not
increment across a program change, all 64 patches, and CRC still MATCHES.

**O3 (incremental refresh):** design + derived-field-map rule in the C9
section below. The proven precedent is `eb_recall_build_voices` (bit-identical,
two teeth). Item-7: the map generator must be synth-agnostic.

**O4 (worst-case closed):** evidence base data/b6_split_sweep.md. Keep split 7.
Open questions IN ORDER: (a) measure the prologue — `S3L_TIME_PROLOGUE` exists
in juno_s3_listen.c, currently 0, so "2,805/voice" is prologue-inflated and no
6-voice projection may use it until split out; (b) explain the delay arm's
+1,45x (fx 3,9xx-4,2xx vs 2,4xx-2,9xx) — arithmetic vs PSRAM access is NOT
separated; if fx drops below ~2,850 the delay patches close at split 7 with no
new latency; (c) 4-vs-18 patch classification mismatch (see the ⚠ section);
(d) only then choose: master-chain split across cores (costs one block, 5.8 ms,
invariant permits) vs arm cycle hunt vs a D-layout — with FOUR cores, FX alone
measures ≤4,276 and fits a core by itself. Board knobs that exist NOW: `,`/`.`
console keys move the split live; `FXP: fx= v1= wait=` prints per second.

**O5 (controls/storage/warm):** chip A core 0 has ~1,600 spare cycles/sample
(data/two_board_advantages.md); the C7 risk is flash-erase stalls, not cycles;
C8's remaining half is putting the warm gate into `make verify`.

**O6 (link):** D1 architecture decided and recorded below (one DAC, chip A
master, three wires, no MCLK). D2-D4 requirements: DEVICE_RECALL.md §6. Chip
B's block arrives one stage late by design — the same trade as the FX pipe.

## What the second board buys beyond cycles (`data/two_board_advantages.md`)
Chip A core 0 has ~1,600 spare cycles/sample MEASURED — the control surface is
nearly free. And 6 voices over 4 cores is **2.7× the compute per voice** of 8
over 2, so the second board is also how the fork can stop approximating:
`EB_HALF_OS_VCF`, `EB_DCO_WT` and `EB_CR_N=4` become reconsiderable. That is
END_GOAL item 1, not item 4.

## ⚠ THE DELAY-PATCH COST, RE-MEASURED 2026-08-18 (`data/b6_split_sweep.md`)
The 2026-08-12 "~10,000 vs ~5,200, 18 of 64 patches" figure that stood here is
SUPERSEDED — it predated the IRAM move and the four-cell recall fix. Current,
board-measured at 2v+FX, split 7: non-delay 5,112-5,389 (UNDER 5,442), delay
patches **6,526-6,821 (OVER by ~1,100-1,380)**. Only **4 patches (5/16/21/49)**
show the high band on the stepped run, while b4_stress.py classifies 18 as
TYPE 2/3/5 — that mismatch is UNRESOLVED and is O4's first question, because a
worst-case budget must be met by the worst patch, whichever list is right.

## The three facts that must not be re-litigated
- **One chip cannot do it:** 6v+FX single-chip measured 10,479 = 1.93× over.
- **The split matters more than any lever:** wrong split costs 1,863 cycles.
- **Bursts, not averages, cause stuttering:** M1 fits and still clicks.
  Headroom is the finish line, not parity.
