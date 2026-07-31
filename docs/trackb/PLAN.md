# PLAN — Track B native voice rewrite: execution plan

*Written 2026-07-31, after CELLMAP / DCO / ENV / VCF / MOD. Those five documents
say **what the voice computes**. This one says **in what order to replace it,
what proves each step, and what would tell us to stop.***

**Label discipline (`docs/ROADMAP_EMBEDDED.md` §0) applies to every sentence
below.** In this document essentially everything is **READ** — source inspection
of `src/voice_render.c` (2185 lines), `tools/trackb/*.py`, `Makefile`,
`docs/TRACKB_CHARTER.md`, the five blueprints — plus a small number of
**MEASURED** facts quoted from `docs/trackb/CARRIAGE.tsv` and the charter, and a
few **PROVEN** items where I executed a check in this session (each is marked
inline). **No performance number is invented here.** There is still no SILICON
number; §8 states exactly which decisions that blocks and which it does not.

---

## 0. What already exists, and what this plan adds

Existing (all READ, verified this session):

| piece | where | state |
|---|---|---|
| the transcribed reference | `src/*.c` | sealed bit-exact vs the plugin under Unicorn (`make verify`) |
| the candidate substrate | `native/<x>.c` shadows `src/<x>.c` by filename, `Makefile:139-144` | `native/voice_render.c` is a VERBATIM fork + one `#ifdef`-guarded hook; passthrough null is EXACTLY 0 |
| gate #1 — identity | `tools/trackb/null_ab.py` | 7 scenarios (`SCEN`, :68-83), `--full` 384 bank comparisons, `--fuzz` 24 seeded sequences with live param edits, `--teeth` mutation battery |
| gate #2 — reached | `tools/trackb/coverage_probe.py` | gcov line counts per scenario, `--lines A-B` |
| gate #3 — noticed | `tools/trackb/observability.py` + `perturb_rt.c` | ~2 ULP post-sample cell nudge; also the executed carriage classifier |
| carriage map | `docs/trackb/CARRIAGE.tsv` | 283 cells: 94 CARRIED / 189 NOT-CARRIED, MEASURED |
| the five blueprints | `docs/trackb/{CELLMAP,DCO,ENV,VCF,MOD}.md` | equations, cells, constants, per-subsystem RISK tables |

This plan adds five things and nothing else: a **module order** (§3), a **loop
with a ledger** (§4), the **scenario additions each module needs before its null
means anything** (§5), the **false-green enumeration** (§6 — the section that
matters most), and the **stop rule** (§8).

### 0.1 The acceptance criterion, stated once

The user's criterion is **"sonically identical in every way"**, not bit-exact.
It is operationalised as `null_ab.py`: residual RMS ≤ **−90 dB** relative to the
reference signal RMS, with a **−50 dBFS non-vacuity floor** so silence-vs-silence
cannot pass (`null_ab.py:49-50`). Its meaning is MEASURED, not hoped: a 2-ULP-per-
sample error on the voice output lands at **−129 dB rel**, 39 dB below the
threshold (charter §"Gate #3"), so the gate tolerates roughly 200 ULP
(~2.4 × 10⁻⁵ relative) per sample and catches anything larger.

Two consequences run through the whole plan:

1. **−90 dB is a weaker claim than the seal, deliberately.** `src/` must stay
   untouched and stay bit-exact; `native/` is the subject of the weaker claim.
   The two must never be conflated in a commit, a gate, or a ledger row.
2. **RMS is not perception.** A metric that averages a whole render can hide an
   error that is loud for 30 samples. That is F3/F4 in §6 and it is a required
   M0 fix, not a nicety.

### 0.2 Scope — what Track B rewrites and what it must not touch

Rewritten: the **per-voice inner kernels** of `src/voice_render.c`, and nothing
else. Untouched (stays exact transcription, so the null stays sharp): recall
(`juno_apply.c` + the FX recall files), control/host param path
(`juno_hostparams.c`, `juno_mod.c`), the allocator and note lifecycle
(`juno_note.c`, `gui/juno_bridge.c`), the driver protocol (`juno_driver.c`,
including the per-voice noise snapshot/restore), `master_render.c` and the whole
FX chain, and every stochastic component — the two `juno_wrap24` dither
oscillators (VCF §6.1), the shared noise LFSR (:595-653), the S&H path
(:851-886). **A stochastic component that diverges by one step never re-converges,
so its residual is additive noise for the rest of the render — exactly what a
−90 dB null measures.** They are out of scope by construction, not by preference.

---

## 1. Ground rules inherited

1. **`src/` is frozen for the duration of Track B.** If `src/` moves, both sides
   of the subtraction move and the null compares two copies of the same mistake
   — the 2026-07-27 assigner lesson in miniature (CLAUDE.md: "never validate a
   hand-written component against an oracle in which the plugin component it
   replaces was never reachable"). Any `src/` change requires a full `make
   verify` and re-baselining of every ledger row (§4).
2. **No optimization before a SILICON number** (`ROADMAP_EMBEDDED.md` §0 rule 1).
   §8 splits this plan into what that blocks and what it does not.
3. **Fresh build before trusting any green.** Twice in one week a stale artifact
   produced a false green (CLAUDE.md ⚠ STALE-ARTIFACT TRAP). Every ledger row
   records the candidate's sha256.
4. **`--teeth` is re-run whenever the gate changes** — and M0 plus every module
   in §5 changes `SCEN`, so this is not a rare event.
5. **Label everything.** PROVEN = executed here. READ = source. INFERRED = argued.

---

## 2. M0 — preconditions (no voice code is rewritten in this module)

M0 is gate work. It is the only module that can start today with no hardware
(§8), and **no later module may start before it is complete**, because every
later module's evidence is produced by these tools.

### M0-1 `tools/trackb/fork_check.py` — it is referenced and does not exist

`native/voice_render.c:21` says the fork provenance is "checked by
`tools/trackb/fork_check.py`". **PROVEN (executed `ls` + repo-wide grep this
session): that file does not exist; the string appears in exactly one place, the
comment that claims it runs.** So the fork's recorded upstream sha256
(`aba0925a…6017355`) is currently checked by nothing.

Write it. It must fail, by name, on each of:
- `sha256(src/<x>.c) != ` the SHA recorded in `native/<x>.c`'s header (upstream
  moved under the fork);
- a `native/*.c` with no `src/*.c` counterpart (a filename typo means the file is
  **added**, not substituted — see F2);
- a built `juno_cand.so` that does not export the native marker symbol (below).

### M0-2 The substitution canary — the highest-value single fix

`make juno_cand.so` substitutes by filename (`Makefile:139-140`). If the
substitution silently does not happen, the candidate **is** the reference and the
null reports EXACTLY 0: a perfect green for zero work. Nothing in the harness
currently detects this — `null_ab.py --teeth`'s `build()` copies only `src` and
`gui` (`null_ab.py:262-263`), so the native path is never exercised by the gate's
own self-test.

Two counter-measures, both cheap:
- a marker symbol (`juno_tb_native_marker`) defined in every `native/*.c` and
  asserted present by `fork_check.py` after the build;
- a **procedural canary**: before accepting any module's green, plant a
  deliberate ~1 % error inside that module's own lines, rebuild, and require the
  null to FAIL. Record the residual it produced in the ledger's `canary` column.
  A green whose canary was never run is not a green.

### M0-3 `tools/trackb/celltrace.c` — turn the null into a bisector

Add a second `#ifdef`-guarded hook to `native/voice_render.c`, modelled exactly
on the existing perturb hook (same "emits no code unless `-D` is passed"
discipline): with `-DTRACKB_CELLTRACE`, append a chosen set of per-voice cells to
a file once per voice-sample. Build ref-side and cand-side traces of the module's
**output cells** and compare bit-for-bit.

Why this is worth a session: the audio null tells you *that* a render diverged;
the trace tells you *which cell, at which sample index, in which voice*. Without
it, every failure in M4–M7 is a binary search by hand. It is also the isolation
test named in §3 for six of the seven modules, so it is a prerequisite, not a
convenience.

### M0-4 Re-sweep `CARRIAGE.tsv` — it is already stale

**PROVEN (read the file this session):** `CARRIAGE.tsv` has
`max(scenarios_observing) = 5` across all 283 rows, while `null_ab.SCEN` now has
**7** entries (`null_ab.py:68-83`). Cells **656 / 672 / 688** — the glide
integrator, rate and arrival flag — are still recorded `NOT-CARRIED, 0`, although
`tools/trackb/README.md` documents that adding the glide scenario flipped 656 to
CARRIED. The file predates the scenarios that fix it (mtimes 20:03 vs 20:10).

This is the charter's own near-miss repeated: **NOT-CARRIED is the licence to
drop a cell from memory into a register**, and a stale sweep would authorise
dropping a genuinely carried integrator. Re-sweep with the current `SCEN`, and
make the TSV **fail-closed**: write the scenario-set hash into its header and
have any consumer refuse a mismatch — the same discipline `assigner_ab` already
uses for its reference pickle (CLAUDE.md P0 item 2).

### M0-5 Segmented + peak residual metrics (F3/F4)

`compare()` and `rel_residual()` compute one RMS over the whole render
(`null_ab.py:133-160`). Add, as *additional* pass conditions:
- **worst-block residual**: 1024-sample blocks, residual RMS relative to that
  block's own signal RMS, floored by the global signal RMS so silent blocks do
  not divide by ~0. Threshold may be looser than −90 dB (suggest −80 dB) but must
  exist and must be recorded.
- **peak absolute residual** relative to the reference's peak — catches a single
  bad sample (a click at note-on, a wrong first sample after the retrigger latch,
  :587-594 / :2175-2179).
- for the long scenario only, a **worst-FFT-bin residual**, which is what catches
  an aliasing tone that is broadband-quiet (F4).

Then re-run `--teeth`, and add a *new* teeth mutation that is invisible to the
whole-render RMS and visible to the block metric (e.g. a one-sample error at
note-on) — otherwise the new metric is itself untested.

### M0-6 Harden the gate's own accounting

Each is READ from `null_ab.py` and each is a way a green means less than it looks:

| fix | current behaviour | why it matters |
|---|---|---|
| length mismatch must be a hard FAIL | `rel_residual` returns `(db(0.0), 0.0)` commented "maximal failure" (:135-136), but both bulk gates test `sig < SIG_FLOOR_DB` **first** and `continue` into the *vacuous* bucket (:194-196, :241-243) | a candidate returning fewer frames is silently skipped, not failed |
| reference freshness | `load(os.path.join(REPO, "libjuno.so"))` (:308) with no guard, while 13 `tools/verify` gates go through `tools/verify/freshlib.py` (CLAUDE.md P0 item 3) | the whole claim is "candidate == the sealed engine"; a stale reference voids it |
| `--fuzz` param edits | if `fuzz_diff` was already imported without `FUZZ_PARAMS`, it prints a note and **continues** (:229-232) | the live-edit half of the fuzz gate silently disappears |
| silent-case count | `gate_full` warns only if `vac > n // 3` (:210-212) | record `vac` per run and require it to equal the passthrough baseline exactly |
| teeth strength | global mutations require `fails >= 5` (:315-318) against **7** scenarios; `tools/trackb/README.md` claims "all 7" | two scenarios could go blind and teeth stays green — set `min_catch = len(SCEN)` for the global mutations |
| teeth breadth | teeth runs `compare()` only — never `--full` / `--fuzz` | the charter's "84 of 384" for `noisegain` is MEASURED but asserted nowhere; add `--teeth --all` with a recorded band |

### M0-7 ARM null plumbing (F15)

The whole point of Track B is an in-order Cortex-M7, and every null in this plan
runs on x86-64 glibc. Stand up a `--arch arm` path that runs both sides under
qemu-arm using the toolchain `tools/embed/arm_golden.sh` already locates
(that script proves the *transcribed* engine bit-identical on ARM32, 8/8 —
CLAUDE.md). A module is not accepted until its null is green on **both**.

Standing rule that falls out of it: **introduce no new libm call whose
glibc==newlib parity has not been swept.** `expf` is the only one proven
(32,000,423 inputs, CLAUDE.md); the voice uses `expf` (:798, :1261), `fmodf`
(inside `juno_triangle`, `juno_dsp.c:56-61`) and `fmin`/`fmax`/`fminf`/`fmaxf`.
A native kernel that "helpfully" reaches for `tanf`, `sinf`, `powf`, `exp2f` or
`fma` has added an unproven dependency.

---

## 3. Module order

**The ordering heuristic** (three criteria, in priority order):

1. **Blueprint certainty** — how much of the module is READ equations versus
   INFERRED structure. A module whose spec is uncertain will fail its null for
   reasons that are not the rewrite's fault, which is the worst thing to hit
   early, when the loop itself is not yet trusted.
2. **Carried-state fraction** (MEASURED, `CARRIAGE.tsv`) — carried cells are
   where a native rewrite goes wrong invisibly for many samples. Low first.
3. **Blast radius** — a module downstream of everything (the VCA output) fails
   loudly; a module upstream of everything (the DCO) makes every later module's
   null unreadable if it is wrong. Upstream-and-huge goes last.

Cells per module are MEASURED counts from `CARRIAGE.tsv` (283 rows, re-derived
per range this session — PROVEN(arithmetic on the TSV)). Line ranges are READ and
every boundary line below was opened and confirmed in `src/voice_render.c`
(2185 lines) this session.

| # | module | lines (`src/voice_render.c`) | cells C/NC | why here | blueprint |
|---|---|---|---|---|---|
| M1 | conditioner + gate + noise SVF + source mix | :623-693, :1129-1140, :1141-1149 | 1/17, 2/1, 0/6 | warm-up: trivial math, one carried one-pole pair, any failure is certainly the harness | ENV §2.3, DCO §2.6-2.7 |
| M2 | ENV1 + ENV2 | :964-1021, :1022-1075 | 8/18 | two textually identical copies (+480 map), no libm, no oversampling — but the branch structure is the one *stated* open analytic problem | ENV §2.4 |
| M3 | VCA / HPF / boost / tone / output | :1516-1640 | 8/26 | last purely scalar block; downstream of everything, so it fails loudly, and it re-exercises M2 through the audio path | VCF §3.11-3.13 |
| M4 | glide + LFO + mod router | :682-735, :724-963, :1076-1128 | 1/6, 2/27, 1/18 | biggest structural win per line (the ÷8 hoist) but the first module whose correctness rests on an induction; needs the most new scenarios | MOD §3 |
| M5 | VCF front + cutoff→coefficient mapper | :1150-1229, :1230-1297 | 1/20, 2/3 | highest per-line risk (`expf` + `tan` rational) but **exhaustively testable offline**, which is why it can precede the ladder | VCF §3.1-3.7 |
| M6 | VCF ladder + decimating FIR | :1298-1488, :1489-1514 | 36/17 | highest carried fraction in the voice (68 %); 4 sub-steps, 4 dispersion lines, 16-tap FIR | VCF §3.8-3.10 |
| M7 | pitch spline + DCO bank + 32-tap FIR + correction | :1641-1717, :1718-2136, :2137-2167, :2160-2174 | 32/21 | largest and most upstream; f64 spline, 4× oversampling, BLEP; every earlier null must already be trustworthy | DCO §2.8-2.11 |

Not in scope as modules, deliberately: the retrigger-latch bracket (:587-594,
:2175-2179 — 8 lines, mode-dependent, the source of the e611f7d regression), the
shared noise LFSR (:595-653), and the mod-CV/LFO-rate ladder's saturating arms
(:742-781). Transcription stays.

### M1 — conditioner, gate, noise SVF, source mix

- **Replaces**: `v11 = JF(a1, 208)` … `JF(a1, 720) = v40` (:623-693); the
  Chamberlin-style noise SVF ending `JF(a1, 4320) = …` (:1140); the source mix
  ending at :1149.
- **Structural win (STATIC)**: ~24 of 27 cells are NOT-CARRIED (MEASURED), so
  nearly the whole block is register-legal; the gate binarizer's law collapses to
  `560 = 1 iff (v29 != 0.0f) && ((v29 + JF(544)) >= 0.0f)` (ENV §5.6, READ) with
  the host-ramp machinery kept as a dead input port (ENV §4). Cycle value:
  **UNKNOWN until SILICON** — it is small by construction and its purpose is to
  prove the loop.
- **Isolation test**: a truth-table sweep of the binarizer over `v29` including
  the corrected disagreement region `v29 < −JF(544)` (ENV §5.6); an impulse into
  the noise SVF with `celltrace` on `[4320]`; `observability --cells 4320,6544`.
- **Trap**: the associations at :657 are `(b*k − k*a) + a` — three roundings, not
  a two-rounding lerp (ENV verification note 5, READ).

### M2 — ENV1 + ENV2

- **Replaces**: two 54-line copies of the same ADSR, `:964-1021` and
  `:1022-1075`, related by a +480 cell offset.
- **Structural win**: one function called twice instead of two inlined copies
  (code size, I-cache — an in-order M7 concern, INFERRED); 18 of 26 cells
  NOT-CARRIED (MEASURED). Also the natural place to collapse the branch tree —
  and deriving the clean piecewise ADSR and proving it branch-for-branch equal to
  `:980-1017` is named in CELLMAP §5.4 as "the main analytic task left".
- **Isolation test**: `celltrace` on `[2752]`/`[3232]` (the ENV outputs) driven by
  a gate on/off script, compared bit-for-bit across all four segments, for the
  recalled coefficient sets of all 64 factory patches. This is a **stronger test
  than the null** and it needs no audio.
- **Traps**: `JF(2704)` must keep its three-term form — with `2848 == 1.0` it is
  algebraically `JF(2960)` but **not** numerically (ENV §5.3, PROVEN there by
  float32 recompute). `[9824]` (gate twin) is **1.0 from power-on**, not 0, and
  its smoother settles in ~14 ms while the host idles (ENV §4); a native port
  that starts it at 0 fades in the first note of every voice — far above −90 dB.

### M3 — VCA / HPF / boost / tone / output

- **Replaces**: `JI(a1, 9568) = JI(a1, 9552)` (:1516) through
  `JF(a1, 10672) = v384 * JF(a1, 9856)` (:1640), i.e. the velocity gain, gate-twin
  smoother, gate-mode env, CV mix, HPF, DC blocker (:1606-1613) and the two tone
  shelves (:1614-1637).
- **Structural win**: 26 of 34 cells NOT-CARRIED (MEASURED); three one-pole pairs
  where the *shadow* is the cell actually read collapse to one variable each
  (VCF §6.1 item 6); the `[10496]`/`[10512]` memory alias becomes four
  independent variables (VCF §6.2).
- **Isolation test**: step response of the HPF (:1583-1585) — VCF R6; white noise
  through :1614-1637 with `[9632] = ±0.5` — VCF R5; per-smoother unit test over
  10⁶ random `(t, s, a)` triples — VCF R13.
- **Traps**: the tone shelves are **poles, not FIRs** (VCF §1.8 corrects CELLMAP);
  `[9632]` is **VCA TONE**, a recalled per-patch cell, not an inert copy (ENV §5.1
  correction) — the block does *not* collapse to `v383 = v375` except at TONE 0.
  Every one-pole's algebraic form is load-bearing: compare :1175
  `((v205−v206)*[6928]) + v206` with :1543 `(([9888]*v336) − ([9888]*v337)) + v337`
  — these are **not** interchangeable at the bit level (VCF §6.3).

### M4 — glide + LFO + mod router

- **Replaces**: glide (:682-735, ending `JF(a1, 752) = v56`), the rate ladder and
  LFO (:724-963), the mod router and DCO pitch/PWM mixers (:1076-1128).
- **Structural win, the largest in the plan**: MOD §6.1 — **six carried floats are
  the whole LFO** (`rateSm, extGatePrev, delayRamp, phase, noiseSm, shHold`) out of
  29 cells; and MOD §5.1's P1–P4 argue the LFO state is bit-identical across all 8
  voices, so it can be computed **once per sample and broadcast** — one eighth of
  the LFO cost. **That argument is INFERRED, by induction, not executed** (MOD R4
  lists everything that invalidates it). If the hoist is taken, ship the debug
  assert MOD R4 asks for (voice 0's `[1536]` == voice 7's).
- **Isolation test**: `celltrace` on `[1472]`, `[1776]`, `[1792]`, `[1808]`,
  `[1824]`, `[752]`, `[3776]`, `[3808]` over the long scenario **and** over a new
  LFO-DELAY scenario (§5); plus a `juno_wrap24`-style iterate-10⁶-steps sequence
  comparison for the phase accumulator (:806, :845).
- **Traps**: **`[1792]` has the LFO DELAY envelope applied and `[1808]` does not**
  — PWM and the mod-wheel path use the undelayed one (MOD R1); the retrigger is a
  multiply on the summed phase gated by the **broadcast** any-key-held flag, not
  the voice's own note-on (MOD R2); `[1552]` is written at :811 and read at :854
  **in the same sample** — treating it as a one-sample delay shifts the S&H
  trigger (MOD R9); `[2144]`'s 44100 arm is the **large** one, 2.1768708 (MOD R3);
  the discarded `fmodf` results at :892/:896 must **not** become assignments
  (MOD §6.3).

### M5 — VCF front + cutoff→coefficient mapper

- **Replaces**: the cutoff-CV taper, resonance latch, velocity and LFO smoothers
  and the three-level mod sum (:1150-1229, ending `JI(a1, 7280) = …` at :1229);
  then the mapper `v228 = JF(a1, 6704)` (:1230) through :1297 — the dither, the
  cutoff clamp, `expf` (:1261) and the `tan` rational (:1274-1291).
- **Structural win**: the mapper is gated by `[7632] == 1.0` and runs every
  sample; only 5 cells, 2 carried. The win here is not memory, it is the
  possibility of replacing `expf` with an exact table of its integer-argument
  outputs — VCF §3.7 fixes the argument set at **{−6…3}, 10 values at 44100** and
  **{−6…4}, 11 values at every other rate** (a 10-entry table sized from the
  44100 figure runs off its end at 48000/88200/96000/192000, and the project gates
  at 88200 — VCF verification note 2).
- **Isolation test, the strongest in the plan and it needs no audio** (VCF R1):
  drive the clamp output over its full range — `[−3, 10.397]` at 44100 and
  `[−3, 11]` elsewhere, so **run both arms** — in 2²⁴ steps through both the
  transcribed :1255-1292 and the candidate; require bit-identical `[7520]`. Also
  disassemble the candidate for `rcpss`/`vrcp` (VCF R3): `1.0 / (…)` at :1345
  **must be a division**.
- **Traps**: the mod sum's three-level grouping `(A+B) + ((C+D)+E)`; the clamp's
  `+[7664]` inside the `fminf` and `*[7824]` outside both; the interleaved
  sinh/cosh Horner; `v246 = 1.0 − (v241 + v241)`, not `1 − 2*G`; two clamps with
  **asymmetric NaN behaviour** (the ladder input clamp sends NaN to −1.0, the
  cutoff-CV clamp to 1.0) — all VCF §6.3.

### M6 — VCF ladder + decimating FIR

- **Replaces**: `v242 = JF(a1, 6544)` (:1298) through the four sub-steps to :1488,
  then the decimator to `JF(a1, 9040) = v326` (:1514).
- **Structural win**: 53 cells of which **36 are CARRIED** (MEASURED, 68 % — the
  highest in the voice), so the honest win is *not* register promotion but
  structure: the 8-cell pipeline `[8208..8320]` is **seven named variables**
  rotated once per host sample (VCF §6.1 item 2), and the four 8-cell dispersion
  lines `[8432..8928]` become one circular buffer with a modulo index.
- **Isolation test**: single-voice impulse into `[6544]` with `[6832]` swept
  0→255, `celltrace` on `[9040]` sample-by-sample (VCF R4); the four line heads
  `[8816] [8688] [8560] [8432]` dumped for one sample (VCF R14); a fixed 32-sample
  vector through both FIR expressions (VCF R2). Build with `[9184] = 0` first —
  the linear ladder is exactly solvable — then enable the quintic (VCF §7.2).
- **Traps**: `[8288]`/`[8304]`/`[8320]` hold **state contributions**, not stage
  outputs — a uniform delay-line shift feeds the wrong values into the feedback
  (VCF R4); the FIR accumulation is centre-out with `v324`/`v325` injected out of
  sequence (:1489, VCF §3.10); the quintic is
  `x + ((((x*x)*x)*x) * (x*[9184]))`, not `x*(1 + k*x⁴)`; sub-step 4's tap
  association differs from 1-3 (VCF §3.9). And the held branches: the gates are at
  :1235 and :1338, so :1230-1234 and :1300-1337 — including the stage-state shift
  at :1306 and all four line shifts — run **outside** them, every sample
  (VCF §6.1 item 8). Pulling them inside the `if` while tidying is the natural
  mistake and it changes what the held branch holds.

### M7 — pitch spline + DCO bank + FIR + correction

- **Replaces**: `v385 = fmin(fmax(…), 8.9)` (:1641) through `JF(a1, 4416) = v391`
  (:1665) and the pulse-width sum at :1711; the 4×-oversampled core :1718-2136;
  the 32-tap symmetric FIR :2137-2167; the correction stage to
  `JF(a1, 3520) = v526` (:2174).
- **Structural win**: the largest line count in the voice (≈530 lines/sample) and
  the 4× loop is the obvious target — but 32 of 53 cells are CARRIED (MEASURED),
  so again the win is structure and loop form, not stores. **Quantifying it is
  gated on SILICON** (§8).
- **Isolation test**: `celltrace` on `[4416]`, `[5456]`, `[3520]` plus the four
  sub-block taps; a pitch sweep across the spline's knots; a high-note alias probe
  (§5). The spline must be compared in **f64** — `juno_pitch_table` is
  `static const double[29][26]` (`juno_tables.h:12`), read through a
  `const double *` with a `double` accumulator (:1642-1661); narrowing happens
  only at the `fminf`/`fmaxf` clamp (:1647-1663). **Storing that table as f32, or
  accumulating in f32, will not null** (CELLMAP §5.8).
- **Traps**: `s5536`'s sample-rate law is a strict **2-arm select** — 220/44100 at
  44100, 220/96000 at *everything else* (DCO §5.1) — so 48000 is a genuinely
  different pitch law and a native port must reproduce the select, not a
  "corrected" 220/H; `[5520]` feeds the **pulse width** (`[4816] = [5520] +
  [3808]`, :1711) despite the applier's "tune-trim" label (DCO §5.2 / MOD R7); the
  sub counter compares `>= 4.0` on a float cell that also receives int-bit copies
  — preserve the bit copies exactly (DCO §5.6).

---

## 4. The per-module loop, and the EQUIVALENCE ledger

### 4.1 The loop

```
0.  fork_check.py                       fork provenance + native marker + no orphan file
1.  observability.py --cells <outputs>  ≥1 scenario must OBSERVE them   (else: add a scenario, §5)
2.  edit native/<x>.c                   one module, one commit
3.  make juno_cand.so                   fresh; never trust a pre-existing .so
4.  coverage_probe.py --lines A-B       every scenario must REACH the rewritten range
5.  <module>_iso                        the isolation test of §3 (celltrace / offline sweep)
6.  null_ab.py --cand ./juno_cand.so --all       7 scenarios + 384 bank + 24 fuzz
7.  null_ab.py --cand ... --arch arm     the same, under qemu-arm            (M0-7)
8.  canary: plant a 1% error INSIDE the module, rebuild, require FAIL, revert
9.  null_ab.py --teeth                  iff SCEN or the metric changed in this step
10. record one EQUIVALENCE row; commit; if any step is red, revert the module whole
```

Steps 1, 4, 5 and 8 are the ones that make step 6 mean something. A row with any
of them blank is a **PENDING** row, not a green one.

### 4.2 Ledger — `docs/trackb/EQUIVALENCE.tsv`

One row per module per accepted revision. Rows are never edited in place; a
re-accepted module gets a new row (the history is the audit trail).

| column | content | why it is in the ledger |
|---|---|---|
| `module` | `M4-MOD` | the unit of revert |
| `file` | `native/voice_render.c` | which substitution |
| `lines_ref` | `682-735,724-963,1076-1128` | the replaced range in `src/voice_render.c` **at `src_sha`** |
| `cells_out` | `1472,1792,1808,1824,752,3776,3808` | what the module produces; the argument of steps 1 and 5 |
| `date` | ISO | — |
| `commit` | candidate commit sha | reproducibility |
| `src_sha` | sha256 of the frozen `src/` tree | catches "both sides moved" (F14) |
| `ref_sha` | sha256 of `libjuno.so` + the commit at which `make verify` was last green | the reference is the entire claim (F1) |
| `cand_sha` | sha256 of `juno_cand.so` under test | catches the stale artifact (CLAUDE.md trap) |
| `marker` | native marker symbol present Y/N | catches the un-substituted build (F2) |
| `coverage` | min scenarios covering the range; any unreached line | gate #2 |
| `branch_cov` | branch coverage of the range; unreachable branches listed | F6 |
| `observ` | per output cell: scenarios observing / loudest dB | gate #3; **0/N ⇒ not admissible** |
| `iso` | isolation test name + result (bit-identical / N mismatches) | the strong, non-audio evidence |
| `null_scen` | worst residual over the 7 scenarios, or `EXACTLY 0` | gate #1 smoke |
| `null_block` | worst 1024-block residual; peak-sample residual | M0-5 |
| `null_full` | `n / over-threshold / silent / worst dB` — `silent` must equal the baseline | F12 |
| `null_fuzz` | seeds / over-threshold / worst dB | live param edits |
| `null_arm` | worst residual under qemu-arm, or `SKIP:<reason>` | F15 |
| `opt_levels` | which of `-O0/-O2/-Os` were run green; UBSan/ASan Y/N | F16 |
| `ftz` | residual with FTZ on / off | F17 |
| `canary` | the planted error and the residual it produced | F2 — a green with no canary is not a green |
| `teeth` | date of the last `--teeth` pass and whether `SCEN` changed since | F8 |
| `carriage_rev` | the `CARRIAGE.tsv` revision (+ scenario-set hash) relied on for any register promotion | F7 |
| `risks_closed` | blueprint risk ids, e.g. `VCF-R2,R4,R14` | ties the evidence to the named failure modes |
| `state_parity` | does the module preserve the memory image? Y/N | F20 — decides whether `make verify`'s state gates can still see it |
| `status` | `PENDING` / `GREEN` / `REVERTED` | — |
| `notes` | free text, including anything left INFERRED | honesty column |

---

## 5. Keeping the null sharp — scenarios per module

The rule (charter): **never rewrite behind a blind gate.** Two global facts about
the current `SCEN` drive most of this table:

- the 7-scenario smoke gate runs at **44100 Hz only** (`SR = 44100.0`,
  `null_ab.py:51`); only `--full` adds 48000 (`FULL_RATES`, :181). Any module with
  rate-armed constants must be judged on `--all`, and any module whose *law*
  changes by rate (M5's `expf` argument set; M7's `s5536` 2-arm) needs an explicit
  non-44100 scenario, not just the bank sweep;
- the five original patches (5, 15, 61, 20, 2) were chosen for allocator and FX
  variety, not for DSP-axis coverage. `noisegain` being caught by 1 of 7 is the
  standing proof that "all seven passed" can mean "one of them looked".

| module | scenario(s) to add | the risk it closes | why the current set cannot |
|---|---|---|---|
| M1 | a patch with **DCO NOISE non-zero** and audible | noise SVF + source mix | four of the scenario patches have DCO NOISE at 0 — the `noisegain` lesson, charter §Gate #2 |
| M2 | full **four-segment** exercise: attack cut short by note-off, long decay, sustain hold, long release; a **VCA MODE = 2 (GATE)** patch | ENV branch structure, which is the INFERRED part | current scripts hold notes for a fixed time and mostly test A/S; the gate-mode path (`juno_apply.c:403-409`) is a different amp CV entirely |
| M3 | a patch with **VCA TONE ≠ 0** in *both* signs; one of the 10 **HPF TYPE 1** patches | VCF R5, R12 | at TONE 0 the shelf block collapses to a wire (ENV §5.1) — a wrong shelf is invisible; HPF TYPE is a joint recall function (`juno_apply.c:691-701`) |
| M4 | **LFO DELAY ≠ 0 with PWM SOURCE = LFO**; a **held chord** with an LFO (retrigger law); an **LFO waveform other than the factory-enabled one** (S&H, saw, square) via live `param` edits; keep the existing 300000-frame long render | MOD R1, R2, R8 | R1 is explicit: one-LFO-output ports sound right at DELAY 0 and wrong otherwise, and the current five may contain no such patch. R2 is inaudible on single-note tests. R8 only bites on non-factory waveforms, so it would pass the gate and break the first user patch |
| M4 | **long render is mandatory for anything touching phase.** A phase-increment error too small to see in 30000 frames (0.68 s) is plainly audible over 10 s | phase/LFO/envelope-tail drift | already in `SCEN` as scenario 7 (patch 55, 300000 frames); the requirement is that it must never be dropped, and must be in the coverage/observability run too |
| M5 | a **high-resonance, low-cutoff** patch **plus a live cutoff sweep** (`param` on the VCF CUTOFF row) | VCF R3, R4, R9, R13 | VCF §7.1: `v227` already moves every sample, so the cutoff *axis* is covered — the gap is the **resonance** axis. `[7536]` (the loop gain `k`) is constant within a scenario and no current scenario sets it high, and R3/R4/R9/R13 are error-multiplied by `1/(1+G⁴k)` every sub-step |
| M5 | one scenario at **88200 Hz** (or gate the module on `--all` and record it) | the 11-entry vs 10-entry `expf` argument set | the smoke gate is 44100-only, and the argument set differs at every other rate (VCF verification note 2) |
| M6 | reuse M5's high-resonance scenario; add a **loud transient into a self-oscillating filter** | the ladder pipeline and the decimator | the same reason as M5, plus the pipeline error only shows under feedback |
| M7 | **high notes** (MIDI 96+) for aliasing; **PW extremes** and PWM at depth; **sub-oscillator-heavy** patch; a **glide sweep across spline knots**; and 44100 **and** 48000, because `s5536` is a 2-arm select | DCO §5.1, §5.6; alias energy | the alias residual is broadband-quiet and can hide under a whole-render RMS (F4) — this is why M0-5's FFT metric exists |

Every scenario added here changes `SCEN`, therefore: re-run `--teeth`, re-run the
`CARRIAGE.tsv` sweep (its header hash changes), and re-baseline `gate_full`'s
silent count. That cost is the reason M0 comes first.

---

## 6. How do we know the test is not lying

This is the user's central fear and the project's documented failure mode: the
assigner arc (both sides wrong together), the fine-FX blind spot (oracle and port
both skipping the same leaves), the stale-artifact false greens, the multiplicative
carriage probe that could not perturb a zero. Every entry below is a concrete way
**this** gate could report green on a broken candidate, with the counter-measure
that closes it. Entries marked ⚠ are **live today** — verified this session, not
hypothetical.

| # | false-green mechanism | evidence | counter-measure |
|---|---|---|---|
| F1 | **Stale or wrong reference.** `null_ab.py` loads `REPO/libjuno.so` with no freshness guard (:308) while 13 `tools/verify` gates go through `freshlib.py`. A `libjuno.so` older than `src/` is not the sealed engine, and the null then proves nothing. ⚠ | READ | route the reference load through `freshlib.py`; ledger `ref_sha` + the commit at which `make verify` was last green |
| F2 | **The candidate is secretly the reference.** Substitution is by filename (`Makefile:139-140`); a typo adds a file instead of replacing one and the null reports EXACTLY 0. `--teeth`'s `build()` copies only `src`/`gui` (:262-263), so the native path is never self-tested. ⚠ | READ | `fork_check.py` (M0-1, currently **missing** — PROVEN) + native marker symbol + the per-module **canary** (M0-2), ledger columns `marker`, `canary` |
| F3 | **Whole-render RMS hides a localized error.** One RMS over 30000-300000 frames, normalized by the loud part: a click at note-on or an error confined to the release tail contributes almost nothing. | READ (:133-160) | worst-1024-block residual + peak-sample residual (M0-5), and a teeth mutation that only the block metric can catch |
| F4 | **Spectral hiding.** A residual that is small broadband can still be an audible alias tone where the reference has no energy — most likely exactly in M7. | INFERRED | worst-FFT-bin residual on the long scenario; the M7 alias scenarios in §5 |
| F5 | **Scenario blindness** — the code runs and the error is multiplied out downstream (the `noisegain` case: 1 of 7). | MEASURED (charter §Gate #2) | `observability.py --cells <module outputs>` before the rewrite; **0/N ⇒ not admissible**; ledger `observ` |
| F6 | **Line coverage ≠ branch coverage.** `coverage_probe` counts lines. The ENV state machine and the held branches (`[7632]!=1`, `[9056]!=1`) can be implemented wrongly and never executed. | READ | `gcov -b` for the module range; unreachable branches recorded as OUT-OF-SCOPE-UNREACHABLE **with the grep proof of no writer**, never silently deleted (VCF §6.1 item 8) |
| F7 | **A stale MEASURED artifact authorising a wrong transform.** `CARRIAGE.tsv` has `max(scenarios_observing) = 5`; `SCEN` has 7. Cells 656/672/688 (the glide integrator) still read `NOT-CARRIED, 0` although the README documents the glide scenario flipping 656 to CARRIED. NOT-CARRIED is the licence to drop a cell into a register. ⚠ | PROVEN (read the TSV this session) | re-sweep (M0-4); scenario-set hash in the file header; consumers fail closed on mismatch; ledger `carriage_rev` |
| F8 | **The teeth are weaker than their documentation.** Global mutations require `fails >= 5` (:315-318) against 7 scenarios; `tools/trackb/README.md` says "all 7". Two scenarios could go blind with teeth green. ⚠ | READ | `min_catch = len(SCEN)` for global mutations; per-scenario expectation table |
| F9 | **The teeth never test the gates that accept the work.** `--teeth` runs `compare()` only, never `--full`/`--fuzz`; the "84 of 384" figure is MEASURED and asserted nowhere. | READ | `--teeth --all` with a recorded catch-count band |
| F10 | **The teeth mutations are in the wrong place.** All four are planted in `src/`, three outside the regions being rewritten. | READ | one teeth mutation per module, anchored **inside** that module's own line range, with an honest expected-scenario count |
| F11 | **A length mismatch is scored as silence.** `rel_residual` returns `(db(0.0), 0.0)` commented "maximal failure" (:135-136), but both bulk gates test the vacuity floor first and `continue` (:194-196, :241-243). `compare()` `zip`s and truncates. ⚠ | READ | hard FAIL on length mismatch before any vacuity test |
| F12 | **Silence creeping in.** A broken envelope can make patches silent; those comparisons are skipped and only warn above `n//3` (:210-212). | READ | record `silent` per run; require equality with the passthrough baseline |
| F13 | **The fuzz gate quietly dropping live param edits** if `fuzz_diff` was imported without `FUZZ_PARAMS` (:229-232) — it prints a note and continues. ⚠ | READ | hard exit |
| F14 | **Both sides move together.** Any edit to `src/` during Track B changes the reference; the null then compares two copies of the same mistake — the assigner lesson. | READ (CLAUDE.md) | freeze `src/`; ledger `src_sha`; any `src/` change ⇒ full `make verify` + re-baseline every row |
| F15 | **Right on x86, wrong on the target.** Every null here runs x86-64/glibc/-O2; the target is an in-order M7 with newlib. New libm calls, `float` evaluation and FMA contraction can all differ. | READ | per-module ARM null under qemu (M0-7); FMA canary in the candidate's own build; **no new libm function without a glibc==newlib parity sweep** (only `expf` is proven, 32,000,423 inputs) |
| F16 | **Correct only at one optimization level.** The dual-typed JF/JI cells (CELLMAP §5.3) invite strict-aliasing UB; `-fno-strict-aliasing` masks it at `-O2` and may not elsewhere. | READ | `-O0/-O2/-Os` nulls once per module; UBSan + ASan once per module; **memcpy** for dual-typed cells, never a float assignment |
| F17 | **Denormals / FTZ.** `juno_ftz.c` is load-bearing on WASM; the tails are where denormals live and where a flush changes the sound. | READ | run each module's null with FTZ on and off; ledger `ftz`; treat FTZ as a change to be measured, never a free win |
| F18 | **Threshold gaming.** The easiest way to pass is to move `THRESH_DB`. | — | `THRESH_DB`, `SIG_FLOOR_DB` and the block thresholds are charter constants; changing one is a user decision and forces a full `--teeth` re-run |
| F19 | **Flaky non-determinism read as a pass.** Uninitialized memory or pointer-dependent behaviour can null on one run and not the next; a re-run "fixes" it. | INFERRED | three consecutive identical runs recorded per row; MSan/ASan once per module |
| F20 | **Audio-green, state-red — and the confusion between them.** The null compares samples; `recall_gate` / `coldstate_ab` / `renderstruct_ab` compare cells. Dropping a write-only shadow store is legal for a −90 dB null and fails the bit-exact gates (VCF §6.2 caveat, CELLMAP §5.1). | READ | the state gates always run against `src/`, never the candidate; ledger `state_parity` states per module whether the memory image is preserved, so the two claims are never traded for each other |
| F21 | **The blueprint is wrong and the null agrees with it.** If a module is built from a doc's INFERRED reading (ENV branch labels, the LFO hoist induction, the DCO correction-stage intent), a green null only proves candidate == reference for the *inputs the scenarios produced*. | READ | for each module, list in `risks_closed` which blueprint items were INFERRED and remained so; prefer the offline exhaustive isolation tests (M5's 2²⁴ sweep, M2's 64-patch coefficient sweep) over audio evidence wherever the input space is small enough to exhaust |
| F22 | **Green by construction: the "native" version is the transcription.** If nulling only succeeds after restoring the exact float tree, the module has been renamed, not rewritten — a real green with zero value. | INFERRED | this is a **STOP condition**, S4 in §8, not a bug: record it and move on |

**The standing rule that ties them together:** a Track B green is admissible only
when gates #1, #2 and #3 are green **for the subsystem being rewritten**
(charter §The rule), the canary fired, and the ledger row is complete. Any one of
those missing turns "PASS" back into "nobody looked".

---

## 7. Redoing this for another synth (JX-3P, …)

`tools/trackb/README.md` already lists the tool-level split. What this plan adds
to the reusable side is the **method**, which is where most of the cost actually
sits.

**Reusable as-is — the method:**
- the three-question structure (reached / noticed / identical) and the rule that
  the second and third exist because the first cannot answer them;
- **the module-ordering heuristic** of §3: blueprint certainty first, carried-cell
  fraction second, blast radius third — warm-up module first so the loop fails
  before the math does;
- the per-module loop of §4.1 and the **ledger schema** of §4.2, essentially
  verbatim (only `lines_ref` and `cells_out` are synth-shaped);
- **the false-green table F1–F22**: F1, F2, F3, F5, F6, F7, F8, F9, F10, F11,
  F12, F14, F16, F18, F19, F20, F21, F22 are properties of *this kind of gate*,
  not of the JUNO. Start the next synth by re-asking all eighteen;
- the blueprint recipe in CELLMAP §5.9 (region strides by diffing per-voice
  function copies → cell scan → names from the plugin's own registry → dataflow
  grouping → equations with line cites → only then a rewrite);
- the tools: `coverage_probe.py` entirely; `observability.py` + `perturb_rt.c`
  entirely (given a flat state pointer and a place for the hook); `celltrace`
  (M0-3); `fork_check.py` (M0-1); `null_ab.py`'s comparator, thresholds,
  non-vacuity floor, `--full`/`--fuzz` structure and the teeth discipline;
- the `native/<x>.c` shadowing rule in the `Makefile`;
- the STOP rule shape of §8 (measure the ceiling before paying for the win).

**JUNO-specific — a new synth must supply:**
- the cell vocabulary: `JF(a1, N)`/`JI(a1, N)`, the 10512-byte voice stride, the
  base-relative shared block, and the `written_cells()` regex if the
  transcription uses other accessors;
- the **2-arm rate constants** (44100 vs everything else) — a JUNO artefact of the
  plugin's frozen design, and the reason several tests must be run at two rates;
- the f64 pitch spline (`juno_pitch_table`, `juno_tables.h:12`), the 4× DCO / 3×
  ladder oversampling factors, `juno_wrap24`, `juno_triangle`;
- `SCEN`: patches and scripts, chosen so every subsystem is *observed* — verify
  with `observability.py`, never assume, and expect §5's table to be entirely
  different;
- the mutation set in `build()` — every mutation needs a real anchor in that
  engine's source and its own honest expected-scenario count;
- the bank loader (`truth.BANK`, `juno_gui_apply_bank`) and the `juno_gui_*` API
  names in `load()`;
- **a sealed bit-exact reference to null against. This is the load-bearing one.**
  Track B is trustworthy only because a proven-exact engine sits on the other side
  of the subtraction. Without that seal, a null test compares two guesses — which
  is precisely the failure the assigner arc recorded. **For a new synth, the seal
  is the first project, and Track B is the second.**

---

## 8. Effort, what is decidable now, and the STOP rule

### 8.1 What is decidable now, and what is gated on silicon

The standing rule is **no optimization before a SILICON number exists**
(`ROADMAP_EMBEDDED.md` §0). That rule does not stop this plan; it partitions it.

**Decidable now, no hardware — all of it correctness or evidence work, none of it
optimization:**
- the whole of **M0** (fork check, canary, celltrace, carriage re-sweep, metrics,
  teeth strengthening, ARM plumbing) — these fix gates that are *already* weaker
  than their documentation, independent of whether Track B ever proceeds;
- every **scenario addition in §5** — they close blind spots in a gate the project
  will want regardless;
- the **analytic work** each module needs: the ENV piecewise derivation
  (CELLMAP §5.4), the `expf` argument-set table per rate (VCF §3.7), the offline
  isolation harnesses. These are needed whatever the eventual answer, and several
  of them (the 2²⁴ mapper sweep) are stronger evidence than any null.

**Gated on the SILICON number (P1/E2: cycles-per-voice `V` and floor `F`):**
- **whether to write any module at all** (S1 below);
- **which** modules — each module's ceiling probe (S2) is itself a silicon
  measurement;
- **every claim about the win.** Nothing in §3 quantifies a speedup, on purpose.
  The strongest thing this plan is willing to say is structural: 189 of 283
  per-voice cells are NOT-CARRIED (MEASURED) and therefore register-legal; the
  LFO's carried state is six floats and is INFERRED voice-invariant; the ENV is
  two textual copies of one function. Whether any of that is worth cycles on an
  in-order M7 is exactly the question the $41 board answers.

### 8.2 Effort per module (INFERRED — estimates, in focused work-sessions)

| module | sessions | what dominates |
|---|---|---|
| M0 | 1–2 | five separate tool fixes + a teeth re-run per fix |
| M1 | 1 | mostly loop practice; math is trivial |
| M2 ENV | 2–3 | deriving the piecewise ADSR and proving it branch-for-branch (a stated open problem) |
| M3 VCA | 2 | six one-poles with two non-interchangeable algebraic forms; tone shelves |
| M4 MOD/LFO | 3–4 | four new scenarios, the hoist induction + its assert, the retrigger law |
| M5 VCF front + mapper | 3–4 | the `expf`/`tan` chain and the 2²⁴ two-arm sweep; per-rate table |
| M6 ladder | 4–6 | 36 carried cells, four sub-steps with differing associations, FIR order |
| M7 DCO | 5–8 | f64 spline, 4× core, BLEP, 32-tap FIR, two rate arms |
| **total** | **21–30** | consistent with `ROADMAP_EMBEDDED.md` §3's "weeks + quality risk" for option C |

### 8.3 The STOP rule

Track B exists for one reason: voices 5–8 on a board that cannot otherwise hold
them. The fallback is not failure — it is `ROADMAP_EMBEDDED.md` option A or B:
**fewer voices, bit-exact**, on hardware that already builds and links. A
bit-exact 4-voice Daisy already exceeds the commercial JU-06A's fidelity
(ROADMAP §2). Stopping is cheap; being wrong is not.

**S1 — pre-emptive, checked before M1 is written.** With P1's `V` and `F`:
- if `F + 8V ≤ 18503` (Teensy 4.1 @816 MHz, 44.1 kHz) → **stop before M1.** Option
  B is real; buy the Teensy and ship the bit-exact 8-voice engine.
- if `F + 8V ≤ 10884` (Daisy @480 MHz) → **stop before M1.** The model was very
  wrong and Daisy-8v works bit-exact.
- if `⌊(10884 − F)/V⌋ ≥ 4` and the user accepts 4 voices → **stop before M1.**
- otherwise Track B has a target, and it is `8V_native + F ≤ B_board`.

**S2 — the ceiling probe, per module, before writing it.** Build a candidate in
which the module is replaced by a **dependency-chain-only stub** — audio-wrong on
purpose, keeping only the carried state so the engine still runs — and measure it
on silicon. That is the module's absolute ceiling. **If the ceiling of all
remaining modules combined is smaller than the gap to the next integer voice
count, stop: no achievable rewrite buys a voice.** This is the rule that keeps the
plan honest about the fact that 36 of the ladder's 53 cells and 32 of the DCO's 53
are CARRIED (MEASURED) — carried state does not vanish under any rewrite.

**S3 — evidence, after M1–M3.** If cumulative measured silicon speedup after the
three *cheap* modules is under ~10–15 %, stop: the remaining modules are the risky
ones (M6, M7), and the transform is not paying for the risk already taken.

**S4 — structural (F22).** If a module can only null by reproducing the
transcription's exact float tree — the likely outcome for M5's `expf`/`tan` chain
and for both FIRs (VCF §6.3 lists eight separate associations that must not be
restructured) — then the native version *is* the transcription. Record the module
as NO-WIN, revert it, and move on. Do not spend a second session on it.

**S5 — quality, absolute.** Stop and revert if a module's null is green on x86 and
cannot be made green on ARM; or can only pass by loosening `THRESH_DB`; or by
removing a scenario; or if the block/peak metric fails while the whole-render RMS
passes and the difference is judged inaudible **by argument rather than by
measurement**. The criterion is the user's ("sonically identical in every way"),
not the gate's.

**S6 — charter, absolute.** If `make verify` on `src/` goes red at any point,
everything halts until it is green. The reference is the entire claim.

---

## 9. What this plan does not cover

1. **The master/FX chain** (`master_render.c`, 2946 lines) is out of scope by
   §0.2. If the SILICON floor `F` turns out to be dominated by the master rather
   than by the voices, this plan is aimed at the wrong half of the engine — and
   P1's E2 measurement (0/1/2/4/8 voices) is exactly what distinguishes them.
   **Re-read that number before starting M1.**
2. **Fixed-point** anything. Every module here stays float32 in the transcription's
   evaluation order; a fixed-point voice is a different project with a different
   acceptance criterion.
3. **The `#112` / DAW-parity track.** Independent (`ROADMAP_EMBEDDED.md`
   §"Parallel track"); nothing here touches it, and nothing there blocks this.
4. **Any claim that a module is faster.** There are none in this document, and
   there must be none until E2 exists.
