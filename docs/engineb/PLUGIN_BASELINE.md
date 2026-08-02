# PLUGIN BASELINE — every written module, checked against the authority

**2026-08-02. Step 1 of the user's own sequence: check what we HAVE written
against the plugin, before changing anything.**

## Result

All nine modules, all six scenarios each, against the **plugin binary executed
under Unicorn** — not against the port:

| module | vs the PLUGIN |
|---|---|
| dco | **6/6 BIT-EXACT** |
| vcf_ladder | **6/6 BIT-EXACT** |
| env | **6/6 BIT-EXACT** |
| chorus | **6/6 BIT-EXACT** |
| delay | **6/6 BIT-EXACT** |
| reverb | **6/6 BIT-EXACT** |
| vca_hpf | **6/6 BIT-EXACT** |
| vcf_cv | **6/6 BIT-EXACT** |
| pwm_cv | **6/6 BIT-EXACT** |

**54 comparisons, zero failures, zero non-zero residuals.** Not "under −100 dB" —
bit-exact.

Scenarios: pluck POLY (patch 5), MONO retrig (15), UNISON pile (61), chorus pad
(20), delay keys (2), DCO noise (32).

## Why this baseline matters more than it looks

Until now every engine B module was proven against **`src/`**, which is a proxy.
The user's objection was exact: *"that sounds dangerous if there are ANY holes in
the port."* There was one — UNISON diverged from the plugin after a single idle
sample, on 2 of 64 factory patches, and every gate in `make verify` said green
because all 57 of its patches are driven cold.

That hole is fixed, and this table is the first evidence that **no other one is
hiding underneath engine B's results**. Every module is now anchored to the
binary, not to our transcription of it.

## What this baseline does NOT cover, stated plainly

* **Eleven scenarios, not thirty.** The Unicorn oracle costs ~12 s of wall time per
  scenario, so `plugin_check` is deliberately a small set of authoritative
  points, not a sweep. The 30-scenario set still runs against `src/`.
* **44,100 Hz only.** 48 kHz is the delivery rate and is not covered here.
* ~~**No idle-prefix scenarios.**~~ **CLOSED 2026-08-02.** Five idle-prefix
  variants were added (`pluck POLY idle` 1,777 frames, `chorus pad idle` 6,113,
  `delay keys idle` 4,391, `DCO noise idle` 953, `UNISON 1-idle` 1). The prefix
  lengths are unequal and mutually non-multiple on purpose, because the chorus
  LFO, the noise LFSR and the DCO phase free-run at different periods and an
  aligned prefix can be silently harmless. MEASURED against the authority:
  `--check-port` **11/11 BIT-EXACT** and `--module all` **11/11 BIT-EXACT**.
  `UNISON 1-idle` is the regression guard for the retrigger-latch bug — it is
  the row that was red before the fix, and it is the cheapest in the set.
* **Delay TYPES 1–5, EFFECT TYPE 4 (flanger), and REVERB TYPE 5** are not written
  or not selected by any scenario.
* The unwritten blocks — decimator, noise SVF, CV conditioning, voice summing —
  are obviously not covered.

## The immediate next thing

**Extend `plugin_check` to 48,000 Hz.** 48 kHz is the delivery rate for engine B
and no authoritative comparison has ever been made at it. That is now the
largest uncovered surface in this table.
