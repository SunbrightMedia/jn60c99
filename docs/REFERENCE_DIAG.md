# Reference-render diagnosis — SQ Dynamic ARPG

A render from the **real plugin** was provided as a diagnostic oracle ONLY (fixes
must come from the decompiled code, never by fitting to the render). Measured
differences vs our capture-free render, to direct the code investigation.

## Measured (reference = original plugin; ours = `host/render_test.c`)

| Property | Reference | Ours | Finding |
|---|---|---|---|
| Arp note rate | IOI 0.128 s | 0.125 s | ✓ matches (1/16 @ 120 BPM) |
| Input chord octave | C5-E5-G5 (midi 72/76/79) | was C4-E4-G4 | **FIXED** — render at octave 5 |
| Within-note pitch drift | ~7 cents | ~6 cents | ✓ comparable (NOT a fast wobble) |
| Spectral centroid (0.6-2.5s) | 3428 Hz | **5147 Hz** | **ours ~1.5× too BRIGHT** |
| Rolloff 85% | 6768 Hz | 10307 Hz | ours too much HF energy |
| Arp note sequence | irregular (repeats) | clean UP cycle | possible **dynamic PATTERN**, not simple UP |

## Open investigations (agents, code-only fixes)

1. **Too bright (1.5×)** — the dominant "doesn't sound like the original" factor.
   Suspect: VCF cutoff/env-mod/key-follow too open, or a mis-bound filter param.
   (VCF ENV MOD step 190, KEY FOLLOW step 255 are high.) Audit the 22 param
   bindings against `refs/param_registry.json` (authoritative offset↔name).
2. **"Weird pitch drift"** — NOT within-note (that's stable ~6c). Suspect a
   slower cross-note effect: the patch's LFO→pitch (DCO LFO MOD step 128, LFO RATE
   step 63) spanning the arp, or the chorus. Verify the LFO rate/depth are faithful
   to the code (the reference, with the same patch params, does NOT drift — so a
   coefficient/binding is likely wrong, e.g. LFO RATE tableId → wrong Hz).
3. **Arp pattern** — "Dynamic ARPG" may use a CKbdArp programmed pattern, not the
   base UP engine. Re-decode TYPE/RANGE/STEP from the bank's stride-4 region (same
   decode class as the FX selectors, which had a stride bug).

## Rule
Use the reference to *characterize the target only*. Every fix must trace to the
decompiled code / bank data. Do not tune constants to match the render.
