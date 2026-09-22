#!/usr/bin/env python3
"""jx_ctrl.py -- ISOLATION CONTROL (mantra 5): the JX-3P oracle under the SAME drive as the JP8,
pitch vs rate, with the D2 recall law (raw pool byte + engine-DB min) applied identically.
usage: jx_ctrl.py <sr> [patch=0]"""
import sys, os, time, math
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jx_emu as J, audio_metrics as AM, numpy as np, pe_recon
sr=float(sys.argv[1]); patch=int(sys.argv[2]) if len(sys.argv)>2 else 0; t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
rows=pe_recon.PE(J.BIN).params([J.POOL_BASE_ID+p for p in J.ACTIVE_POOLS])["rows"]
mins={J.POOL_BASE_ID+p: rows[J.POOL_BASE_ID+p]["min"] for p in J.ACTIVE_POOLS}
neg={k:v for k,v in mins.items() if v}
log("JX engine-DB pool mins != 0: %s (the raw+min law is a no-op on the JX when this is empty)"%neg)
jx=J.JX(); jx.run_static_init(); jx.build(); jx.set_ftz(); jx.set_sr(sr); w,f=jx.host_init(); assert f==0
blob=J.patch_blob(J.bank_bytes(),patch)
for u in range(J.N_UNITS):
    for pool in J.ACTIVE_POOLS:
        pid=J.POOL_BASE_ID+pool; jx.dispatch(u,pid,J.pool_value(blob,pool)+mins[pid])
jx.notify(); jx.snap_ramps(); jx.clear_latch()
rng=J.pool_value(blob,20); log("JX patch %d DCO1 RANGE %d (3 = 8'; jx_listen law: pitch tracks keys by 12*(RANGE-3) = %+d semis)"%(patch,rng,12*(rng-3)))
res=[]
for note in (48,60):
    jx.note_on(note,100); jx.render_dry(1024); d=np.array(jx.render_dry(16384)); jx.note_off(note,64); jx.render_dry(4000)
    f0=AM.f0_autocorr(d,sr); c=1200*math.log2(f0/AM.midi_hz(note)) if f0>0 else float('nan'); h=AM.harmonicity(d,sr,f0) if f0>0 else 0
    res.append(c); log("JX sr %g patch %d key %d: DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g"%(sr,patch,note,f0,c,h,float(np.abs(d).max())))
ok=all(abs(c-100*12*(rng-3))<=25 for c in res)
log("JX CONTROL sr %g patch %d: %s (offsets %s vs RANGE law %+d semis)"%(sr,patch,"PASS" if ok else "FAIL",["%+.0f"%c for c in res],12*(rng-3)))
