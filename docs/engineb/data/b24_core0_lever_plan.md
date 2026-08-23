# The core-0 lever plan — what to build, in what order, and what it will not reach

`docs/engineb/data/b24_core0_lever_plan.md` — 2026-08-23
Inputs: three levers that survived both skeptics. All cycle figures below are the **skeptics'**, never the proposers'.

---

## 0. The sentence

**The 5 % headroom target (811) and the 10 % target (1,083) are NOT reachable from anything now on the table, and the three surviving levers do not even reach parity: their optimistic sum is 364 cycles against the 539 that patch 50 needs and the 598 that patch 0 needs.**

The reason is arithmetic, not effort. Headroom is a **total-work** problem, and every surviving lever is small. Parity is an **allocation** problem, and it may still be reachable — but only through one lever that nobody has priced, which costs one more block of latency.

---

## 1. The survivors

| id | change | cycles pess | cycles opt | both skeptics agree | sonic cost | risk | the ONE test that decides it |
|---|---|---|---|---|---|---|---|
| **L-A** | `wt_live` rebuilt every sample: delete 4 dead stores, delete the empty `call8`, gate the 9-field copy and `set_pitch` on `CR_RUN(EB_CR_PITCH, EB_CR_NP)` | **85** | **190** | 110–175 | EXACTLY 0, by construction | MED (4 preconditions, and **no existing gate covers the 2 paths it changes**) | fork-vs-fork **bit** compare at SHIP flags, with a NEW mid-note program-change scenario. Must read 0 differ, and must be **seen to FAIL** with the re-seed guard removed |
| **L-B** | LFO output tail computed on every sample, read on half of them: split `eb_lfo_tick` at the dataflow cut, take the tail only when `(i & 1) == 0` | **40** | **160** | 70–150 | EXACTLY 0, by construction | MED-HIGH (the cut is a **dataflow** cut, not a line cut; it feeds a phase integrator) | `S3L_TIME_PROLOGUE=1` A/B, lever off vs on. Then bit compare, with an off-by-one predicate **seen to FAIL** |
| **P3** | 7 dead pre-zero stores at the head of `eb_engine_render_shared`, guarded with `#if !EB_LFO_FREERUN` | **0** | **14** | 6–8 | EXACTLY 0, by construction | LOW | `.s` diff at SHIP flags: only those stores leave, and `eb_engine_render_range$part$0` stays **byte-identical** |
| | **SUM** | **125** | **364** | **186–333** | | | |

All three are SCHEDULING, not arithmetic. None of them changes a number that any consumer reads. The sonic-cost tiebreak therefore does not separate them.

**Two caveats that belong in the table.**
1. **L-A's average is not L-A's worst sample.** Three quarters of its saving lands on non-CR-run samples. On a CR-run sample only the dead stores and the empty call survive: **30–45 cycles**. A chord struck on one sample aligns every voice's phase and produces exactly that case. If `5,981` was measured as a per-sample MAX rather than a block mean, L-A will measure ~40, not ~150. **State which it is before the flash** (playbook 11b).
2. **Every lever here is below this board's ~300-cycle noise floor** (`eb_render.c`, `EB_ABLATE` header: the sweep's 4-voice point came in 273 cycles BELOW its 3-voice point). None of them can be seen in the whole-loop number. Section 5 says what to measure instead.

---

## 2. Do they add up? No.

Measured deficits, from the board: patch 50 = 5,981 − 5,442 = **539**. Patch 0 = 6,040 − 5,442 = **598**. Patch 0 is the binding case.

| target | need | pessimistic sum 125 | optimistic sum 364 |
|---|---|---|---|
| parity, patch 50 | 539 | 23 % — **short by 414** | 68 % — **short by 175** |
| parity, patch 0 | 598 | 21 % — **short by 473** | 61 % — **short by 234** |
| 5 % headroom | 811 | 15 % — **short by 686** | 45 % — **short by 447** |
| 10 % headroom | 1,083 | 12 % — **short by 958** | 34 % — **short by 719** |

### The arithmetic that matters more

Total work ≈ 10,944. Budget 5,442 per core. Let **S** = cycles removed by the levers (all land on core 0), **M** = cycles moved from core 0 to core 1.

- Balanced per-core = (10,944 − S) / 2.
- S = 125 → **5,410**, i.e. 32 under budget (0.6 % headroom).
- S = 364 → **5,290**, i.e. 152 under budget (2.8 % headroom).
- 5 % headroom needs per-core ≤ 5,170, so **S ≥ 604**.
- 10 % headroom needs per-core ≤ 4,898, so **S ≥ 1,148**.

**Read that again: perfect balance plus all three levers gives 0.6–2.8 % headroom, never 5 %.** Moving work cannot create headroom; only removing work can. The inventory removes at most 364 and needs 604.

To reach even parity, the levers are not enough on their own: **M must be (976 − S) / 2 = 306 to 426 cycles**, and every proposal to move that work is dead except one (section 6).

---

## 3. Order, and the one to do first

Ranking rule, stated before use: **pessimistic cycles ÷ number of unproven preconditions.** This is judgement, not a measurement.

| rank | lever | pess cycles | unproven preconditions | ratio |
|---|---|---|---|---|
| 1 | L-A | 85 | 4 (LERP guard, ABLATE guard, `eb_recall` field coupling, new scenario) | ~21 |
| 2 | L-B | 40 | 3 (dataflow cut, `cr_ph` alignment, predicate tooth) | ~13 |
| 3 | P3 | 0 | 1 (guard form, not delete) | payoff too small to rank |

**Do L-B FIRST, with P3 in the same commit and the same build. Not L-A.** The ratio says L-A; measurability overrules it, for four reasons:

1. **L-B is the only lever this board can measure directly today.** `S3L_TIME_PROLOGUE=1` already exists, already batches all 256 prologues per block, and already prints `PROLOGUE %.2f us/sample`. At two decimal places its resolution is **0.01 us ≈ 2.4 cycles/sample** — 125x finer than the whole-loop noise floor. Precedent: `docs/engineb/data/prologue_measured.md`.
2. **P3 and L-B live in the same function**, so one probe build measures both.
3. **It calibrates the model everything else rests on.** L-A's 85–190 and L-B's 40–160 are both instruction counts times an assumed cycles-per-instruction. Seven of eight estimates in this project were wrong. L-B is the cheapest way to learn which direction *this* code's estimates err in — before a build is spent on L-A.
4. Sonic cost is EXACTLY 0 for all three, so the preference rule ("scheduling over arithmetic") does not separate them.

If only one lever will ever be built, build **L-A** — it is the biggest. If they will be built in sequence, build **L-B + P3** first.

---

## 4. The three concrete changes

### 4.1 L-B — the LFO output tail (do this first)

- **Files**: `engine_b/eb_lfo.c`, `engine_b/eb_lfo.h`, `engine_b/eb_render.c` (call site :131-136), `esp32s3/main/juno_s3_listen.c` (probe only).
- **Functions**: split `eb_lfo_tick` into `eb_lfo_advance` (state) and `eb_lfo_outputs` (tail).
- **Flag**: `EB_LFO_TAIL_CR` (engine_b), default 0. Trunk cannot move.
- **THE CUT IS A DATAFLOW CUT, NOT `eb_lfo.c:184`.** `v96`, `v97`, `v99`, `v100`/`L1472` and `v102`/`L1408` sit *before* the last state store and are output-only. `L1408` and `L1472` are **not** in the state struct (`eb_lfo.h:57-64`), so the tail must be handed them or rebuild them. Cut it by line number and `v120` reads a stale `L1472` — that is an arithmetic change, and it lands on a phase-integrated path.
- **The predicate is `(i & 1) == 0`, not an OR over voices.** `cr_ph` is forced to 0 on every at-rest sample (`eb_render.c:389`), `CHUNK` is 256 and 256 mod 4 = 0, so every sounding voice sits at the same phase. The proposed latch-and-OR machinery is unnecessary, and worse: the host gate holds every voice awake, so it would exercise only the always-true arm — the same blindness that hid the `EB_LFO_FREERUN` defect.
- **Do not zero the published fields on skipped samples.** Leave them holding the previous value, so any future accidental reader gets a one-sample-stale LFO rather than 0.0.
- **The firmware must print** (every line carries the build tag):
  ```
  PROLOGUE 2.99 us/sample (~717 cycles) [LFOTAIL=0]
  LFOTAIL taken=128 skipped=128 per chunk      (expect 128/128)
  LFOTAIL misalign=0                            (expect 0)
  ```
  `misalign` counts skipped samples on which any rendered voice had `(cr_ph & 1) == 0`. **A non-zero `misalign` voids the run**: the alignment premise is broken and no number from that build may be quoted. A `taken/skipped` split that is not 128/128 means the same.
- **Tooth**: burn N cycles inside the timed region, as `S3L_FXPROF_TOOTH` already does (`juno_s3_listen.c:2442-2452`). `PROLOGUE` must rise by exactly N. A timer nobody has seen move is a number, not a measurement.

### 4.2 P3 — the seven dead pre-zero stores (same commit)

- **File**: `engine_b/eb_render.c:79-81`, plus `:84` (`v0_atrest` is an eighth dead store, and it has no reader anywhere outside `build/`).
- **Guard, do NOT delete**: `#if !EB_LFO_FREERUN`. `eb_render.c:893` declares `eb_shared_tick sh;` uninitialised and sets only `.ready`, so the FREERUN=0 host path genuinely needs those zeros.
- **Do NOT fold in the "additionally" claim** about `S3L_VOICE_LO > 0`. It needs a firmware macro to reach inside `engine_b/`, which the bit-exact trunk also compiles, and `v0_pitch_cv` is written through an out-pointer. Different, larger, riskier edit. Also `v0_dly_env` is **not** dead — it is `eb_lfo_tick`'s input at `:132`.
- **Nothing is printed.** It is 6–8 cycles; the board cannot see it. Prove it statically:
  1. Trunk `eb_render.o` **byte-identical** before and after (`make verify` covers it).
  2. `-S` at the SHIP flag list (`tools/engineb/ab_wavs.py:55-62` holds that list verbatim): exactly the 7 stores and their zero constant leave, one `movi.n` may return, and `eb_engine_render_range$part$0` is **byte-identical**. That last line is the whole safety argument — it is what `trim_result.md` could not say.

### 4.3 L-A — the `wt_live` rebuild (do second, biggest)

- **File**: `engine_b/eb_render.c:697-739`; `engine_b/eb_dco_wt.c:39-42`; `engine_b/dev/eb_recall.c:448-455`.
- **Flag**: `EB_DCO_WT_LIVE_CR` (engine_b), default 0.
- **Four parts**: (1) `#if !EB_DCO_WT || EB_DCO_PULSEFAST`-guard the four dead stores `.g/.pw/.pwm1/.pwp1` and the `sub.s`/`add.s` that feed them; (2) make `eb_dco_wt_bind_tables` an empty `EB_INLINE` in the header rather than deleting the call site — that kills the `call8` at `eb_recall.c:450` too and keeps the entry point; (3) **move the 9-field copy into the seed block at `:653-656`** and gate the hot copy on `CR_RUN` alone — this removes the need for `just_seeded`, which spills; (4) move `eb_dco_wt_set_pitch` and the `.inc` store inside the `CR_RUN(EB_CR_PITCH, EB_CR_NP)` gate.
- **Three guards are mandatory, not optional.**
  - `#if EB_CR_LERP_PITCH` → `#error`. With LERP on, `inc` is **not** constant across the hold group; freezing it gives a phase error of `1.5*(prev-nv)` per group **with a fixed sign** through any glide or pitch sweep. That is a bias-law breach, and it would be a silent detune.
  - `#if EB_ABLATE == 12 || EB_ABLATE == 14` → fall back to the per-sample call. Those builds set `inc` outside the CR gate; freezing it corrupts the ablation ladder's own measurement.
  - Add `sat_hi`, `sat_lo`, `subthr` to the at-rest refresh at `eb_recall.c:448-455`. Today it names only six of the nine. Exactness on the recall-then-struck path currently depends on an accident in a third file (`eb_render.c:385-388` re-arms `cr_ph` while at rest). Three free stores end that coupling.
- **New probe** `S3L_TIME_VOICES`, built on `S3L_TIME_PROLOGUE`'s exact shape (one timed batch, timer read twice per BLOCK, loop total serialised and **not quotable**). It must print:
  ```
  VOICES 9.84 us/sample/voice (~2362 cycles) [WTLIVE=0]
  WTLIVE copies=64 seeds=0 per chunk per voice  (expect 64 = CHUNK/EB_CR_NP)
  WTLIVE latecopy=0                              (expect 0)
  ```
  `latecopy` counts any sample where `dco_live_seeded` went 0→1 and the 9-field copy did not run in that same sample. Non-zero means a program change is landing up to three samples late — the exact defect the guard exists to prevent — and voids the run.
- **Poison tooth**: under a debug flag, fill `.g/.pw/.pwm1/.pwp1` with NaN at seed. The bit compare must stay identical. If any reader survives, it goes non-zero.

---

## 5. How to measure, and what may never be quoted

1. **No single A/B flash can see any of these levers.** The floor is ~300 cycles. Use the batched probes.
2. **Measure lever-off against lever-on inside the SAME probe build type.** Quote the delta, never the absolute. The probe deliberately serialises the two cores, so its loop total is worse by construction.
3. **The probe measures the lever's size, not its shipping value.** The batched arrangement has different scheduling from the shipping interleave. Once all three are stacked, the whole-loop number is a **non-regression check only**: it must not rise by more than the noise floor. It cannot confirm a 125-cycle gain and must never be quoted as confirming one.
4. **The fork-vs-fork bit compare does not exist as a named tool.** I looked. `ab_wavs.py` holds the SHIP flag list but compares trunk against fork; `sonic_gate.py` builds its candidate **without** `EB_LFO_SHARED`, so for P3 it would compile the identical object twice, print its usual 0.40 dB, PASS, and have measured nothing. `null_b.py`'s 36 scenarios contain **no mid-stream program change** at all — I checked `BASE_SCEN`; the ops are only `render`/`on`/`off`. Budget one small runner (both sides at SHIP flags, one extra `-D`, streams compared **byte for byte**, expect 0 differ) plus one new scenario. It must be seen to fail before any green from it is believed.
5. FREEZE the tree while any gate runs.

---

## 6. What I did not find, and whether the target is reachable

**What is not there.** No lever anywhere near 600 cycles. The largest survivor is 190 optimistic. Four adversarial passes have now produced nothing bigger, and the killed list has closed the whole "move the prologue" family, the memory-placement family and the cache family.

**Three corrections to the brief's own framing, all from reading the firmware:**

1. **Core 1's ~976 idle cycles are not freely usable, and "976" is a subtraction.** Core 1's voice pass is throttled by `w_ready`, which core 0 advances once per sample (`juno_s3_listen.c:2401-2425`). Core 1's pass therefore **ends when core 0's ends**. The firmware records the measurement: when the FX ran *after* the voices, the board read **8,746 against a predicted 4,984**. Only work that depends on the **previous chunk** can fill that slack. That is why the FX is free, and it is why ordinary voice work cannot simply move across.
2. **"Cutting FX cycles buys nothing" is true today and false in the end state.** After a fine-grained rebalancing lever exists, balanced per-core = (T − X)/2, so **each FX cycle removed is worth up to 0.5 cycles of headroom on both cores**. The FX's 2,622 cycles are the largest block of work never attacked for the headroom goal — but they are worth exactly 0 until the rebalancing lever exists.
3. `core 0 ≈ 5,960 + output 91 = 6,051` against a measured loop of `5,981` leaves 70 cycles unexplained. Anchor on the measured deficits (539 / 598), which are direct, not on the per-core split, which is not.

**The one unpriced lever — the keystone.** A **chunk-pipelined voice back half**: compute `eb_vcf_tick` + `eb_vca_tick` for one or more core-0 voices on core 1, one chunk behind, exactly as the FX already runs.
- It is not the killed master-chain split. `eb_master_render` is a closed per-sample loop (`eb_master_in.c:28`, b22). The voice back half is **feed-forward**: `nmix → vcf → vca → vout`.
- The cut set is already written down. `EB_VCF_ILV` stashes it (`eb_render.c:777-782`). **Two corrections for a chunk-late pass**: it must also carry `st->glide[v].s560` (7 floats, not 6 — the ILV pass reads it live, which is safe within a sample and a silent one-chunk skew a chunk later); and `eb_modcv_latch` must **stay on core 0**, because `decim → modcv → dco` closes a one-sample loop inside the voice.
- **Why it is not costed here**: the per-module split of the 2,362-cycle voice slope is not measured on silicon at the granularity needed. The ladder alone is READ at 1,083 cycles (`eb_render.c`, `EB_FUSE_VCA` note: 516 instructions, c/i 2.1). That is **2.5x the 306–426 that needs to move** — moving one voice's ladder overshoots and makes core 1 critical at ~6,067. So the cut must be finer (VCA-only, or noisemix+nsvf), and nobody has priced those on this silicon. `EB_ABLATE` is the instrument, and its ~300-cycle floor is coarse for modules this size.
- **Its price**: one more chunk of latency (5.8 ms) on top of the FX pipe's, and a risk that work added at the head of core 1's slot erodes the FX-first hiding that bought 2,608 cycles.
- **It is a MOVE lever. It can buy parity. It can never buy headroom.**

### The verdict

- **10 % headroom (1,083): not reachable.** It needs 1,148 cycles off the total. The inventory supplies at most 364.
- **5 % headroom (811): not reachable on today's evidence.** It needs 604 cycles off the total.
- **Parity (539 / 598): reachable only if the keystone works**, and only with all three levers, and only if the pipeline cut can be tuned to about ±100 cycles. It is unpriced. Call it a coin-flip, not a plan.
- **The three levers alone: no.** They leave 175–414 short on patch 50 and 234–473 short on patch 0.

**And parity is not the goal anyway.** MIDI, parameter control and device recall are still missing, and recall is a burst.

**So the decision that belongs to the user, not to this plan.** Three ways forward that do **not** touch anything ruled out (no third chip, no different chip, no 32 kHz, no fewer voices, no dropped FX):

1. **Buy latency.** The keystone, at one more block. This is the only path to parity that survives measurement.
2. **Buy a measured sonic trade in the fork.** The fork is allowed to be audible; `sonic_gate.py` bounds it and the user judges by ear. This is the only path that can produce the 604+ cycles that headroom needs. No such trade is on the table today, and the last one tried (the 2-tap decimator) read 10.07 dB against a 3.17 dB control.
3. **Stop needing headroom.** Headroom is wanted for MIDI, parameter moves and recall. O3 already proved on silicon that a burst can be chunked and bounded (76,779 edits, unknown=0, 15.0x coalescing, b17). Make every new subsystem chunked and bounded, and the requirement becomes a **deadline** requirement rather than a **cycle** requirement. This is a design proposal, not a measurement — but it is the only one of the three that costs neither latency nor sound.