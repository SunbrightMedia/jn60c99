#!/usr/bin/env python3
"""jp8_probe.py -- bounded pitch probes on the fixed drive.
  jp8_probe.py set <sr> <patch> <id> <val> <flag>   override one engine id after recall, keys 48/60
  jp8_probe.py windows <sr> <patch> <key> [n=4]      f0 per consecutive 16384-sample window (sweep test)"""
import sys, os, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
mode=sys.argv[1]; sr=float(sys.argv[2]); patch=int(sys.argv[3]); t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); w,f=jp.host_init(); assert f==0
jp.recall(patch)
def meas(d,note):
    f0=AM.f0_autocorr(d,sr); c=1200*math.log2(f0/AM.midi_hz(note)) if f0>0 else float('nan')
    return f0,c,(AM.harmonicity(d,sr,f0) if f0>0 else 0)
if mode=="set":
    pid=int(sys.argv[4]); val=int(sys.argv[5]); flag=int(sys.argv[6])
    for u in range(9): jp.dispatch(u,pid,val,flag=flag)
    jp.notify(); jp.snap_ramps(); jp.clear_latch()
    for note in (48,60):
        jp.note_on(note,100); jp.render_both(1024); d,Lw,Rw=jp.render_both(8192); d=np.array(d); jp.note_off(note,64); jp.render_both(6000)
        f0,c,h=meas(d,note); log("sr %g patch %d id %d := %d flag %d key %d: DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g"%(sr,patch,pid,val,flag,note,f0,c,h,float(np.abs(d).max())))
elif mode=="windows":
    key=int(sys.argv[4]); n=int(sys.argv[5]) if len(sys.argv)>5 else 4
    jp.snap_ramps(); jp.clear_latch(); jp.note_on(key,100); jp.render_both(1024)
    for k in range(n):
        d,Lw,Rw=jp.render_both(16384); d=np.array(d); f0,c,h=meas(d,key)
        log("sr %g patch %d key %d window %d (%d..%d): DRY f0 %.2f Hz (%+.0f cents) harm %.2f peak %.3g"%(sr,patch,key,k,1024+16384*k,1024+16384*(k+1),f0,c,h,float(np.abs(d).max())))
# mode tail: jp8_probe.py tail <sr> <patch> <key> <tail_samples>  -- master/dry peak per 8192 after note-off
if mode=="tail":
    key=int(sys.argv[4]); n=int(sys.argv[5])
    jp.snap_ramps(); jp.clear_latch(); jp.note_on(key,100); jp.render_both(16384); jp.note_off(key,64)
    rows=[]
    for k in range(n//8192):
        d,Lw,Rw=jp.render_both(8192); L,nan=AM.words_to_floats(Lw); rows.append("%.3g/%.3g"%(float(np.abs(L).max()),max(abs(x) for x in d)))
    log("sr %g patch %d key %d release tail, master/dry peak per 8192: %s"%(sr,patch,key," ".join(rows)))
    log("master decays to <5%% of first block: %s"%(float(rows[-1].split('/')[0])<0.05*float(rows[0].split('/')[0])))
# mode tailfx: like tail but EFFECT/REVERB/DELAY LEVEL (794/795/796) := 0 first
if mode=="tailfx":
    key=int(sys.argv[4]); n=int(sys.argv[5])
    for pid in (794,795,796):
        for u in range(9): jp.dispatch(u,pid,0)
    jp.notify(); jp.snap_ramps(); jp.clear_latch(); jp.note_on(key,100); jp.render_both(16384); jp.note_off(key,64)
    rows=[]
    for k in range(n//8192):
        d,Lw,Rw=jp.render_both(8192); L,nan=AM.words_to_floats(Lw); rows.append("%.3g/%.3g"%(float(np.abs(L).max()),max(abs(x) for x in d)))
    log("FX OFF sr %g patch %d key %d release tail, master/dry peak per 8192: %s"%(sr,patch,key," ".join(rows)))
    log("master decays to <5%% of first block: %s"%(float(rows[-1].split('/')[0])<0.05*float(rows[0].split('/')[0])))
