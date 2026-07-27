#!/usr/bin/env python3
"""DECISIVE: compute the SUB(65Hz)/MAIN(130Hz) ratio from the PLUGIN'S OWN DSP
under Unicorn for BS Solid, to compare against the port's 0.096. If the plugin
gives ~0.45 the port has a real bug; if it gives ~0.096 the port matches the
plugin and the capture's instance differed. Oracle-only (no libjuno here)."""
import sys, struct, numpy as np
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR=44100.0
bank=open(BANK,'rb').read(); leaves=R.leaf_table()
e=RA.prepare_recall(3,bank,leaves,E,R,SR)
e.note_on(60,100)
Lb,Rb=e.render(int(SR*2.4), block=512)
f=lambda b: struct.unpack('<f',struct.pack('<I',b))[0]
x=np.array([f(v) for v in Lb])
def sp(t0,t1):
    s0,s1=int(t0*SR),int(t1*SR); s=x[s0:s1]*np.hanning(s1-s0)
    S=np.abs(np.fft.rfft(s))/(s1-s0); fr=np.fft.rfftfreq(s1-s0,1/SR); return fr,S
def pk(fr,S,fq,tol=8):
    m=(fr>fq-tol)&(fr<fq+tol); return S[m].max() if m.any() else 0
for nm,t0,t1 in [("EARLY 0.02-0.40s",0.02,0.40),("SUSTAIN 0.7-1.9s",0.7,1.9)]:
    fr,S=sp(t0,t1)
    s65,s130=pk(fr,S,65),pk(fr,S,130)
    print("%s: PLUGIN 65Hz %.1f dB  130Hz %.1f dB   SUB/MAIN ratio = %.3f"%(
        nm,20*np.log10(s65+1e-30),20*np.log10(s130+1e-30),s65/(s130+1e-30)))
print("\n(port measured earlier: EARLY 0.096, SUSTAIN 0.069; capture: 0.450 / 0.118)")
