# Audible patch recall — feasibility, plan, and progress

Goal: load a JU60 bank patch and hear it, by **porting the original code** (no
runtime captures). This records what was proven with the plugin binary +
decompile in hand, and the concrete plan.

## STATUS — end-to-end recall works in the web app (partial coverage, exact where bound)

The browser app (`gui/web/`, mirrored to `docs/`) now does the full loop:
**import a `.bin` bank → pick a preset → Apply → press a key → hear it.**
Wiring: `juno_gui_apply_bank` (bridge) → `juno_bank_apply` (src/juno_apply.c) →
`juno_curve` (bit-exact vs the real machine code) writes the engine coefficient
slots; the piano triggers the ported note/gate/ADSR driver and plays the **dry
voice** signal.

What is EXACT vs PARTIAL, stated plainly:
- **Bit-exact:** the curve evaluator (proven vs Unicorn) and the **11 bound
  coefficients** — VCF cutoff & resonance, both ADSR envelopes (filter + amp
  attack/release, filter sustain), filter env-mod, key-follow, VCA tone.
  Oracle-proven: patch 5 `LD Classic Lead` VCF cutoff = `juno_curve(22,153)` =
  `0.600000`, matching the plugin's own stored float. Verified in-browser
  (Chromium): apply patch 5 → cutoff slot = 0.600000, note peak 0.0207, audible.
- **NOT yet bound (stay at engine defaults):** DCO oscillator mix (saw/sub/pwm/
  noise levels — the OscVoice setters live outside the range extracted so far),
  ENV2 decay/sustain (255/255 value-collision in the anchor patch → blob order
  unproven), HPF (sample-rate-variant curve unresolved), LFO, and the FX chain.
- **Approximate (documented hacks, not fabrication):** note-on **pitch** is a
  DCO-domain calibration and the **gate** opener pokes the phase-accumulator
  slot (see src/juno_note.c). Timbre is exact; base pitch may sit an octave off.
- **Preview is the dry voice** (pre-FX): the master/chorus **output stage needs
  ~250 coefficients Hex-Rays could not decompile** (src/master_render.c), so the
  master's dry & chorus-I output collapse to silence. The dry voice is the most
  faithful audible signal the port can produce today.

Next for coverage: extract the OscVoice/VoiceCmn setters (DCO + VCA levels) and
add them to the binding table only once each (curve, offset) is certain.

## Verdict: BOTH remaining units are BOUNDED and portable from what we have

The earlier "disproportionate / needs data we don't have" conclusion
(`PARAM_SETTER_PLAN.md`) predated having the **bank file** (the preset data) and
the **plugin binary** (all the code + `.rdata` tables). With both in hand, two
independent deep traces (against `refs/` + the `.vst3`) find:

### Unit #1 — note-on / gate / ramp engine — BOUNDED (~450 lines Tier-1)
Small, fully-decompiled functions. Tier-1 (minimal audible note): descriptor
set/get/trigger, ramp ctor/start/step/reset, the active-voice vector, voice
trigger `sub_1803C2920`, pruner `sub_1803C24A0`, gate on/off
`sub_1803C1720/17A0`, + a per-block driver. Corrections found vs old docs:
- **Ramp target is 4.0** (`unk_…EB50` = `0x40800000`), not 1.0.
- Ramp is **stepped-linear**, advanced by the pruner once per control tick,
  incrementing every `subdiv`(=10) ticks; `rate` (engine+80) = sample rate.
- The note-on edge `state[101504]` is a **one-shot** (latches DCO phase, then
  self-zeros the same sample) — holding it high re-zeros the phase → silence
  (that was the earlier empirical test's bug).
- Note→pitch: the integer note stays integer through the whole keyboard/assign
  chain; the octave conversion happens in the CDSPJu60 engine
  (`sub_180413320` handler) reading a cents/1200 fine-tune table. **One function
  to trace — do NOT fabricate `(note-60)/12`.**

### Unit #2 — patch → engine coefficient applier — BOUNDED (~500–800 lines + data)
NOT the reflection framework that was feared. The actual math is **`clamp + LUT`**:
- `sub_1803B6380` — one curve evaluator: a 66-arm switch, each arm
  `clamp(value,0,N); return LUT[v]` over ~28 baked `.rdata` float tables
  (`dword_…5C97D0` … `…5CE2E0`), with sample-rate variants. ~100 C lines + the LUTs.
- ~130–188 per-parameter setter thunks collapse to a **~150-row data table**
  `(programmer_field → curve_id, engine_offset)` + one generic apply loop.
- ID→offset map: already `docs/COEFF_PARAM_MAP.md` (312/349).
- Factory-default patch `sub_1803A66B0`: ~1121 `(offset, const)` raw stores → a
  data table (gives the default patch entirely from original code, no capture).
- **~138 of the runtime coeffs are DIRECT** (raw-stored; the perceptual curve is
  in the DSP we already have — e.g. `voice_render` maps normalized cutoff to
  frequency itself). The **57 "computed" biquad taps are all in the post-voice FX
  chain** (delay/chorus/reverb), recomputed by each effect's own setup — a JUNO
  panel patch never touches them.
- Residual wiring (which field drives which setter) lives in `.rdata` vtable
  dispatch tables **present in the `.vst3`** → extract statically. No capture.

## Progress this session
- ✅ **Ramp engine ported** — `src/juno_ramp.c/.h`, exact transcription of
  `sub_1803C2E80/2E00/2E60` (incl. the `0x1F800000/0x9F800000` direction nudges).
- ✅ **Blocker pinpointed empirically.** With the captured PD-Juno-Pad coeffs +
  the ramp engine: the **DCO oscillator runs** (saw `state[1792]≈-0.99`) and the
  **VCA path is open**, but the **filter envelope gate `state[2576]` stays 0**
  (VCF output `state[10544]=0`) because the ADSR gate `state[560]` never leaves 0.
  So the exact missing wiring is: **what the note-on trigger ramps to make
  `state[560]` open the filter/amp ADSRs.** `state[560]` is computed from a
  DCO-path signal, so the gate is not a naive `state[544]=4` (confirmed silent).

## MILESTONE — the port makes its first audible note (unit #1 Tier-1)

`src/juno_note.c/.h` — an offline note driver over the ported ramp engine.
Verified: with the captured PD-Juno-Pad patch loaded, `juno_note_on(st,0,60,100)`
+ per-sample `juno_note_tick` + `juno_voice_render` produces a **non-silent,
ADSR-enveloped tone** (peak |out| ≈ 0.022; attack rise → sustain → release on
`juno_note_off`). `make test` still green. This is the first time the port
sounds — from ported control-layer code, no captures.

**What is correctly traced (real code):** the shared ADSR gate is `state[560]`
(both filter and amp envelopes: `attack ⇔ state[560] ≥ 0.5`, since the fixed
thresholds `state[2864]=state[3344]=-0.5` from init). `state[560]` is the output
of the DCO gate-conditioner `v29 = s272·s240·(s208−s320) + s320`; with the patch
DCO-coeff slots 208/240/272 at 0, `v29 = state[320]`, so ramping `state[320]`
opens the gate. This corrected the earlier misread (`state[560]` is derived, not
directly writable; and `v125=1` is *idle*, not attack).

**Honest caveats — the DSP is fine; both gaps are un-ported CONTROL-LAYER inputs:**
0. **The DSP layer is NOT the problem.** Measured: `state[4416]` doubles per
   octave of `state[4448]` exactly (clean frequency scaling); the ADSR gate
   `state[560]` and thresholds are read exactly. An earlier note here claimed a
   "DSP scaling discrepancy" — that was wrong and is retracted. The DSP plays
   whatever inputs it's given, correctly. The two issues below are inputs the
   note-on (control layer) must supply and that we haven't traced.
1. **Gate opener is a HACK, not the faithful write.** `state[560]` opens when the
   conditioner `v29 = s272·s240·(s208−s320)+s320 > 0`. The real note-on loads
   pitch-derived DCO coefficients into 208/240/272/320 so v29>0 falls out; we
   instead poke `state[320]` — the DCO **phase accumulator** — which works but is
   the wrong mechanism. The faithful write needs the descriptor-1090 ramp
   out-pointer binding (unresolved init gap).
2. **Pitch VALUE is an unverified calibration.** The DSP plays `state[4448]`
   exactly; we just don't have the control-layer integer-note→octave formula, so
   the constant in `juno_note_pitch` is a guess (currently ~an octave off). Trace
   `sub_180413320` for the real note→pitch map → in tune.
3. **Velocity is accepted but unused** (amp comes from the ADSR).

## Next steps (in order)
1. Trace the descriptor→ramp-object→slot binding for the gate param (the init
   that sets each ramp object's out-pointer) → the exact slot the trigger ramps,
   and how it makes `state[560]` open. Then Tier-1 unit #1 → **first audible note**
   (with the already-captured patch).
2. Trace `sub_180413320` note→octave → correct pitch.
3. Port unit #2 (curve evaluator + LUTs + 150-row binding table + factory
   default) + extract the `.rdata` dispatch tables from the `.vst3` → **any bank
   patch audible**.
4. Verify: factory-default patch (from `sub_1803A66B0`, no capture) is a
   ground-truth cross-check for the applier; per-note A/B once a note sounds.
