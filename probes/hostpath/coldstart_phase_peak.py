#!/usr/bin/env python3
"""Does the UNISON peak depend on how long the engine has been running before the
first note? At engine BUILD the port arms every voice's DCO retrigger latch, so a
COLD note-on starts all 8 unison DCOs phase-aligned -> coherent 8x sum. A real DAW
instance has been free-running (with per-voice CONDITION scatter detuning each DCO)
for seconds before you play, so the voices should have drifted apart.
Port-side only (ctypes), no Unicorn."""
import ctypes, sys
sys.path.insert(0, 'tools/verify'); import truth

lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_midi_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'

def run(bk, p, idle):
    c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
    lib.juno_gui_apply_bank(c, bk, len(bk), p)
    BL = 512
    done = 0
    while done < idle:                      # free-run BEFORE the note, like a live DAW track
        n = min(BL, idle - done)
        b = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, b, n); done += n
    lib.juno_gui_midi_note_on(c, 60, 100)
    N = 22050
    buf = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, buf, N)
    pk = max(abs(x) for x in buf)
    import math
    rms = math.sqrt(sum(x*x for x in buf)/(2*N))
    lib.juno_gui_destroy(c)
    return pk, rms

cw = open(CW, 'rb').read(); fac = open(truth.BANK, 'rb').read()
print("%-12s %-4s %10s %10s %10s %10s" % ("bank", "p", "cold_pk", "1s_pk", "5s_pk", "10s_pk"))
for nm, bk, ps in (("CHILLWAVE", cw, [3, 4, 12]), ("FACTORY", fac, [61, 0])):
    for p in ps:
        row = []
        for idle in (0, 44100, 220500, 441000):
            pk, rms = run(bk, p, idle)
            row.append(pk)
        print("%-12s %-4d %10.3f %10.3f %10.3f %10.3f" % (nm, p, row[0], row[1], row[2], row[3]))
