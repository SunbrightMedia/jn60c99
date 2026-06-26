# Provenance correction — `state_t0`/`runtime_coeffs` is NOT SQ Dynamic ARPG

This supersedes the claim recorded in commit `330499c` and in
`refs/db_engine_map_full.json` that `state_dump/state_t0.bin` / `state_t1.bin`
(and the `src/runtime_coeffs_data.c` derived from them) are a capture of bank
**record 1, "SQ Dynamic ARPG."** That identification is **wrong**, and a chain of
analysis built on it (the "the loader corrupts the SQ ARPG state / 34-of-49
coefficients mismatch" conclusion) was a measurement ghost: it compared the
SQ-ARPG-loaded engine state against a capture of a *different* preset.

## The hard test that settles it

The ENV1 attack coefficient at engine offset **2784** is a direct,
preset-specific function of the patch's ATTACK step (`DB784`) via the attack-rate
table `lut35`. It is the hardest value to match by coincidence.

| Source | offset 2784 | = lut35(step) | implied ATTACK step |
|---|---|---|---|
| `state_t0.bin` / `state_t1.bin` / `runtime_coeffs_data.c` | `0x3b42b82a` = 0.00297 | lut35(**197**) | ~197 (slow / pad) |
| `captured_patch.c` | `0x3e378a96` = 0.17924 | lut35(**53**) | 53 (record 0) |
| bank record 0 "SY Poly Synth", `DB784` decode | — | — | **53** ✓ |
| bank record 1 "SQ Dynamic ARPG", `DB784` decode | — | — | **0** (fast / arp) |

- `state_t0` attack (step ~197, slowest) ≠ SQ ARPG (`DB784` step = **0**, fastest).
  An arp patch has a fast attack; a pad has a slow one. `state_t0` is a **pad**.
- No factory record in `bank1.bin` has `DB784` step = 197, so `state_t0` is an
  out-of-bank / edited patch — exactly matching its own file header in
  `runtime_coeffs_data.c`: *"captured … for preset 'PD The Juno Pad'."*
- `captured_patch.c` attack (step 53) **does** match record 0 — so
  `captured_patch.c` is a genuine record-0 ("SY Poly Synth") capture, and the
  loader's mechanism validation against it (23/24 params) **still holds**.

## Why the earlier "rec1" and "rec0" proofs were coincidences

`db_engine_map_full.json` simultaneously asserted `state_t0` = rec1 (via the delay
send `DB796`=96) **and** = rec0 (via reverb time `DB877`=170) — two mutually
exclusive claims in the same file. Both used single-point matches on FX nodes that
can collide across presets; neither survives the attack-coefficient test, which is
preset-specific and rules out **both** records 0 and 1.

## Consequences

1. **The loader is not corrupting SQ ARPG.** For record 1 it correctly applies a
   fast-attack arp patch (`lut35(0)`); the "corruption" was an artifact of diffing
   against the wrong preset's capture.
2. **There is no captured oracle for SQ Dynamic ARPG.** The only real captures we
   hold are `captured_patch.c` (record 0, "SY Poly Synth") and `state_t0`
   ("PD The Juno Pad", out of bank). The SQ ARPG render is therefore verified only
   *indirectly*: the DSP is bit-exact vs the decompile, and the loader mechanism is
   validated vs the record-0 capture.
3. The **REVERB LEVEL → node 10759440** binding remains correctly removed (the ECF
   ctor `sub_7FF91E01CCC0` writes that node unconditionally; decompile evidence,
   independent of the oracle question).

## Seed breakdown — does the capture actually change the SQ ARPG sound?

Quantified the 279-coeff seed against the full render pipeline (preset load +
driver attach + reverb activate) with the seed disabled:

| bucket | count | verdict for SQ ARPG |
|---|--:|---|
| Pipeline already MATCHES the captured value | 9 | redundant |
| Loader DIFFERS (correctly overrides with SQ-ARPG values) | 21 | seed value is the *wrong* (pad) value, but the loader wins → correct |
| Pipeline leaves ZERO (survives from capture) | 249 | analysed below |

Of the 249 survivors:
- **~119 FX coefficients** (chorus 6396xxx ×40, delay 6497xxx ×17, reverb
  10759xxx ×45, FX-A 4297xxx ×17). These depend only on the chorus MODE / reverb
  TYPE selectors. **SQ ARPG and the captured "PD The Juno Pad" share the same
  selectors (chorus mode 2, HALL2/type 3)**, so the seeded FX coefficients are
  *coincidentally correct* for SQ ARPG. (They would be wrong for a preset with a
  different chorus mode / reverb type — a real global-accuracy gap.)
- **~106 voice-region constants.** Mostly preset-INDEPENDENT: the M.CV pitch base
  `6.66847` (repeated ×12), unity `1.0` switches, velocity-curve constants. These
  are the same for every patch, so seeding them is correct (they should be written
  by `engine_init`, which currently doesn't).
- The envelope-block offsets 2592–2768 (and 3072–3248) are **per-sample state**,
  not config — `voice_render.c:941–987` reads and rewrites them every sample. They
  look "stable" only because both capture snapshots caught steady-state sustain.

**Conclusion:** for SQ Dynamic ARPG specifically, the seed does **not** materially
change the sound — the FX coeffs are coincidentally correct, the constants are
preset-independent, the params are loader-overwritten, and the envelope siblings
are self-overwriting state. Eliminating the capture is a **capture-free *purity*
goal** (and a **global-accuracy** fix for presets whose chorus-mode/reverb-type
differ from the captured pad), **not** the cause of "SQ ARPG sounds off."

The remaining audible gap is therefore most plausibly the **arp performance
harness** (`host/render_test.c` retriggers a single voice 0 rather than the
plugin's polyphonic arp voice allocation, with a host-derived BPM/gate) and/or
genuine analog-domain modeling — not a static-coefficient transcription bug.
