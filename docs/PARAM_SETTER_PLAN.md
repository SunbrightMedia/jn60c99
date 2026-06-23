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

## RESOLVED (param_setter/ dumped): Option B is NOT tractable as a recipe
`sub_1803ABA00` turned out to be plain `std::vector::push_back` of a 40-byte
descriptor `{name, &slot, type-flag}`; its whole callee tree is vector machinery
(grow/realloc/move/throw). **It writes nothing to the coefficient slots.** So the
values are applied later by the host/preset driving per-parameter setters — the
full parameter framework, dependent on default/preset data absent from static
dumps. Transcribing that is disproportionate and still needs the host's values.

**Decision: pivot to a *validated* runtime capture** (Option A, hardened):
- base-pointer sanity: known fields must read their static values
  (`state[2199956]==0x80000`, `state[95828]==1024`, `state[101028]==1024`);
- coefficient-vs-state: capture twice; anything that changes between snapshots is
  per-sample state, not a coefficient — drop it;
- semantic cross-check: each value against its parameter name
  (`docs/COEFF_PARAM_MAP.md`) — an on/off slot must read 0/1, "Part Tune" centred;
- final arbiter: sample-accurate A/B of port vs plugin on the same note.

The capture script `tools/capture_runtime_coeffs.js` now does the first three.

## (historical) The fork (what the next dump decided)
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
