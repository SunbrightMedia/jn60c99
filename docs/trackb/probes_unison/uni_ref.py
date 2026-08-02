#!/usr/bin/env python3
"""REF side (Unicorn only): patch 61, render N idle frames, dump per-unit state.
usage: uni_ref.py OUT.pkl NIDLE [--note NOTE]"""
import sys, os, pickle
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools", "verify"))
import e2e_emu as E, real_recall as R, recall_render_ab as AB

out_path, nidle = sys.argv[1], int(sys.argv[2])
note = int(sys.argv[3]) if len(sys.argv) > 3 else 48
SR = 44100.0
bank = E.bank_bytes(); leaves = R.leaf_table()
e = AB.prepare_recall(61, bank, leaves, E, R, SR)
DUMP = 110000
snap = lambda: [bytes(e.uc.mem_read(e.state[u], DUMP)) for u in range(9)]
res = {"nidle": nidle, "note": note}
res["after_recall"] = snap()
if nidle:
    e.render(nidle)
res["after_idle"] = snap()
e.note_on(note, 100)
res["after_noteon"] = snap()
L, Rr = e.render(512)
res["post"] = (L, Rr)
res["after_post"] = snap()
pickle.dump(res, open(out_path, "wb"), 2)
