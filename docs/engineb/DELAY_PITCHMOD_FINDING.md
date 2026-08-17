# The delay pitch-hoist defect, and what the blind battery hid
2026-08-17. All numbers PROVEN(executed) unless labelled otherwise.

## What was wrong
`make engineb` failed its CLEAN CONTROL: the composite `[engine_all]` did not
null, on 6 scenarios.

| scenario | patch | delay type | residual (before) |
|---|---|---|---|
| pluck POLY | 5 | 5 | 2.1 dB rel |
| MONO glide | 5 | 5 | -0.9 dB rel |
| DCO neg pitch sweep | 5 | 5 | 0.1 dB rel |
| DCO neg wrap + PWM clamp | 5 | 5 | -0.2 dB rel |
| DELAY type 2 | 11 | 2 | -4.6 dB rel |
| DELAY type 3 | 19 | 3 | -0.9 dB rel |

The gate is `<= -100 dB rel`. A residual near 0 dB rel means the difference is
about as loud as the signal. The scenario NAMES mislead: the common factor is
not "DCO" or "glide", it is the DELAY ARM. Isolation proved it -- `delay_t23`
alone gave exactly the 2 type-2/3 rows, `delay_t5` alone gave exactly the 4
patch-5 rows, their union is the composite's 6, and `dco` and `voices` were
EXACTLY 0 on their own.

## Cause
`7936d3b` hoisted a per-sample 13-term DOUBLE-precision pitch call out of the
TYPE 2/3 and TYPE 5 delay ticks into a coef field, `pitchmod_pre`. The field is
computed in `eb_master_coefs_build()`. It has three builders:

| builder | filled it before | why |
|---|---|---|
| `eb_master_coefs.c` | yes | the hoist was written here |
| `shim/delay_t23/master_render.c` | NO | builds the struct cell by cell |
| `shim/delay_t5/master_render.c` | NO | same |

The structs are function-level `static`, so the unassigned field was `0.0f` for
the life of the process: the delay's pitch modulation was frozen at zero.

## Why it survived eight days
Two independent failures, and either alone would have caught it.

1. **The hoist was proven on the one build that fills the field.** `7936d3b`'s
   proof line is "trunk null --module standalone EXACTLY 0", and `standalone`
   is the only shim that calls `eb_master_coefs_build`. Playbook 53.
2. **The battery had not run.** The `voiceidleskip` tooth's anchor stopped
   matching in 73a7657 and `_plant()` asserted; `foundation.sh` step 4 calls
   `die`, so steps 4b-8 -- including every per-module null -- had not executed
   since 2026-08-09. Playbook 54.

Note the blame correction: the guard gained `|| v >= EB_SLOTS` in **73a7657**
(2026-08-09), not 61e3a2c. `git log -S "v >= EB_SLOTS" -- engine_b/eb_render.c`
returns exactly one commit. Commit 3ad0b12's message says 61e3a2c and is wrong.

## Fix
`engine_b/eb_delay_pitchmod.h` -- one function, called by all three builders.
Both arms used the IDENTICAL expression on different operands, so copying it
per builder is what allowed one to be forgotten. The expression is
character-for-character as it was; `-ffp-contract=off` remains load-bearing.

PROVEN after the fix (`null_b --quick`, EXACTLY 0 everywhere, zero non-exact
residuals):

| module | before | after |
|---|---|---|
| `standalone` | PASS | PASS -- the CONTROL. It was already green, so it is what could refute the refactor. Moving the expression changed no bit. |
| `delay_t23` | FAIL (2) | PASS |
| `delay_t5` | FAIL (4) | PASS |
| `engine_all` | FAIL (6) | PASS |
| `lfo` | not run | PASS (run to test a separate question, below) |

Fork side: `tools/engineb/devrecall_gate.py --quick` -> **DEVRECALL GATE: PASS**,
with its own teeth CAUGHT, including "omit the delay route latch".

## The defect class, swept
An audit of all 30 coef structs (763 fields; 32 derived in 10 structs) found
`pitchmod_pre` was the ONLY derived field a shim ever failed to fill. The
reason is structural, not luck: every other derived value is produced inside a
module-owned setter (`eb_env_set_adsr`, `eb_dco_set_pitch`, `eb_glide_prepare`,
`ebsh_load_coef`, ...) that a shim cannot fill the struct without calling.
`pitchmod_pre` was the one written as a bare inline expression, so each builder
had to re-type it. The fix gives it the same shape as the rest.

LATENT, not broken today, recorded so the next hoist does not repeat this:
- `eb_dco_coef.rm1` / `.rp1` -- assigned only in `eb_dco_set_pitch`.
  `eb_render.c:697-706` assigns the per-sample half field by field and
  re-derives `pulse_h`/`saw_h`/`sub_h` with a comment naming exactly this
  hazard, then stops short of `rm1`/`rp1`.
- `eb_dly_t4_coef` has no `pitchmod_pre`: the TYPE 4 arm's equivalent call is
  NOT yet hoisted (`eb_dly_t4.c:112`). If it is hoisted, it inherits this
  defect unless it uses the shared helper.

## Still red, and NOT engine B's DSP
`make engineb` remains RED at step 4 on two HARNESS teeth. Both are
pre-existing, both were unobservable while the battery aborted, and neither is
an engine B divergence:

1. `out:lfo:(1.0f + 1e-7f)` is a PASS-side probe that got CAUGHT, at -93.3 dB
   in 1 scenario. It is not a module divergence: `--module lfo` is EXACTLY 0
   everywhere. One ULP of `1.0f` is ~1.19e-7, so `1e-7` already IS one ULP and
   anything smaller rounds to `1.0f` and perturbs nothing. **A pass-side probe
   is therefore impossible for this module**, exactly as already recorded for
   `pitch`, `glide`, `pwm_cv`, `dcoprep` and `cvgate`. The fix is to move `lfo`
   into that fail-only list WITH the measurement, not to move the gate
   (precedent: the 2026-08-02 reverb re-calibration, `null_b.py:947-960`).
2. The static coefficient audit does not refuse a planted cell 4736 -- "the
   audit is blind". Untouched by this work; owed.

## What the repaired teeth then exposed (2026-08-17, later the same day)
With both teeth fixed, `make engineb` ran past step 4 for the first time in
eight days and reached **step 8**. Steps 4-7 are GREEN: teeth PASS, composite
regenerated, and ALL 30 per-module nulls EXACTLY 0. It now stops on ledger
integrity, and what it stopped on is worth more than the stop.

**Two rows re-emitted cleanly** (`noise_lfsr`, `triangle`); their old rows are
SUPERSEDED. **Two could not** (`chorus`, `env`), both refused with:

    parsed 36 scenario lines but null_ab.SCEN has 30

That is not a counting bug. `ledger.scenario_fingerprint()` hashes
`null_ab.SCEN` (30 tags), but engine B's null runs `null_b.BASE_SCEN`, which is
those 30 PLUS six engine-B-only scenarios:

    DELAY type 2 | DELAY type 3 | DELAY type 4 (synthetic)
    EFFECT type 0 (synthetic) | EFFECT type 1 (arp) | EFFECT type 4 (synthetic)

So every engine B null row's fingerprint describes a scenario set SIX SMALLER
than the one actually run -- and the six missing ones are the delay and effect
arms, precisely where today's defect lived. The function's own docstring states
the standard it is failing: "`26/26 EXACTLY 0` was true when there were 26
scenarios and is a lie now that there are 30."

OWED, and deliberately NOT done here: point the fingerprint at the scenario set
actually executed. It is a small edit with a large tail -- it changes the
fingerprint of EVERY row, marking all 18 stale and requiring a full
`ledger.py emit --all`, which re-runs every proof. That is a scoped piece of
work, not a side effect to slip into an unrelated fix.

Standing count of pre-existing harness defects this one repair exposed: the
blind tooth, the vacuous coefficient audit, the unreachable lfo pass probe, the
48 kHz brackets judged at 44.1 kHz, and this fingerprint. None was an engine B
audio divergence; all five were the verification failing to verify.
