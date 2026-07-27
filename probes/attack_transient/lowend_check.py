#!/usr/bin/env python3
"""Is the harmonic grid right? DCO RANGE=2 (16') puts note 60 at ~130 Hz and the
SUB oscillator an octave below (~65 Hz). If a strong 65 Hz component exists, the
true f0 is 65 Hz and the earlier comparison used the wrong grid. Also compares
the 65 Hz : 130 Hz balance directly = the SUB-vs-MAIN oscillator mix."""
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
def sp(x,t0,t1):
    s0,s1=int(t0*SR),int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR); return fr,S
def peak(fr,S,f,tol=8):
    m=(fr>f-tol)&(fr<f+tol); return S[m].max() if m.any() else 0
for nm,t0,t1 in [("EARLY 0.52-0.90s",0.52,0.90),("SUSTAIN 1.2-2.4s",1.2,2.4)]:
    frc,Sc=sp(a,t0,t1); frp,Sp=sp(p,t0,t1)
    print("== %s =="%nm)
    print("   freq     capture dB    port dB    delta")
    for f in (32.5,65,97.5,130,195,260,390,520,650):
        vc,vp=peak(frc,Sc,f),peak(frp,Sp,f)
        if vc<=0 or vp<=0: continue
        print("  %6.1f    %8.1f   %8.1f   %+7.1f"%(f,20*np.log10(vc),20*np.log10(vp),20*np.log10(vc/vp)))
    r_c=peak(frc,Sc,65)/(peak(frc,Sc,130)+1e-30); r_p=peak(frp,Sp,65)/(peak(frp,Sp,130)+1e-30)
    print("   SUB(65Hz)/MAIN(130Hz) ratio: capture %.3f   port %.3f   -> port has %s sub"%(
        r_c,r_p,"MORE" if r_p>r_c else "LESS"))
    # find the strongest low peak
    for tag,fr_,S_ in (("capture",frc,Sc),("port",frp,Sp)):
        m=(fr_>30)&(fr_<300); i=np.argmax(S_[m]); print("   %s strongest 30-300Hz peak: %.1f Hz"%(tag,fr_[m][i]))
    print()
