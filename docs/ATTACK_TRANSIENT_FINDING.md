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
