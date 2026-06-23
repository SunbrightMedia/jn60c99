# Option B — transcribe the parameter→coefficient setter: plan & decision point

## Goal
Get the 349 runtime-applied coefficients (`docs/COEFF_PARAM_MAP.md`) by transcribing
the code that computes them — verifiable, general — instead of reading opaque
numbers out of the live plugin.

## What we established (from data in hand, no new extraction)
- The 349 coefficients are **registered parameters**: `sub_180388170` registers
  ~1121 of them, each `lea rax,[rdi+slot]` (target) + a descriptor → registrar
  `sub_1803ABA00` (1086×), `sub_1803ABA40` (31×), `sub_180387F80` (4×).
- **312/349 mapped to a parameter name** (`docs/COEFF_PARAM_MAP.md`).
- **41/349 register with default 0** (`xorps`) → already correct in our zero-init.
- The descriptor's "default" constant is `xmmword_18098C030` = bytes `{1,0,0,0}` —
  a **type flag, not a value**. So the registration does NOT carry the coefficient
  value; it is applied downstream by the parameter system.

## The fork (what the next dump decides)
`tools/extract_param_setter.py` dumps `sub_1803ABA00` (+ the other registrars and
their callees) and the default-constant bytes. It answers one question:

- **If the registrar writes a usable default into `*slot`** (e.g. denormalize a
  per-parameter default via a simple curve) → Option B is tractable: transcribe
  that one apply/denormalize function + read each parameter's min/max/curve, and
  compute all 349 coefficients at init. Verifiable and general. **Do B.**
- **If it only stores metadata** and the value comes from a preset blob / host
  automation we don't have → Option B = transcribing the whole parameter+preset
  framework (large, mostly non-DSP) and still needs preset data. Disproportionate.
  **Fall back to a validated runtime capture** — now far safer because we can
  cross-check each captured value against its parameter name (an on/off slot must
  read 0/1; "Part Tune" ≈ centred; etc.) and against time-invariance.

## Either way, the arbiter is behavioral
No coefficient source (computed or captured) is "true" until the port, given the
same note, produces the same output as the plugin sample-for-sample. That A/B
harness is the thing that actually proves correctness and is worth building next
regardless of which branch we take.

## Run
See `docs/RUN_GUIDE_PARAM_SETTER.md`. Output `param_setter/` → upload.
