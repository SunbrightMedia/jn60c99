#!/usr/bin/env python3
"""jp8_listen2.py -- PORT_PIPELINE step 4 on the JP8 oracle, the JX law (jx_listen.track_verdict):
boot = DRIVE2 (jp8_emu default, S3_STATUS D7: static init -> HOST via the plugin's FACTORY 0x444FE0 -> BUILD -> FTZ ->
SETSR float -> host_init -> recall through HOSTPARAM (host id, raw bank value); NO snap, NO latch clear; a ramp census
after every stage must show 0 live NaN/inf ramps), idle must not run away, each key's DRY and MASTER pitch by autocorrelation, harmonic >= 0.80,
f0 on the engine's OWN pitch cells (drive2: DRY f0 within 25 cents of midi_hz(key)*2^(cell-2) of one VCO, cells
[state+0x16e0]/[+0x16f0] read at the window start and end; PORT_LESSONS 3) in the EARLY window (1024..17408 after
note-on) or, when that fails, the LATE window (49152..65536; the sweep's rule, PORT_LESSONS 4), the JX whole-semitone track on DRY and MASTER (unchanged), release decays (24000 samples, else the 3 s tail rule of jp8_sweep.py: the delay/reverb
tail, S3_STATUS master release rule), no NaN. Instruction count per sample by a CODE hook installed after a TB flush (a block hook added
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
cen=[]
jp=J.JP8(); assert not jp.legacy, "drive2 listen: unset JP8_EMU_LEGACY_HOST"
jp.boot(sr=sr, patch=patch, census=lambda t,c,h: cen.append((t,c,h))); ok,fail=jp.static_ok; f_static=jp.faults_static
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
for t,c,h in cen:
    if c: log("CENSUS %-12s live ramps %d, live NaN/inf %d (all records %d, bad %d), latch sum %d, state+0x10 %r, host_map %d"%(t,c["live"],c["live_bad"],c["records"],c["all_bad"],c["latch_sum"],c["rate0"],h))
    else: log("CENSUS %-12s host_map %d"%(t,h))
bad=sum(c["live_bad"] for t,c,h in cen if c); fails+=bad>0
log("%s boot census: live NaN/inf ramps over all stages %d; HOST via factory %d allocations; host_init writes %d"%("PASS" if not bad else "FAIL",bad,jp.host_allocs,jp.hostinit_writes))
dry,Lw,Rw=jp.render_both(4096); L,nanL=AM.words_to_floats(Lw); pk=float(np.abs(L).max()); dpk=max(abs(x) for x in dry)
ok=pk<0.01 and dpk<0.01; fails+=not ok
log("%s idle 4096: dry peak %.3g master peak %.3g NaN %d"%("PASS" if ok else "FAIL",dpk,pk,nanL))
c4=jp.ramp_census(); fails+=c4["live_bad"]>0; log("%s census after idle: live ramps %d (NaN/inf %d), latch sum %d"%("PASS" if not c4["live_bad"] else "FAIL",c4["live"],c4["live_bad"],c4["latch_sum"]))
ipn_idle=count(32); log("idle cost: %.0f instr/sample (code hook, 32 samples)"%ipn_idle)
resd=[]; resm=[]; nan_total=0; ipn_note=None; oncell=[]
def cells(key):
    o=[]
    for u in range(8):
        c1,c2=struct.unpack("<ff",jp.uc.mem_read(jp.state[u]+0x16e0,4)+jp.uc.mem_read(jp.state[u]+0x16f0,4))
        if c1!=0 or c2!=0: o.append((u,AM.midi_hz(key)*2**(c1-2.0),AM.midi_hz(key)*2**(c2-2.0)))
    return o
def measure(n):
    eng0=cells(n)
    d,Lw,Rw=jp.render_both(16384); d=np.array(d); L,nanL=AM.words_to_floats(Lw); R,nanR=AM.words_to_floats(Rw)
    eng1=cells(n); eng=eng0+eng1
    f0d=AM.f0_autocorr(d,sr); hd=AM.harmonicity(d,sr,f0d) if f0d>0 else 0
    f0m=AM.f0_autocorr(L,sr); hm=AM.harmonicity(L,sr,f0m) if f0m>0 else 0
    dev=min((abs(1200*math.log2(f0d/fe)) for u,f1,f2 in eng for fe in (f1,f2)),default=float('inf')) if f0d>0 else float('inf')
    return dict(d=d,L=L,f0d=f0d,hd=hd,f0m=f0m,hm=hm,dev=dev,eng0=eng0,eng1=eng1,nan=nanL+nanR+jp.dry_nan)
for n in notes:
    jp.note_on(n,100); jp.render_both(1024)
    m=measure(n); win="EARLY"; nan_total+=m["nan"]
    if not (m["hd"]>=0.80 and m["dev"]<=25):   # the sweep's LATE window (PORT_LESSONS 4: pitch envelopes, slow attacks)
        jp.render_both(49152-17408); m2=measure(n); nan_total+=m2["nan"]
        if (m2["hd"]>=0.80 and m2["dev"]<=25) or (m2["hd"]>m["hd"] and m2["dev"]<=m["dev"]): m,win=m2,"LATE"
    d=m["d"]; L=m["L"]; f0d,hd,f0m,hm,dev=m["f0d"],m["hd"],m["f0m"],m["hm"],m["dev"]
    cd=1200*math.log2(f0d/AM.midi_hz(n)) if f0d>0 else float('nan'); cm=1200*math.log2(f0m/AM.midi_hz(n)) if f0m>0 else float('nan')
    log("key %d %s: DRY f0 %.2f Hz (%+.0f c) harmonic %.3f peak %.4g | MASTER f0 %.2f Hz (%+.0f c) harmonic %.3f peak %.4g | NaN %d"%(n,win,f0d,cd,hd,float(np.abs(d).max()),f0m,cm,hm,float(np.abs(L).max()),m["nan"]))
    okc=hd>=0.80 and dev<=25; fails+=not okc; oncell.append(dev<=25)
    log("%s key %d engine pitch (%s): cells at window start %s, end %s | DRY f0 %.1f c from the nearest VCO cell, harmonic %.3f (law: <= 25 c, >= 0.80)"%(
        "PASS" if okc else "FAIL",n,win," ".join("u%d %.2f/%.2f"%e for e in m["eng0"]) or "no unit"," ".join("u%d %.2f/%.2f"%e for e in m["eng1"]) or "no unit",dev,hd))
    resd.append((n,f0d,hd)); resm.append((n,f0m,hm))
    if ipn_note is None: ipn_note=count(32); log("sustain cost: %.0f instr/sample (code hook, 32 samples)"%ipn_note)
    jp.note_off(n,64)
    tail,Lw,Rw=jp.render_both(24000); tail=np.array(tail); Lt,nt=AM.words_to_floats(Lw); nan_total+=nt+jp.dry_nan
    hd_,ld_=float(np.abs(tail[:4096]).max()),float(np.abs(tail[-4096:]).max()); hm_,lm_=float(np.abs(Lt[:4096]).max()),float(np.abs(Lt[-4096:]).max())
    okd=ld_<0.05*max(hd_,1e-9) or ld_<1e-4; okm=lm_<0.05*max(hm_,1e-9) or lm_<1e-4
    ext=""
    if not (okd and okm):   # the 3 s tail rule (jp8_sweep.py): render on to 132300 samples, judge the last 8192 block
        peaks=[]
        for k in range((132300-24000)//8192):
            d2,Lw,Rw=jp.render_both(8192); L2,n2=AM.words_to_floats(Lw); nan_total+=n2+jp.dry_nan
            peaks.append((float(np.abs(np.array(d2)).max()),float(np.abs(L2).max())))
        okd=okd or peaks[-1][0]<0.05*max(hd_,1e-9) or peaks[-1][0]<1e-4
        okm=okm or peaks[-1][1]<0.05*max(hm_,1e-9) or peaks[-1][1]<1e-4
        ext=" | 3 s tail rule: dry %.3g master %.3g at 3.0 s -> %s/%s"%(peaks[-1][0],peaks[-1][1],"PASS" if okd else "FAIL","PASS" if okm else "FAIL")
    fails+=(not okd)+(not okm)
    log("%s release dry %d: %.3g -> %.3g | %s release master: %.3g -> %.3g (24000 samples)%s"%("PASS" if okd else "FAIL",n,hd_,ld_,"PASS" if okm else "FAIL",hm_,lm_,ext))
okd,msgd=track_verdict(resd); okm,msgm=track_verdict(resm); fails+=(not okd)+(not okm)
log("DRY    %s (patch VCO1 RANGE predicts %+d) | every key on its engine cell: %s"%(msgd,12*(rng-3),all(oncell))); log("MASTER %s"%msgm)
ok=nan_total==0; fails+=not ok; log("%s NaN census %d; faults after static init %d"%("PASS" if ok else "FAIL",nan_total,jp.faults-f_static))
for lab,i in (("idle",ipn_idle),("sustain",ipn_note)):
    log("S3 estimate (%s): %.0f x86 instr/sample x 1.75 = %.0f cyc/sample = %.0f%% of 10,000 cyc/sample @48k (count PROVEN on this oracle; 1.75 calibration INFERRED)"%(lab,i,i*1.75,i*1.75/100))
log("JP8 LISTEN sr %g patch %d: %s"%(sr,patch,"GREEN" if not fails else "%d FAIL"%fails))
sys.exit(1 if fails else 0)
