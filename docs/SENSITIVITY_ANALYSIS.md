# Voice-region capture sensitivity analysis (SQ Dynamic ARPG)

Goal: determine which of the 133 remaining capture-seeded voice-region offsets
actually affect the SQ ARPG sound, so effort targets real issues — not dead ends.

## Method
Perturb each stuck offset in the full render path and compare output. Two passes:
1. Raw output hash (catches any change).
2. **Normalized-waveform** RMS-difference (the render peak-normalizes, so pure
   level changes are removed — only timbre/shape changes count).

## Results
- 129 voice-region stuck offsets tested: **50 affect raw output, 78 irrelevant, 1 index/crash.**
- Of the 50, most are either (a) already set correctly by the loader (ADSR
  2784/2800/2816/2832, osc levels 4192/4224, VCF 6736, ENV2 3264.., PWM 4144,
  noise 6528, etc.), or (b) **level-only** (removed by normalization), or
  (c) self-converging smoother/envelope state, or (d) confirmed global constants.

### Confirmed NOT bugs (global constants / correct pad value)
- **304 M.CV = 6.66847**: master-tune CV, `.rdata` literal @0x97f780; master tune
  is center across all 64 factory banks → global constant. (Biggest raw effect,
  but correct.)
- **5520 Duty Tune = 0.02**: = construction default `lut[27][1]`, `.rdata` @0x97e4d0. Global.
- **9824 Mute = 1.0**, plus ~18 unity `1.0` switch slots: construction defaults
  (sub_3A66B0), global.

### The note-on / velocity handler is a DEAD END for the sound
The JUNO-60 is **not velocity-sensitive**: the velocity depth (offset 9600/9648)
is 0, so the velocity-curve output (9680 = `lut[57][midi_velocity]`, formula
confirmed) is multiplied by 0. Forcing 9680 to 5.0 yields a **bit-identical**
render. The amp-chain values (9616/9776/9824/9856) are level-only (normalized
away). => Transcribing the note-on velocity handler would NOT change this sound.

### The one real remaining suspect: LFO tempo-sync rate (1072)
- Loader sets tempo-sync **ON** (1056=1) and **VCF LFO MOD = −1.27** (strong) for
  SQ ARPG, and **DCO LFO MOD = 0**. So a strong tempo-synced LFO wobbles the VCF
  cutoff.
- The synced rate **1072 = 2.7298 is stuck at the pad capture value** (it is a
  COMPUTED value — host-tempo × sync-division — not a `.rdata` literal or LUT
  entry). Our render hardcodes 120 BPM but never recomputes 1072, so the filter
  wobbles at the *pad's* rate, not SQ ARPG's. Normalized timbre-diff when halved =
  0.33 (the largest of any uncertain offset) → audible.
- FIX requires the tempo-sync rate formula + SQ ARPG's LFO sync-division param +
  plumbing the host BPM to the engine. This is the highest-value remaining lead
  for "sounds off" — concrete, not vague analog uncertainty.

### Residual uncertain (small effect, computed/non-default, no oracle)
- 1072 (above), 2672 (=8.15, computed, envelope-region), 6512 (Osc1 Level
  =1.00736 = `lut[54][173]`, non-default — likely a model osc-level trim).
