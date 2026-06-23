# How to run `extract_init.py` (recover the missing coefficient values)

This grabs the coefficient *values* that `voice_render` and the chorus read but
never set — the numbers filled in by startup/constructor code that wasn't in the
first dump. Run it the same way as `extract_dsp.py`, in the same IDA database.

## Steps

1. In IDA, with the Cloud 60 database already open and analyzed (bottom bar
   **AU: idle**) — the same one you used before.
2. Menu **File → Script file…** → choose `tools/extract_init.py`.
3. Watch the **Output window**. You'll see:
   ```
   [extract_init] scanning 45223 functions for .rdata float references…
   [extract_init]   …5000/45223 scanned
   ...
   [extract_init] decompiling top 60 initializer candidates…
   [extract_init] DONE. Wrote ... to ...\init_dump
   ```
   The scan touches every function, so give it a few minutes.
4. A folder **`init_dump/`** appears next to the database. **Zip it** (right-click
   → Send to → Compressed folder) and **upload `init_dump.zip`** here.

## What it produces

- `init_ranking.md` — the functions that load the most float constants (the
  coefficient initializers, ranked).
- `000_*.c … 059_*.c` — their decompiled pseudocode, each listing the exact
  `.rdata` float values it uses. This is what maps **value → struct field**.
- `global_float_constants.txt` — every float constant referenced anywhere in the
  code, as a safety net so no stored value is missed.

## Important honesty note

This recovers every coefficient that is **stored** as a static constant. A few
**chorus** values are **computed at runtime** (from the sample rate at init) and
are not constants anywhere — those come from the old project's **Frida** files
(`frida_chorus_coeffs.js`, `captures/golden_dump_*.txt`). If you can find those
too, upload them; if not, we can do one short Frida run later when we reach the
chorus. The voice path should be fully covered by this script.
