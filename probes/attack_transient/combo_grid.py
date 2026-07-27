#!/usr/bin/env python3
"""Are the two partial effects independent and jointly sufficient? Grid over
velocity x DCO SUB LEVEL. If a combination collapses BOTH attack and sustain
error AND the sub/main ratio, the real instance differs in those specific ways.
LOCATE ONLY - no fitted value is written into the port."""
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
rows=re.findall(r'\{"([^"]+)"',open('src/juno_hostparams.c').read())
IX={nm:i for i,nm in enumerate(rows)}
def render(vel,sub=None):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    if sub is not None: L.juno_gui_host_set(c,IX["DCO SUB LEVEL"],sub)
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
    return np.array([ (S[(fr>f0*k-25)&(fr<f0*k+25)].max() if ((fr>f0*k-25)&(fr<f0*k+25)).any() else 0.0) for k in range(1,19)])
WIN=[("A",0.02,0.40),("S",0.70,1.90)]
HC={wn:harm(a,oa,t0,t1) for wn,t0,t1 in WIN}
def sc(x):
    o=onset(x); tot=0; pr={}
    for wn,t0,t1 in WIN:
        hp=harm(x,o,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
        d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30)); pr[wn]=float(np.sqrt(np.mean(d**2))); tot+=pr[wn]
    return tot,pr
print("  vel  sub   ATTACK  SUSTAIN  TOTAL")
best=None
for vel in (100,110,115,120):
    for sub in (83,128,160,192,224):
        t,pr=sc(render(vel,sub))
        if best is None or t<best[0]: best=(t,vel,sub,pr)
        print("  %3d  %3d   %6.2f  %7.2f %6.2f"%(vel,sub,pr["A"],pr["S"],t))
print("\nBEST: vel %d sub %d -> attack %.2f sustain %.2f total %.2f (baseline vel100/sub83 = 13.11)"%(
    best[1],best[2],best[3]["A"],best[3]["S"],best[0]))
