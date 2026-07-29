#!/usr/bin/env python3
"""How long must the engine free-run before the 8 unison DCOs have decorrelated
into the generic (representative) condition a real instance is always in?
Measures PEAK and SPECTRAL CENTROID vs pre-note idle time. Port-side only."""
import ctypes, sys, math
sys.path.insert(0, 'tools/verify'); sys.path.insert(0, 'scratchpad')
import truth
import numpy as np
from centroid_util import centroid

lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_midi_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR = 44100.0

def run(bk, p, idle):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, bk, len(bk), p)
    done = 0
    while done < idle:
        n = min(512, idle - done)
        b = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, b, n); done += n
    lib.juno_gui_midi_note_on(c, 60, 100)
    N = 22050
    buf = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, buf, N)
    a = np.frombuffer(bytes(buf), dtype='<f4').astype(np.float64)
    mono = a[0::2] + a[1::2]
    lib.juno_gui_destroy(c)
    return float(np.max(np.abs(a))), centroid(mono, SR)

cw = open(CW, 'rb').read()
GRID = [0, 22050, 44100, 66150, 88200, 132300, 176400, 220500, 330750, 441000]
for p, nm in ((3, 'BS Solid'), (4, 'BS Glide')):
    print("\nCHILLWAVE p%d %s   idle_s :  peak   centroid_Hz" % (p, nm))
    for idle in GRID:
        pk, ct = run(cw, p, idle)
        print("    %6.2f s : %6.3f   %8.1f" % (idle/SR, pk, ct))
