#!/usr/bin/env python3
"""jp8_d2.py -- D2 root-cause probe: id 769 VCO2 SUB RANGE (engine range -36..36) is dispatched
as the RAW bank byte 36 by recall(). Re-dispatch it after recall and measure DRY f0.
usage: jp8_d2.py <sr> <patch> <val> <flag> | jp8_d2.py <sr> <patch> none"""
import sys, os, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
sr=float(sys.argv[1]); patch=int(sys.argv[2]); t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); w,f=jp.host_init(); assert f==0
jp.recall(patch)
if sys.argv[3]!="none":
    val=int(sys.argv[3]); flag=int(sys.argv[4])
    for u in range(9): jp.dispatch(u,769,val,flag=flag)
    jp.notify(); lab="769:=%d flag %d"%(val,flag)
else: lab="control (recall only)"
jp.snap_ramps(); jp.clear_latch()
for note in (48,60):
    jp.note_on(note,100); d,Lw,Rw=jp.render_both(8192); d=np.array(d); jp.note_off(note,64); jp.render_both(6000)
    f0=AM.f0_autocorr(d[2048:],sr); c=1200*math.log2(f0/AM.midi_hz(note)) if f0>0 else float('nan')
    h=AM.harmonicity(d[2048:],sr,f0) if f0>0 else 0
    log("sr %g patch %d %s key %d: DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g faults %d"%(sr,patch,lab,note,f0,c,h,float(np.abs(d).max()),jp.faults))
