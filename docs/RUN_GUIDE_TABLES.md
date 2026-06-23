# How to run `extract_tables.py` (final voice-engine data dump)

A tiny **pure-data** dump (no decompiling, instant) of the three `.rdata` lookup
tables `voice_render` indexes. Earlier dumps captured individual constants; this
captures the full table bodies. This is the last data the voice engine needs.

## Steps
1. In IDA, same analyzed Cloud 60 database, **AU: idle**.
2. **File → Script file…** → `tools/extract_tables.py`.
3. It writes a single file: **`tables_dump/tables.txt`** next to the database.
4. **Upload `tables.txt`** here (it's small — you can paste it or attach it).

## What it captures
- A float window over `0x18098AC00…0x18098AE00` — the two exponent/`ldexp`
  scaling tables (`dword_18098ACC0[]`, `dword_18098AD3C[]`) and their neighbours.
- `unk_1809894E0` — the pitch spline: 29 rows × 26 doubles (208-byte stride).

That's everything. After this, the voice engine transcribes end-to-end with no
further extraction.
