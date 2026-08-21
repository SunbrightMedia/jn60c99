# JX-3P vs JUNO-60 — the architecture delta (S1/S2, from Script.xml)

Same vendor, same engine family (25 of ~43 audible parameters shared, and the
DSP class inventory maps module-for-module). This records where the JX-3P is
genuinely DIFFERENT, so S3 transcription meets no surprises.

## The one real structural difference: TWO DCOs

* **JUNO-60**: ONE DCO with a waveform-source mixer — SAW / PWM / SUB / NOISE
  levels, PWM depth+source. A single oscillator blended from parts.
* **JX-3P**: TWO independent DCOs — DCO1 and DCO2, each with WAVEFORM / RANGE /
  FREQ MOD, plus DCO2 FINE TUNE, DCO2 TUNE, and DCO2 **CROSS MOD**.

Consequence for the port: the JX voice has a second oscillator and a cross-mod
path the JUNO never had. Expect `CDSPJx3pOscVoice` to render two DCOs, and the
voice STATE to be larger than the JUNO's — the `voice_stride` in synth/jx3p.json
stays null until the IDA dump gives the real number. **Do not copy the JUNO
stride.**

## Renamed, same concept (no new DSP, just a label)

    JUNO                     JX-3P
    HPF CUTOFF FREQ      ->  HPF CUTOFF
    VCF ENV MOD          ->  VCF ENV1 MOD
    VCF KEY FOLLOW       ->  VCF PITCH FOLLOW
    VCA TONE             ->  BRILLIANCE (high-tone control)
    EFFECT DEPTH         ->  EFFECT LEVEL

## Shared, unchanged

LFO (rate/delay/mod depths/key trig), the ENV1/ENV2 pair (filter + amp ADSR),
VCF cutoff/resonance/env mod, portamento, LEGATO, **ASSIGN MODE 0..2 (UNISON at
value 2 — the JUNO's near-miss case, present here too)**, BEND RANGE, TEMPO
SYNC, the delay/reverb/effect sends, CONDITION scatter (0..255, default 128).

## What this means for the plan

* S3 transcription scope is JUNO + a second DCO + cross-mod. Larger, not
  structurally new — the transformers handle it the same way.
* The FX family differs slightly (JX adds EfxPh phaser, EfxCr; drops EfxCe/
  EfxMt) — confirmed from the DSP class inventory, effect arms transcribe per
  DELAY/EFFECT TYPE exactly as the JUNO's did.
* 290 total parameters vs the JUNO's ~1121 registry entries is the same order;
  the param registry closure (IDA phase 5) covers them.

No re-scope. The delta is contained and known before a line is written.
