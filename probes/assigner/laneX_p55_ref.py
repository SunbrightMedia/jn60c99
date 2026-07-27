#!/usr/bin/env python3
"""Oracle half: patch 55 (POLY + LEGATO + PORTA), note 60, render, note 67 --
pickle the plugin's 9-unit state right after the SECOND note-on."""
import sys, pickle
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA
SR, P = 44100.0, 55
OUT = '/tmp/p55_ref.pkl'
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RA.prepare_recall(P, bank, leaves, E, R, SR)
e.note_on(60, 100)
e.render(3000, block=512)
e.note_on(67, 100)
st = [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(9)]
pickle.dump(st, open(OUT, 'wb'))
print("wrote", OUT)
