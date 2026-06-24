# Making the port fully capture-free (everything from the decompile)

Goal (user directive): the port reproduces the plugin with **no external input** — no
live captures, no reference renders, no external patch files — because the entire
decompiled VST3 is in the repo, so every value is derivable from it.

## The one external crutch left
`src/runtime_coeffs_data.c` — 279 coefficients captured from the live plugin (PD Juno
Pad). Everything else (voice/master/chorus/FX DSP, init, param-apply mechanism) is
already transcribed from the decompile. This plan removes the capture.

## The identity that makes it possible
Every engine coefficient = **`f(param_value, tables)`**, and both sides are in the binary:
- **`f()`** — the apply functions: LUT denormalize (`sub_356380`), scale+offset
  (`sub_356150`), and the FX-coefficient setup (reverb/delay/chorus). All decompiled.
- **`param_value`** — a patch's per-parameter **step**. For a capture-free source we use
  the plugin's **default patch**, whose default steps live in the parameter DB
  `unk_7FF91E5EC040` (rva 0x98C040): 16-byte records `{min,max,default,flag}` (i32),
  4966 entries; the construction loop (decomp_3C0000.c ~4988) registers each default.

## Work items
1. **Default patch** (task #9) — PARTIAL / boundary found. The 123 binary-sourced synth
   init-patch defaults ARE extracted (`refs/default_patch.json`, DB-index 755–877: feet,
   PWM source, ENV times, tune-center, noise type, etc.). BUT the **paramID↔DB-index bridge
   is NOT statically present**: the registry (`sub_388170`) records no DB-index, the DB has
   no param names (only value-format specs), the controller ctor takes a VST3 ParamID but
   no DB-index, and the only link is a **runtime-built red-black tree** (`sub_3C7AE0`).
   So a *fully* binary-sourced default patch needs either that tree's reconstruction or
   ~123 semantic spec→name matches (uncertain). **Deferred — not on the critical path:**
   we already have a real patch's step values in-repo (PD Juno Pad, recovered from the
   existing capture in `refs/recovered_param_steps.json` — derived data, not new external
   input). The pragmatic capture-free port computes coefficients from those.
2. **FX-coefficient setup** (task #10) — the 57 reverb/delay/chorus filter coefficients
   (29% of the capture: `Rev Ecf *`, `High Cut *`, `Delay Time`, `Wet/Dry`) are computed
   by the FX setup from the FX tables (`refs/reverb_tables.json`, `refs/delay_tables.json`).
   Transcribe that setup math; validate bit-exact vs the capture.
3. **scale+offset family** (task #11) — `coeff = value*scale[idx]+offset` (`sub_356150`,
   const `dword_7FF91E7450B4`, per-object `+0x2C` scale arrays). ~5 LFO-rate-type synth
   params + the ~20 unnamed synth coeffs. Transcribe + validate.
4. **Integrate** (task #12) — `juno_init_default(st)`: apply the default patch through the
   param engine + FX setup + scale, producing ALL coefficients with **no capture linked**.
   Keep `runtime_coeffs_apply` only as a validation oracle, not a build dependency.

## How we validate capture-free (still no external input)
The apply **mechanism** is already proven bit-exact (88/88 LUT) against the in-repo
capture. Once defaults + FX setup + scale are transcribed, the computed coefficients are
correct **by construction** (faithful transcription of decompiled code applied to
binary-sourced values). The capture in the repo is the cross-check; nothing new is needed.

## Status
- Param-apply engine: ✅ LUT + switch, 88/88 bit-exact; 550-param definitive table.
- Default patch / FX setup / scale+offset / integration: in progress (above).
