#!/usr/bin/env python3
"""Assigner-level A/B on the CHILLWAVE bank -- the patches the user actually
reports on (BS Solid 3 and BS Glide 4 are both ASSIGN=2). Same note SEQUENCES as
tools/verify/assigner_ab.py, but this bank lives outside truth/ so it stays a
probe rather than a durable gate. Oracle half."""
import sys, pickle
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA
from assigner_ab import SCRIPTS, BLOCK

CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
OUT = '/tmp/cw_seq_ref.pkl'
SR = 44100.0
PATCHES = [3, 4, 30, 35, 10, 12, 6, 31]
bank = open(CW, 'rb').read(); leaves = R.leaf_table()
out = {}
for p in PATCHES:
    e = RA.prepare_recall(p, bank, leaves, E, R, SR)
    mode, leg = e.rd_i32(e.assign[0] + 16), e.rd_i32(e.assign[0] + 20)
    del e
    for name, script in sorted(SCRIPTS.items()):
        e = RA.prepare_recall(p, bank, leaves, E, R, SR)
        L, Rr = [], []
        for ev in script:
            if ev[0] == 'on':    e.note_on(ev[1], ev[2])
            elif ev[0] == 'off': e.note_off(ev[1])
            else:
                a, b = e.render(ev[1], block=BLOCK); L += a; Rr += b
        del e
        out[(p, name)] = (mode, leg, L, Rr)
        print("  ref: CW p%-2d %-8s mode=%d legato=%d" % (p, name, mode, leg), flush=True)
pickle.dump(out, open(OUT, 'wb'))
print("wrote", OUT)
