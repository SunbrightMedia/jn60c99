#!/usr/bin/env python3
"""CONFIRMATORY: if the user's instance has Keyboard Velocity SW ON (so notes
arrive at their real velocity instead of the forced 100), then EVERY bounce of a
velocity-sensitive patch should fit better at a higher velocity. Factory 0
(VCF VEL SENS 105) and factory 5 (92) are the independent tests; factory 1/3/6
(sens 0) are the control - their fit must NOT depend on velocity."""
import ctypes, numpy as np, wave, os, sys
sys.path.insert(0,'tools/verify'); import truth
DIR='/home/user/jn60c99/scratchpad/diag_bounces'
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(truth.BANK,'rb').read()
def rd(p):
    w=wave.open(p,'rb'); sr=w.getframerate(); n=w.getnframes(); nch=w.getnchannels()
    x=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float64)/32768.0; w.close()
    if nch==2: x=x.reshape(-1,2).mean(axis=1)
    return x,sr,n
def render(idx,n,SR,vel):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),idx)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_on(c,60,vel); k=n-pos; out[pos:pos+k]=blk(k)
    return out
def onset(x):
    t=np.max(np.abs(x))*0.02; return int(np.argmax(np.abs(x)>t))
def tilt(x,o,SR,f0):
    s0,s1=o+int(0.02*SR),o+int(0.40*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/len(s); fr=np.fft.rfftfreq(len(s),1/SR)
    h1=S[(fr>f0-12)&(fr<f0+12)].max(); m=(fr>=400)&(fr<3000)
    return 20*np.log10(h1/(np.sqrt(np.mean(S[m]**2))+1e-30))
def f0of(x,o,SR):
    s0,s1=o+int(0.7*SR),o+int(1.9*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(len(s),1/SR); b=(fr>50)&(fr<700)
    return float(fr[b][np.argmax(S[b])])
SENS={0:105,5:92,1:0,3:0,6:0}
print("attack tilt delta (capture-port); best velocity per patch")
print("  patch  velsens |  v100    v110    v120    v127  | best")
for i in (0,5,1,3,6):
    p=os.path.join(DIR,'preset%d.wav'%i)
    if not os.path.exists(p): continue
    a,SR,n=rd(p); oa=onset(a); f0=f0of(a,oa,SR); tc=tilt(a,oa,SR,f0)
    ds=[]
    for vel in (100,110,120,127):
        x=render(i,n,SR,vel); ds.append(tc-tilt(x,onset(x),SR,f0))
    bi=int(np.argmin(np.abs(ds)))
    print("   %d       %4d  | %+6.1f %+6.1f %+6.1f %+6.1f | v%d"%(
        i,SENS[i],ds[0],ds[1],ds[2],ds[3],(100,110,120,127)[bi]))
print("\n  (BS Solid, velsens 157: v100 -11.4, best fit around v115)")
print("  If the SENS>0 patches also prefer a higher velocity -> the user's")
print("  instance has Kbd Vel SW ON. If they prefer v100 -> BS Solid is unique.")
