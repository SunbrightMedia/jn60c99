#!/usr/bin/env python3
"""Does writing note-bus param 467+v back to 0 RESTORE the voice's portamento
cells (592, 9824), or leave them zeroed? The POLY LEGATO arm writes 1 when the
keyboard was silent and 0 once a voice is sounding, so the answer decides the
port's law. PROVEN by execution -- the plugin's own setter, both orders."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

SR, P = 44100.0, 55
CELLS = [592, 9824]
bank = E.bank_bytes(); leaves = R.leaf_table()

def rd(e, u, v, off):
    return struct.unpack('<f', e.uc.mem_read(
        e.state[u] + off + (176 if off >= 176 else 0)*0 + v*10512, 4))[0]

e = RA.prepare_recall(P, bank, leaves, E, R, SR)
def show(tag):
    print("  %-22s " % tag + "  ".join(
        "v%d[%d]=%g" % (v, c, struct.unpack('<f', e.uc.mem_read(
            e.state[0] + c + v*10512, 4))[0]) for v in (0, 1) for c in CELLS))
show("after recall")
for (idx, val) in ((467, 1), (467, 0), (467, 1), (468, 1), (468, 0)):
    R.wr_desc(e, idx, val)
    e.dispatch(0, idx, val)
    show("dispatch %d = %d" % (idx, val))
del e
