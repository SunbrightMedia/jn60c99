#!/usr/bin/env python3
"""jx_tune_probe.py -- does the JX recall's RAW dispatch of id 769 (DCO2 TUNE, engine -128..127, bank
raw 128 = centre) detune DCO2? Boot patch <p> with the repo's own recall (raw), mute DCO1 (770 := 0),
then set 769 := <val> (flag 1) and measure DCO2's pitch. usage: jx_tune_probe.py <patch> <val>"""
import sys, os, time, math
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jx_emu as J, audio_metrics as AM, numpy as np
patch=int(sys.argv[1]); val=int(sys.argv[2]); sr=44100.0; t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jx=J.JX().boot(sr, patch=patch, host_init=True, snap=False)
for u in range(J.N_UNITS): jx.dispatch(u,770,0); jx.dispatch(u,769,val)
jx.notify(); jx.snap_ramps(); jx.clear_latch()
for note in (48,60):
    jx.note_on(note,100); jx.render_dry(1024); d=np.array(jx.render_dry(16384)); jx.note_off(note,64); jx.render_dry(4000)
    f0=AM.f0_autocorr(d,sr); c=1200*math.log2(f0/AM.midi_hz(note)) if f0>0 else float('nan'); h=AM.harmonicity(d,sr,f0) if f0>0 else 0
    log("JX patch %d DCO1 muted, 769 DCO2 TUNE := %d (flag 1) key %d: DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g"%(patch,val,note,f0,c,h,float(np.abs(d).max())))
