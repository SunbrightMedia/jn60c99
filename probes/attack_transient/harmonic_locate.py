#!/usr/bin/env python3
"""COVENANT role 1 (LOCATE ONLY). Proper harmonic-structure comparison between
the port's current BS Solid and the user's capture: per-harmonic amplitudes,
attack window vs sustain window, gain-matched on the fundamental. No number from
the capture is copied into the port, a gate, or the ledger."""
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
def port():
    c=lib.juno_gui_create(ctypes.c_float(float(SR)),0)
    lib.juno_gui_apply_bank(c,bank,len(bank),3)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); lib.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    lib.juno_gui_note_on(c,60,100)
    k=int(2.0*SR); out[pos:pos+k]=blk(k); pos+=k
    lib.juno_gui_note_off(c,60,64)
    k=n-pos
    if k>0: out[pos:pos+k]=blk(k)
    return out
p=port()

def harmonics(x,t0,t1,f0):
    s0,s1=int(t0*SR),int(t1*SR); seg=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(seg))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    out=[]
    for k in range(1,25):
        f=f0*k; m=(fr>f-6)&(fr<f+6)
        out.append(S[m].max() if m.any() else 0.0)
    return np.array(out)

# find f0 from the capture sustain
s0,s1=int(1.0*SR),int(2.2*SR); seg=a[s0:s1]*np.hanning(s1-s0)
S=np.abs(np.fft.rfft(seg)); fr=np.fft.rfftfreq(s1-s0,1/SR)
b=(fr>60)&(fr<300); f0=fr[b][np.argmax(S[b])]
print("f0 = %.2f Hz\n"%f0)

for label,(t0,t1) in [("ATTACK 0.50-0.75s",(0.50,0.75)),
                      ("EARLY  0.75-1.10s",(0.75,1.10)),
                      ("SUSTAIN 1.2-2.4s", (1.20,2.40))]:
    hc=harmonics(a,t0,t1,f0); hp=harmonics(p,t0,t1,f0)
    g=hc[0]/(hp[0]+1e-30); hp=hp*g
    print("== %s (gain-matched on H1, x%.3f) ==" % (label,g))
    print("   H  freq   capture dB   port dB   delta(cap-port)")
    for k in range(0,18):
        c_,p_=hc[k],hp[k]
        if c_<=0 or p_<=0: continue
        print("  %3d %6.0f    %8.1f  %8.1f   %+7.1f" %
              (k+1,f0*(k+1),20*np.log10(c_),20*np.log10(p_),20*np.log10(c_/p_)))
    print()
# envelope shape (RMS over time) — is the filter sweep timing different?
def env(x):
    w_=int(0.02*SR); e=[]
    for i in range(int(0.45*SR),int(3.0*SR),w_):
        e.append(np.sqrt(np.mean(x[i:i+w_]**2)))
    return np.array(e)
ec,ep=env(a),env(p); g=ec.max()/(ep.max()+1e-30); ep=ep*g
t=np.arange(len(ec))*0.02+0.45
print("== AMPLITUDE ENVELOPE (peak-matched), every 100 ms ==")
print("   t(s)  capture dB   port dB   delta")
for i in range(0,len(ec),5):
    if ec[i]<=0 or ep[i]<=0: continue
    print("  %5.2f   %8.1f  %8.1f  %+7.1f"%(t[i],20*np.log10(ec[i]),20*np.log10(ep[i]),20*np.log10(ec[i]/ep[i])))
