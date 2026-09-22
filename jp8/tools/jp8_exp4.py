#!/usr/bin/env python3
"""jp8_exp4.py -- candidate-cell probes + stability. usage: jp8_exp4.py stab <sr> | cand <id> <raw> [sr]"""
import sys, os, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
mode=sys.argv[1]; patch=2
if mode=="stab":
    sr=float(sys.argv[2])
    jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); jp.host_init(); jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
    jp.note_on(60,100); d,Lw,Rw=jp.render_both(65536); d=np.array(d)
    for k in range(0,65536,8192):
        seg=d[k:k+8192]; f0=AM.f0_autocorr(seg,sr); c=1200*math.log2(f0/AM.midi_hz(60)) if f0>0 else float('nan')
        log("sr %g key 60 block %2d (%6d..): f0 %.2f Hz (%+.0f c) rms %.3g"%(sr,k//8192,k,f0,c,float(np.sqrt((seg**2).mean()))))
else:
    pid=int(sys.argv[2]); raw=int(sys.argv[3]); sr=float(sys.argv[4]) if len(sys.argv)>4 else 44100.0
    jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); jp.host_init(); jp.recall(patch)
    for u in range(9): jp.dispatch(u,pid,raw)
    jp.notify(); jp.snap_ramps(); jp.clear_latch()
    jp.note_on(60,100); d,Lw,Rw=jp.render_both(8192); d=np.array(d)
    f0=AM.f0_autocorr(d[2048:],sr); c=1200*math.log2(f0/AM.midi_hz(60)) if f0>0 else float('nan')
    log("CAND id %d := raw %d (sr %g) patch 2 key 60: DRY f0 %.2f Hz (%+.0f cents) peak %.3g"%(pid,raw,sr,f0,c,float(np.abs(d).max())))
