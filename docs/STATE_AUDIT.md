# Root cause: the port runs faithful code on an incomplete coefficient state

Audited why the port sounds wrong. Two findings, both from line-by-line comparison
against the decompile (image base 0x7FF91DC60000):

## 1. The audio code is faithful (not the bug)
`src/voice_render.c` is a verbatim, line-by-line transcription of `sub_180369070`
(voice DSP) — normalized bodies are line-count-identical, **zero** arithmetic/offset/
sign/constant/control-flow divergences across DCO / HPF / 4-pole VCF / ENV1 / ENV2 /
VCA / LFO / output; every Hex-Rays-dropped helper arg re-verified against the asm.
(`src/master_render.c` chorus LFO likewise verified, `docs/CHORUS_VIBRATO_DIAG.md`.)

## 2. The coefficient STATE is incomplete and inconsistent (the bug)
The voice path reads **535** distinct coefficient offsets (region +320..+10832).
`engine_init` (`sub_1803990C0`) writes **2207** real coefficients; `chorus_init`
(`sub_1803A1300`) only zero-inits + BBD buffers. That leaves **340** offsets (`R\W`)
that must be supplied by the **runtime parameter layer** — the param-apply the plugin
runs on construction (all param *defaults*) and on patch load (the patch values).

The port fakes that layer with a 279-entry capture (`src/runtime_coeffs_data.c`,
`juno_runtime_coeffs_apply`) that covers only **103** of the 340. **237 are read as
`0.0`.** Most are legitimately-zero switches, but several are load-bearing continuous
coefficients that must be nonzero:

| offset | param | consequence of 0.0 |
|---|---|---|
| 6832 | LPF Resonance | filter has no resonance |
| 7600 / 7616 | Cutoff Tune / Resonance Tune (filter-coeff bias) | wrong cutoff/res mapping & tracking |
| 4208 | DCO pulse/square level | **pulse oscillator silent** |
| 4064 / 4080 | ENV1 / ENV2 modulation level | envelope depths zeroed |
| 368 / 384 / 3952 / 3968 | Master/Part Tune, Tune/Detune | tuning off |

**Cleanest proof:** the DCO pulse level (4208) is 0 while its saw (4192) and sub
(4224) siblings ARE captured — the capture is just an incomplete dump, not a real
patch. The synth has been running with no resonance, a dead pulse oscillator, zeroed
envelope depths, and wrong filter tuning.

## The fix
Stop faking the runtime layer with a partial capture. Apply the param system properly
from a clean init:
1. `engine_init` + `chorus_init` (static tables + structure) — have these.
2. **Apply every registered param's default** through the real apply path (LUT
   `sub_356380` ✓, scale+offset `sub_356150` — TODO, FX-coeff setup ✓), filling all
   340 runtime offsets consistently.
3. **Override** the ~84 exposed patch params with the preset's values
   (`docs/SCRIPT_PARAM_MAP.md` gives DB-index → offset).

This replaces `runtime_coeffs_data.c` entirely with the plugin's own logic
(`juno_apply_full_patch`). Tracked as the apply-path completion (the scale+offset
family + per-param multi-coefficient compute).
