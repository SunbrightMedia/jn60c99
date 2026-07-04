# Audible patch recall — feasibility, plan, and progress

Goal: load a JU60 bank patch and hear it, by **porting the original code** (no
runtime captures). This records what was proven with the plugin binary +
decompile in hand, and the concrete plan.

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
