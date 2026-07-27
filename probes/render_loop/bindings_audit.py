#!/usr/bin/env python3
"""Audit the port's hand-written BINDINGS table (src/juno_apply.c) against the
PLUGIN'S OWN parameter-name table (rva 0x9a0030). The port binds by 'blob' index;
the plugin dispatches by index. For the SYNTH block the relation is
disp = blob + 744 (verified on 6 independent anchors). A row whose port label
disagrees with the plugin's name at that dispatch index is a mis-binding — a
class of bug NO gate can see, because every gate feeds both sides the same map.
Oracle-only (image read); no libjuno."""
import sys, re
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

e = E.E2E(); uc = e.uc
NT = E.IB + 0x9a0030
def pname(idx):
    if idx < 0 or idx > 4965: return '<oob>'
    p = int.from_bytes(uc.mem_read(NT + 8*idx, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 128:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

src = open('/home/user/jn60c99/src/juno_apply.c').read()
# rows look like:  { 29, 54, T_ID,  6528, "DCO NOISE LEVEL" },
rx = re.compile(r'\{\s*(\d+)\s*,\s*(\d+)\s*,\s*(T_\w+)\s*,\s*(\d+)\s*,\s*"([^"]*)"')
rows = rx.findall(src)
print("BINDINGS rows parsed: %d\n" % len(rows))

def norm(s):
    s = s.upper().replace('(', '').replace(')', '').strip()
    return ' '.join(s.split())

ok = mism = skipped = 0
print("blob  disp  cell    port label                plugin name                     match")
for blob, curve, ty, cell, label in rows:
    b = int(blob); disp = b + 744
    if disp > 830:          # extended block uses a different position law
        skipped += 1; continue
    pn = pname(disp)
    m = norm(pn) == norm(label)
    if m: ok += 1
    else: mism += 1
    print("%4d  %4d  %6s  %-24s  %-30s  %s" % (b, disp, cell, label, pn, "OK" if m else "*** MISMATCH ***"))
print("\nSYNTH-block rows: %d OK, %d MISMATCH  (%d extended rows skipped: disp>830)" % (ok, mism, skipped))
