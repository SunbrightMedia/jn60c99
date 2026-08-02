#!/usr/bin/env python3
"""REF audio for an arbitrary event script (JSON list) on a patch."""
import sys, os, pickle, struct, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools", "verify"))
import e2e_emu as E, real_recall as R, recall_render_ab as AB
out, patch, script = sys.argv[1], int(sys.argv[2]), json.loads(sys.argv[3])
bank = E.bank_bytes(); leaves = R.leaf_table()
e = AB.prepare_recall(patch, bank, leaves, E, R, 44100.0)
inter = []
for ev in script:
    if ev[0] == 'on': e.note_on(ev[1], ev[2])
    elif ev[0] == 'off': e.note_off(ev[1])
    elif ev[0] == 'render':
        L, Rr = e.render(ev[1])
        for lb, rb in zip(L, Rr):
            inter.append(struct.unpack("<f", struct.pack("<I", lb))[0])
            inter.append(struct.unpack("<f", struct.pack("<I", rb))[0])
    elif ev[0] == 'arm': pass          # plugin arms it itself; no-op here
pickle.dump(inter, open(out, "wb"), 2)
