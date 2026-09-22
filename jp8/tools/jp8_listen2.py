#!/usr/bin/env python3
"""jp8_listen2.py -- PORT_PIPELINE step 4 on the JP8 oracle, the JX law (jx_listen.track_verdict):
boot (static init -> BUILD -> SETSR float -> FTZ -> host_init -> recall in the ENGINE frame -> snap
+ latch), idle must not run away, each key's DRY and MASTER pitch by autocorrelation, harmonic >= 0.80,
the keys tracked by ONE whole number of semitones (the patch's VCO1 RANGE: 3 = 8'), release decays,
no NaN. Instruction count per sample by a CODE hook installed after a TB flush (a block hook added
after the blocks were cached undercounted 90x in listen_p0_n60.log).
usage: jp8_listen2.py <sr> <patch> [notes=48,60,72]"""
import sys, os, time, math, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
sys.path.insert(0, "/home/user/jn60c99/jx3p/tools")
import jp8_emu as J, audio_metrics as AM, numpy as np
from jx_listen import track_verdict
from unicorn import *
sr=float(sys.argv[1]); patch=int(sys.argv[2]); notes=[int(x) for x in (sys.argv[3] if len(sys.argv)>3 else "48,60,72").split(",")]
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp=J.JP8(); ok,fail=jp.run_static_init(); f_static=jp.faults
jp.build(); jp.set_ftz(); jp.set_sr(sr); w,f=jp.host_init(); assert f==0
jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
name=J.patch_name(J.bank_bytes(),patch); blob=J.patch_blob(J.bank_bytes(),patch)
rng=J.pool_value(blob,20); sub=J.pool_value(blob,29)+jp.pool_mins()[769]
log("boot sr %g patch %d %r: static ok=%d fail=%d faults(static)=%d faults(after)=%d; VCO1 RANGE %d -> predicted shift %+d semis; VCO2 SUB RANGE engine %d"%(sr,patch,name,ok,fail,f_static,jp.faults-f_static,rng,12*(rng-3),sub))
def count(n):
    """instructions per sample over n samples, code hook, TB cache flushed first"""
    c=[0]
    def h(uc,a,s,u): c[0]+=1
    jp.uc.ctl_flush_tb(); hh=jp.uc.hook_add(UC_HOOK_CODE,h)
    try: jp.render_both(n)
    finally: jp.uc.hook_del(hh); jp.uc.ctl_flush_tb()
    return c[0]/n
fails=0
dry,Lw,Rw=jp.render_both(4096); L,nanL=AM.words_to_floats(Lw); pk=float(np.abs(L).max()); dpk=max(abs(x) for x in dry)
ok=pk<0.01 and dpk<0.01; fails+=not ok
log("%s idle 4096: dry peak %.3g master peak %.3g NaN %d"%("PASS" if ok else "FAIL",dpk,pk,nanL))
ipn_idle=count(32); log("idle cost: %.0f instr/sample (code hook, 32 samples)"%ipn_idle)
resd=[]; resm=[]; nan_total=0; ipn_note=None
for n in notes:
    jp.note_on(n,100); jp.render_both(1024)
    d,Lw,Rw=jp.render_both(16384); d=np.array(d); L,nanL=AM.words_to_floats(Lw); R,nanR=AM.words_to_floats(Rw); nan_total+=nanL+nanR+jp.dry_nan
    f0d=AM.f0_autocorr(d,sr); hd=AM.harmonicity(d,sr,f0d) if f0d>0 else 0
    f0m=AM.f0_autocorr(L,sr); hm=AM.harmonicity(L,sr,f0m) if f0m>0 else 0
    cd=1200*math.log2(f0d/AM.midi_hz(n)) if f0d>0 else float('nan'); cm=1200*math.log2(f0m/AM.midi_hz(n)) if f0m>0 else float('nan')
    log("key %d: DRY f0 %.2f Hz (%+.0f c) harmonic %.3f peak %.4g | MASTER f0 %.2f Hz (%+.0f c) harmonic %.3f peak %.4g | NaN %d"%(n,f0d,cd,hd,float(np.abs(d).max()),f0m,cm,hm,float(np.abs(L).max()),nanL+nanR+jp.dry_nan))
    resd.append((n,f0d,hd)); resm.append((n,f0m,hm))
    if ipn_note is None: ipn_note=count(32); log("sustain cost: %.0f instr/sample (code hook, 32 samples)"%ipn_note)
    jp.note_off(n,64)
    tail,Lw,Rw=jp.render_both(24000); tail=np.array(tail); Lt,nt=AM.words_to_floats(Lw); nan_total+=nt+jp.dry_nan
    hd_,ld_=float(np.abs(tail[:4096]).max()),float(np.abs(tail[-4096:]).max()); hm_,lm_=float(np.abs(Lt[:4096]).max()),float(np.abs(Lt[-4096:]).max())
    okd=ld_<0.05*max(hd_,1e-9) or ld_<1e-4; okm=lm_<0.05*max(hm_,1e-9) or lm_<1e-4; fails+=(not okd)+(not okm)
    log("%s release dry %d: %.3g -> %.3g | %s release master: %.3g -> %.3g (24000 samples)"%("PASS" if okd else "FAIL",n,hd_,ld_,"PASS" if okm else "FAIL",hm_,lm_))
okd,msgd=track_verdict(resd); okm,msgm=track_verdict(resm); fails+=(not okd)+(not okm)
log("DRY    %s (patch VCO1 RANGE predicts %+d)"%(msgd,12*(rng-3))); log("MASTER %s"%msgm)
ok=nan_total==0; fails+=not ok; log("%s NaN census %d; faults after static init %d"%("PASS" if ok else "FAIL",nan_total,jp.faults-f_static))
for lab,i in (("idle",ipn_idle),("sustain",ipn_note)):
    log("S3 estimate (%s): %.0f x86 instr/sample x 1.75 = %.0f cyc/sample = %.0f%% of 10,000 cyc/sample @48k (count PROVEN on this oracle; 1.75 calibration INFERRED)"%(lab,i,i*1.75,i*1.75/100))
log("JP8 LISTEN sr %g patch %d: %s"%(sr,patch,"GREEN" if not fails else "%d FAIL"%fails))
sys.exit(1 if fails else 0)
