#!/usr/bin/env python3
"""Which parameter drives the SUB(65Hz)/MAIN(130Hz) ratio to the capture's 0.45?
Port-side sweep via the port's own recall (juno_gui_host_set edits the record
byte and re-runs the exact recall). LOCATE ONLY."""
import ctypes, numpy as np, re
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR=44100
L=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
L.juno_gui_create.restype=ctypes.c_void_p
L.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
L.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_host_set.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
L.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
bank=open(BANK,'rb').read()
src=open('src/juno_hostparams.c').read()
rows=re.findall(r'\{"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\}',src)
names={i:r[0] for i,r in enumerate(rows)}
def ratio(ov=()):
    c=L.juno_gui_create(ctypes.c_float(float(SR)),0)
    L.juno_gui_apply_bank(c,bank,len(bank),3)
    for i,v in ov: L.juno_gui_host_set(c,i,v)
    L.juno_gui_note_on(c,60,100)
    nf=int(SR*0.45); b=(ctypes.c_float*(2*nf))(); L.juno_gui_render(c,b,nf)
    x=np.frombuffer(b,dtype=np.float32).astype(np.float64)[0::2]
    s=x[int(0.02*SR):]*np.hanning(len(x)-int(0.02*SR))
    S=np.abs(np.fft.rfft(s)); fr=np.fft.rfftfreq(len(s),1/SR)
    pk=lambda f:(S[(fr>f-8)&(fr<f+8)].max() if ((fr>f-8)&(fr<f+8)).any() else 0)
    return pk(65)/(pk(130)+1e-30)
base=ratio(); print("port baseline SUB/MAIN = %.3f   (capture 0.450, plugin-emulated 0.100)\n"%base)
CAND=[i for i,r in enumerate(rows) if r[0] in
      ("DCO SUB LEVEL","DCO SAW LEVEL","DCO PWM LEVEL","DCO NOISE LEVEL","DCO RANGE",
       "VCF CUTOFF FREQ","VCF RESONANCE","HPF CUTOFF FREQ","HPF TYPE","VCA TONE","VCF ENV MOD")]
print(" param                 value giving ratio closest to 0.450")
for i in CAND:
    best=None
    for v in range(0,256,8):
        try: r=ratio([(i,v)])
        except Exception: continue
        d=abs(r-0.450)
        if best is None or d<best[0]: best=(d,v,r)
    print("  %-20s v=%3d -> ratio %.3f   (|err| %.3f)%s"%(names[i],best[1],best[2],best[0],
          "   <== reaches the capture's ratio" if best[0]<0.05 else ""))
