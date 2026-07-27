#!/usr/bin/env python3
"""HYPOTHESIS TEST (LOCATE ONLY): does an output-stage saturation reconcile the
port with the capture? The port lacks any output boost/saturation stage because
Boost Mode / Output Gain write ZERO engine cells (they live in the wrapper's
output path). Soft clipping compresses the dominant fundamental, which raises
harmonics, sub AND broadband noise relative to it — exactly the three things
measured. If a modest drive collapses the harmonic error, the missing stage is
identified. NOTHING here is copied into the port; any real fix must be derived
from the binary's own boost implementation."""
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
c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
L.juno_gui_apply_bank(c,bank,len(bank),3)
p=np.zeros(n); pos=0
def blk(nf):
    b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
    return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
k=int(0.5*SR); p[pos:pos+k]=blk(k); pos+=k
L.juno_gui_note_on(c,60,100); k=n-pos; p[pos:pos+k]=blk(k)
def onset(x):
    t=np.max(np.abs(x))*0.02; return int(np.argmax(np.abs(x)>t))
oa,op=onset(a),onset(p); f0=130.0
def harm(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    r=[]
    for kk in range(1,19):
        m=(fr>f0*kk-25)&(fr<f0*kk+25); r.append(S[m].max() if m.any() else 0.0)
    return np.array(r)
WIN=[("ATTACK",0.02,0.40),("SUSTAIN",0.70,1.90)]
HC={wn:harm(a,oa,t0,t1) for wn,t0,t1 in WIN}
def score(x,o):
    tot=0; parts={}
    for wn,t0,t1 in WIN:
        hp=harm(x,o,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
        d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30))
        parts[wn]=float(np.sqrt(np.mean(d**2))); tot+=parts[wn]
    return tot,parts
t0,p0=score(p,op)
print("port as-is:                        ATTACK %5.2f  SUSTAIN %5.2f  TOTAL %5.2f"%(p0["ATTACK"],p0["SUSTAIN"],t0))
print("\nwith an output-stage soft saturation tanh(drive*x)/drive:")
best=None
for drive in (1.5,2,3,4,6,8,12,16,24,32):
    y=np.tanh(drive*p)/drive
    t,pp=score(y,onset(y))
    mark=""
    if best is None or t<best[0]: best=(t,drive); mark=""
    print("  drive %5.1f  ->  ATTACK %5.2f  SUSTAIN %5.2f  TOTAL %5.2f"%(drive,pp["ATTACK"],pp["SUSTAIN"],t))
print("\nbest drive %.1f -> total %.2f  (baseline %.2f, improvement %.2f dB)"%(best[1],best[0],t0,t0-best[0]))
