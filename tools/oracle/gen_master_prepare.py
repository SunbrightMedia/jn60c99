#!/usr/bin/env python3
"""Emit C for the shared/master-region gaps from the full A/B (/tmp/algo_gap.json
+ /tmp/fx_cell_gap.json). Excludes offset 136 (the params-vector pointer, owned
by juno_driver_attach_host at runtime) and offset 4 (pure object-header count).
All emitted as raw 32-bit patterns (JI) so int and float cells are bit-exact.
"""
import json, struct
def f32(u): return struct.unpack("<f", struct.pack("<I", u))[0]

algo = json.load(open("/tmp/algo_gap.json"))          # [[off, emu], ...]
cells = json.load(open("/tmp/fx_cell_gap.json"))      # [[off, emu, cnocap, name], ...]

EXCLUDE = {136, 4}     # params pointer (attach_host) + object header count

rows = []
for o, ev in algo:
    if o in EXCLUDE: continue
    rows.append((o, ev, "algo const"))
for o, ev, cv, nm in cells:
    if o in EXCLUDE: continue
    rows.append((o, ev, nm))
rows.sort()

print(f"/* {len(rows)} shared/master-region prepare constants */")
for o, ev, tag in rows:
    fv = f32(ev)
    # show float if it looks like one, else note integer
    print(f"    JI(st, {o:9d}) = 0x{ev:08x};  /* {fv:>13.6g}  {tag} */")
print(f"\n/* excluded (runtime-owned): {sorted(EXCLUDE)} */")
