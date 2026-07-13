#!/usr/bin/env python3
"""rate88_dump.py — plugin post-recall values for ALL suspect FX cells at 88200,
plus the reverb per-patch cells at every rate. If a cell@88200 == its 96k bits,
it's a rate-CLASS arm constant (encode 3 arms); if not, it's continuous."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

CELLS = [102448, 102544, 102608, 102656,
         4297680, 4297776, 4297904, 4297952,
         6396128, 6396272, 6396336, 6396400, 6396528,
         6497264, 6497360, 6497424, 6497472,
         10693008, 10693152, 10693216, 10693280,
         10759360, 10759520, 10759536, 10759552,
         10759568, 10759584, 10759600, 10759616, 10759632,
         10759648, 10759696, 10759744, 10759792]
def f(u): return struct.unpack('<f', struct.pack('<I', u & 0xffffffff))[0]

def dump(patch, sr):
    e = E.E2E(); e.build(sr); e.snap_all(); E.recall_patch(e, patch); e.snap_all()
    st8 = e.state[8]
    return {c: struct.unpack('<I', e.uc.mem_read(st8 + c, 4))[0] for c in CELLS}

# 88200 for one patch per v39 type
for patch in (13, 4, 11, 19, 5):
    d = dump(patch, 88200.0)
    print(f"patch {patch} @88200:", flush=True)
    for c in CELLS:
        if d[c]:
            print(f"   {c:8d} = {d[c]:08x} ({f(d[c]):.9g})", flush=True)
