# DECISION: OPTION B — a purpose-written engine, held to the sealed one

**User, 2026-08-01, verbatim:**

> "why are you CONTINUING TO MAKE C AN OPTION????? hardware compatibility was
> the GOAL FROM THE START"
> "we obviously need B. but it has to be accurate to all hell"

Correct, and the record agrees: `GOAL.md` has said "portable to a Teensy 4.1
later" since the beginning. Hardware was never a stretch goal. **"Ship the
browser version and stop" is struck and is not to be offered again.**

## What B is

A **new** engine, written to be fast, whose every module is derived from and
gated against the **sealed bit-exact engine as an oracle**. Not a transcription
of the plugin's instruction sequence — that is what `src/` already is, and it is
80× too slow. A JUNO-60 built the way a JUNO-60 should be built, and then proven
to sound like the sealed one.

`src/` does not change. It stops being the shipping engine on hardware and
becomes the **reference instrument**: it can generate unlimited exact reference
audio for any patch, any parameter, any sequence. That is a far better position
than starting from a datasheet, and it is why B is credible.

## Why B can actually fit, when the port cannot

The port's cost is not arithmetic, it is **memory traffic**: 9,850 accesses per
sample at ~68 cycles each, because a transcribed engine round-trips every
intermediate through a flat 12 MB array. 620 distinct cells per voice per
sample, each on its own 16-byte boundary.

A purpose-written voice holds its state in registers and a small struct. The
per-sample working set drops from 85 KB of cache lines to a few hundred bytes.

Order-of-magnitude budget (ESTIMATE, to be measured, not a promise):

| | cycles/sample |
|---|---|
| budget @48 kHz, 400 MHz | **8,333** |
| 8 voices at ~300 cyc/voice | 2,400 |
| chorus + delay + reverb | 1,500–2,500 |
| **total** | **~4,000–5,000** |

That fits, with margin, and it fits *because* the 98% idle floor is an artefact
of transcribed code — not a property of the synthesizer.

## "Accurate to all hell" — what the gate actually enforces

A rewritten engine **cannot** sample-null everywhere, and pretending otherwise
would set an impossible gate and cause thrashing. The honest standard is
layered by what is deterministic:

**Tier 1 — deterministic paths: sample-domain null, tight.**
DCO, HPF, VCF, VCA, envelopes, key scaling, all parameter laws. Given the same
patch and the same note events these are fully determined, so the candidate must
null against the oracle in the sample domain. Target **≤ −100 dB** global RMS
*and* worst-1024-block — tighter than the current −90 dB gate, which was
measured to ignore errors up to ~200 ULP/sample.

**Tier 2 — free-running and stochastic paths: statistical + spectral.**
Analog noise (an autonomous LFSR), chorus/BBD LFO phase, and the per-voice
CONDITION scatter cannot be phase-reproduced by a different implementation. For
these the standard is: matching spectrum (long-window average within a stated
dB-per-band tolerance), matching level, matching modulation rate and depth, and
matching statistical distribution — with the tolerance stated as a number, not
"sounds fine".

**Tier 3 — parameter laws: exhaustive, not sampled.**
Every front-panel parameter, every byte 0–255, every rate. The sealed engine can
answer all 256 values for every parameter; there is no excuse for sampling.
This is where "accurate to all hell" is actually won or lost, because it is what
makes patch 37 sound right and not just patch 5.

**Tier 4 — the whole bank.**
All 64 factory patches plus the user's Chillwave bank, played through real note
sequences in every voice-assign mode, against the oracle. The existing
`null_ab.py --all` shape: 7 scenarios + 384 full-bank + 24 fuzz.

**Never by ear. Never a user A/B.** That rule does not relax for B.

## The rule that does not change

No module may be written behind a blind gate. `docs/trackb/MODULE_ORDER.md`
stands: the DCOs are currently 5/12 observable and are BLOCKED until the
scenario set reaches them. For B this matters more, not less — B rewrites
everything, so every module needs its gate open first.

## Order of work

1. **Scenario closure** — open the blind gates, DCOs first. Already in progress.
2. **Behavioural extraction** — for each module, use the sealed engine as an
   oracle to derive WHAT it computes (transfer curves, coefficient laws, filter
   topology, envelope shapes) rather than HOW the binary computes it. The
   blueprints in `docs/trackb/{DCO,VCF,ENV,MOD,CELLMAP}.md` are the starting
   point; the oracle settles every question they leave open.
3. **Implement + gate module by module**, cheapest-and-most-observable first.
4. **Integrate, then measure on silicon.**

The `sxgate` framework (`docs/trackb/SSX_FRAMEWORK.md`) is now on the critical
path rather than a nicety: B is exactly the case it was designed for, and it is
what makes this reusable for the next synth.
