#!/usr/bin/env python3
"""Independent check that BS Solid's ASSIGN MODE really is 2 — using the PLUGIN'S
OWN leaf table (dispatch->record byte) and the PLUGIN'S OWN record parser and name
table, keyed by DISPATCH INDEX (798/799/800), never by our blob-position guess.
Parse only, no render."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_bank_parse as RB, real_recall as RR

CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
import truth
e = E.E2E(); uc = e.uc
NT = E.IB + 0x9a0030
def pname(idx):
    p = int.from_bytes(uc.mem_read(NT + 8*idx, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 128:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

leaves = dict(RR.leaf_table())          # dispatch -> record/blob byte, PLUGIN-DERIVED
print("plugin's own leaf table entries for the voice-assign family:")
for d in (798, 799, 800):
    print("   disp %d %-14r -> record byte %s" % (d, pname(d), leaves.get(d, "NOT IN LEAF TABLE")))

for nm, path, idxs in (("CHILLWAVE", CW, [3, 4, 30]), ("FACTORY", truth.BANK, [0, 5, 61])):
    recs = RB.parse_records(open(path, 'rb').read())
    print("\n=== %s (plugin's own parser) ===" % nm)
    for i in idxs:
        vals = []
        for d in (798, 799, 800):
            bb = leaves.get(d)
            vals.append("%s=%s" % (pname(d), RB.record_value(recs[i], bb) if bb is not None else "?"))
        print("  p%-2d  %s" % (i, "  ".join(vals)))
