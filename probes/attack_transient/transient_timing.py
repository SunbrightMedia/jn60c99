#!/usr/bin/env python3
"""COVENANT role 1 (LOCATE ONLY): fine-grained transient timing — amplitude and
brightness vs time for the port and the capture, 10 ms resolution, first 700 ms.
Characterises WHEN each reaches peak and how fast it decays."""
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

def track(x):
    W=int(0.010*SR); ts=[];amp=[];cen=[]
    for i in range(int(0.48*SR),int(1.30*SR),W):
        s=x[i:i+W]
        if len(s)<W: break
        r=np.sqrt(np.mean(s**2)); amp.append(r)
        sp=np.abs(np.fft.rfft(s*np.hanning(len(s)))); fr=np.fft.rfftfreq(len(s),1/SR)
        m=sp.sum(); cen.append(float((fr*sp).sum()/m) if m>0 else 0.0)
        ts.append(i/SR)
    return np.array(ts),np.array(amp),np.array(cen)
tc,ac,cc=track(a); tp,ap,cp=track(p)
gc=ac.max(); gp=ap.max()
print("PEAK TIME: capture %.3f s   port %.3f s   (note-on at 0.500 s)"%(tc[ac.argmax()],tp[ap.argmax()]))
print("  -> capture peaks %.0f ms after note-on; port peaks %.0f ms after"%(
    (tc[ac.argmax()]-0.5)*1000,(tp[ap.argmax()]-0.5)*1000))
print("\n  t-on(ms)  capAmp dB  portAmp dB   capCentroid Hz  portCentroid Hz")
for i in range(0,len(tc),4):
    if i>=len(tp): break
    print("   %6.0f   %8.1f  %9.1f   %11.0f  %13.0f"%((tc[i]-0.5)*1000,
        20*np.log10(ac[i]/gc+1e-12),20*np.log10(ap[i]/gp+1e-12),cc[i],cp[i]))
