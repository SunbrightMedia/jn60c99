#!/usr/bin/env python3
"""Worst WARM peak across all 128 patches (both banks) -> the measured criterion
for the webapp monitor-fader default. Warm = 4 s free-run before the note, i.e.
the condition a real instance is always in when a human actually plays it."""
import ctypes, sys
sys.path.insert(0, 'tools/verify'); import truth, e2e_emu as E
lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_midi_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_warmup.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR = 44100.0; WARM = int(4*SR)

def peak(bk, p, chord):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, bk, len(bk), p)
    lib.juno_gui_warmup(c, WARM)
    for n in chord: lib.juno_gui_midi_note_on(c, n, 100)
    N = 22050; buf = (ctypes.c_float*(2*N))(); lib.juno_gui_render(c, buf, N)
    pk = max(abs(x) for x in buf); lib.juno_gui_destroy(c)
    return pk

banks = [("F", open(truth.BANK,'rb').read()), ("CW", open(CW,'rb').read())]
for label, chord in (("single note 60", [60]), ("4-note chord", [48,52,55,60])):
    worst = (0, None)
    for nm, bk in banks:
        for p in range(64):
            pk = peak(bk, p, chord)
            if pk > worst[0]: worst = (pk, "%s%d" % (nm, p))
    print("%-16s worst WARM peak = %.3f  (%s)   -> unity-safe fader = %.2f"
          % (label, worst[0], worst[1], 1.0/worst[0] if worst[0] > 0 else 1))
