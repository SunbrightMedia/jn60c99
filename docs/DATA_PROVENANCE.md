# Data provenance & trust verdict

What is trustworthy as a coefficient/algorithm source for this port, and what is
not. Recorded so it is never re-litigated. The project rule: the decompile is the
spec; fitted/calibrated numbers are forbidden (see `HANDOFF_IDA.md`).

## TRUSTED — use these

| Source | What it provides | Why trusted |
|--------|------------------|-------------|
| `dsp_dump/` | The audio **algorithm** (voice render, master dispatch, chorus code, helpers) | Direct Hex-Rays decompile of the shipped binary. |
| `init_dump/` | The **coefficient values** the voice path reads | Static `.rdata` floats + the initializer (`0x1803990C0`) that writes them into the voice struct. Freshly extracted from the same binary. |

### Proof the voice path is fully covered

`sub_1803990C0` (the voice initializer, 2289 struct writes) writes every
read-only coefficient field `voice_render` consumes. Spot-decoded:

- Waveshaper polynomial `a1+2160..+2256` = `0.0027, 0.1221, 2.1487, −0.8796,
  −0.3931, −0.5017, 2.718282`. The trailing `2.718282` is **e** — these are the
  genuine designed exp-saturation coefficients.
- Mix/scale `a1+2352..+2464` = `0.5, 1, 1, 2, 0.5, 14, 0.0142`.

`dsp_dump` (algorithm) + `init_dump` (values) ⇒ the **voice engine is
bit-exact-portable with no external data**.

## UNTRUSTED — quarantined, do NOT use as coefficient source

Files in `quarantine/old_project_UNTRUSTED/` (kept only as evidence):

- **`golden_dump_20260621.txt`** — from the failed previous project.
  **Contaminated with fitted values.** Cross-checked its filter/LFO/master
  numbers against the binary's static `.rdata`:

  | old-dump value (claim) | in binary `.rdata`? |
  |---|---|
  | `0.10703` "cascade g" | ABSENT |
  | `0.56808`, `-0.28404` "filter taps" | ABSENT |
  | `0.000038666` "the missing coeff" | ABSENT |
  | `0.24184303`, `1.4754223`, `0.83815932` | ABSENT |
  | `0.6428789` | present (genuine — it's in the voice-init table) |

  Its own notes confirm fitting: *"APPLIED to fitted filter"*, *"calibrated to
  0.539x from P6 audio"*, *"fixed 4x level deficit"*, *"Needs targeted
  re-capture"*. This is exactly the "poison" the handoff warns against. Only ever
  used here as a loose sanity cross-reference — never as a value source.

- **`frida_chorus_coeffs.js`** — a capture *script* (not data) reading chorus
  offsets `0x419410…`. The golden dump itself states the chorus was "NOT
  initialized/active" in that capture and the offsets may be wrong. Not relied on.

## CHORUS — derive from code; recapture only if a value is truly runtime-only

The chorus DSP object is heap-allocated; its coefficients are **computed at
runtime** (BBD clock from sample rate, LFO rate/depth, mix). The chorus
**algorithm** is in `dsp_dump` (`0x1803C5070` init, `0x1803C52E0` process, BBD
stages). Plan: transcribe the chorus code and **derive** its coefficients from
the algorithm + sample rate. Only if a genuinely runtime-only value remains
unknown after transcription do we do a **fresh, correct Frida capture with chorus
confirmed ON** — with a corrected script, not the old one.
