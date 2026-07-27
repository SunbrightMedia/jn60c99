#!/usr/bin/env python3
"""COVENANT role 1 (LOCATE ONLY): BS Solid has VCF VELOCITY SENS = 157, which
scales the filter envelope by note velocity. Render the port across velocities
and see which one reproduces the CAPTURE's attack harmonic profile. This locates
whether velocity (or its scaling law) is the divergent variable. No capture
number is copied into the port/gate/ledger."""
import ctypes, numpy as np, wave
CAP='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/438e4cb3-lastcatpureEVER.wav'
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
w=wave.open(CAP,'rb'); SR=w.getframerate(); n=w.getnframes(); nch=w.getnchannels()
a=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float64)/32768.0; w.close()
if nch==2: a=a.reshape(-1,2).mean(axis=1)
lib=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype=ctypes.c_void_p
lib.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
lib.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
lib.juno_gui_note_off.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
lib.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
def render(vel):
    c=lib.juno_gui_create(ctypes.c_float(float(SR)),0)
    lib.juno_gui_apply_bank(c,bank,len(bank),3)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); lib.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    lib.juno_gui_note_on(c,60,vel); k=int(2.0*SR); out[pos:pos+k]=blk(k); pos+=k
    lib.juno_gui_note_off(c,60,64); k=n-pos
    if k>0: out[pos:pos+k]=blk(k)
    return out
f0=130.0
def harm(x,t0,t1):
    s0,s1=int(t0*SR),int(t1*SR); seg=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(seg))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    return np.array([S[(fr>f0*k-6)&(fr<f0*k+6)].max() for k in range(1,19)])
hc=harm(a,0.50,0.75)
print("attack-window harmonic fit vs capture (gain-matched on H1); lower RMS err = closer")
print(" vel   RMS err(dB) over H2..H18    mean delta(cap-port) dB")
best=None
for vel in (64,80,100,110,120,127):
    hp=harm(render(vel),0.50,0.75); g=hc[0]/(hp[0]+1e-30); hp*=g
    d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30))
    err=float(np.sqrt(np.mean(d**2))); md=float(np.mean(d))
    print("  %3d      %6.2f                    %+7.2f"%(vel,err,md))
    if best is None or err<best[1]: best=(vel,err)
print("\nbest-fitting velocity: %d (err %.2f dB)"%best)
