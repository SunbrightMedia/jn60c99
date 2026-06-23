# How to run `extract_param_setter.py` (Option B — the decisive dump)

This is the small, decisive dump that tells us whether transcribing the
parameter→coefficient setter ("Option B") is tractable or a tar pit. See
`docs/PARAM_SETTER_PLAN.md` for the reasoning.

## Steps
1. IDA Pro 9.3, same analyzed database, **AU: idle**.
2. **File → Script file…** → `tools/extract_param_setter.py`.
3. Runs in seconds (targets are known: the registrar `sub_1803ABA00` + variants +
   their direct callees + three constants).
4. Output folder **`param_setter/`** appears next to the database. **Zip and
   upload it.**

## What it contains
- `reg_sub_1803ABA00_*.c/.asm` — the registrar (decompile + disassembly). **This
  is the key file:** does it write a default into the coefficient slot, or only
  store metadata?
- `reg_sub_1803ABA40_*`, `reg_sub_180387F80_*` — the other register variants.
- `callee_*` — one level of callees (the mapping/apply chain, if any).
- `default_constants.txt` — the raw bytes + float/int views of
  `xmmword_18098C030`, `dword_18098BC64`, `dword_18098BE1C` (the descriptor
  defaults), so we can read them directly.

After upload I can tell within one read whether to transcribe the setter (Option
B proper) or pivot to a name-validated runtime capture.
