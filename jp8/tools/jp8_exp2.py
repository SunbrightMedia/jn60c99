#!/usr/bin/env python3
"""jp8_exp2.py -- where does the sample rate go? Boot to SETSR(44100), snapshot unit 0 + unit 8 + HOST,
SETSR(48000) again, diff. Then scan for the float/double 44100 and 1/44100 in state[0]. Also the JX twin."""
import sys, os, struct, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
which=sys.argv[1]
if which=="jp8":
    import jp8_emu as J; jp=J.JP8()
else:
    import jx_emu as J; jp=J.JX()
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0)
uc=jp.uc; SZ=J.STATE_SZ
def snap(): return [bytes(uc.mem_read(jp.state[u],SZ)) for u in (0,8)]+[bytes(uc.mem_read(jp.HOST,0x8000))]
a=snap(); jp.set_sr(48000.0); b=snap(); jp.set_sr(44100.0); c=snap()
for k,lab in enumerate(("state0","state8","HOST")):
    diffs=[i for i in range(0,len(a[k]),4) if a[k][i:i+4]!=b[k][i:i+4]]
    back=[i for i in diffs if a[k][i:i+4]==c[k][i:i+4]]
    log("%s: %d dwords differ 44100->48000, %d of them return at 44100"%(lab,len(diffs),len(back)))
    for i in diffs[:24]:
        fa=struct.unpack("<f",a[k][i:i+4])[0]; fb=struct.unpack("<f",b[k][i:i+4])[0]
        ia=struct.unpack("<I",a[k][i:i+4])[0]; ib=struct.unpack("<I",b[k][i:i+4])[0]
        log("   +0x%06x: %r -> %r  (u32 %d -> %d)"%(i,fa,fb,ia,ib))
# scan for literal 44100 in state 0 (float, double, int)
s=a[0]
for lab,pat in (("f32 44100",struct.pack("<f",44100.0)),("f64 44100",struct.pack("<d",44100.0)),("i32 44100",struct.pack("<i",44100)),("f32 1/44100",struct.pack("<f",1/44100.0)),("f32 22050",struct.pack("<f",22050.0))):
    hits=[]; k=0
    while True:
        k=s.find(pat,k)
        if k<0 or len(hits)>12: break
        hits.append(k); k+=1
    log("state0 scan %s: %s"%(lab,["0x%x"%h for h in hits]))
h=a[2]
for lab,pat in (("f32 44100",struct.pack("<f",44100.0)),("f64 44100",struct.pack("<d",44100.0))):
    hits=[]; k=0
    while True:
        k=h.find(pat,k)
        if k<0 or len(hits)>12: break
        hits.append(k); k+=1
    log("HOST scan %s: %s"%(lab,["0x%x"%x for x in hits]))
