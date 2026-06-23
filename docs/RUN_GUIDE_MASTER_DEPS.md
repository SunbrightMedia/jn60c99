# How to run `extract_master_deps.py` (final chorus/master extraction)

Gets the last pieces needed to transcribe the master/chorus (`sub_180363380`)
exactly: 3 small wave helpers, the master's disassembly (for dropped XMM args),
and the chorus-coefficient generator (found by scanning for functions that touch
the chorus coefficient offsets).

## Steps
1. IDA, same analyzed database, **AU: idle**.
2. **File → Script file…** → `tools/extract_master_deps.py`.
3. It dumps the helpers + asm instantly, then scans ~45k functions for the
   coefficient generator (a few minutes; progress every 5000).
4. Output folder **`master_deps/`** appears next to the database. **Zip and
   upload it.**

## What it contains
- `helper_*.c` / `helper_*.asm` — the 3 wave helpers + their disassembly.
- `master_sub_180363380_*.asm` — disassembly of the master (to pin dropped args).
- `coeff_gen_ranking.md` + `coeffgen*_*.c` — the function(s) that write the
  chorus coefficients, ranked and decompiled.

After this, the master/chorus transcribes end-to-end with no further extraction.
