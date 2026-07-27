#!/usr/bin/env python3
"""Does the GATE leaf (450+v) restore cell 9824 after the LEGATO arm's 467+v=1
zeroed it? The first probe could not see this: its baseline had 9824 already at
1, so a write of 1 produced no diff (docs/P112_FINDINGS.md s8, baseline error).
Start from a ZEROED 9824 and re-run the gate leaf. PROVEN by execution."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA
SR, P = 44100.0, 55
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RA.prepare_recall(P, bank, leaves, E, R, SR)
def show(t):
    g = lambda c: struct.unpack('<f', e.uc.mem_read(e.state[0] + c, 4))[0]
    print("  %-26s 592=%-4g 9824=%-4g 320=%-4g 9680=%g" % (t, g(592), g(9824), g(320), g(9680)))
show("after recall")
for (idx, val) in ((467, 1), (450, 100), (467, 1), (450, 0), (467, 1), (433, 60), (467, 0), (450, 100)):
    R.wr_desc(e, idx, val); e.dispatch(0, idx, val)
    show("dispatch %d = %d" % (idx, val))
del e
