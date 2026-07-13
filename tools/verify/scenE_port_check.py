#!/usr/bin/env python3
"""scenE_port_check.py — Scenario E: live param move mid-note. Fixed port
(libjuno.so) vs cached plugin dispatch streams (out/plug_<PARAM>_{L,R}.bin).
Sequence (patch 13, 48k, chorus=0): note_on(60,105) -> render 3000 ->
set_param(idx,byte) -> render 6000. 9000 frames/channel, bit-compare."""
import ctypes, struct, sys
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
OUT = "/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/out"
CASES = [  # (fname token, param_index, byte)
    ("VCF_CUTOFF", 0, 200), ("VCF_RES", 1, 60), ("DCO_SAW", 17, 40),
    ("ENV1_ATK", 6, 180), ("ENV2_ATK", 10, 140), ("VCA_LEVEL", 16, 180),
    ("VCA_TONE", 14, 220), ("ENV2_REL", 11, 200), ("ENV1_SUS", 8, 60),
]
PRE, POST = 3000, 6000
lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_set_param.restype = ctypes.c_float
lib.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
bank = open(BANK, 'rb').read()

def render(c, n):
    buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
    inter = struct.unpack("<%dI" % (2*n), bytes(buf))
    return list(inter[0::2]), list(inter[1::2])

allok = True
for name, idx, byte in CASES:
    c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), 13)
    lib.juno_gui_note_on(c, 60, 105)
    L, R = render(c, PRE)
    lib.juno_gui_set_param(c, idx, byte)
    l2, r2 = render(c, POST); L += l2; R += r2
    lp = open(f"{OUT}/plug_{name}_L.bin", 'rb').read()
    rp = open(f"{OUT}/plug_{name}_R.bin", 'rb').read()
    N = len(lp)//4
    Lp = struct.unpack("<%dI" % N, lp); Rp = struct.unpack("<%dI" % N, rp)
    n = min(N, len(L))
    first = next((i for i in range(n) if L[i] != Lp[i] or R[i] != Rp[i]), None)
    nd = sum(1 for i in range(n) if L[i] != Lp[i] or R[i] != Rp[i])
    tag = "BIT-EXACT" if nd == 0 else f"FIRST@{first} (change at {PRE})"
    if nd: allok = False
    print(f"  {name:12s} idx{idx:2d} b{byte:3d}: {n} frames diffs={nd:5d}  {tag}")
print("\n" + ("ALL 9 BIT-EXACT" if allok else "SOME DIVERGENT"))
