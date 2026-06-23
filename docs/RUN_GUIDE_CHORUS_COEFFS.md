# How to run `extract_chorus_coeffs.py` (chorus coefficient generator dump)

The stereo BBD chorus in `sub_180363380` reads ~250 read-only coefficient
offsets that the voice initializer `sub_1803990C0` does **not** write. They are
produced at runtime by **`sub_180388170`** — but **Hex-Rays returns None** on
that function, so its algorithm cannot be read from pseudocode. This script dumps
the one thing static decompilation can't give us: its **disassembly**, plus how
it's **called** (to recover its arguments) and the **values** of every `.rdata`
float it references.

Until this is captured the chorus coefficients are zero and the port keeps the
**dry path correct** (chorus is inert). This dump unblocks the exact transcription
of the coefficient math.

## Steps
1. IDA Pro 9.3, same analyzed database, **AU: idle**.
2. **File → Script file…** → `tools/extract_chorus_coeffs.py`.
3. Runs in seconds (no full-database scan this time — the targets are known).
4. Output folder **`chorus_coeffs/`** appears next to the database. **Zip and
   upload it.**

## What it contains
- **`coeffgen_sub_180388170_*.asm`** — the primary artifact: full disassembly of
  the coefficient generator (the algorithm to transcribe).
- `coeffgen_sub_180388170_*_callers.asm` — ~40 instructions of context before
  each call site, so the generator's arguments (sample rate / mode / param
  pointers in `rcx/rdx/r8/xmm0…`) are recoverable.
- `coeffgen_sub_180388170_*_constrefs.txt` — every data address it references,
  with `f32`/`f64` interpretations: the genuine coefficient values it multiplies.
- `zeroinit_sub_1803A1300_*` — secondary; `sub_1803A1300` already decompiles (a
  zeroing/ctor init), dumped only for completeness.

After this is uploaded, `sub_180388170` can be transcribed exactly and the chorus
coefficients become real — no fitting, no guessing.
