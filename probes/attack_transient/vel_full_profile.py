#!/usr/bin/env python3
"""Velocity scales VCF ENV depth (VCF VELOCITY SENS=157 on this patch), which
dominates the ATTACK and barely moves the SUSTAIN — exactly the measured
asymmetry. Score the FULL profile (attack + sustain) across velocities."""
import ctypes, numpy as np, wave
CAP='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/438e4cb3-lastcatpureEVER.wav'
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
w=wave.open(CAP,'rb'); SR=w.getframerate(); n=w.getnframes(); nch=w.getnchannels()
a=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float64)/32768.0; w.close()
if nch==2: a=a.reshape(-1,2).mean(axis=1)
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
def render(vel):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_on(c,60,vel); k=n-pos; out[pos:pos+k]=blk(k)
    return out
def onset(x):
    t=np.max(np.abs(x))*0.02; return int(np.argmax(np.abs(x)>t))
oa=onset(a); f0=130.0
def harm(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    r=[]
    for k in range(1,19):
        m=(fr>f0*k-25)&(fr<f0*k+25); r.append(S[m].max() if m.any() else 0.0)
    return np.array(r)
WIN=[("ATTACK",0.02,0.40),("SUSTAIN",0.70,1.90)]
HC={wn:harm(a,oa,t0,t1) for wn,t0,t1 in WIN}
def subm(x,o):
    s0,s1=o+int(0.02*SR),o+int(0.40*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(s1-s0,1/SR)
    pk=lambda f:(S[(fr>f-8)&(fr<f+8)].max() if ((fr>f-8)&(fr<f+8)).any() else 0)
    return pk(65)/(pk(130)+1e-30)
print("full-profile fit vs capture (capture sub/main = 0.450)\n")
print("  vel   ATTACK  SUSTAIN   TOTAL   sub/main")
for vel in (100,110,115,120,124,127):
    x=render(vel); o=onset(x); tot=0; pr={}
    for wn,t0,t1 in WIN:
        hp=harm(x,o,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
        d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30)); pr[wn]=float(np.sqrt(np.mean(d**2))); tot+=pr[wn]
    print("  %3d   %6.2f  %7.2f  %6.2f   %.3f"%(vel,pr["ATTACK"],pr["SUSTAIN"],tot,subm(x,o)))
