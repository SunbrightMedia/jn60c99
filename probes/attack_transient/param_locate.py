#!/usr/bin/env python3
"""COVENANT role 1 (LOCATE ONLY). Which single parameter, when varied, best
explains the CAPTURE's attack harmonic profile? Sweeps each candidate over its
range through the port's own recall (juno_gui_host_set edits the record byte and
re-runs the exact recall) and reports the value minimising RMS harmonic error in
the attack window. This LOCATES the divergent parameter; any fix must then be
re-derived from the binary, never copied from here."""
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
L.juno_gui_host_set.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_off.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
def render(overrides=(),vel=100):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    for i,v in overrides: L.juno_gui_host_set(c,i,v)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_on(c,60,vel); k=int(2.0*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_off(c,60,64); k=n-pos
    if k>0: out[pos:pos+k]=blk(k)
    return out
f0=130.0
def harm(x,t0,t1):
    s0,s1=int(t0*SR),int(t1*SR); seg=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(seg))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    return np.array([S[(fr>f0*k-6)&(fr<f0*k+6)].max() for k in range(1,19)])
WINS=[("ATTACK",0.50,0.75),("SUSTAIN",1.20,2.40)]
HC={w:harm(a,t0,t1) for w,t0,t1 in WINS}
def err(x):
    tot={}
    for wn,t0,t1 in WINS:
        hp=harm(x,t0,t1); hc=HC[wn]; g=hc[0]/(hp[0]+1e-30); hp=hp*g
        d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30))
        tot[wn]=float(np.sqrt(np.mean(d**2)))
    return tot
base=err(render())
print("BASELINE (patch as decoded, vel100): attack err %.2f dB, sustain err %.2f dB\n"%(base["ATTACK"],base["SUSTAIN"]))
CANDS=[(13,"VCF ENV MOD",215),(16,"VCF VELOCITY SENS",157),(22,"ENV1 DECAY",121),
       (23,"ENV1 SUSTAIN",23),(12,"VCF RESONANCE",86),(10,"VCF CUTOFF FREQ",15),
       (21,"ENV1 ATTACK",18),(14,"VCF KEY FOLLOW",128)]
print("param sweep — value giving the LOWEST attack error (and what it does to sustain):")
print("  %-20s cur  best  attackErr(cur->best)  sustainErr@best"%"param")
for idx,nm,cur in CANDS:
    rows=[]
    for v in range(0,256,16):
        e=err(render(overrides=[(idx,v)]))
        rows.append((e["ATTACK"],v,e["SUSTAIN"]))
    rows.sort()
    ea,bv,es=rows[0]
    print("  %-20s %3d  %3d   %5.2f -> %5.2f        %5.2f %s"%(nm,cur,bv,base["ATTACK"],ea,es,
          "  <== big improvement" if ea<base["ATTACK"]-2 else ""))
