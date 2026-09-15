#!/usr/bin/env python3
# env_measure.py -- measure ATTACK and RELEASE time of factory patches on the
# HOST port (libjuno.so), to attribute the "latency" the user hears to the
# patch envelope or rule it out. A number, no ears. Decimated peak envelope
# (no numpy on this box); ms resolution is unaffected.
import ctypes, sys, math
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth
LIB  = '/home/user/jn60c99/libjuno.so'
BANK = open(truth.BANK, 'rb').read()
SR   = 44100.0
HOLD = int(1.6 * SR)
TAIL = int(2.0 * SR)
WIN  = 441                 # 10 ms envelope window
NOTE, VEL = 60, 105

lib = ctypes.CDLL(LIB)
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes  = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_render.restype = ctypes.c_int
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

def env_windows(c, n):
    """Render n frames; return the per-WIN peak envelope (max |L|,|R|)."""
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    env = []
    i = 0
    while i + WIN <= n:
        pk = 0.0
        base = 2 * i
        # stride 8 frames inside the window: peak-hold, cheap, ms-accurate
        for j in range(0, WIN, 8):
            l = buf[base + 2 * j]; r = buf[base + 2 * j + 1]
            a = l if l >= 0 else -l
            b = r if r >= 0 else -r
            if a > pk: pk = a
            if b > pk: pk = b
        env.append(pk)
        i += WIN
    return env

def measure(idx):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, BANK, len(BANK), idx)
    lib.juno_gui_note_on(c, NOTE, VEL)
    wa = env_windows(c, HOLD)
    lib.juno_gui_note_off(c, NOTE)
    wr = env_windows(c, TAIL)
    lib.juno_gui_destroy(c)
    peak = max(wa) if wa else 0.0
    if peak <= 1e-9:
        return None
    ms = lambda w: w * WIN / SR * 1000.0
    lo = peak * 0.01     # -40 dB "sounding"
    hi = peak * 0.90     # 90% "at level"
    onset = next((ms(i) for i, v in enumerate(wa) if v >= lo), -1)
    atk   = next((ms(i) for i, v in enumerate(wa) if v >= hi), -1)
    rel   = next((ms(i) for i, v in enumerate(wr) if v < lo), ms(len(wr)))
    return onset, atk, rel, peak

names = {0: "SY Poly Synth (boot)"}
print("== patches the user played ==")
print("patch  onset_ms  attack_ms  release_ms   peak   name")
for idx in [0, 37, 39]:
    r = measure(idx)
    if r is None:
        print("%3d    SILENT" % idx); continue
    onset, atk, rel, pk = r
    print("%3d    %7.1f   %8.1f   %9.1f   %.3f  %s"
          % (idx, onset, atk, rel, pk, names.get(idx, "")))

print("\n== slowest attacks across all 64 factory patches ==")
rows = []
for idx in range(64):
    r = measure(idx)
    if r:
        rows.append((r[1], r[2], r[0], idx))
rows.sort(reverse=True)
for atk, rel, onset, idx in rows[:10]:
    print("  patch %2d: onset=%.0f attack=%.0f release=%.0f ms" % (idx, onset, atk, rel))
p0 = next(((a, r, o) for a, r, o, i in rows if i == 0), None)
if p0:
    print("\n  >>> patch 0 (boot): onset=%.0f attack=%.0f release=%.0f ms" % (p0[2], p0[0], p0[1]))
