#!/usr/bin/env python3
"""spectral probe: recall <patch> with flag <rflag>, overrides, snap, key <key>: early window f0/harm + top-8 spectral
peaks + engine pitch cells at the window start and end. usage: d4_spec.py <patch> <rflag> <key> [id=val ...]"""
import sys, os, struct, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
t0=time.time(); SR=44100.0
patch=int(sys.argv[1]); rflag=int(sys.argv[2]); key=int(sys.argv[3]); over=[a.split("=") for a in sys.argv[4:]]
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(SR); w,f=jp.host_init(); assert f==0
jp.recall(patch,flag=rflag)
for pid,v in over:
    for u in range(9): jp.dispatch(u,int(pid),int(v),flag=1)
if over: jp.notify()
jp.snap_ramps(); jp.clear_latch(); uc=jp.uc
def cells():
    return [(u,)+struct.unpack("<ff",uc.mem_read(jp.state[u]+0x16e0,4)+uc.mem_read(jp.state[u]+0x16f0,4)) for u in range(8) if any(uc.mem_read(jp.state[u]+o,4)!=b"\0\0\0\0" for o in (0x16e0,0x16f0))]
jp.note_on(key,100); jp.render_both(1024); c0=cells()
d,Lw,Rw=jp.render_both(16384); d=np.array(d); c1=cells()
f0=AM.f0_autocorr(d,SR); h=AM.harmonicity(d,SR,f0); pk=AM.spectral_peaks(d,SR,8)
print("[%5.1fs] patch %d rflag %d %s key %d: f0 %.2f Hz (%+.0f c) harm %.2f | peaks %s | cells@start %s | cells@end %s"%(time.time()-t0,patch,rflag," ".join("%s:=%s"%tuple(o) for o in over),key,f0,1200*math.log2(f0/AM.midi_hz(key)),h,
      " ".join("%.0fHz:%.2g"%(hz,m) for hz,m in pk)," ".join("u%d %.4f/%.4f"%c for c in c0)," ".join("u%d %.4f/%.4f"%c for c in c1)),flush=True)
