#!/usr/bin/env python3
"""Test candidate DCO-mix assignments against the capture's FULL harmonic profile
(onset-aligned, attack + sustain). Our decode: PWM=217 SAW=197 SUB=83 NOISE=73.
The sub/main ratio points at SUB~192, suspiciously close to SAW's 197 -> test a
swap. LOCATE ONLY: whichever wins must then be re-derived from the binary."""
import ctypes, numpy as np, wave, re
CAP='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/438e4cb3-lastcatpureEVER.wav'
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
w=wave.open(CAP,'rb'); SR=w.getframerate(); n=w.getnframes(); nch=w.getnchannels()
a=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float64)/32768.0; w.close()
if nch==2: a=a.reshape(-1,2).mean(axis=1)
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_host_set.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
rows=re.findall(r'\{"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(\d+)',open('src/juno_hostparams.c').read())
IX={r[0]:i for i,r in enumerate(rows)}
def render(ov=()):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    for k,v in ov: L.juno_gui_host_set(c,IX[k],v)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k_=int(0.5*SR); out[pos:pos+k_]=blk(k_); pos+=k_
    L.juno_gui_note_on(c,60,100); k_=n-pos; out[pos:pos+k_]=blk(k_)
    return out
def onset(x):
    thr=np.max(np.abs(x))*0.02; return int(np.argmax(np.abs(x)>thr))
oa=onset(a); f0=130.0
def harm(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    r=[]
    for k in range(1,19):
        m=(fr>f0*k-25)&(fr<f0*k+25); r.append(S[m].max() if m.any() else 0.0)
    return np.array(r)
WIN=[("ATTACK",0.02,0.40),("SUSTAIN",0.70,1.90)]
HC={w:harm(a,oa,t0,t1) for w,t0,t1 in WIN}
def score(x):
    o=onset(x); tot=0; parts={}
    for wn,t0,t1 in WIN:
        hp=harm(x,o,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
        d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30))
        parts[wn]=float(np.sqrt(np.mean(d**2))); tot+=parts[wn]
    return tot,parts
CASES=[("as decoded (PWM217 SAW197 SUB83)",()),
       ("SUB<-192",(("DCO SUB LEVEL",192),)),
       ("SUB<-197",(("DCO SUB LEVEL",197),)),
       ("SWAP SAW<->SUB (SAW83 SUB197)",(("DCO SAW LEVEL",83),("DCO SUB LEVEL",197))),
       ("SWAP PWM<->SUB (PWM83 SUB217)",(("DCO PWM LEVEL",83),("DCO SUB LEVEL",217))),
       ("ROTATE (PWM197 SAW83 SUB217)",(("DCO PWM LEVEL",197),("DCO SAW LEVEL",83),("DCO SUB LEVEL",217))),
      ]
print("harmonic RMS error vs capture (lower=better), onset-aligned\n")
print("  %-34s ATTACK  SUSTAIN   TOTAL"%"case")
for nm,ov in CASES:
    t,p=score(render(ov))
    print("  %-34s %6.2f  %7.2f  %6.2f"%(nm,p["ATTACK"],p["SUSTAIN"],t))
