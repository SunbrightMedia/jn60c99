# Data provenance & trust verdict

What is trustworthy as a coefficient/algorithm source for this port, and what is
not. Recorded so it is never re-litigated. **Project rule: the decompile is the
spec; fitted/calibrated numbers are forbidden.**

## TRUSTED — the decompile is the single source

| Source | What it provides | Why trusted |
|--------|------------------|-------------|
| `refs/allcode_decomp.tgz` | The audio **algorithm** (voice render, master/chorus, FX graph, helpers) and the **coefficient values** (static `.rdata` floats + the initializer `sub_1803990C0` that writes them) | Direct Hex-Rays decompile of the shipped binary; full plugin, indexed by `refs/manifest.tsv`. |
| `asm_dump/`, `everything_static/`, `master_deps/`, `param_setter/`, `host_layer/` | Disassembly for functions Hex-Rays dropped args on or returned `None` for | Raw IDA asm of the same binary — the only version-controlled disassembly. |
| `refs/data/`, `refs/*.json` | Resolved FX/arp vtables and extracted coefficient tables | Extracted from the binary's data segments. |

### Proof the voice path is fully covered

`sub_1803990C0` (2289 struct writes) writes every read-only coefficient field
`voice_render` consumes. Spot-decoded:
- Waveshaper polynomial `a1+2160..+2256` = `0.0027, 0.1221, 2.1487, −0.8796,
  −0.3931, −0.5017, 2.718282` — the trailing `2.718282` is **e**: genuine designed
  exp-saturation coefficients.
- Mix/scale `a1+2352..+2464` = `0.5, 1, 1, 2, 0.5, 14, 0.0142`.

⇒ The voice engine is **bit-exact-portable with no external data**.

## FORBIDDEN — fitted/calibrated numbers (the failed-project poison)

The previous, abandoned effort produced a "golden dump" of fitted coefficients
("calibrated to 0.539x from P6 audio", "fixed 4x level deficit", "fitted filter").
Those values do **not** exist in the binary's static `.rdata` (verified offset by
offset) and were never used as a source here. The raw poison files have been
**removed** from the repo; this verdict is kept so the lesson is not re-learned:
**if a number isn't in the decompile, it does not go in the port.**

## Captures that remain — oracles only, never sources

A small number of live-plugin captures survive strictly as **cross-checks**, never
compiled in as the port's values:
- `state_dump/*.bin.gz` — memory snapshot backing the 2289/2289 init bit-exact
  proof.
- `src/runtime_coeffs_data.c` — a captured PD-Juno-Pad coefficient set used to
  validate the param-apply engine (88/88 LUT members exact). The apply mechanism
  is transcribed from the decompile; the capture only confirms it.

The chorus and every FX coefficient are **derived from the decompiled code +
recovered tables**, not measured. No new capture is needed for the port to be
complete.
