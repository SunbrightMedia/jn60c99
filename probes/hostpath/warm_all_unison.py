#!/usr/bin/env python3
"""Control + full sweep: is the cold-start peak/darkness specific to UNISON
(phase-aligned voice sum), or does it affect POLY patches too?
Compares idle=0 vs idle=4s for every ASSIGN=2 patch in both banks plus poly controls."""
import ctypes, sys
sys.path.insert(0, 'tools/verify'); sys.path.insert(0, 'scratchpad')
import truth, numpy as np
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
    d = 0
    while d < idle:
        n = min(512, idle-d); b=(ctypes.c_float*(2*n))(); lib.juno_gui_render(c,b,n); d+=n
    lib.juno_gui_midi_note_on(c, 60, 100)
    N=22050; buf=(ctypes.c_float*(2*N))(); lib.juno_gui_render(c,buf,N)
    a=np.frombuffer(bytes(buf),dtype='<f4').astype(np.float64)
    lib.juno_gui_destroy(c)
    return float(np.max(np.abs(a))), centroid(a[0::2]+a[1::2], SR)

def assign_of(bk, p):
    import e2e_emu as E
    blob = E.patch_blob(bk, p)
    return ((blob[2*56]&0xF)<<4)|(blob[2*56+1]&0xF)

WARM = int(4*SR)
for nm, bk in (("CW", open(CW,'rb').read()), ("F", open(truth.BANK,'rb').read())):
    uni = [p for p in range(64) if assign_of(bk,p)==2]
    poly = [p for p in range(64) if assign_of(bk,p)==0][:3]
    print("\n=== %s : UNISON patches %s ===" % (nm, uni))
    print("  p    cold_pk  warm_pk   cold_cent warm_cent")
    for p in uni+poly:
        c0,t0 = run(bk,p,0); c4,t4 = run(bk,p,WARM)
        tag = "UNISON" if p in uni else "poly  "
        print("  %-4d %7.3f  %7.3f   %8.1f  %8.1f   %s" % (p,c0,c4,t0,t4,tag))
