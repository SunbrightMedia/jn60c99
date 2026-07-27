#!/usr/bin/env python3
"""LANE E: dump the proc-object vtable (rva 0x9C3018) slots 0..15."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
uc = E.E2E().uc
for s in range(0, 16*8, 8):
    q = int.from_bytes(uc.mem_read(E.IB + 0x9C3018 + s, 8), 'little')
    tag = ('rva 0x%X' % (q - E.IB)) if E.IB <= q < E.IB + E.IMGSZ else '<0x%x>' % q
    print("   +%-3d slot %2d %s" % (s, s//8, tag))
