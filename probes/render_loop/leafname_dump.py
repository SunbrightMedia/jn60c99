#!/usr/bin/env python3
"""Dump the PLUGIN'S OWN parameter names (name table rva 0x9a0030, stride 8,
char* per dispatch index) for the front-panel DCO/VCF block, so the port's
record-byte -> parameter mapping can be checked against the plugin instead of
against our own labels. Oracle-only; pure image read."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

e = E.E2E()
uc = e.uc
NT = E.IB + 0x9a0030

def name(idx):
    p = int.from_bytes(uc.mem_read(NT + 8*idx, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ):
        return None
    b = bytearray()
    a = p
    while len(b) < 200:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

DESC = E.IB + 0x98c040
import struct
def desc(idx):
    mn, mx, df, tg = struct.unpack('<iiii', uc.mem_read(DESC + 16*idx, 16))
    return mn, mx, df

print("dispatch  name (plugin's own table)                          desc[min,max,default]")
for i in range(748, 800):
    n = name(i)
    if n is None: continue
    mn, mx, df = desc(i)
    print("  %4d    %-50s  [%d,%d] d=%d" % (i, n, mn, mx, df))
