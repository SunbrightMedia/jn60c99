# ENGINE B — MODULE M-REVERB: EXACT, AND IT FITS THE CYCLE BUDGET BUT NOT THE MEMORY BUDGET

2026-08-02. Files: `engine_b/eb_reverb.c`, `engine_b/eb_reverb.h`,
`engine_b/shim/reverb/master_render.c`, `tools/engineb/fx_reverb_split_proof.py`,
`tools/engineb/eb_reverb_cost.c`.
Specification: `docs/engineb/FX_REVERB.md`. `src/` was not modified.

## 0. Headline

| claim | number | label |
|---|---|---|
| `null_b.py --module reverb` | **30/30 EXACTLY 0** (0 differing samples; all 17 idle-prefix scenarios included) | MEASURED |
| split-buffer vs the plugin's masked 65,536-float line | **bit-exact both channels, both rates, 60,000 samples each, max_abs_err 0.0** | PROVEN (executed) |
| non-vacuity: a one-sample tap error | caught by **27 of 27** scenarios, worst −31.8 dB rel | MEASURED |
| cost, S3 internal SRAM | **812 cyc/sample**, band 614…1,297, **23 % of 3,500** (band 18–37 %) | MODELED on a MEASURED rho |
| host, executed | **524 instructions/sample**, rho **0.774** | MEASURED (callgrind) |
| libm / softfloat calls per sample | **0 / 0** on host, M7 and S3 | MEASURED-STATIC |
| memory | `sizeof(eb_reverb_state)` = **199,640 B** | MEASURED (sizeof) |
| … of which must go to PSRAM | **138,104 B** (the four long loop delays) | MEASURED |
| … of which may stay internal | **61,192 B** of rings + 344 B of scalars | MEASURED |

**The arithmetic is not the problem. The memory is.** 812 cycles is 23 % of the
whole-engine budget for the largest single FX block; 199,640 B is 100 % of the
200 KB internal budget on its own. That was already FX_REVERB.md's conclusion
and this module does not escape it — it only makes the split placeable.

## 1. What was built

`eb_reverb.c` is the whole master-stage reverb arm: the send scaling, the DC
block, the 2-pole input lowpass, the pre-delay with its modulated read, four
series allpasses, four parallel damped loops with two stereo taps each, the
output multiply chain, the mute crossfade, the lazy wipe and the tap latch.

Every floating-point operation is in the plugin's order and grouping. Nothing is
algebraically simplified and no coefficient is folded. Two orderings that look
like details and are not:

* the output chain is `(((tapsum · wet) · 16) · mute) · gate`, and
* the two stereo sums are in DIFFERENT orders — `L = ((B + A) + C) + D` and
  `R = ((A + B) + C) + D`. Float addition is not associative, so loop A is
  accumulated to a scalar and loop B is added on the correct side of it. Summing
  both channels in loop order is a plausible, wrong, and silent change.

### The one structural change: 13 rings instead of one masked line

The plugin addresses ONE 65,536-float line with a 16-bit mask — 262,144 B, over
the whole internal budget by itself, and unsplittable. Engine B gives each of
the 13 delay elements its own circular buffer, read at a depth and advanced by a
compare-and-add. That is 199,296 B of rings, and it is what makes the four long
loop delays separately placeable.

**That substitution is proven, not argued.** `fx_reverb_split_proof.py` runs the
split formulation, seeded from the engine's own masked line at t = 0, and
requires the stereo pair to be BIT-IDENTICAL to the engine's cells
101200/101216:

```
44100  bit_exact_L true  bit_exact_R true  max_abs_err 0.0  60,000 samples  (rms 0.702)
48000  bit_exact_L true  bit_exact_R true  max_abs_err 0.0  60,000 samples  (rms 1.204)
```

Non-vacuous: the compared signal is not zero at either rate.

**Read-then-write is load-bearing.** In the masked line a read at depth = the
element's length and a write at depth 0 are simply different indices. In a ring
of exactly that capacity they are the SAME SLOT, so every element reads its taps
before writing this sample's value. Getting that backwards is a one-sample error
in every element at once — which is the error class the `reverbtap` teeth case
now plants deliberately.

**The pre-delay ring is 416 samples longer than the pre-delay.** REVERB TYPE 5
modulates that one read, and the plugin's `phase · depth · (∓2048)` product is
negative for either sign of the phase (MEASURED), so the modulation only ever
reads DEEPER. Sizing that ring to the pre-delay alone would wrap TYPE 5's read
onto fresh data and still make a plausible noise.

### The one behavioural deviation, stated

The plugin's lazy wipe zeroes one 256-float stripe of its line per sample for
256 samples. Engine B zeroes all thirteen rings in one go at the moment the
countdown reaches zero. This is EQUIVALENT, not approximate: while the countdown
runs the tank arm does not execute at all (the mute has already reached 0, which
is the condition for the wipe to advance), so no ring is read between the first
stripe and the latch. The plugin also leaves 44 cells of its line un-wiped; they
sit beyond every tap and are never read.

The 2,756-sample post-recall silence (up to 2,500 mute samples + 256 wipe) and
the 0.0004/sample fade-in are reproduced exactly, because a warm patch change
otherwise cannot null.

## 2. The gate

`python3 tools/engineb/null_b.py --module reverb`

```
SELF-TEST: no module substituted (must be EXACTLY 0): PASS
engine B [reverb]: PASS (worst global EXACTLY 0 everywhere)
VERDICT: PASS
```

**30 of 30 scenarios, EXACTLY 0** — not "below −100 dB", zero differing samples.
That includes all 17 idle-prefix scenarios (idle chorus / unison / noise at 1,
48, 441, 4,410 and 44,100 samples, plus the two allocate→release→idle→reallocate
cases), which are the ones that would catch a lockstep error in the tank's
free-running state.

### Teeth — and what they measured

Four new cases were added to `null_b.py --teeth`, all planted inside
`engine_b/eb_reverb.c` and built with the reverb shim in the library, because a
mutation the build cannot reach measures nothing.

| planted | size | result | what it establishes |
|---|---|---|---|
| CLEAN CONTROL `[reverb]` | — | EXACTLY 0 | the module is not being bypassed |
| `reverbtap` | one output tap one sample early | **FAIL, 27/27 scenarios**, −64.0…−31.8 dB | the null is NON-VACUOUS: the reverb is audible in every scenario, and the smallest possible addressing error is caught everywhere |
| `reverbwet` | tank output ×(1 + 6.25e−5) | PASS at **−100.5 dB** | calibration, lower side |
| `reverbwet10` | tank output ×(1 + 6.25e−4) | FAIL at −80.5 dB | calibration, upper side |
| `reverbskip` | skip the tank when \|input\| < 1e−6 | FAIL | the LOCKSTEP class: a ringing tank may not be skipped because its input went quiet |

The `reverbwet` pair is the number worth carrying: **an error in the tank
arrives at the gate about 20 dB quieter than the same relative error on the
whole output**, so this module is effectively gated at ~6e−5 of its OWN signal
rather than at 1e−5 of the mix. The gate still bites two orders of magnitude
finer than anything audible, but the leverage is now measured instead of
assumed.

**Two teeth cases were wrong on their first run and were fixed by running
them.** `reverbwet` was originally declared must-FAIL and landed at −100.5 dB, a
half-decibel under the gate — reported as a teeth failure, correctly, and
converted into the calibration pair above. `reverbskip` originally skipped on
`x == 0.0f` and produced NO residual at all: once the tank is running its input
is never bit-zero, so the mutation was unreachable and the case measured
nothing. The threshold form reaches it.

## 3. Cost

MEASURED first. `tools/engineb/eb_reverb_cost.c` drives the module with the
MEASURED REVERB TYPE 2 coefficient set at 48 kHz (the longest tap set of the six
types, so the worst case for memory), and `cost.py density` takes a two-point
callgrind slope so seeding and the wipe cancel:

```
eb_reverb_process   524 dynamic host instr/sample   678 static   rho 0.774   MEASURED
```

That rho is MEASURED for this function, not transferred from
`juno_voice_render`, and it is what the cycle model below is run with.

| target | tier | cycles/sample | % of 3,500 | label |
|---|---|---|---|---|
| x86-64 host | — | 210 (157…422) | — | MODELED on MEASURED counts |
| Cortex-M7 | TCM | 728 (453…1,328) | 21 % | MODELED |
| **ESP32-S3** | **internal SRAM** | **812 (614…1,297)** | **23 % (18–37 %)** | **MODELED, ±2× — no S3 silicon exists** |
| ESP32-S3 | all-PSRAM, uncached | 15,830 (8,160…31,231) | 452 % | MODELED-UNVALIDATED, a bound, not a prediction |

Static instruction mix on the S3: 757 total, 117 FP arithmetic, 135 FP memory,
263 integer ALU, 190 integer memory, 34 branches, **0 libm and 0 soft-float**.
The last is the one that had to be checked: the LX7 has no double unit and the
sealed port emits 168 soft-float helper calls per sample. This module emits
none.

**The realistic PSRAM figure, and why the 15,830 row is not it.** Only the four
long loop delays go to PSRAM. Counted from the code, that is **16 PSRAM accesses
per sample** — per loop, one recirculation read, two stereo tap reads and one
write. Each is its own sequential stream advancing exactly one float per sample,
so a 32-byte line serves 8 samples and the expected miss rate is 2 lines/sample,
not 16 accesses. At the rig's 30…120 cycle line-fill guess that is **60…240
extra cycles/sample**, i.e. **674…1,537 all in, nominal ~900**. That arithmetic
is MODELED on an UNVALIDATED latency tier and rests on 16 streams not
conflict-missing against each other or against the voices. **It is the first
thing to measure on real S3 silicon.**

**Against the first-guess 500-cycle reverb budget the module is 1.6× over**
(812 nominal, internal SRAM). FX_REVERB.md already recommended raising that line
to ~700 from the candidate's numbers; the built module says **~850, and ~950 if
the long delays are in PSRAM and stream as expected**. `docs/engineb/SCOPE.md`
should carry that instead of 500.

**Where the extra cost is, honestly.** The plugin's own reverb arm executes 298
host instructions/sample (MEASURED, FX_REVERB.md §8); the earlier sketch
`fx_reverb_cand.c` measured 363; this module measures 524. The difference is
paid for two things and both are required:

1. **13 compare-and-add wraps instead of one 16-bit AND.** That is the price of
   splitting the line, and the split is what makes 138 KB movable to PSRAM.
2. **Runtime tap depths.** `s->dep[]` and `s->ot[][]` are loaded from state, not
   compile-time constants, because REVERB TYPE and PRE DELAY change them at
   recall. Freezing them would be worth roughly 20 loads/sample and would
   violate the project's rule that recall must be correct for ANY preset value —
   it is not offered as an option.

## 4. Memory — the decision this module forces

MEASURED by `sizeof`:

| group | bytes | placement |
|---|---|---|
| pre-delay (5,216) + 4 series allpasses + 4 loop allpasses | **61,192** | internal SRAM |
| 4 long loop delays (7,165 / 7,615 / 9,755 / 9,991 floats) | **138,104** | **PSRAM** |
| scalars (filter, damper, LFO, mute, latched taps, depths, indices) | **344** | internal |
| `sizeof(eb_reverb_state)` | **199,640** | |
| `sizeof(eb_reverb_cfg)` | 108 | |

Capacities are compile-time `EB_REV_CAP_*`, one per element, at the 48 kHz worst
case over REVERB TYPE 0…5 with the maximum PRE DELAY. 44.1 kHz is strictly
smaller in every element, so this build covers both gate rates. A latched depth
that does not fit is not silently wrapped: `overrun` is set and the shim aborts.

The four long delays are the LAST members of the struct precisely so a linker
section can move them without touching the DSP.

**This does not fit a 200 KB internal budget, and no cheaper exact version
exists.** The element lengths are the plugin's own tap table; they are what the
reverb IS. The only levers, all of which change the sound and are therefore NOT
taken:

| lever | saving | measured cost |
|---|---|---|
| run the tank at 44.1 kHz instead of 48 | 113,772 B (the 48 kHz reverb is 2.08× longer, MEASURED) | resamples the whole send path; not a null at any threshold |
| support only REVERB TYPE 0 | 172,440 B | 5 of 6 types gone; the factory bank uses several |
| cap PRE DELAY at its default | 15,360 B | recall wrong for any preset with PRE DELAY > 20 |
| 16-bit samples in the long delays | 69,052 B | ~90 dB of dynamic range in the tank; fails the −100 dB standard by construction |

The honest statement is the one FX_REVERB.md already made: **the reverb must
have PSRAM.** What this module adds is that the PSRAM requirement is now exactly
138,104 B in four sequential streams, and the remaining 61,536 B is internal.

## 5. What is NOT closed

1. **No S3 silicon.** Every cycle figure here is MODELED. The PSRAM streaming
   assumption is the largest single uncertainty in the module.
2. **The recall side is not written.** This module consumes a latched 34-int tap
   table and a coefficient set; producing them from the patch bytes (the send
   LUT, the joint TYPE×TIME damper table, the PRE DELAY closed form — all
   MEASURED and tabulated in `docs/engineb/data/fx_reverb.npz`) belongs to
   MODULE PARAM and is not done.
3. **REVERB TYPE 5's modulated read is never exercised by the gate.** No factory
   scenario in the null set selects TYPE 5, so the modulated pre-delay path is
   correct by the split proof's construction and by the 416-sample sizing, but
   is NOT covered by a scenario. A TYPE-5 scenario is owed before that path is
   called gated.
4. **`--module all`** is the acceptance point and cannot run until every module
   exists; this is still the FAST proxy comparison against `src/`, and `src/` is
   never the authority. The B-vs-plugin gate (`plugin_check.py`) is what retires
   the claim.
