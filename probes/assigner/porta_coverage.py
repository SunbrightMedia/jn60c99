#!/usr/bin/env python3
"""Which patches have PORTAMENTO / LEGATO / ASSIGN != default, in BOTH banks?
Pure blob read (plugin's own record layout, blob byte 54/55/56). READ."""
import sys, os
sys.path.insert(0, 'tools/verify')
import truth
CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')

def patches(path):
    b = open(path, 'rb').read()
    # same slicing recall_render_ab/e2e_emu use: 64 records, find via e2e helper
    return b

import e2e_emu as E
for nm, path in (("FACTORY", truth.BANK), ("CHILLWAVE", CW)):
    bank = open(path, 'rb').read()
    rows = []
    for p in range(64):
        blob = E.patch_blob(bank, p)
        g = lambda i: ((blob[2*i] & 0xF) << 4) | (blob[2*i+1] & 0xF)
        rows.append((p, g(54), g(55), g(56)))
    print("=== %s ===" % nm)
    nz = [r for r in rows if r[1] or r[2] or r[3]]
    print("  patches with PORTA/LEGATO/ASSIGN nonzero: %d/64" % len(nz))
    for p, po, lg, asg in nz:
        print("   p%-2d PORTA=%-3d LEGATO=%d ASSIGN=%d" % (p, po, lg, asg))
    print("  PORTA range: %d..%d ; distinct nonzero: %s"
          % (min(r[1] for r in rows), max(r[1] for r in rows),
             sorted({r[1] for r in rows if r[1]})))
