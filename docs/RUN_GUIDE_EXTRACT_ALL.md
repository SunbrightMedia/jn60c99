# How to run `extract_all.py` — the one-and-done full extraction

After this, **no more IDA sessions.** It dumps the entire plugin's code so every
remaining piece (the note/MIDI handler #1, the parameter appliers #2, and
anything else) is findable OFFLINE by searching the result.

## Steps
1. Your analyzed JUNO-60 database, **AU: idle**.
2. **File → Script file… → `tools/extract_all.py`**.
3. It decompiles thousands of functions — **this takes a while** (could be
   10–30 min). It logs progress every 2000 functions. Let it finish.
4. Output folder **`allcode/`** appears next to the database.
5. **Zip `allcode/` and upload it.** It's text, so it compresses a lot.

## What it contains
- `manifest.tsv` — every function: rva, name, size, #xrefs, #callees, and the
  **string literals it references** (so handlers can be located by their strings).
- `decomp_XXXXXX.c` — Hex-Rays decompile of all plugin functions (RVA < 0x600000),
  grouped into ~256 KB buckets.
- `asm_XXXXXX.asm` — disassembly of the same, same buckets.

That's the whole plugin. From it I locate and transcribe the note handler and the
parameter appliers, and validate each against the captured ground truth — with no
further extractions.

If the zip is too big to upload in one piece, upload `manifest.tsv` + the
`decomp_*.c` files first (I can work from decompile alone for most of it; asm is
only needed for occasional SIMD-arg resolution).
