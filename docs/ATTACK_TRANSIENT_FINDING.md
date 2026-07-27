# BS Solid — the divergence is an ATTACK-TRANSIENT difference (2026-07-27)

**Status: LOCATED, not yet fixed.** Probes in `probes/attack_transient/`.

## How this was reached

The user reported the port still sounds wrong after the velocity-default fix.
A rendered WAV straight from the engine (no browser, no Web Audio) sounds wrong
the same way → **the webapp delivery path is EXONERATED**; it is engine-side.

The capture is used ONLY to LOCATE (covenant role 1). No number from it has
entered the port, a gate, or the ledger.

## The measurement (per-harmonic, windowed — the earlier band-RMS was too coarse)

Gain-matched on the fundamental (130 Hz), port vs capture:

| window | result |
|---|---|
| **SUSTAIN 1.2-2.4 s** | **matches** — harmonics 1..11 within ±2 dB, most <1 dB |
| **ATTACK 0.50-0.75 s** | capture is **+10 to +15 dB richer on nearly every harmonic 2..18** |

Fine timing (10 ms windows, spectral centroid = brightness):

| ms after note-on | capture | port |
|---|---|---|
| 20 | 1283 Hz | 936 Hz |
| 60 | **766 Hz** | **455 Hz** |
| 100 | 396 Hz | 382 Hz |
| 300+ | tracks within a few % | |

Amplitude: the capture peaks ~60 ms after note-on and decays quickly; the port
peaks ~30 ms in and then *lingers* (at 140 ms the port is 4.8 dB hotter
relative to its own peak).

**So: the real plugin's filter snaps open brighter and closes faster. The
divergence is confined to roughly the first 100 ms of every note. Steady state
is correct.** On a plucky bass patch that transient IS the character — which is
why it reads as "there's more in the real one".

## What it is NOT (each ruled out by measurement, not argument)

- **Not a wrong recalled value.** A full sweep of every plausible parameter
  (VCF ENV MOD, VCF VELOCITY SENS, ENV1 ATTACK/DECAY/SUSTAIN, VCF RESONANCE,
  VCF CUTOFF, VCF KEY FOLLOW) over its whole range: the best single-parameter
  change only moves attack error 9.6 dB -> ~5-6 dB, never near zero, and the
  ones that help most (ENV1 SUSTAIN, VCF CUTOFF) **wreck** the sustain match
  (sustain error 3.2 dB -> 17 dB / 56 dB). No single value explains it.
- **Not velocity.** The attack fits best at velocity ~120-127 rather than 100,
  but even the best fit leaves ~6 dB RMS scatter, so velocity is at most a
  partial contributor. The forced-velocity constant was re-checked in the
  binary: `BYTE10 = 100` when Keyboard Velocity SW is off — our value is right.
- **Not the webapp/browser path** (the raw WAV diverges identically).
- **Not sample rate** (the plugin's own DSP has the same spectral shape at
  44.1 k and 48 k).
- **Not the render loop, recall completeness, bank decode, or note terminus** —
  all proven equivalent this session (`docs/RENDER_LOOP_LOG.md`).

## Where this points

Everything steady-state is right and everything transient is wrong, while the
port and the emulated plugin are bit-exact *given the same starting state*.
That combination points at the **per-note initial conditions** — the state a
voice is in at the instant a note begins (envelope/smoother/filter starting
values) — rather than at any coefficient. This is the one area where the
port's own driver, not the transcribed DSP, decides what the voice starts from.

**Next step (not yet done):** instrument the first 100 ms at cell level —
capture the VCF cutoff-CV and ENV1 output cells sample-by-sample for the first
~5000 samples in the port, and compare against the plugin driven identically
under Unicorn. The two are bit-exact in aggregate, so any divergence must be in
what the voice is initialised to, and a per-sample trace of the attack will show
it directly.

---

# ROUND 2 (same session): sharpened to a single quantitative discriminator

## The measurement that matters

Onset-aligned (verified: onset offset is only **0.3 ms**, so the earlier
window-misalignment failure mode is excluded), the capture is **~+8 dB richer
than the port on harmonics 2..18 across the WHOLE note**, settling to ~+2 dB in
long sustain. The single sharpest number:

**SUB(65 Hz) / MAIN(130 Hz) amplitude ratio, early note:**

| | ratio |
|---|---|
| capture (real plugin, real DAW) | **0.450** |
| port | 0.096 |
| **plugin under emulation, same recall** | **0.100** |

The port reproduces the plugin-as-we-drive-it (0.096 vs 0.100). Both differ from
the real instance by ~4.5x. Everything except the fundamental is lifted:
harmonics +8 dB, sub 4.5x, inter-harmonic broadband +1.2 dB.

## Hypotheses tested and REFUTED this round (each by execution)

| hypothesis | result |
|---|---|
| webapp / Web-Audio delivery | **refuted** — a plain WAV rendered straight from the engine sounds wrong the same way (user-confirmed) |
| a wrong recalled value | **refuted** — full-range sweep of VCF ENV MOD, VCF VELOCITY SENS, ENV1 A/D/S, VCF RESONANCE, VCF CUTOFF, VCF KEY FOLLOW: best single change only moves attack error 9.6 -> 5-6 dB, never near zero, and the biggest movers destroy the sustain match (3.2 -> 17 / 56 dB) |
| DCO mix leaves swapped (SUB<->SAW etc.) | **refuted** — every permutation tested; best total 12.05 vs baseline 13.11, and each improves attack only by worsening sustain |
| velocity | **partial at best** — attack fits best at ~120-127 vs 100, but still ~6 dB RMS scatter; the forced-velocity constant was re-read in the binary and is 100 (`BYTE10 = 100`), i.e. ours is right |
| JU-06A-only leaves being wrongly applied | **refuted** — every parenthesised/`_NULL_` leaf in our map is either 0 on BS Solid or writes no cells; 0 suspects |
| output-stage saturation (Boost Mode / Output Gain, which write ZERO engine cells and are absent from the port) | **refuted as the explanation** — best soft-clip only 13.1 -> 10.8 and needs an implausible 12x drive |
| ASSIGN MODE 2 = UNISON not honoured (bridge hard-overrides to POLY) | **refuted** — forcing the patch's real UNISON makes it far worse (error 13.1 -> 25.4, peak 0.25 -> 1.53). The existing POLY override is correct |
| sample rate (webapp 48k vs DAW 44.1k) | **refuted** — the plugin's own DSP has the same spectral shape at both |

## Where this leaves it — stated precisely

The port faithfully reproduces the plugin **as our recall drives it** — confirmed
again this round on the sub/main ratio itself. And **no setting reachable from
our recall reproduces the captured sound**: if this were a wrong recalled value,
some value would have fitted. None did.

So the real instance sits in a state our recall cannot produce, and the
divergence is now pinned to one concrete, quantitative target rather than a
subjective impression:

> **make the DCO SUB(65 Hz)/MAIN(130 Hz) early-note ratio 0.45 instead of 0.10,
> without disturbing the sustain match — at the same displayed DCO SUB LEVEL of
> 83, which the user independently read off their own front panel.**

That is a much sharper target than "sounds wrong" and any future attempt can be
scored against it directly. It remains consistent with the one link in the chain
that has never been *executed* (the record-byte -> parameter position map,
reachable only through the walled controller preset path), and it is the natural
next thing to attack.

Covenant note: the capture was used ONLY to locate and to score hypotheses. No
number from it has entered the port, a gate, or the ledger; every refutation
above was produced by executing the plugin or the port, not by fitting.

---

# ROUND 3: the requirement is OUTSIDE the reachable parameter range

## The decisive normalisation test

Gain-matching on H1 cannot distinguish "harmonics too quiet" from "fundamental
too loud". Re-normalising on TOTAL RMS settles it:

| window | port H1 vs capture H1 (RMS-normalised) | 400-3000 Hz band | H1-vs-band tilt |
|---|---|---|---|
| ATTACK | port **+3.3 dB** louder | port **-8.1 dB** quieter | **-11.4 dB** |
| SUSTAIN | port +1.2 dB | port -0.9 dB | -2.0 dB |

Both signals put their resonant peak at the SAME frequency (129 / 131 Hz), so
the cutoff mapping is NOT displaced. The requirement is specifically:

> **~+11 dB more filter opening during the ATTACK, while the SUSTAIN stays put.**

## Why no parameter can deliver that

- **Velocity** moves both windows together: vel 115 fixes the attack
  (9.45 -> 3.88) but *breaks* the sustain (3.65 -> 7.00). Grid over
  velocity x DCO SUB LEVEL (20 combinations): best total 10.88 vs baseline
  13.11 — no combination collapses both. Attack and sustain trade off.
- **VCF ENV MOD** is already 215 of a 255 maximum. Going to the ceiling buys
  only ~1.4 dB of extra envelope depth — an order of magnitude short of the
  +11 dB required. Even at max, the attack cannot reach the captured brightness.
- **DCO SUB LEVEL** moves the sub/main ratio but not the mid band; the capture's
  0.450 is unreachable without wrecking the harmonic fit.

**So the needed attack brightness lies OUTSIDE the range the parameters can
produce.** That is the strongest structural statement available from this data:
it is not a mis-decoded value, because no legal value — including the maximum —
gets there.

## Honest status

**The cause is NOT identified.** What is established:

1. The port reproduces the plugin-as-our-recall-drives-it (sub/main 0.096 vs
   the emulated plugin's 0.100; render A/B bit-exact everywhere else).
2. The real instance needs ~+11 dB more attack-phase filter opening at an
   unchanged sustain, plus ~4.5x the sub content.
3. **No parameter, or combination, within the legal ranges produces that** —
   which rules out the "one wrong recalled byte" family of explanations
   entirely, and points at something structural in how the filter envelope's
   peak contribution is formed, or at a signal path we do not model.

Everything in rounds 1-3 was produced by executing the plugin or the port. The
capture was used only to locate and to score; no number from it has been written
into the port, a gate, or the ledger.

## The one avenue not yet possible here

Both remaining candidates (the un-executed record-byte -> parameter POSITION MAP,
and any wrapper-side signal path) live behind the plugin's controller preset
lifecycle, which cannot be constructed in this environment (CRT/thread-pool wall,
`docs/FINAL_SCOPE_LOG.md`). Until that is reachable, this specific residual
cannot be closed from the engine side.

---

# ROUND 4: questioning the TESTS (user's suggestion) — the corpus result

The user's point ("if the issue is truly invisible, maybe something is wrong
with our tests") drove the most informative round so far. The whole
investigation had been staring at ONE patch. There are **8 unused factory-preset
bounces** (same protocol). Measuring the SAME discriminator on all of them:

## Is the divergence systematic or patch-specific?

H1-vs-(400-3000 Hz) tilt, capture minus port. Negative = port duller.

| preset | f0 | ATTACK delta | SUSTAIN delta |
|---|---|---|---|
| factory 0 | 261.7 | -3.5 | -2.4 |
| factory 1 | 261.7 | +2.8 | -4.7 |
| factory 2 | 261.7 | +6.9 | +0.3 |
| factory 3 | 261.7 | +0.5 | +0.3 |
| factory 4 | 130.8 | -3.6 | +5.3 |
| factory 5 | 530.8 | +7.7 | +2.8 |
| factory 6 | 65.0 | +2.3 | +6.3 |
| factory 7 | 385.8 | +2.0 | +9.7 |
| **mean** | | **+1.9** | **+2.2** |
| **BS Solid** | 130.0 | **-11.4** | -2.0 |

**Two conclusions, and the second is uncomfortable but important:**

1. **The flaw is NOT systematic.** The factory deltas scatter around zero in
   BOTH directions. The DSP, filter, envelopes and harness are not globally
   wrong; BS Solid is a genuine outlier.
2. **The metric itself carries ~8 dB of uncontrolled scatter** (-3.6 .. +7.7) on
   patches the user has never complained about. So "-11.4 dB" is only ~1.5x the
   worst honest scatter — a weaker signal than earlier rounds treated it as.
   Chasing it by spectral fitting is not converging, and that is a property of
   the *test*, not only of the port.

## Further eliminations this round

- **Factory 2 has nearly identical VCF settings to BS Solid** (cutoff 27 vs 15;
  VCF ENV MOD **215 — identical**; both HPF 0) and lands at **+6.9**, the
  opposite sign. An 18 dB swing at the same filter settings **rules out the
  cutoff / env-mod law** as the cause.
- **The port's velocity response is bit-exact to the plugin** — `bssolid_ab`
  re-run at BOTH vel 100 and vel 127: BIT-EXACT at each
  (peak 0.23259 / 0.24053, port == plugin to the sample). So the capture
  behaving like vel ~115 is not a port defect; that instance received a
  different velocity.
- **Every velocity-sensitive patch does respond to velocity in the port**
  (vel 1 vs 127 changes ~22000 samples on each). An earlier "0.0 dB change"
  reading was my tilt metric rounding a small 100->127 delta, not a bug.
- The velocity-sens corpus is real: factory 0 (sens 105) and factory 5 (92)
  exercise it; 72 of 128 patches have non-zero VCF VEL SENS.

## Status

**Cause still NOT identified.** Ruled out this round: systematic DSP/harness
error, the cutoff/env-mod law, the port's velocity handling, and
velocity-sensitivity plumbing. Combined with rounds 1-3, the "wrong recalled
value" family is fully excluded (no legal value — including maxima — reaches the
captured brightness), as are the render loop, recall completeness, bank decode,
note terminus, noise policy, webapp delivery, unison, saturation and rate.

**Methodological note for whoever picks this up:** the port-vs-DAW-bounce
comparison has ~8 dB of intrinsic scatter. Any future attempt should either
(a) reduce that scatter (identical session, documented velocity and Kbd Vel SW
state, several patches bounced together), or (b) work from a comparison that is
not bounce-based at all — i.e. the controller preset path, still walled.
