#!/usr/bin/env python3
"""Does the port GLIDE on 'BS Glide' (Chillwave 4, PORTAMENTO 65)?
Play note A, then overlap note B, and track the pitch. A portamento patch should
sweep from A to B; the port forces c->legato = 0 (juno_bridge.c:891), which gates
off the glide (line 533: `c->legato && c->portamento_on`)."""
import ctypes, numpy as np
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR=44100
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_off.argtypes=[ctypes.c_void_p,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
def run(idx):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),idx)
    out=[]
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        out.append(np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2])
    L.juno_gui_note_on(c,48,100); blk(int(0.40*SR))     # low note
    L.juno_gui_note_on(c,60,100); blk(int(0.60*SR))     # overlap a note an octave up
    return np.concatenate(out)
def pitch_track(x):
    W=int(0.04*SR); out=[]
    for i in range(0,len(x)-W,int(0.02*SR)):
        s=x[i:i+W]*np.hanning(W)
        S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(W,1/SR)
        m=(fr>40)&(fr<800)
        out.append((i/SR, float(fr[m][np.argmax(S[m])])))
    return out
for idx,nm in ((4,"CW4 'BS Glide' (PORTAMENTO 65)"),(3,"CW3 'BS Solid' (PORTAMENTO 0)")):
    x=run(idx); tr=pitch_track(x)
    print("== %s =="%nm)
    print("   t(s)  dominant Hz     (note 48 at t=0, note 60 added at t=0.40)")
    for t,f in tr[::5]:
        mark=" <-- 2nd note" if abs(t-0.40)<0.03 else ""
        print("   %.2f   %7.1f%s"%(t,f,mark))
    seg=[f for t,f in tr if 0.40<t<0.60]
    print("   distinct pitches in the 200 ms after the 2nd note: %d  -> %s\n"%(
        len(set(round(f,0) for f in seg)),
        "GLIDE PRESENT" if len(set(round(f,0) for f in seg))>2 else "NO GLIDE (instant jump)"))
