#!/usr/bin/env python3
"""Find every value-tree leaf whose PLUGIN-DECLARED range is SIGNED (min < 0).
Our decode dec()/record_value() returns an unsigned 0..255 byte, so any signed
leaf is fed a wrong value whenever the stored byte is negative (>=128).
Cross-check against both banks to see which are actually exercised."""
import sys, struct, os
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, real_bank_parse as RB, truth

e = E.E2E(); uc = e.uc
NT = E.IB + 0x9a0030
DESC = E.IB + 0x98c040
def pname(i):
    p = int.from_bytes(uc.mem_read(NT + 8*i, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 96:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')
def drange(i):
    return struct.unpack('<iii', uc.mem_read(DESC + 16*i, 12))

leaves = R.leaf_table()
signed = [(d, bb) + drange(d) for (d, bb) in leaves if drange(d)[0] < 0]
print("SIGNED-range leaves in the position map: %d\n" % len(signed))
banks = [('FACTORY', truth.BANK),
         ('CHILLWAVE', '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')]
parsed = {t: RB.parse_records(open(p, 'rb').read()) for t, p in banks}
for (d, bb, mn, mx, df) in signed:
    print("disp %4d  %-26s recb %4d  range[%d,%d] default %d" % (d, pname(d), bb, mn, mx, df))
    for t, _ in banks:
        vals = {}
        for p in range(64):
            v = RB.record_value(parsed[t][p], bb)
            vals.setdefault(v, []).append(p)
        bad = {v: ps for v, ps in vals.items() if not (mn <= v <= mx)}
        print("    %-10s distinct raw values: %s" % (t, sorted(vals)))
        if bad:
            for v, ps in sorted(bad.items()):
                sv = v - 256 if v >= 128 else v
                inr = mn <= sv <= mx
                print("      OUT-OF-RANGE raw %d on patches %s -> as int8 = %d (%s)"
                      % (v, ps, sv, "IN range" if inr else "still out"))
