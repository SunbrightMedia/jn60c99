#!/usr/bin/env python3
"""warm_all64.py — DEFINITIVE per-patch warm A/B for all 64 patches. Plugin warm
note (leaf-driven, held) vs port warm note (browser config: create chorus mode 2,
warmup, apply, arp FORCED OFF so arp patches compare synthesis-to-synthesis, note).
Phase-invariant metrics (RMS L/R, stereo balance dB, best-lag correlation) — the
warm note is phase-stable but not sample-exact. Flags any patch whose port output
falls outside the plugin's own phase band (corr < 0.95 or |balance err| > 0.6 dB)."""
import sys, ctypes, json
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
import numpy as np
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
IDLE, NOTE = 48000, 12000
meta = dict((i, m) for i, m in json.load(open("/home/user/jn60c99/scratchpad/oracle/idstate64/batch_summary.json")))

def plug_warm(p):
    e = E.E2E(); e.build(48000); e.snap_all(); e.clear_latch(); e.set_ftz()
    e.render(IDLE); e.snap_all(); E.recall_patch(e, p); e.snap_all(); e.clear_latch()
    e.note_on(60, 105); L, R = e.render(NOTE)
    return (np.array(L, np.uint32).view(np.float32).astype(np.float64),
            np.array(R, np.uint32).view(np.float32).astype(np.float64))

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
for f, rt, at in [("juno_gui_create", ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
  ("juno_gui_warmup", None, [ctypes.c_void_p, ctypes.c_int]),
  ("juno_gui_apply_bank", None, [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
  ("juno_gui_arp_config", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]),
  ("juno_gui_note_on", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
  ("juno_gui_render", None, [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int])]:
    getattr(lib, f).restype = rt; getattr(lib, f).argtypes = at
bank = open(BANK, "rb").read()
def port_warm(p):
    c = lib.juno_gui_create(48000.0, 2); lib.juno_gui_warmup(c, IDLE)
    lib.juno_gui_apply_bank(c, bank, len(bank), p)
    lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)   # arp OFF: synthesis-to-synthesis
    lib.juno_gui_note_on(c, 60, 105)
    buf = (ctypes.c_float * (2 * NOTE))(); lib.juno_gui_render(c, buf, NOTE)
    a = np.ctypeslib.as_array(buf).astype(np.float64); return a[0::2], a[1::2]

def rms(x): return float(np.sqrt((x * x).mean()))
def db(x): return 20 * np.log10(max(x, 1e-12))
def corr(x, y, maxlag=96):
    b = -2
    for lag in range(0, maxlag + 1):
        xx = x[lag:]; yy = y[:len(y) - lag] if lag else y; n = min(len(xx), len(yy))
        xx, yy = xx[:n], yy[:n]
        if xx.std() < 1e-9 or yy.std() < 1e-9: continue
        b = max(b, float(((xx - xx.mean()) * (yy - yy.mean())).mean() / (xx.std() * yy.std())))
    return b

flagged = []
print("patch name             mode  plugRMS   portRMS   balErr  corrL corrR  verdict", flush=True)
for p in range(64):
    pl, pr = plug_warm(p); ql, qr = port_warm(p)
    if rms(pl) < 1e-5 and rms(ql) < 1e-5:
        print("  %2d %-16s silent both" % (p, meta[p]['name'])); continue
    balerr = abs((db(rms(pl)) - db(rms(pr))) - (db(rms(ql)) - db(rms(qr))))
    cl, cr = corr(pl, ql), corr(pr, qr)
    ok = balerr < 0.6 and cl > 0.95 and cr > 0.95
    if not ok: flagged.append(p)
    print("  %2d %-16s v551=%d  %.4f  %.4f  %.2fdB  %.3f %.3f  %s"
          % (p, meta[p]['name'], meta[p]['v551'], rms(pl), rms(ql), balerr, cl, cr,
             "OK" if ok else "**FLAG**"), flush=True)
print("\nFLAGGED patches (port outside plugin phase band): %s" % (flagged or "NONE — all 64 faithful"), flush=True)
