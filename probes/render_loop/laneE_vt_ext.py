#!/usr/bin/env python3
"""LANE E: engine vtable slots 0..47 (rva 0x9df1d8) + the MIDI-CC sub-dispatch
targets used by slot 17 (0x34AE90)."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
uc = E.E2E().uc
VT = E.IB + 0x9df1d8
for s in range(0, 48*8, 8):
    q = int.from_bytes(uc.mem_read(VT + s, 8), 'little')
    if E.IB <= q < E.IB + E.IMGSZ:
        print("  +%-4d slot %2d rva 0x%X" % (s, s//8, q - E.IB))
    else:
        print("  +%-4d slot %2d <non-code 0x%x>" % (s, s//8, q))
