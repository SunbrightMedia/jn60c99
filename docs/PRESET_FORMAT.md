# Preset/patch data — parsing patch values from the plugin's own files

The DSP **algorithm** is fully transcribed from code. A specific **patch** (the
values that make "PD The Juno Pad" sound the way it does) is **data**, stored in the
plugin's installed files — not in the executable. This is the principled,
capture-free source for patch coefficients. Reconnaissance from the loader code:

## Formats the loader recognises (`sub_18033CF30`, format-detect)
`.s8p`, `.PRM`, `PLUGOUT_PATCH`, `.bin`, `.txt` — dispatched to per-format parsers.

## Where patch values live (string refs in the loader region)
- `data_fact_patch%d_bank%c.inc` — **factory patch banks** (`sub_18033A0F0`); the
  decompile shows `// PATCH NAME %03d-%03d` comments, so these `.inc` files are
  likely text/include data with named patches.
- `data_init_patch%d.inc` — the init/default patches.
- `.bin` patch banks + `/InstalledBankNames.dat` (`sub_18032FD50`, `sub_18033D50`).
- A string-keyed parameter layer (`sub_18034E3E0`) addresses params by name, e.g.
  `fm.PATCH.FLT.VCF CUTOFF FREQ`, `fm.PATCH.LFO.LFO RATE` — these map onto the same
  parameter IDs as docs/PARAM_MAP.tsv.

## Plan
1. Obtain one real patch file from the installed plugin (a factory `.inc`/`.bin`
   bank, or a preset exported as `.s8p`).
2. Identify its format from the magic/extension and transcribe **only that format's
   parser** (`sub_18033C330` deserialize for the matching branch) — reading the byte
   layout faithfully rather than re-implementing all of the C++ std::string plumbing.
3. Map parsed param values -> flat-state offsets via docs/PARAM_MAP.tsv and write
   them the same way `juno_runtime_coeffs_apply` does (raw store). Result: named
   presets sourced from the plugin's own data, no capture.

## What I need
One of:
- a factory bank file: `data_fact_patch*.inc` or a `*.bin` patch bank from the
  plugin's install/resources (+ `InstalledBankNames.dat` if present), **or**
- a single preset exported from the plugin UI as **`.s8p`** (e.g. PD The Juno Pad).

Typical locations: the plugin's resource/data folder under the Roland Cloud install,
or wherever the plugin's "export patch" writes. Attach the file and I'll reverse the
layout and build the parser for that format.

## The file you provided (5c53067b-1_Preset.bin)
- Magic `KoaBankFile00003`, product `PG-JU60`, bank name `SY Poly Synth`.
- 1,294,295 bytes. It is a BANK: one real patch at the front (~bytes 39–4900),
  then ~4096 empty 236-byte init slots (repeating `$$$$$$$$`/`11111111` markers,
  stride 236, in 64 groups separated by 5355-byte gaps).
- Patch values are stored POSITIONALLY as small integer/nibble bytes; the field
  names (`fm.PATCH.FLT.VCF CUTOFF FREQ`, `…RATE H`, …) are the code's schema, not in
  the file. The "H" suffixes are high-resolution high-bytes (8-bit base + extension).

## Decoding cost (honest)
Faithful decode needs the schema (field order + size + per-field scaling) from the
config-driven deserializer `sub_18033C330`/`sub_18033DD00` (format descriptor:
patchIdPosition/Size, bankNamePosition/Size, nonActiveAreaPosition/Size, …). This is
the largest remaining transcription, and mostly generic Roland-framework plumbing
shared across products (SH-101/SH-2/System-8/…), not JUNO DSP. Guessing the scaling
is forbidden, so this is a real sub-project — tracked here, decision pending.
