#!/usr/bin/env python3
"""NON-CIRCULAR validation of the ONE reconstructed step in the whole chain:
the record-byte <-> dispatch-index POSITION MAP (real_recall.leaf_table(),
derived from Script.xml, never executed via the plugin's value tree).

Every gate feeds BOTH sides values decoded with this map, so a shifted position
is structurally invisible. Test: the plugin's OWN descriptor DB (rva 0x98c040 +
16*idx) declares [min,max] for every dispatch index. If the map were shifted,
decoded values would fall OUTSIDE their declared range (e.g. a 0..5 enum
receiving 217). Run it over EVERY patch of BOTH banks.

PROVEN inputs: values come from the plugin's own record parser; ranges from the
plugin's own descriptor table. Oracle-only (Unicorn)."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_bank_parse as RB, real_recall as RR, truth

BANKS = [('FACTORY', truth.BANK),
         ('CHILLWAVE', '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')]

e = E.E2E(); uc = e.uc
NT = E.IB + 0x9a0030
DESC = E.IB + 0x98c040
def pname(idx):
    p = int.from_bytes(uc.mem_read(NT + 8*idx, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 128:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')
def drange(idx):
    mn, mx, df, tg = struct.unpack('<iiii', uc.mem_read(DESC + 16*idx, 16))
    return mn, mx, df

leaves = RR.leaf_table()
print("leaves in position map: %d" % len(leaves))
total = bad = 0
badrows = []
for tag, path in BANKS:
    bank = open(path, 'rb').read()
    recs = RB.parse_records(bank)
    for p in range(64):
        for (disp, bb) in leaves:
            v = RB.record_value(recs[p], bb)
            mn, mx, df = drange(disp)
            total += 1
            if not (mn <= v <= mx):
                bad += 1
                badrows.append((tag, p, disp, pname(disp), bb, v, mn, mx))
    print("  %s: checked" % tag, flush=True)

print("\nchecked %d (leaf x patch) values against the plugin's own declared ranges" % total)
print("OUT-OF-RANGE: %d" % bad)
seen = set()
for r in badrows:
    key = (r[2], r[5])
    if key in seen: continue
    seen.add(key)
    print("   %s patch %2d disp %4d %-24s recb %4d value %4d NOT in [%d,%d]" % r)
    if len(seen) > 60: print("   ..."); break
print("\nVERDICT:", "POSITION MAP consistent with the plugin's own declared ranges"
      if bad == 0 else "*** %d out-of-range -> position map suspect ***" % bad)
