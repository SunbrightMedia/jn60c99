# Cold-start DCO phase alignment — why unison patches played hot AND dark

**Status: ROOT CAUSE FOUND AND FIXED (2026-07-28).** This is the defect behind the
user's report after the assigner fix landed: *"the starting note is peaking
intensely, the synth peaks in a bunch of other places, the filter sounds even
quieter."* All three are one bug, and it is a **delivery-lifecycle** bug, not an
engine bug.

## One paragraph

The engine constructor arms **every voice's DCO retrigger latch** (aux Array A,
`101504 + v*32`), and each voice consumes it on its first rendered sample. So a note
played on a **cold** engine starts all 8 DCOs *exactly in phase*. In POLY that is
harmless — one voice sounds. In **UNISON** all 8 voices sound the same note, so a
phase-aligned stack sums **coherently**: the fundamental adds ×8 while the upper
partials, which the per-voice detune spread scatters, do not. The result is a note
that is both far too loud and far too dark. Per-voice **CONDITION** analog scatter
detunes the voices, so over the first few seconds of free-running they drift apart
and the sum becomes the ordinary incoherent one. A real DAW instance renders
continuously from activation, so by the time a human plays a note it has *always*
left this state. The web app was presenting it.

## The measurement (PROVEN, `probes/hostpath/`)

`warm_curve.py` — peak and spectral centroid vs pre-note free-run time, note 60
vel 100 @ 44.1 kHz, Chillwave 3 "BS Solid":

| idle before note | peak | centroid |
|---|---|---|
| 0.0 s (cold) | 1.736 | 235 Hz |
| 1.0 s | 1.504 | 313 Hz |
| 1.5 s (the old warmup) | 1.245 | 413 Hz |
| 2.0 s | 0.891 | 486 Hz |
| 4.0 s | 0.810 | 487 Hz |

`warm_all_unison.py` — cold vs 4 s warm, **every** ASSIGN=2 patch in both banks,
with POLY patches as the control:

| patch | peak cold → warm | centroid cold → warm | |
|---|---|---|---|
| Chillwave 3 BS Solid | 1.736 → **0.810** | 235 → **487 Hz** | UNISON |
| Chillwave 4 BS Glide | 1.981 → **0.931** | 128 → **858 Hz** | UNISON |
| Chillwave 5 | 1.088 → 0.728 | 231 → 901 Hz | UNISON |
| Chillwave 12 | 1.849 → 0.782 | 206 → 421 Hz | UNISON |
| Chillwave 15 | 1.445 → 0.684 | 678 → 1056 Hz | UNISON |
| Chillwave 35 | 0.088 → 0.590 | 246 → 3160 Hz | UNISON |
| factory 61 | 0.527 → 0.202 | 830 → 1488 Hz | UNISON |
| Chillwave 0 / 1 | 0.233 → 0.181 / 0.126 → 0.140 | ~flat | poly (control) |
| factory 0 / 1 / 2 | ~flat | ~flat | poly (control) |

**The poly control is what makes this non-vacuous:** poly patches barely move, so the
effect is specifically the unison voice stack, not some global convergence.

Every low-numbered Chillwave slot the user would reach for (3, 4, 5, 12, 15) is
ASSIGN=2, and cold they play **~2× too hot and 2–6× too dark**.

## Why this is the web app's bug and NOT an engine defect

The port is proven bit-exact to the plugin in **both** conditions, so the cold→warm
change is necessarily identical inside the plugin itself:

* **cold** — `recall_render_ab` 57/57, `assigner_ab` 28/28 (+16/16 Chillwave), all
  driven from a freshly built engine;
* **warm** — `renderstruct_ab`'s warm-lifecycle A/B (idle → apply on a running
  engine → idle → note) is bit-exact.

So no engine, recall or DSP code may change. What was wrong is *which state the web
app hands the player*. The plugin's own constructor leaves the voices aligned too —
the difference is that nobody plays a DAW instance within 2 s of instantiating it.

## The fix

`gui/web/index.html`: the boot warm-up was **1.5 s**, chosen when the only thing it
had to settle was the ~190 smoothed control cells. It is now **4 s**, which covers
the slowest patch measured (BS Glide settles ~4 s). One-time boot cost; later patch
changes keep the warmed cells (recall uses changed-byte delta replication and never
rewrites the phase state).

The **monitor fader** default is now derived from the measured worst **warm** peak
across all 128 patches in both banks rather than the cold one (`warm_worst_peak.py`)
— see `gui/web/index.html` for the number and its justification. It remains a
delivery-only control occupying the DAW-fader role; the engine is untouched.

## Related: the velocity family is no longer INFERRED (HOSTPATH scope STEP 1)

`probes/hostpath/system_velocity_defaults.py` reads the plugin's own descriptor
table (rva `0x98c040 + 16*idx`) against its own name table (rva `0x9a0030`):

| idx | the plugin's own name | range | default |
|---|---|---|---|
| 12 | `Keyboard Velocity SW` | 0..1 | **0 = OFF** |
| 13 | `Keyboard Fixed Velocity` | 0..126 | 126 |
| 14 | `Keyboard Velocity Curve` | 0..2 | **1** |
| 15 | `Keyboard Velocity Offset` | −10..10 | **0** |
| 18 | `Local SW` | 0..2 | 1 |
| 20 | `MASTER TUNE` | −100..100 | 0 |

Each range matches its own name (a 0..1 "SW", a ±10 "Offset"), which self-validates
that this is the right table. Consequences:

* The port's `kbd_velocity_sw` default of **OFF** — until now the last INFERRED item
  in the whole note path — is **READ and correct**. A fresh instance really does
  force every note to the constant 100 that the three decompiled wrapper sites
  hardcode.
* **Velocity Curve and Velocity Offset are identity at their defaults** (curve 1 =
  the middle of 0..2, offset 0), so the port not modelling them cannot affect a
  default instance. Their laws stay underived; that is now a bounded, named residual
  rather than an unknown, and only matters if those SYSTEM settings are ever exposed.
* Note `Keyboard Fixed Velocity` defaults to 126, **not** the 100 the SW-OFF rule
  substitutes — so that constant is genuinely hardcoded in the wrapper and is not
  sourced from this setting. The three independent decomp sites already said so.

Caveat, recorded honestly: `CLAUDE.md` states the SYSTEM param DB lives at rva
`0x5EC040 + 16*id`. Dumping that region yields x86 opcode bytes, not descriptors, so
that note is wrong — the usable table is the engine descriptor DB above.

## Methodology note

This is a sixth entry for the protocol-error list in `docs/P112_FINDINGS.md` §8:
**a gate that only ever exercises one lifecycle phase cannot see a defect that lives
in which phase the user is placed in.** Every render gate was bit-exact and every one
of them was right; the port and the plugin simply agreed on a state the user should
never have been listening to. When a user reports something the gates say is
impossible, ask *which lifecycle state* they are hearing, not only *which values*.
