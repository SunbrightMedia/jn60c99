# JX-3P — S1 INTAKE + THE GO/NO-GO CHECKPOINT

Read-only analysis of the delivered material against `docs/JX3P_PLAN.md` S1.
No JX-3P byte has entered `truth/` yet — that is the first mutating step and
waits behind S0's exit gate.

## Delivered (checksummed on receipt, provenance pending phase 0)

| file | size | first 16 hex of sha256 | what it is |
|---|---|---|---|
| JX3PVST3_64bit.vst3 | 14,284,800 | 2d427ec68c3ab7d3 | PE32+ DLL, x86-64, 6 sections — the ground truth |
| Script.xml | 252,224 | (read) | the parameter schema |
| 1_Preset.bin | 1,294,295 | 61f1bdecf3a11217 | one preset bank (of four) |
| Code1.Dat | 1,245,376 | 580a8585beb8e537 | plugin data file, role TBD |
| Code8_1.Dat | 2,490,560 | 185780b0ff747b95 | plugin data file, role TBD |

⚠ Two Aug-13 `_Preset.bin` uploads also sit in the upload dir. **One of them
(`7aaabd26`) decodes to the JUNO factory names** ("SY Poly Synth"…) — it is a
JUNO bank, not a JX one, exactly the mix-up you warned about. The JX bank is
`ad7735fa-1_Preset.bin` ("String 1", "Organ 2"…). Named at phase 0 so the
wrong file can never enter `truth/`.

## THE CHECKPOINT — all four criteria PASS

The plan said: confirm the JUNO idioms hold, or stop and re-size. They hold,
decisively.

### 1. Same vendor, same architecture — CONFIRMED beyond the your-word level

The DSP class inventory is a near one-to-one map, `Jx3p` for `Ju60`:

    Osc/Flt/Env/Lfo/AmpVoice, Noise, Mst, VoiceMix/VoiceCmn, CvOut,
    PatchLev, EfxCmn/EfxCh/EfxDs/EfxOd/EfxFz  -- present in BOTH.

JX adds a few effects (EfxPh phaser, EfxCr, EfxDsType); JUNO had EfxCe/EfxMt
the JX lacks. **The skeleton the transcription follows is identical.** Same
`CPrmDSP*` parameter-plumbing classes, same boost::shared_ptr idiom.

### 2. SSE2 single precision, no FMA — CONFIRMED

Whole-`.text` instruction survey:

    mulss 10,532   addss 8,276   subss 3,231   divss 575
    vfmadd 133 (0.9%)   mulsd 1,484 (double, the pitch/tempo paths as on JUNO)

The engine is scalar single-precision SSE2. The 133 vfmadd are library math,
not the DSP loops (the JUNO's decompile showed the same, and its port is FMA-
free with `-ffp-contract=off`). The reference build stays x86 SSE2, no FMA.

### 3. Flat-state addressing — CONFIRMED

28,019 `movss` loads at large constant offsets off a base register, across
3,178 distinct offsets on the four common base registers. That is the flat
per-object state block `arm_xform.py` / `translate_*` consume, same as the
JUNO. `*(float *)(base + N)` is the transcription's input and it is present.

### 4. The render seeds are MECHANICALLY RECOVERABLE — CONFIRMED, and a tool built

`tools/rtti_seeds.py` (new, item-7) parses the PE's MSVC RTTI and prints every
DSP class's vtable and virtual slots — the roots `extract_dsp.py` climbs from.
It resolves 35 JX classes and 34 JUNO classes.

⚠ Honest scope, corrected during the work: the vtable slots are the
`process`/`reset` ENTRY points, not the render leaf. The JUNO's hand-found
render `0x180369070` is a non-virtual helper the OscVoice process slot calls,
NOT a vtable slot. So the tool replaces the human who found the *seed roots* by
hand; IDA's call-graph walk still descends to the leaf, and which slot is
`process` is confirmed against the decompile. It does not skip phase 1, it
feeds it.

## The bank mix-up, quantified — and why the JX bank is genuinely JX

The Aug-13 `7aaabd26` "twin" differs from the JUNO truth bank at **exactly two
bytes, offsets 20346-20347, both inside patch 1** — a JUNO bank with one patch
nudged, not a JX bank. It decodes to JUNO names because it essentially *is* the
JUNO bank. It must never enter `jx3p/truth/`.

The real JX bank (`ad7735fa`) is 99.0% byte-identical to the JUNO bank, which
looked alarming until measured: the JUNO bank is **94.1% zeros** (the
20,223-byte stride is mostly padding), and the JX bank differs across **all 64
patches**, ~194 bytes each — the actual patch payload. It is genuinely
different data in the same container, not a renamed copy.

## The preset bank is a BYTE-COMPATIBLE container

The JX bank is exactly 1,294,295 bytes = `23 + 20223 * 64` — the JUNO's header,
stride and patch count to the byte — and its names decode with the JUNO's own
`juno_bank_patch_name`. So the bank-geometry half of `synth/jx3p.json` is
already known: header 23, stride 20223, 64 patches. The per-patch BYTE LAYOUT
(which offset is DELAY TYPE, etc.) is NOT assumed from this — it is derived in
S2 by perturb-and-diff, because a shared container can still reorder fields.

## THE ONE GENUINE UNKNOWN — the .Dat files

`Code1.Dat` and `Code8_%d.Dat` are referenced by BOTH DLLs (one ref each), but
the JUNO port never reads them — its bit-exact render needs neither. Two
readings, and the oracle settles it in S1/S2, not argument:

* **If the JX render path faults opening `Code1.Dat` under the emulator**, they
  are ground truth (wavetables or coefficient pages) and all four `Code8_*`
  are needed — you have 2 of 4.
* **If it renders without them**, they are installer/UI data (bank-name tables,
  the `TextCodeTable.dat` also referenced) and irrelevant to the port.

Their entropy (Code1 6.63, Code8_1 5.25 bits/byte) is consistent with either
structured tables or packed coefficients — inconclusive by inspection, which
is why it is an emulator question. **Recorded as the single open item; flagged
to you now rather than discovered mid-S2.**

## VERDICT

**PROCEED. Timeline stands (5 sessions nominal, 7 with slack).** Every S1
criterion passed; the only open item is whether two more `Code8_*` files are
needed, answerable early in S2 and cheap to supply if so. No re-scope.
