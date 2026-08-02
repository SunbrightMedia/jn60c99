#!/usr/bin/env python3
"""CAND side (ctypes only): same script through libjuno.so, dump state.
usage: uni_cand.py LIB OUT.pkl NIDLE [NOTE]"""
import sys, os, ctypes, pickle
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools", "trackb"))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools", "verify"))
import null_ab, truth

lib_path, out_path, nidle = sys.argv[1], sys.argv[2], int(sys.argv[3])
note = int(sys.argv[4]) if len(sys.argv) > 4 else 48
lib = null_ab.load(lib_path)
lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]
bank = open(truth.BANK, "rb").read()
DUMP = 110000
c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
lib.juno_gui_apply_bank(c, bank, len(bank), 61)
buf = ctypes.create_string_buffer(DUMP)
def snap():
    lib.juno_gui_dump(c, 0, buf, DUMP); return bytes(buf.raw)
def render(n):
    b = (ctypes.c_float * (2 * n))(); lib.juno_gui_render(c, b, n); return list(b)
res = {"nidle": nidle, "note": note}
res["after_recall"] = snap()
if nidle: render(nidle)
res["after_idle"] = snap()
lib.juno_gui_note_on(c, note, 100)
res["after_noteon"] = snap()
res["post"] = render(512)
res["after_post"] = snap()
pickle.dump(res, open(out_path, "wb"), 2)
