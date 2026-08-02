#!/usr/bin/env python3
"""CAND audio for the same script; ('arm',) pokes aux Array A on all 8 voices
(the proposed conditional UNISON retrigger arm), placed by the script."""
import sys, os, ctypes, pickle, json
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(H, "..", "tools", "trackb"))
sys.path.insert(0, os.path.join(H, "..", "tools", "verify"))
import null_ab, truth
lib_p, out, patch, script = sys.argv[1], sys.argv[2], int(sys.argv[3]), json.loads(sys.argv[4])
lib = null_ab.load(lib_p)
lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
bank = open(truth.BANK, "rb").read()
c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
lib.juno_gui_apply_bank(c, bank, len(bank), patch)
o = []
for ev in script:
    if ev[0] == 'on': lib.juno_gui_note_on(c, ev[1], ev[2])
    elif ev[0] == 'off': lib.juno_gui_note_off(c, ev[1])
    elif ev[0] == 'arm':
        for v in range(8): lib.juno_gui_poke(c, 101504 + 32 * v, 0x3f800000)
    else:
        b = (ctypes.c_float * (2 * ev[1]))(); lib.juno_gui_render(c, b, ev[1]); o.extend(b)
pickle.dump(o, open(out, "wb"), 2)
