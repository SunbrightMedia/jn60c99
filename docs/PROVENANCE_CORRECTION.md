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
