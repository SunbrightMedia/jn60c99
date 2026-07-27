#!/usr/bin/env python3
"""IS THE DIVERGENCE PATCH-SPECIFIC OR SYSTEMATIC?

The whole investigation has focused on one patch. There are 8 factory-preset
bounces (same protocol: 44.1k, note 60, vel 100, 0.5 s silence + 2 s note).
Measure the SAME discriminator (H1-vs-midband tilt, RMS-normalised) for every
one. If all 8 show the same tilt, the flaw is systematic (DSP/harness) and every
bit-exact gate has been comparing the wrong thing. LOCATE ONLY."""
import ctypes, numpy as np, wave, os, sys
sys.path.insert(0,'tools/verify')
import truth
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
def render(idx,n,SR):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),idx)
    out=np.zeros(n); pos=0
    def blk(nf):
        b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
        return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    k=int(0.5*SR); out[pos:pos+k]=blk(k); pos+=k
    L.juno_gui_note_on(c,60,100); k=n-pos; out[pos:pos+k]=blk(k)
    return out
def onset(x):
    t=np.max(np.abs(x))*0.02; i=np.argmax(np.abs(x)>t); return int(i)
def tilt(x,o,SR,t0,t1,f0):
    s0,s1=o+int(t0*SR),o+int(t1*SR)
    s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/len(s); fr=np.fft.rfftfreq(len(s),1/SR)
    h1=S[(fr>f0-12)&(fr<f0+12)].max() if ((fr>f0-12)&(fr<f0+12)).any() else 1e-30
    m=(fr>=400)&(fr<3000); bd=np.sqrt(np.mean(S[m]**2)) if m.any() else 1e-30
    return 20*np.log10(h1/(bd+1e-30))
def f0of(x,o,SR):
    s0,s1=o+int(0.7*SR),o+int(1.9*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(len(s),1/SR)
    b=(fr>50)&(fr<700); return float(fr[b][np.argmax(S[b])])
print("H1-vs-(400-3000Hz) tilt, dB. NEGATIVE delta = port has MORE H1 relative to mids")
print("  (i.e. port duller / capture richer). Same protocol as BS Solid.\n")
print("  preset  f0(Hz)   ATTACK cap  port  delta    SUSTAIN cap  port  delta")
deltas=[]
for i in range(8):
    p=os.path.join(DIR,'preset%d.wav'%i)
    if not os.path.exists(p): continue
    a,SR,n=rd(p); x=render(i,n,SR)
    oa,op=onset(a),onset(x); f0=f0of(a,oa,SR)
    ta_c,ta_p=tilt(a,oa,SR,0.02,0.40,f0),tilt(x,op,SR,0.02,0.40,f0)
    ts_c,ts_p=tilt(a,oa,SR,0.70,1.90,f0),tilt(x,op,SR,0.70,1.90,f0)
    deltas.append((ta_c-ta_p,ts_c-ts_p))
    print("   %d      %6.1f    %7.1f %6.1f %+6.1f      %7.1f %6.1f %+6.1f"%(
        i,f0,ta_c,ta_p,ta_c-ta_p,ts_c,ts_p,ts_c-ts_p))
if deltas:
    da=[d[0] for d in deltas]; ds=[d[1] for d in deltas]
    print("\n  ATTACK  delta: mean %+.1f dB  min %+.1f  max %+.1f"%(np.mean(da),min(da),max(da)))
    print("  SUSTAIN delta: mean %+.1f dB  min %+.1f  max %+.1f"%(np.mean(ds),min(ds),max(ds)))
    print("\n  (BS Solid measured: ATTACK -11.4, SUSTAIN -2.0)")
    print("  SYSTEMATIC if every preset shows a similar negative ATTACK delta.")
