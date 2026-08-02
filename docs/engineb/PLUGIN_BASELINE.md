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

* **Six scenarios, not thirty.** The Unicorn oracle costs ~12 s of wall time per
  scenario, so `plugin_check` is deliberately a small set of authoritative
  points, not a sweep. The 30-scenario set still runs against `src/`.
* **44,100 Hz only.** 48 kHz is the delivery rate and is not covered here.
* **No idle-prefix scenarios.** The UNISON bug needed exactly one idle sample to
  appear, and `plugin_check`'s six scenarios are cold. **This is the same
  structural blind spot that hid the bug in the first place**, now present in the
  tool built to catch it. It must be closed.
* **Delay TYPES 1–5, EFFECT TYPE 4 (flanger), and REVERB TYPE 5** are not written
  or not selected by any scenario.
* The unwritten blocks — decimator, noise SVF, CV conditioning, voice summing —
  are obviously not covered.

## The immediate next thing

Add idle-prefix scenarios to `plugin_check`. A tool whose purpose is to catch
what the cold gates miss should not itself be cold-only.
