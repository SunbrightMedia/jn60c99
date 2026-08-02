#!/usr/bin/env python3
"""Reconnaissance for the ENGINE B chorus spec. Prints measured cells."""
import ctypes, os, sys, struct
import numpy as np
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
J = ctypes.CDLL(os.path.join(R, "libjuno.so"))
P = ctypes.CDLL(os.path.join(R, "scratchpad", "fx_chorus_probe.so"))
J.juno_gui_create.restype = ctypes.c_void_p
J.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
J.juno_gui_peek.restype = ctypes.c_uint
J.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
J.juno_gui_get.restype = ctypes.c_float
J.juno_gui_get.argtypes = [ctypes.c_void_p, ctypes.c_int]
J.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_void_p]

BLOCKA = {91120: "DelayTime", 91136: "ErrorDepth", 91152: "LFORate", 91168: "LFOPhase",
          91184: "LFODepth", 91200: "NoiseLevel", 91216: "DryLevel", 91232: "WetLevel",
          91248: "IpFc", 91264: "OnOff", 91280: "Mute"}

def fx(ctx, sig, offs):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*sig)
    L = (ctypes.c_float * n)()
    Rr = (ctypes.c_float * n)()
    co = (ctypes.c_int * len(offs))(*offs)
    tr = (ctypes.c_float * (n * len(offs)))()
    P.pb_fx(st, a, n, L, Rr, co, len(offs), tr)
    return (np.frombuffer(L, np.float32).copy(), np.frombuffer(Rr, np.float32).copy(),
            np.frombuffer(tr, np.float32).reshape(n, len(offs)).copy())

def main():
    rate = float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    print("rate", rate)
    print("EFFECT routing 11022052 =", J.juno_gui_peek(c, 11022052))
    for o, n in sorted(BLOCKA.items()):
        print("  %6d %-11s %.9g  0x%08x" % (o, n, J.juno_gui_get(c, o), J.juno_gui_peek(c, o)))
    for o in (95824, 95828, 91456, 91472, 91488, 91504, 91520, 91536, 91552,
              91568, 91600, 91616, 91632, 91648, 91664, 91680, 91696, 91712,
              91296, 91312, 91328, 91344, 91360, 91376, 91392, 91408, 91424, 91440):
        print("  aux %6d = %.9g  0x%08x" % (o, J.juno_gui_get(c, o), J.juno_gui_peek(c, o)))
    print("  LFO state 90624=%.9g 90640=%.9g 90656=%.9g 90672=%.9g"
          % tuple(J.juno_gui_get(c, o) for o in (90624, 90640, 90656, 90672)))
    # impulse
    offs = [84624, 90368, 90384, 90656, 90688, 90800, 90816, 91088, 91104,
            95824, 95840, 95856, 95860, 95864, 95872, 95876, 95880]
    sig = np.zeros(2000, np.float32); sig[0] = 1.0
    L, Rr, tr = fx(c, sig, offs)
    print("offs:", offs)
    for i in list(range(6)) + [100, 140, 141, 142, 143, 144, 145]:
        print(i, " ".join("%.6g" % v for v in tr[i]))
    print("out nonzero idx", np.nonzero(np.abs(L) > 1e-12)[0][:10])
    print("chorusL nonzero idx", np.nonzero(np.abs(tr[:, 7]) > 1e-12)[0][:10])
    J.juno_gui_destroy(c)

main()
