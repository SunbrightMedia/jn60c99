#!/usr/bin/env python3
"""ENGINE B - REVERB, pass 0: reconnaissance.

Reads the sealed port's reverb state cells and proves, by execution, where the
reverb delay line is, how long it is, what the tap array holds, and that the
probe reaches the reverb at all.
"""
import ctypes, json, os, sys
import numpy as np

R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(R, "tools", "verify"))
import truth

J = ctypes.CDLL(os.path.join(R, "libjuno.so"))
P = ctypes.CDLL(os.path.join(R, "scratchpad", "fx_chorus_probe.so"))
for f, rt, at in (("juno_gui_create", ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
                  ("juno_gui_destroy", None, [ctypes.c_void_p]),
                  ("juno_gui_peek", ctypes.c_uint, [ctypes.c_void_p, ctypes.c_int]),
                  ("juno_gui_get", ctypes.c_float, [ctypes.c_void_p, ctypes.c_int]),
                  ("juno_gui_set", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_float]),
                  ("juno_gui_apply_bank", ctypes.c_int,
                   [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                  ("juno_gui_host_set", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int])):
    getattr(J, f).restype = rt; getattr(J, f).argtypes = at
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_float)]

BANK = open(truth.BANK, "rb").read()

BUF = 10759888
POS = 10759856
WIPE = 10759872
TAP_W = 11022064          # working (latched) tap array read by the DSP
TAP_L = 11022208          # tap array written by recall
MUTE = 11022032


def render(ctx, sig, trace_offs=()):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*sig.astype(np.float32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    no = len(trace_offs)
    co = (ctypes.c_int * max(no, 1))(*(trace_offs or [0]))
    tr = (ctypes.c_float * (n * max(no, 1)))()
    P.pb_fx(st, a, n, L, Rr, co, no, tr)
    l = np.frombuffer(L, np.float32).copy(); r = np.frombuffer(Rr, np.float32).copy()
    t = np.frombuffer(tr, np.float32).reshape(n, max(no, 1)).copy() if no else None
    return l, r, t


def taps(ctx, base):
    return [ctypes.c_int32(J.juno_gui_peek(ctx, base + 4 * k)).value for k in range(34)]


out = {}
for rate in (44100, 48000):
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    J.juno_gui_apply_bank(c, BANK, len(BANK), 0)
    d = {
        "taps_latched_after_recall": taps(c, TAP_L),
        "taps_working_after_recall": taps(c, TAP_W),
        "pos": J.juno_gui_peek(c, POS),
        "wipe": ctypes.c_int32(J.juno_gui_peek(c, WIPE)).value,
        "predelay_10759360": float(J.juno_gui_get(c, 10759360)),
        "gate_10759376": float(J.juno_gui_get(c, 10759376)),
        "ap_coef_10759392": float(J.juno_gui_get(c, 10759392)),
        "send_10759408": float(J.juno_gui_get(c, 10759408)),
        "dry_10759424": float(J.juno_gui_get(c, 10759424)),
        "wet_10759440": float(J.juno_gui_get(c, 10759440)),
        "lfo_depth_10759488": float(J.juno_gui_get(c, 10759488)),
        "lfo_inc_10759504": float(J.juno_gui_get(c, 10759504)),
        "mute_11022032": float(J.juno_gui_get(c, MUTE)),
        "inpfilt": {str(o): float(J.juno_gui_get(c, o))
                    for o in (10759520, 10759536, 10759552, 10759568,
                              10759584, 10759600, 10759616, 10759632)},
        "dampers": [{"fc": float(J.juno_gui_get(c, 10759648 + 48 * k)),
                     "hp": float(J.juno_gui_get(c, 10759664 + 48 * k)),
                     "lp": float(J.juno_gui_get(c, 10759680 + 48 * k))} for k in range(4)],
    }
    # run 4000 samples of silence, watch the wipe countdown and the position
    l, r, t = render(c, np.zeros(4000, np.float32), (POS, WIPE, MUTE))
    d["after4000"] = {"pos": int(J.juno_gui_peek(c, POS)),
                      "wipe": ctypes.c_int32(J.juno_gui_peek(c, WIPE)).value,
                      "mute": float(J.juno_gui_get(c, MUTE)),
                      "taps_working": taps(c, TAP_W)}
    d["pos_trace_first8"] = [float(x) for x in t[:8, 0]]
    # impulse
    sig = np.zeros(20000, np.float32); sig[0] = 1.0
    l, r, _ = render(c, sig)
    d["impulse_peak"] = [float(np.max(np.abs(l))), float(np.max(np.abs(r)))]
    d["impulse_first_nonzero"] = int(np.argmax(np.abs(l) > 1e-12))
    d["impulse_rms_tail"] = float(np.sqrt(np.mean(l[10000:] ** 2)))
    out[str(rate)] = d
    J.juno_gui_destroy(c)

print(json.dumps(out, indent=1)[:6000])
