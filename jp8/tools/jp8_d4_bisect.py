#!/usr/bin/env python3
"""d4_bisect.py -- fresh boot: recall patch <base>, then apply patch <donor>'s ENGINE-frame values for the pools in
<spec> (e.g. 10-25 or 10,12,30), plus fixed overrides id=val; measure DRY f0 at key 60 (fresh note).
usage: d4_bisect.py <base> <donor> <spec> [id=val ...]"""
import sys, os, struct, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
t0=time.time()
base=int(sys.argv[1]); donor=int(sys.argv[2]); spec=sys.argv[3]; over=[a.split("=") for a in sys.argv[4:]]
pools=[]
for part in spec.split(","):
    if "-" in part: a,b=part.split("-"); pools+=list(range(int(a),int(b)+1))
    elif part: pools.append(int(part))
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
jp.recall(base)
mins=jp.pool_mins(); blob=J.patch_blob(J.bank_bytes(),donor)
for pool in pools:
    pid=J.POOL_BASE_ID+pool
    for u in range(9): jp.dispatch(u,pid,J.pool_value(blob,pool)+mins[pid],flag=1)
for pid,v in over:
    for u in range(9): jp.dispatch(u,int(pid),int(v),flag=1)
jp.notify(); jp.snap_ramps(); jp.clear_latch()
key=60; jp.note_on(key,100); jp.render_both(1024); d,Lw,Rw=jp.render_both(16384); d=np.array(d)
f0=AM.f0_autocorr(d,44100.0); c=1200*math.log2(f0/AM.midi_hz(key)) if f0>0 else float('nan'); h=AM.harmonicity(d,44100.0,f0) if f0>0 else 0
print("[%5.1fs] base %d + donor %d pools %s + %s key %d: DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g"%(time.time()-t0,base,donor,spec," ".join("%s:=%s"%tuple(o) for o in over),key,f0,c,h,float(np.abs(d).max())),flush=True)
