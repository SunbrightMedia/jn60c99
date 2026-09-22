#!/usr/bin/env python3
"""jp8_sweep.py -- ONE patch of the 64-patch listen sweep at 44100 (PORT_COMPLETENESS_CHARTER reach before step 5).
Fresh boot per patch on the CORRECTED drive (recall dispatch flag 0 = the HOSTPARAM path, then snap + latch).
Per key 48/60/72, a FRESH note:
  EARLY window (samples 1024..17408 after note-on): DRY f0 by autocorrelation, harmonicity, and the engine's OWN
  pitch cells [0x16e0]/[0x16f0] read at the window start (key-independent OFFSETS in octaves: expected f =
  midi_hz(key)*2^(cell-2), jp8_d4_law.py / PORT_LESSONS 3). A key PASSES when harmonic >= 0.80 and f0 is within 25
  cents of one VCO's engine pitch OR of a whole semitone (the JX law; a CROSS MOD patch's cell carries the FM term and
  is no steady pitch). If EARLY fails (a pitch envelope, a slow attack, a cross-mod mess), a LATE window
  (49152..65536) is measured too and the better one counts (stated per key). The patch's pitch PASSES when every key
  passes and either every key matched the engine cell or the keys track by ONE common whole number of semitones.
  RELEASE: note-off, 24000-sample dry+master tail must decay to <5% of its first 4096 (or <1e-4); a master
  that fails gets the 3 s TAIL RULE (delay/reverb): 132300 samples, PASS if the last 8192 < 5% of the first.
Also: idle 4096 silent (peaks < 0.01), NaN census, faults after static init, instr/sample (idle + sustain), and the
JX whole-semitone law on the dry f0s (info). Never tuned to pass: every FAIL names its confound candidates
(VCO ENV MOD != 128, CROSS MOD, SYNC, LOW FREQ, long ENV releases, delay/reverb levels) for the reader to check.
usage: jp8_sweep.py <patch> [outdir]   -> writes <outdir>/p<NN>.log (default jp8/logs/sweep44100/)"""
import sys, os, time, math, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
sys.path.insert(0, "/home/user/jn60c99/jx3p/tools")
import jp8_emu as J, audio_metrics as AM, numpy as np
from jx_listen import track_verdict
from unicorn import UC_HOOK_CODE
SR=44100.0; KEYS=(48,60,72)
patch=int(sys.argv[1]); outdir=sys.argv[2] if len(sys.argv)>2 else os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","logs","sweep44100")
os.makedirs(outdir,exist_ok=True); out=open(os.path.join(outdir,"p%02d.log"%patch),"w")
t0=time.time()
def log(m):
    s="[%6.1fs] %s"%(time.time()-t0,m); print(s,flush=True); out.write(s+"\n"); out.flush()
jp=J.JP8(); ok,fail=jp.run_static_init(); f_static=jp.faults
jp.build(); jp.set_ftz(); jp.set_sr(SR); w,f=jp.host_init(); assert f==0
jp.recall(patch); jp.snap_ramps(); jp.clear_latch(); uc=jp.uc
bank=J.bank_bytes(); name=J.patch_name(bank,patch).strip(); blob=J.patch_blob(bank,patch)
P=lambda pool: J.pool_value(blob,pool)
conf=[]
if P(36)!=128: conf.append("VCO ENV MOD %d"%P(36))
if P(21): conf.append("CROSS MOD %d"%P(21))
if P(28): conf.append("SYNC")
if P(27): conf.append("LOW FREQ")
if P(58): conf.append("PORTAMENTO %d"%P(58))
if P(47)>150 or P(52)>150: conf.append("ENV REL %d/%d"%(P(47),P(52)))
if P(55) or P(56): conf.append("REVERB %d DELAY %d"%(P(55),P(56)))
if P(10)!=0 and P(13)!=128: conf.append("LFO->VCO %d"%P(13))
log("boot sr %g patch %d %r: static ok=%d fail=%d faults(static)=%d faults(after)=%d; VCO1 RANGE %d VCO2 RANGE %d FINE %d SUB %d; confound candidates: %s"%(
    SR,patch,name,ok,fail,f_static,jp.faults-f_static,P(20),P(25),P(26),P(29)-36,", ".join(conf) or "none"))
def count(n):
    c=[0]
    def h(uc_,a,s,u): c[0]+=1
    uc.ctl_flush_tb(); hh=uc.hook_add(UC_HOOK_CODE,h)
    try: jp.render_both(n)
    finally: uc.hook_del(hh); uc.ctl_flush_tb()
    return c[0]/n
def cells(key):
    o=[]
    for u in range(8):
        c1,c2=struct.unpack("<ff",uc.mem_read(jp.state[u]+0x16e0,4)+uc.mem_read(jp.state[u]+0x16f0,4))
        if c1!=0 or c2!=0: o.append((u,AM.midi_hz(key)*2**(c1-2.0),AM.midi_hz(key)*2**(c2-2.0)))
    return o
fails=[]; nan_total=0
dry,Lw,Rw=jp.render_both(4096); L,nanL=AM.words_to_floats(Lw); pk=float(np.abs(L).max()); dpk=max(abs(x) for x in dry); nan_total+=nanL+jp.dry_nan
idle_ok=pk<0.01 and dpk<0.01
if not idle_ok: fails.append("idle")
log("%s idle 4096: dry peak %.3g master peak %.3g NaN %d"%("PASS" if idle_ok else "FAIL",dpk,pk,nanL))
ipn_idle=count(32); ipn_note=None
res=[]; keyrows=[]
def measure(key):
    d,Lw,Rw=jp.render_both(16384); d=np.array(d); L,nanL=AM.words_to_floats(Lw); R,nanR=AM.words_to_floats(Rw)
    f0=AM.f0_autocorr(d,SR); h=AM.harmonicity(d,SR,f0) if f0>0 else 0.0
    c=1200*math.log2(f0/AM.midi_hz(key)) if f0>0 else float('nan')
    eng=cells(key); dev=min((abs(1200*math.log2(f0/fe)) for u,f1,f2 in eng for fe in (f1,f2)),default=float('inf')) if f0>0 else float('inf')
    semi=abs(c-100.0*round(c/100.0)) if f0>0 else float('inf')
    return dict(f0=f0,h=h,c=c,dev=dev,semi=semi,eng=eng,peak=float(np.abs(d).max()),mpeak=float(np.abs(L).max()),nan=nanL+nanR+jp.dry_nan)
def key_ok(m): return m["h"]>=0.80 and (m["dev"]<=25 or m["semi"]<=25)
for key in KEYS:
    jp.note_on(key,100); jp.render_both(1024)
    m=measure(key); win="EARLY"; nan_total+=m["nan"]
    okp=key_ok(m)
    if not okp:
        jp.render_both(49152-17408); m2=measure(key); nan_total+=m2["nan"]
        if key_ok(m2) or (m2["h"]>m["h"] and min(m2["dev"],m2["semi"])<=min(m["dev"],m["semi"])): m,win=m2,"LATE"
        okp=key_ok(m)
    if ipn_note is None: ipn_note=count(32)
    if not okp: fails.append("pitch%d"%key)
    log("%s key %d %s: DRY f0 %.2f Hz (%+.0f c vs key) harmonic %.3f peak %.4g master peak %.4g | engine %s | dev %.0f c vs engine, %.0f c vs semitone | NaN %d"%(
        "PASS" if okp else "FAIL",key,win,m["f0"],m["c"],m["h"],m["peak"],m["mpeak"]," ".join("u%d %.1f/%.1f"%e for e in m["eng"]) or "no unit",m["dev"],m["semi"],m["nan"]))
    res.append((key,m["f0"],m["h"])); keyrows.append((key,win,m["c"],m["h"],m["dev"]))
    jp.note_off(key,64)
    tail,Lw,Rw=jp.render_both(24000); tail=np.array(tail); Lt,nt=AM.words_to_floats(Lw); nan_total+=nt+jp.dry_nan
    hd_,ld_=float(np.abs(tail[:4096]).max()),float(np.abs(tail[-4096:]).max()); hm_,lm_=float(np.abs(Lt[:4096]).max()),float(np.abs(Lt[-4096:]).max())
    okd=ld_<0.05*max(hd_,1e-9) or ld_<1e-4; okm=lm_<0.05*max(hm_,1e-9) or lm_<1e-4
    ext=""
    if not (okd and okm):
        first=None; last=None; peaks=[]
        for k in range((132300-24000)//8192):
            d2,Lw,Rw=jp.render_both(8192); L2,n2=AM.words_to_floats(Lw); nan_total+=n2+jp.dry_nan
            peaks.append((float(np.abs(np.array(d2)).max()),float(np.abs(L2).max())))
        okd=okd or peaks[-1][0]<0.05*max(hd_,1e-9) or peaks[-1][0]<1e-4
        okm=okm or peaks[-1][1]<0.05*max(hm_,1e-9) or peaks[-1][1]<1e-4
        ext=" | 3 s tail rule: dry %.3g master %.3g at 3.0 s -> %s/%s"%(peaks[-1][0],peaks[-1][1],"PASS" if okd else "FAIL","PASS" if okm else "FAIL")
    if not okd: fails.append("reldry%d"%key)
    if not okm: fails.append("relmaster%d"%key)
    log("%s release dry %d: %.3g -> %.3g | %s release master: %.3g -> %.3g (24000 samples)%s"%("PASS" if okd else "FAIL",key,hd_,ld_,"PASS" if okm else "FAIL",hm_,lm_,ext))
okt,msgt=track_verdict(res); alleng=all(dv<=25 for k,w,c,h,dv in keyrows)
if not (okt or alleng): fails.append("track")
log("%s JX law (dry): %s | every key on its engine cell: %s"%("PASS" if (okt or alleng) else "FAIL",msgt,alleng))
if nan_total: fails.append("NaN")
if jp.faults-f_static: fails.append("faults")
log("%s NaN census %d; faults after static init %d; instr/sample idle %.0f sustain %.0f"%("PASS" if not nan_total else "FAIL",nan_total,jp.faults-f_static,ipn_idle,ipn_note or 0))
verdict="PASS" if not fails else "FAIL(%s)"%",".join(fails)
row="| %d | %s | %s | %s | %s | %.3g | %d | %d | %.0f/%.0f | %s |"%(patch,name,verdict," ".join("%d:%+.0fc(%s)"%(k,c,w[0]) for k,w,c,h,dv in keyrows),
    " ".join("%.2f"%h for k,w,c,h,dv in keyrows),max(dpk,pk),nan_total,jp.faults-f_static,ipn_idle,ipn_note or 0,"; ".join(conf) or "-")
log("ROW "+row)
log("JP8 SWEEP patch %d: %s"%(patch,verdict))
out.close(); sys.exit(0 if not fails else 1)
