#!/usr/bin/env python3
"""Do FACTORY patches with non-zero VCF VELOCITY SENS actually respond to
velocity in the port? Render each at vel 1 vs 127 and compare audio directly.
A velocity-sensitive patch that is velocity-INVARIANT is a bug that every render
A/B is blind to, because those gates use the SAME fixed velocity on both sides."""
import ctypes, numpy as np, sys
sys.path.insert(0,'tools/verify'); import truth, real_bank_parse as RB
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(truth.BANK,'rb').read(); recs=RB.parse_records(bank)
chl=open('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin','rb').read()
crecs=RB.parse_records(chl)
SR=44100
def render(bk,idx,vel,secs=0.5):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bk,len(bk),idx)
    L.juno_gui_note_on(c,60,vel)
    nf=int(SR*secs); b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
    return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
print("port response to velocity (vel 1 vs vel 127), first 0.5 s\n")
print("  bank/patch   VCFvel VCAvel   peak@1     peak@127   differing samples")
for tag,bk,rs,idxs in (("FACTORY",bank,recs,[0,5,1,2,3,7]),("CHILLW",chl,crecs,[3])):
    for i in idxs:
        vs=RB.record_value(rs[i],1852); va=RB.record_value(rs[i],2086)
        a=render(bk,i,1); b=render(bk,i,127)
        nd=int(np.sum(a!=b))
        flag=""
        if vs and nd==0: flag="   <== VEL SENS SET BUT NO RESPONSE (BUG)"
        print("  %-8s %2d   %4d  %4d   %.6f  %.6f   %7d%s"%(tag,i,vs,va,
              np.max(np.abs(a)),np.max(np.abs(b)),nd,flag))
