# ESP32-S3 FEASIBILITY — THE CORRECTED ASSESSMENT (2026-08-03)

This document replaces the verdict in `docs/engineb/LEVERS.md` ("not reachable
by rearranging this engine"). That verdict rested on an invalid comparison:
host x86 instruction counts (15,450/sample) set directly against an S3 cycle
budget, and against the ONE-CORE target only. The comparison was wrong in both
directions at once. It hid ~35,000 instructions/sample of S3-only soft-float
cost (too optimistic), and it ignored 4,500 cycles/sample of budget that the
binding constraints permit (too pessimistic). This page redoes the sum with
the 2026-08-03 measurements and attacks its own conclusion from both sides.

Every number carries a label. PROVEN = the gate executed. MEASURED = counted
in execution. STATIC = counted in a disassembly. MODELED = computed from an
assumption that is stated. INFERRED = argued, not counted.

---

## 0. The capacity arithmetic, checked

240,000,000 Hz / 48,000 Hz = **5,000 cycles/sample per core. Exact.**

| budget line | cycles/sample | what it is |
|---|---|---|
| one core, hard limit | 5,000 | physics of the part (`SCOPE.md`) |
| engine B target | 3,500 | 70% of one core; the 30% is chosen headroom, not physics |
| two cores, theoretical | 10,000 | 2 x 5,000 |
| **two cores, working figure** | **~9,500** | keeps ~500 cyc/sample for I2S/DMA service, control, and the inter-core hand-off. MODELED allowance, not measured. |

`SCOPE.md` wrote "the audio must not need two cores." The binding constraint
ranking (`docs/trackb/CONSTRAINTS.md`: 8 voices and all FX outrank everything;
6 voices is the only compromise and the last resort) now explicitly permits
spending the reserve core BEFORE any voice is dropped. Spending it means:
audio on both cores, and the control plane lives inside the ~500-cycle
allowance. So the honest capacity is **9,500, not 3,500** — the prior analysis
judged the engine against 37% of the money it is allowed to spend.

---

## 1. THE CASE AGAINST "UNREACHABLE"

The prior analysis missed or mispriced five levers.

### 1.1 It used the wrong budget (mispriced 2.7x)

15,450 host instr/sample against 3,500 is 4.4x over. The same count against
the permitted 9,500 is 1.63x over — before any lever is pulled. The
"unreachable" conclusion was 2.7x too harsh on capacity alone. (Both numbers
are still host counts and still invalid as cycles; the point is the ratio of
budgets, which is arithmetic.)

### 1.2 The dominant S3 cost is one removable class, and its removal is nearly proven

The 2026-08-03 S3 census (`data/s3_cost_table.md`, `data/softfloat_cost.md`)
shows the largest single cost is not the synthesiser at all. It is
double-precision arithmetic in `eb_pitch.c`, executed 8x/sample on a core
with no double FPU:

* Pitch soft-double path: **18,200–22,300 instr/sample** (STATIC common-path
  band on a MEASURED census; ~21,000–30,000 cyc/sample MODELED). That is
  ~55–60% of the whole engine.
* The precision null (`data/pitch_precision_null.md`, MEASURED, full
  30-scenario set) already shows the replacement is close: the Dekker
  double-float variant is **22/30 BIT-EXACT, 30/30 on the block gate, and
  fails the -100 dB global gate in only 2 scenarios, by 4.2 dB and 1.9 dB**.
  The gap is attributed BY MEASUREMENT to evaluation precision alone (variant
  B2); the float clamp and row select contributed nothing. A compensated or
  triple-float summation is a concrete, staged next candidate.
* A passing float-class variant removes the ENTIRE per-sample soft-double
  load: the Dekker build's runtime arithmetic is pure single-float FPU, and
  its remaining soft-double relocations are all table-splits-at-use, which a
  pre-split static table removes (STATIC census of the variant objects).

"Unreachable" cannot stand on a cost class that is 55–60% of the engine and
one bounded precision fix away from removal. It is not removed YET — see
section 2 — but the prior analysis did not even see it (its host count priced
the pitch polynomial at 536 instr/sample, because the host has a double FPU).

### 1.3 The divide penalty has a measured, gate-passing fix on the shelf

`eb_dco` executes 32 `__divsf3`/sample (MEASURED). `EB_DCO_RECIP=1` already
exists in `engine_b/eb_dco.h` and is **MEASURED through the full 30-scenario
null: worst global -121.1 dB (21 dB of margin), worst block -115.2 dB (35 dB
of margin), 30/30 PASS**. It removes **16 of the 32** divides — note: the
task briefing said "the 32 divides"; the header's own accounting says 16 of
32, and the header is the measured source. Saving: 16 x 35–55 cyc =
**~560–880 cyc/sample** (STATIC body x MEASURED count; the header's older
25–180/call band predates the hand trace of the shipped libgcc `__divsf3`,
which is 30 straight-line FPU-assisted instructions — trust the trace).
The `eb_vcf_ladder` divide (8/sample, INFERRED count) is the same treatment
if it nulls: ~280–440 more.

### 1.4 The clamp calls are almost-free removals

newlib double `fmin`/`fmax` cost ~80–120 cycles EACH (three nested windowed
calls; STATIC trace) — one double clamp costs about one `__muldf3`. The pitch
path executes 4 double + 2 float clamps per voice per sample (~400–500
instr/voice, STATIC); the non-pitch float clamps are ~312 instr/sample
(INFERRED). Inline sign-tested compares remove nearly all of it. Small next
to 1.2, but it is money on the floor.

### 1.5 Call overhead and block processing were never measured on Xtensa

The engine renders per sample through per-voice function calls. The Xtensa
windowed ABI charges `entry`/`retw` traffic and window-overflow exceptions
(~20–40 cycles each, MODELED, explicitly EXCLUDED from every band above).
Blockwise rendering amortises this. No number exists in either direction —
this is an unmeasured lever, listed as such, not counted in any sum below.

### 1.6 The verdict of section 1

The prior "unreachable" is REFUTED as stated: it compared the wrong quantity
against the wrong budget and could not see the one dominant, removable cost
class. Nothing above proves the target reachable. Section 2 tries the
opposite attack.

---

## 2. THE CASE AGAINST "REACHABLE"

Now assume every lever in section 1 lands, and sum what is LEFT.

### 2.1 The honest post-fix sum

Start from the S3 base model (`data/s3_cost_table.md`: MEASURED host executed
counts x STATIC cross-compile ratios; the 14 rows reconcile with the
whole-DSP callgrind figure to 0.4%, so the row set is complete):

| item | instr/sample (nominal) | label |
|---|---|---|
| engine base, all modules, minus eb_pitch base | 14,856 | MODELED |
| pitch replacement (passing float-class candidate — **does not exist yet**) | 2,000–6,000 | MODELED-INFERRED (Dekker/triple-float caller cost band; unmeasured) |
| DCO divides after RECIP (16 remain) | ~500–900 | STATIC x MEASURED |
| VCF divide (8/sample, if not RECIP'd) | ~250–450 | STATIC x INFERRED |
| clamps after inlining | ~50 | INFERRED |
| **post-fix total** | **~17,700–22,300** | **MODELED** |

At the stated 1.0–1.5 cycles/instruction band (LX7 in-order, single-issue,
code and hot state in internal SRAM): **~17,700–33,400 cycles/sample.**

### 2.2 The gap, as a number

| against | post-fix gap |
|---|---|
| 5,000 (one core, hard) | **3.5x–6.7x OVER** |
| 3,500 (target) | 5.1x–9.5x over |
| **9,500 (two cores)** | **1.9x–3.5x OVER** |

**After every measured and staged lever is cashed, and after the reserve core
is spent, the model still says the engine is roughly 2x–3.5x too big.** That
is the number "reachable" has to answer, and today nothing measured answers
it.

### 2.3 What the remaining mass is

Post-fix, ~12,500 of the ~17,700 nominal (70%) is the per-voice
4x-oversampled path: `eb_dco_step4` + `eb_vcf_tick` + `eb_vcf_substep` +
`eb_decim_tick` + `eb_vcf_cv_tick`. FX are small (~1,200 total). And the
oversampled path is fenced on both sides:

* It is what makes the instrument sound like itself (`LEVERS.md`), and the
  accuracy standard gives no spectral fallback — any redesign must null at
  -100 dB against the port. No such candidate exists or is claimed.
* Even the FORBIDDEN move does not clearly fit: `LEVERS.md` MEASURED the
  no-oversampling floor at 10,002 host instr/sample. Scaled by the base-model
  ratio (~1.10) that is ~11,000 S3 instr nominal → **1.2x–1.7x over 9,500**
  at the c/i band. Destroying the sound would still not obviously close the
  gap. This is the strongest single fact on the "unreachable" side.

### 2.4 The model itself leans optimistic

The M7 precedent in this repo: the calibrated model was **2.2x BELOW the
silicon number**. Every figure in 2.1 is MODELED on an ISA pair the method
has never been validated on, window-overflow exceptions are excluded, and
the table assumes all hot code and state in internal SRAM — which collides
with 2.5. The uncertainty is not symmetric; it points the wrong way.

### 2.5 Memory is a second, independent wall

`EB_DELAY_LEN=65536` floats = **256 KB of the S3's 512 KB internal SRAM**
(STATIC), before reverb, chorus, voices, code, and stacks. If delay/reverb
lines spill to PSRAM, the 1.0–1.5 c/i band no longer holds for those
accesses at all. Nobody has measured S3 PSRAM streaming cost for this
engine. Unresolved, and not priced into any number above.

### 2.6 The verdict of section 2

"Reachable" is NOT established. On the current model, the engine misses the
two-core budget by ~2x–3.5x after every known fix, the residual mass has no
admissible lever measured, and the model's only precedent erred optimistic.

---

## 3. THE HONEST POSITION

* The target is **not proven unreachable**. The claim that said so used
  invalid numbers and 37% of the real budget.
* The target is **not proven reachable**. The corrected sum, with every
  staged lever counted as landed, still models 1.9x–3.5x over two cores.
* **Nothing S3-real has been executed.** Every total is MODELED. The single
  cheapest way to shrink the uncertainty band is now available in this
  container: the verified Espressif QEMU (esp32s3 machine boots, `-icount`
  accepted, no TCG plugins → CCOUNT method) yields MEASURED executed-Xtensa-
  instruction counts for the real code path — including every soft-float
  instruction actually run — though NOT cycles. Cycles need silicon.
* Do not tell the user "unreachable" again, and do not tell them "reachable."
  Tell them: **modeled 2x–3.5x over the full two-core budget after all known
  fixes, model unvalidated on this ISA, first real instruction count is one
  QEMU run away.**

---

## 4. WHERE THE AGENTS' NUMBERS DISAGREE, AND WHICH TO TRUST

| quantity | value A | value B | trust | why |
|---|---|---|---|---|
| pitch soft-double penalty | 33,728 instr/sample (full static bodies, `s3_cost_table.md`) | 18,200–22,300 (hand-traced common path, `softfloat_cost.md`) | **B** | the disassembly shows the static 105/116 include NaN/inf/denormal arms normal audio never executes; A's own caveat says its figure is a top bound. Quote A only as the static ceiling. |
| double fmin/fmax sites in eb_pitch | 2 (task briefing) | 4 + 2 float (relocation census) | **B** | MEASURED census beats a briefing. |
| RECIP saving | "the 32 divides" (task briefing) | 16 of 32 (`eb_dco.h`) | **B** | the header carries the measurement and the mechanism (only the pulse-phase divides are hoisted). |
| `__divsf3` cost/call | 25–180 cyc (`eb_dco.h`, older band) | 35–55 cyc (hand trace: 30 straight-line FPU-assisted instrs, serial chain) | **B** | the trace read the shipped libgcc body; the old band predates it. |
| host whole-DSP instr/sample | 14,871–14,927 (`COST_MEASURED.md`, row set) | 15,431–15,450 (post-step-1 / `LEVERS.md`) | either | different builds of the same engine, 3.5% apart, both MEASURED; no conclusion changes inside that spread. |
| two-core capacity | 7,000 (`VERDICT_ONE_CORE.md`, 2 x 3,500) | 9,500 (working figure) | **9,500** | 7,000 double-counts the 30% headroom on both cores; headroom is a target, not capacity. State it once. |

---

## 5. THE WORK PLAN, RANKED

Order: biggest measured/modeled saving first, each step with its accuracy
gate and the measurement that retires it. No step ships without its gate.

1. **Pitch precision candidate v3.** Compensated (error-free) or triple-float
   summation for the 13-term sum only; float clamp and row select stay
   (attribution says they contributed nothing); coefficients as a pre-split
   static table; clamps inlined.
   Saving: removes the ~21,000–30,000 MODELED cyc/sample soft-double path,
   replaced by an unmeasured 2,000–6,000 band. The largest lever by far.
   Gate: `tools/engineb/null_b.py`, FULL 30-scenario set, -100/-80. It must
   flip `DCO neg pitch sweep` (-95.8) and `idle chorus 44100` (-98.1); the
   probe (`data/pitch_precision_probe.py`) exists and is the harness.
   Retired by: the null run PLUS an S3 relocation census of the new object
   showing zero soft-double calls on the per-sample path.
2. **QEMU icount measurement of the whole engine.** Build the ~30-line SRAM
   harness described in the QEMU report; measure executed Xtensa
   instr/sample for 8 voices + FX, patch 20, before and after step 1.
   Saving: none — it converts the whole assessment from MODELED to
   MEASURED(instructions) and validates or destroys the ratio model.
   Gate: none (measurement, not a change). Caveat spoken every time: icount
   counts instructions, not cycles.
   Retired by: the run itself. Do this in parallel with step 1.
3. **EB_DCO_RECIP=1.** Already written, already MEASURED: -121.1 dB global /
   -115.2 dB block, 30/30 PASS, written budget in `eb_dco.h` per the
   accuracy standard.
   Saving: ~560–880 cyc/sample (16 of 32 divides).
   Gate: re-run the full null with the flag on (the recorded result), plus
   `plugin_check.py` unchanged scenarios.
   Retired by: QEMU delta count with the flag on/off.
4. **VCF ladder reciprocal.** Same treatment for the 1 divide site x 8/sample.
   Saving: ~280–440 cyc/sample MODELED.
   Gate: full null; if it does not hold -100 dB with margin, drop it — it is
   small.
   Retired by: QEMU delta.
5. **Inline the remaining clamps** (non-pitch fminf/fmaxf, ~312 instr/sample
   INFERRED). The inline compare must reproduce newlib's NaN handling
   exactly.
   Gate: null must stay EXACTLY 0 (this is a bit-exactness claim, not a
   -100 dB claim).
   Retired by: QEMU delta.
6. **Blockwise rendering / call-overhead reduction.** Unmeasured on Xtensa.
   Measure first (QEMU: per-call `entry`/`retw` and window-overflow traffic),
   then restructure only if the measurement says it pays.
   Gate: EXACTLY 0 — reordering arithmetic is not permitted, only batching
   calls; anything that changes a rounding is a new -100 dB candidate.
7. **The two-core split.** 4+4 voices, FX on the lighter core, or
   voices/FX. Capacity ~9,500. A split changes no arithmetic, so the gate is
   EXACTLY 0; the free-running lockstep rule holds across the boundary
   (ACCURACY_STANDARD rule 4), and the hand-off must be lock-free.
   Retired by: silicon CCOUNT on both cores under load.
8. **Silicon.** One function first (pins the c/i band and validates the
   model, the exact hole the M7 2.2x error fell through), then the engine.
   The standing rule holds: no optimisation argument survives contact with
   the first silicon number — re-rank this list when it exists.
9. **Memory plan for the 256 KB delay line** (parallel track, blocks
   shipping, not feasibility arithmetic): measure S3 PSRAM sequential
   streaming cost under QEMU/silicon; delay and reverb lines stream
   sequentially, voices and hot state must stay internal.
10. **Only if still over after 1–8: oversampled-path redesign.** It must
    null at -100 dB; no candidate exists; `LEVERS.md`'s measured floor says
    even deleting oversampling entirely (~11,000 S3 instr nominal) is
    1.2x–1.7x over two cores — so do not expect rescue here, expect at most
    a contribution.
11. **LAST RESORT — 6 voices** (`docs/trackb/CONSTRAINTS.md`: the only
    permitted compromise). Engine B's cost is linear in sounding voices
    (MEASURED on host: per-voice ≈ 1/8 of the voice-linear mass, ~1,089
    instr at the LEVERS floor — unlike the port's 91% idle floor). Two fewer
    voices saves ~25% of the voice path: ~4,000–5,200 nominal instr/sample
    off the post-fix band → **~13,500–17,100 → still 1.4x–2.7x over 9,500 on
    the current model.** On today's numbers the last resort does not close
    the gap by itself, which is exactly why it stays last.

---

## 6. SOURCES

* `docs/engineb/data/s3_cost_table.md` — per-function S3 model, penalties.
* `docs/engineb/data/softfloat_cost.md` — hand-traced helper common paths.
* `docs/engineb/data/pitch_precision_null.md` — the decision measurement.
* `engine_b/eb_dco.h` — RECIP option and its measured budget.
* `docs/engineb/LEVERS.md` — the superseded host-count verdict (kept: its
  build-vs-build RATIOS are measured and still valid).
* `docs/engineb/COST_MEASURED.md`, `docs/engineb/SCOPE.md`,
  `docs/engineb/VERDICT_ONE_CORE.md`, `docs/trackb/CONSTRAINTS.md`,
  `docs/trackb/ACCURACY_STANDARD.md`.
* Gate state 2026-08-03 (PROVEN, this session's agents): engine_b unit tests
  PASS; `null_b.py --module all --quick` 29/29 EXACTLY 0; `plugin_check.py
  --check-port --quick` 3/3 BIT-EXACT vs the plugin under Unicorn;
  `merge_shims.py --check` up to date. Feasibility work starts from a green
  board.
