#!/usr/bin/env python3
"""rev_fc44.py — REVERB TYPE (idx 876) dispatch at 44100 + 88200: read the 4 DPF
Fc cells (10759648/96/744/92) and the type-5 stage 10759488 for TYPE 0..5.
Gives the 44.1k arm of REV_FC[] / REV_R488[] (88.2k expected = 48k/96k arm)."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
def f(u): return struct.unpack('<f', struct.pack('<I', u & 0xffffffff))[0]

for sr in (44100.0, 88200.0):
    e = E.E2E(); e.build(sr); e.snap_all()
    print(f"--- rate {int(sr)} ---", flush=True)
    for t in range(6):
        for u in range(9):
            try: e.dispatch(u, 876, t)
            except RuntimeError: pass
        e.snap_all()
        st8 = e.state[8]
        fc  = struct.unpack('<I', e.uc.mem_read(st8 + 10759648, 4))[0]
        fc2 = struct.unpack('<I', e.uc.mem_read(st8 + 10759696, 4))[0]
        r488= struct.unpack('<I', e.uc.mem_read(st8 + 10759488, 4))[0]
        eq = "all4eq" if all(struct.unpack('<I', e.uc.mem_read(st8 + off, 4))[0] == fc
                             for off in (10759696, 10759744, 10759792)) else "MIXED"
        print(f"  type {t}: FC={fc:08x} ({f(fc):.9g}) [{eq}]  R488={r488:08x} ({f(r488):.9g})", flush=True)
