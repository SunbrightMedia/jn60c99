# JUNO-60 port — roadmap to production (accuracy-first ordering)

"Production ready" = the port faithfully reproduces the real Roland Cloud JUNO-60
plugin for **arbitrary presets and note input**, verified at the audio sample level —
not merely "compiles and makes a sound."

Current state: ~30–35%. The voice DSP and the effects are genuinely transcribed /
reverse-engineered from the binary, and init is bit-exact. The gap is the layer that
turns *parameters* into *sound* and the means to *prove* correctness. See
`docs/PORT_STATUS.md` for the per-component breakdown.

## Sequencing principle
Ordered for **highest accuracy-per-unit-effort**, not feature count:
1. **Measure before fixing.** Every "match by ear / by statistics" so far drifted
   because there was no audio-level oracle. Build that first; it makes every later
   step verifiable instead of guesswork.
2. **Fix what's audibly broken in the existing path** before adding anything new.
3. **Build the keystone** (parameter→coefficient layer) — it unblocks presets *and*
   effect coefficients *and* the arp. Nothing downstream is faithful without it.
4. **Then breadth** — presets, effects, arp, polyphony hardening, packaging.

Each task lists its **oracle** (how we prove it) and **needs** (what's required,
including anything from the user). 🔴 = blocks production · 🟡 = important · ⚪ = optional.

---

## Phase 0 — Validation oracle (do this first) 🔴🔴
*Without this, accuracy is unmeasurable. This is the highest-efficacy work because it
converts all later work from guessing into testing.*

- **0.1 Reference render set.** Collect plugin-rendered WAVs for a small matrix of
  {known patch} × {defined note events} at 96 kHz, each with an exact event log
  (note on/off sample positions, velocity). Start with 1 patch (the captured
  PD Juno Pad) + 2–3 others. *Oracle source.* **Needs: user renders from the plugin
  (like the C-major export already provided), plus the patch files used.**
- **0.2 Audio-rate A/B harness.** `tests/ab_audio` — drive the port with the same
  event log, compare to the reference WAV: per-sample error, spectral error, and
  per-stage state where capturable. Report pass/fail against thresholds.
  *Oracle: 0.1.* **Needs: 0.1.**
- **0.3 Per-stage probes.** Extend the existing control-rate A/B to dump intermediate
  voice signals (post-DCO, post-VCF, post-VCA) so divergence is localized to a stage,
  not just "the output is wrong." *Oracle: state dumps already in `state_dump/`.*

**Exit:** we can quantify, for any patch we have a reference for, exactly how far the
port is and *which stage* diverges.

---

## Phase 1 — Fix the existing signal path 🔴
*Cheap, high-impact: make the one patch we can already load sound correct before
generalizing.*

- **1.1 Resolve the pitch vibrato/warble.** Pitch = `state[4448]+state[3776]`;
  `3776` mixes ENV1/ENV2→pitch and the LFO term, and the **always-on BBD chorus** is
  a modulated delay. Use 0.2/0.3 to bisect: is the warble in the voice pitch path or
  the chorus modulation? Fix the wrong coefficient/path. *Oracle: 0.2 + a dry vs
  chorus-on comparison.*
- **1.2 Validate voice DSP at audio rate** for PD Juno Pad; close any per-sample gaps
  vs the reference (the control-rate match is necessary but not sufficient).
  *Oracle: 0.2/0.3.*
- **1.3 Validate master + BBD chorus** audio-rate; confirm/repair the chorus
  coefficients (the 70 uncaptured runtime values most relevant to chorus).
  *Oracle: 0.2.*

**Exit:** PD Juno Pad renders sample-accurate (or within a defined tolerance) vs the
plugin, with no spurious vibrato.

---

## Phase 2 — Parameter → coefficient layer (the keystone) 🔴🔴
*The single most important capability. Until panel/preset values map to coefficients
the way the plugin does, no preset is faithful and effect coeffs can't be set.*

- **2.1 Transcribe the parameter apply path.** The registry `sub_180388170` names the
  ~1122 params and their offsets (`docs/COEFF_PARAM_MAP.md`, `docs/PARAM_MAP.tsv`); the
  *values* are applied downstream by the parameter system (`docs/PARAM_SETTER_PLAN.md`).
  Transcribe that apply/curve code: param value → state coefficient(s), including the
  curve LUTs. *Oracle: we already have a full captured coefficient set for PD Juno Pad
  — applying that patch's param values must reproduce those 279+ coefficients exactly.*
- **2.2 Cover the per-control transfer functions** for every audible panel param
  (DCO mix/PWM/range, VCF cutoff/res/env/kbd, ENV1/ENV2 ADSR, LFO rate/delay, HPF,
  VCA, chorus). Validate each against the capture. *Oracle: 2.1's reproduction test.*
- **2.3 Replace the hand-tuned overlays** (`tests/play_preset.c`) with a real
  `juno_apply_params(state, param_values[])`. *Oracle: 0.2 on any patch we can render.*

**Exit:** given a patch's param values, the port computes the same coefficients the
plugin does — arbitrary patches become faithful, not fitted.

---

## Phase 3 — Preset / patch loading 🔴
*Turns "param values" into "named presets from the plugin's own data."*

- **3.1 Acquire a real patch file** (`.s8p` export, or a factory `.inc`/`.bin` bank).
  **Needs: user-provided patch file(s).**
- **3.2 Transcribe the one matching format parser** (`docs/PRESET_FORMAT.md` scoped
  `sub_18033C330` branch) → param values → (Phase 2) coefficients.
  *Oracle: load PD Juno Pad from file, compare to the capture; 0.2 on the audio.*

**Exit:** load any factory/user preset by name/file and render it faithfully.

---

## Phase 4 — Effects into the audio path 🔴
*The DSP is already reverse-engineered (`docs/REVERB_DSP.md`, `DELAY_DSP.md`,
`V538_BLOCK.md`; coeffs in `refs/*_tables.json`). Now port + wire + feed it.*

- **4.1 Port reverb (Griesinger plate)** from `REVERB_DSP.md` to C; unit-test against
  the documented topology. *Oracle: impulse response vs a plugin reverb-only render.*
- **4.2 Port delay/chorus/flanger** (`v39` modes) and the **v538 chorus/drive insert**.
- **4.3 Wire the send chain** input → v538 → v39 FX → plate reverb → out, and **apply
  their coefficients via Phase 2** (this is what gives the missing reverb/delay tail).
  *Oracle: 0.2 on a patch with audible FX (e.g. the SQ ARPG HALL2/DLY tail).*

**Exit:** effect tails and modulation match the plugin; the "no reverb tail" gap closes.

---

## Phase 5 — Arpeggiator & control 🟡
*Transcribed in `docs/ARP_DSP.md` + `refs/arp_patterns.json`; currently only an
approximation in a test rig.*

- **5.1 Port `CArpeggio`/`CKbdArp`** (clock, held-note list, direction modes, the 150
  patterns) to C as the real engine, not the harness approximation.
- **5.2 Host clock / transport integration** (tempo, sync) and note routing to voices.
  *Oracle: plugin arp render vs port for the same held chord + tempo.*

**Exit:** holding a chord with arp on reproduces the plugin's arpeggiation.

---

## Phase 6 — Polyphony & voice allocation hardening 🟡
- **6.1 Validate voices 1–7 audio output** vs the plugin (currently proven only by
  offset-diff). *Oracle: 0.2 on a chord, per-voice probes.*
- **6.2 Real voice-allocation policy** (note stealing, unison) matching the plugin.

**Exit:** chords/voice-stealing behave identically to the plugin.

---

## Phase 7 — Packaging (optional, product-dependent) ⚪
- **7.1 Real-time engine** (block processing, denormal handling, parameter smoothing).
- **7.2 Plugin wrapper** (VST3/AU), **7.3 preset browser / UI**, **7.4 MIDI layer**.

---

## Dependency graph (critical path in bold)
```
Phase 0 (oracle) ──▶ **Phase 1 (fix path)** ──▶ **Phase 2 (param→coeff)** ──┬─▶ Phase 3 (presets)
                                                                            ├─▶ Phase 4 (effects)
                                                                            └─▶ Phase 5 (arp)
Phase 2 ─▶ Phase 6 (poly hardening) ;  all ─▶ Phase 7 (packaging)
```
Phases 3/4/5 can proceed in parallel **once Phase 2 lands** — that's why Phase 2 is the
keystone. Phase 0 gates everything because it's the only way to know any of it is right.

## What I need from you (gates, not nice-to-haves)
- **Reference renders** for Phase 0: a few patches × defined note events, with exact
  on/off timing (you've already shown the workflow with the C-major export).
- **Patch file(s)** for Phase 3: an `.s8p` export or a factory bank from the install.
- A **target scope** for Phase 7: offline renderer, or an actual real-time plugin?

## Definition of done (production)
For every reference patch: port output matches the plugin within tolerance
(per-sample + spectral) across attack/sustain/release **including effect tails**,
loaded from the plugin's own preset data, with no spurious artifacts.
