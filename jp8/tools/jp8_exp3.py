#!/usr/bin/env python3
"""jp8_exp3.py -- pitch vs sample rate on the clean 8' patch (2), key 60, DRY path. usage: jp8_exp3.py <sr>"""
import sys, os, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
sr=float(sys.argv[1]); patch=int(sys.argv[2]) if len(sys.argv)>2 else 2
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); w,f=jp.host_init(); assert f==0
jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
for note in (48,60):
    jp.note_on(note,100); d,Lw,Rw=jp.render_both(8192); d=np.array(d); jp.note_off(note,64); jp.render_both(6000)
    f0=AM.f0_autocorr(d[2048:],sr); c=1200*math.log2(f0/AM.midi_hz(note)) if f0>0 else float('nan')
    pk=AM.spectral_peaks(d[2048:],sr,4)
    log("sr %g patch %d key %d: DRY f0 %.2f Hz (%+.0f cents = %+.2f semis) harm %.2f peaks %s"%(sr,patch,note,f0,c,c/100,AM.harmonicity(d[2048:],sr,f0) if f0>0 else 0,[("%.1f"%a) for a,b in pk]))
