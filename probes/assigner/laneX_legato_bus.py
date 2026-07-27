#!/usr/bin/env python3
"""What do the per-voice note-bus params 467..474 write? The POLY allocator's
LEGATO arm (sub_7FF91DFB3150 LABEL_21) writes them 1 when the keyboard was
silent and 0 when a voice is already sounding. Dispatch them through the
plugin's own setter and diff the full 9-unit state. PROVEN by execution.
Protocol per docs/P112_FINDINGS.md s8: descriptor DB written before dispatch,
values inside the param's own range, baseline is a RECALLED patch."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

SR = 44100.0
bank = E.bank_bytes(); leaves = R.leaf_table()
P = 55  # ASSIGN 0, LEGATO 1, PORTA 33 -- the diverging patch

def snap(e):
    return [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(9)]

def diff(a, b):
    out = []
    for u in range(9):
        for i in range(0, E.STATE_SZ, 4):
            if a[u][i:i+4] != b[u][i:i+4]:
                out.append((u, i,
                            struct.unpack('<f', a[u][i:i+4])[0],
                            struct.unpack('<f', b[u][i:i+4])[0]))
    return out

for idx in (467, 468, 474, 433, 450):
    for val in (1, 0):
        e = RA.prepare_recall(P, bank, leaves, E, R, SR)
        before = snap(e)
        try:
            R.wr_desc(e, idx, val)
            e.dispatch(0, idx, val)
        except RuntimeError as ex:
            print("  idx %d val %d -> dispatch refused (%s)" % (idx, val, ex)); del e; continue
        after = snap(e)
        d = diff(before, after)
        del e
        print("  idx %3d val %d -> %d cells: %s"
              % (idx, val, len(d),
                 ", ".join("u%d@%d %g->%g" % t for t in d[:8]) or "none"))
