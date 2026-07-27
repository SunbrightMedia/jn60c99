#!/usr/bin/env python3
"""Is the port's H1 too LOUD, or its harmonics too QUIET? Gain-matching on H1
cannot tell these apart. Re-normalise three ways (H1, total RMS, and the
400-3000 Hz band) and compare. Also locate the resonant peak in each."""
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
oa,op=onset(a),onset(p)
def seg(x,o,t0,t1): 
    s0,s1=o+int(t0*SR),o+int(t1*SR); return x[s0:s1]
def spec(s):
    S=np.abs(np.fft.rfft(s*np.hanning(len(s))))/len(s); fr=np.fft.rfftfreq(len(s),1/SR); return fr,S
def pk(fr,S,f,tol=10):
    m=(fr>f-tol)&(fr<f+tol); return S[m].max() if m.any() else 0
def band(fr,S,lo,hi):
    m=(fr>=lo)&(fr<hi); return np.sqrt(np.mean(S[m]**2)) if m.any() else 0
for wn,t0,t1 in [("ATTACK 0.02-0.40",0.02,0.40),("SUSTAIN 0.7-1.9",0.70,1.90)]:
    sa,sp_=seg(a,oa,t0,t1),seg(p,op,t0,t1)
    fra,Sa=spec(sa); frp,Sp=spec(sp_)
    rmsa,rmsp=np.sqrt(np.mean(sa**2)),np.sqrt(np.mean(sp_**2))
    print("== %s =="%wn)
    print("   normaliser        cap H1 dB   port H1 dB   cap 400-3k dB  port 400-3k dB")
    for nm,ga,gp in [("H1",1/pk(fra,Sa,130),1/pk(frp,Sp,130)),
                     ("total RMS",1/rmsa,1/rmsp),
                     ("400-3000Hz band",1/(band(fra,Sa,400,3000)+1e-30),1/(band(frp,Sp,400,3000)+1e-30))]:
        print("   %-16s  %9.1f   %10.1f   %12.1f  %13.1f"%(nm,
            20*np.log10(pk(fra,Sa,130)*ga),20*np.log10(pk(frp,Sp,130)*gp),
            20*np.log10(band(fra,Sa,400,3000)*ga),20*np.log10(band(frp,Sp,400,3000)*gp)))
    # resonant peak location (max of smoothed spectrum 40-1200 Hz)
    for tag,fr_,S_ in (("capture",fra,Sa),("port",frp,Sp)):
        m=(fr_>40)&(fr_<1200); sm=np.convolve(S_[m],np.ones(9)/9,mode='same')
        print("   %s resonant peak: %.0f Hz"%(tag,fr_[m][sm.argmax()]))
    print("   H1-vs-band tilt (cap - port), dB: %+.1f"%(
        (20*np.log10(pk(fra,Sa,130)/(band(fra,Sa,400,3000)+1e-30)))-
        (20*np.log10(pk(frp,Sp,130)/(band(frp,Sp,400,3000)+1e-30)))))
    print()
