# Run guide — extract the data sections (one-time, static)

The code-only `allcode` dump didn't include `.rdata`/`.data` (coefficient/tempo
tables, C++ vtables, the preset schema, scalar constants). This reads the **same
IDB you already have** and exports all of it at once — no runtime, no Frida, no
audio. After this, no further data asks for the FX/arp/preset work.

## Steps
1. Open the JUNO-60 IDB in IDA (the one used for `allcode`).
2. **File → Script file…** → select `tools/extract_data_sections.py`.
3. Wait for `[data] DONE.` in the Output window.
4. Zip the `data_sections/` folder it created (next to the `.idb`) and upload it.

## What it produces
- `segments.tsv` — every segment (name, RVA range, size, code/data flag).
- `seg_*.bin` — raw bytes of each **data** segment (the actual `.rdata`/`.data`).
- `data_symbols.tsv` — every named item in data (RVA, size, name) → lets me locate
  any table by name.
- `vtables.tsv` — every C++ vtable resolved to `slot → target function name`
  (this is what makes the delay/arp/reverb's indirect calls resolvable).
- `named_tables/*.bin` — the specific FX/arp/gate tables, pre-cut.

## Why this unblocks everything
- Reverb coeff tables, delay tempo table → `named_tables/` + the data segs.
- Delay/arp process methods → resolved via `vtables.tsv`.
- Bonus: the preset-format schema and the `unk_63EB50` gate constant come along too.

It's a few MB at most. If the upload is large, the two files I need first are
`vtables.tsv` and `data_symbols.tsv` plus `named_tables/` — but the whole folder is
ideal so I never have to ask again.
