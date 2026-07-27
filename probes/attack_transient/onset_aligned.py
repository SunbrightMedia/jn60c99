#!/usr/bin/env python3
"""SELF-CHECK before trusting the attack finding: align BOTH signals on their
TRUE onset (not the nominal 0.5 s) and re-measure. This project has previously
produced a false 'brightness' conclusion from a misaligned window, so the
alignment is verified explicitly here."""
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
L.juno_gui_note_off.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
L.juno_gui_apply_bank(c,bank,len(bank),3)
p=np.zeros(n); pos=0
def blk(nf):
    b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
    return np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
k=int(0.5*SR); p[pos:pos+k]=blk(k); pos+=k
L.juno_gui_note_on(c,60,100); k=int(2.0*SR); p[pos:pos+k]=blk(k); pos+=k
L.juno_gui_note_off(c,60,64); k=n-pos
if k>0: p[pos:pos+k]=blk(k)

def onset(x):
    pk=np.max(np.abs(x)); thr=pk*0.02
    idx=np.argmax(np.abs(x)>thr)
    return idx
oa,op=onset(a),onset(p)
print("onset: capture sample %d (%.4f s)   port sample %d (%.4f s)   offset %+d samples (%+.1f ms)"
      %(oa,oa/SR,op,op/SR,oa-op,(oa-op)/SR*1000))
f0=130.0
def harm(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); seg=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(seg))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR)
    out=[]
    for k in range(1,19):
        m=(fr>f0*k-25)&(fr<f0*k+25)
        out.append(S[m].max() if m.any() else 0.0)
    return np.array(out)
def cen(x,o,t0,t1):
    s0,s1=o+int(t0*SR),o+int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(s1-s0,1/SR)
    return float((fr*S).sum()/S.sum()) if S.sum()>0 else 0
print("\nONSET-ALIGNED comparison:")
for nm,t0,t1 in [("0-50ms",0.0,0.05),("50-150ms",0.05,0.15),("150-400ms",0.15,0.40),("SUSTAIN 0.7-1.9s",0.7,1.9)]:
    hc=harm(a,oa,t0,t1); hp=harm(p,op,t0,t1); g=hc[0]/(hp[0]+1e-30); hp=hp*g
    d=20*np.log10((hc[1:]+1e-30)/(hp[1:]+1e-30))
    print("  %-16s  harm RMS err %5.2f dB  mean %+5.2f   centroid cap %6.0f Hz / port %6.0f Hz"
          %(nm,float(np.sqrt(np.mean(d**2))),float(np.mean(d)),cen(a,oa,t0,t1),cen(p,op,t0,t1)))
