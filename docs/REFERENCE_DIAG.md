# Reference-render diagnosis — SQ Dynamic ARPG

A render from the **real plugin** was provided as a diagnostic oracle ONLY (fixes
must come from the decompiled code, never by fitting to the render). This records
what the investigation actually found.

## KEY CORRECTION (supersedes earlier numbers)

The earlier "ours 5147 Hz vs reference 3428 Hz" centroids were a **measurement
artifact** (inconsistent windowing/tool). Re-measuring every file with one
consistent tool (Hann-windowed power spectrum, L channel, 0.6–2.5 s):

| Render | spectral centroid | rolloff 85% |
|---|--:|--:|
| **Reference (original plugin)** | **1187 Hz** | 1572 Hz |
| Ours — 22-param map (pre-fix) | 1687 Hz | — |
| Ours — 24-param map (+pulse osc + VCA tone) | **1417 Hz** | 1594 Hz |

So the port was only ~1.4× too bright (not at multi-kHz), and the proven binding
additions moved it to ~1.2× and **matched the rolloff** (1594 vs 1572). The three
uploaded reference WAVs are byte-identical (same MD5) — one reference, not three.

## The decisive finding: the loader is CORRECT, the gap is unmapped params

`src/captured_patch.c` (`juno_overlay_patch`) is **NOT** the SQ ARPG patch — it is
**bank record 0 "SY Poly Synth"**, the live-captured running patch (its
`state_dump/meta.txt` patch-name was never filled in). Proven by loading all 64
bank records through `juno_preset_load` and matching voice-0 against the capture:
**record 0 matches 23/24** mapped params (only BEND RANGE off — see below).

⇒ The bank decode + byte→step identity + DB→engine bindings are **validated against
real ground truth**. The "doesn't sound like the original" was therefore NOT a
decode bug. The real gap: the loader applied only **22 of ~61 panel-exposed**
params; the rest stayed at init defaults for **every** preset (a global gap, not a
per-preset one).

### Proven new bindings (capture-validated, record-0 oracle)

Method: for a candidate `db→{off,tid}`, the binding is proven iff
`LUT_tid(rec0_decoded_step) == captured[off]` (the same standard as the original 22).

| DB | param | engine off | tid | evidence |
|--:|---|--:|--:|---|
| 770 | DCO PWM (pulse) LEVEL | 4208 (`JU OSC Sqr Lev`) | 54 | **non-trivial proof**: step 140 → `0x3f11e430` exact; structural (3rd osc mix level, stride-16 between Saw 4192 / Sub 4224, same tid54); consumed in `voice_render.c:1091` |
| 793 | VCA TONE | 9584 (`AMP TONE`) | 21 | name match + tid + matches capture; consumed `voice_render.c:1484/1580` |

Impact: SQ ARPG has **PULSE LEVEL = 255** (full on) — previously rendered at the
default ~half, so the whole pulse oscillator was under-mixed. Adding it is what
moved the centroid 1687 → 1417 (toward the 1187 reference).

## Still open (the remaining ~1.2× brightness / body)

- **FX send levels** DB794 EFFECT DEPTH (=255), DB795 REVERB LEVEL (=195),
  DB796 DELAY LEVEL (=96), DB797 DELAY TIME (=125) are non-default in SQ ARPG but
  unmapped — these live in the master/FX section (not the voice registry) and need
  the DB→engine bridge traced there (in progress). The current render hardcodes
  reverb activation at decay 1.0 with no patch send level.
- **BEND RANGE** (DB801→4128, tid21) is the lone failing voice binding (loader
  `0x3db162c6` vs capture `0x3e2cacad`) — irrelevant without pitch-bend, but a real
  decode/position bug to fix (the inversion wants step 171; loader reads 11).
- "Weird pitch drift": within-note pitch is stable; the perceived motion is the
  (bit-exact) BBD chorus vibrato plus saw+pulse+sub beating — expected analog-ish
  behavior, not a transcription bug.

## Rule
Use the reference to *characterize the target only*. Every fix traces to the
decompiled code / bank data, validated against the record-0 capture. Do not tune
constants to match the render.
