#!/usr/bin/env python3
"""DECISIVE TEST: BS Solid is ASSIGN MODE 2. gui/juno_bridge.c hard-overrides
assign_mode to 0 (POLY) after reading the patch value. Compare the port's
harmonic profile vs the capture with the override ON (current shipping
behaviour) and OFF (patch's real UNISON = 8 stacked detuned voices).
LOCATE ONLY."""
import ctypes, numpy as np, wave, os, subprocess, json, sys
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
def render():
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_on(c,60,100); k=n-pos; out[pos:pos+k]=blk(k)
    return out
def onset(x):
    t=np.max(np.abs(x))*0.02; return int(np.argmax(np.abs(x)>t))
f0=130.0
def harm(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    r=[]
    for k in range(1,19):
        m=(fr>f0*k-25)&(fr<f0*k+25); r.append(S[m].max() if m.any() else 0.0)
    return np.array(r)
oa=onset(a); WIN=[("ATTACK",0.02,0.40),("SUSTAIN",0.70,1.90)]
HC={wn:harm(a,oa,t0,t1) for wn,t0,t1 in WIN}
def sub_main(x,o):
    s0,s1=o+int(0.02*SR),o+int(0.40*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(s1-s0,1/SR)
    pk=lambda f:(S[(fr>f-8)&(fr<f+8)].max() if ((fr>f-8)&(fr<f+8)).any() else 0)
    return pk(65)/(pk(130)+1e-30)
x=render(); o=onset(x); tot=0; parts={}
for wn,t0,t1 in WIN:
    hp=harm(x,o,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
    d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30)); parts[wn]=float(np.sqrt(np.mean(d**2))); tot+=parts[wn]
mode = "UNISON kept (JUNO_KEEP_ASSIGN set)" if os.environ.get('JUNO_KEEP_ASSIGN') else "POLY override (shipping)"
print(json.dumps({"mode":mode,"ATTACK":round(parts["ATTACK"],2),"SUSTAIN":round(parts["SUSTAIN"],2),
                  "TOTAL":round(tot,2),"sub_main":round(sub_main(x,o),3),
                  "peak":round(float(np.max(np.abs(x))),4)}))
