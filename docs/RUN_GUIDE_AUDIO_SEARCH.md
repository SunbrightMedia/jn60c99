# How to run `extract_audio_search.py` (find the chorus + mix/output, statically)

The chorus and the voice-mix/output stage are reached through indirect (vtable)
calls, so the call-graph walk missed them. This finds them **statically** by
ranking every function by floating-point-DSP density — real DSP scores high,
threading/CRT scores ~0 — and dumping the top candidates not already ported.

## Steps
1. In IDA, same analyzed Cloud 60 database, **AU: idle**.
2. **File → Script file…** → `tools/extract_audio_search.py`.
3. It scans all ~45k functions (a few minutes; progress prints every 5000).
4. Output folder **`audio_search/`** appears next to the database:
   - `ranking.md` — all functions ranked by float-op count.
   - `NNN_*.c` — decompiled pseudocode of the top ~40 unknown DSP candidates.
5. **Zip `audio_search/` and upload it.**

## What I'll do with it
Identify the stereo BBD chorus and the voice-mix/output function by their DSP
shape (delay line + modulation for chorus; 8-voice summation for the mix), then
transcribe them exactly — same verbatim approach as voice_render. This keeps the
whole engine bit-accurate to the original (your stated preference) with no
guessing and no Frida.

If the chorus reads runtime-computed coefficients not present statically, the
dumped code will show exactly which, and we handle only those at that point.
