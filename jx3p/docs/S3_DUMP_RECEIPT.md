# JX-3P — THE IDA DUMP IS COMPLETE (receipt, second run)

The corrected `ida_extract_all.py` was run once on `JX3P.vst3`. This is the
verification of that dump against the completeness contract — checked against the
files on disk, not the manifest's word.

## Verdict: COMPLETE. IDA is not needed again.

| contract item | result |
|---|---|
| DSP vtable methods decompiled | **305 / 305, zero missing** (542 method files on disk, all present) |
| voice classes the FIRST dump lost | FltVoice 43/43, LfoVoice 13/13, AmpVoice 12/12, EnvVoice 34/34, EfxPh 10/10, OscVoice 34/34, VoiceMix 33/33, Mst 25/25 |
| master process 0x35D450 (missed before) | present; callees resolve |
| real per-sample DSP math | present — 9 render loops at ~4045 float refs each (regular 0x7650 stride), and the OscVoice process chain bottoms out in real math at 0x3F4AC0 |
| constant tables have VALUES | 2,204 `f32:`/`i32:` arrays with values |
| decompile failures | 2 of 1,909 — both large dispatchers (`CJx3pSim` first method 0x3667D0; 0x377210), NOT math leaves, each with full disassembly in `01_closure.asm` (12,248 / 8,567 asm lines) as the transcription fallback |

## The .Dat question — ANSWERED: not needed

**Zero** decompiled functions reference `Code1.Dat`, `Code8_*`, or any `.Dat`
file. The render path does not open them, exactly as the JUNO port (which needs
no `.Dat` at all). So the two missing `Code8_*` banks are NOT required for the
bit-exact port. Code1.Dat / Code8_1.Dat stay in `truth/` as installer/UI data,
unread by the port.

## Dump shape

1,909 functions total: 1,855 in the DSP band + 54 from the call-graph closure.
Band 0x180346CC0..0x1803FEB70. Contrast the first dump: ~6,000 functions, mostly
JUCE/Gdiplus/CRT, with 132 of the real DSP methods missing. The band strategy
did what it was built to do.

## What this unlocks

S2's execution half and all of S3 (transcription) proceed with NO further IDA
dependency. The two asm-only functions are transcribed from `01_closure.asm` if
and when the port needs them; neither is on the per-sample audio path.
