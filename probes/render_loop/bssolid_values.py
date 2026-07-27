#!/usr/bin/env python3
"""Dump BS Solid (Chillwave #3) with the PLUGIN'S OWN parameter names, values
produced by the PLUGIN'S OWN record parser. Cross-checks the port's binding
table by dispatch index rather than by our own labels."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_bank_parse as RB, real_recall as RR

BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
bank = open(BANK, 'rb').read()
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

leaves = RR.leaf_table()
recs = RB.parse_records(bank)
IDX = 3
rec = recs[IDX]
print("BS Solid = Chillwave #%d — plugin-parsed values, plugin's own names\n" % IDX)
print("disp  rec_b  value  name")
for (disp, bb) in leaves:
    n = pname(disp)
    if n.startswith('(') or n == '_NULL_':   # JU-06A-only / unused on JUNO-60
        continue
    print("%4d  %5d  %5d  %s" % (disp, bb, RB.record_value(rec, bb), n))
