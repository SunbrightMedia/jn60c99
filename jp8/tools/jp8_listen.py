#!/usr/bin/env python3
"""jp8_listen.py -- PORT_PIPELINE steps 3+4 on the JP8 oracle (per-unit
wrapper path, the JX-proven drive: VOICE_WRAP x8 + MASTER_WRAP per sample).
Step 3: boot(sr, patch, host_init=True) -> boot-phase faults == 0, master
finite over 12000 idle samples, idle silent.
Step 4: note-on a real patch, render DRY (voice sum) and through the MASTER
from one pass, audio_metrics.verdict on both (f0 +-25 cents, harmonicity
>= 0.80), release decays, no NaN; instruction count per sample -> S3 est.
usage: jp8_listen.py [patch] [note] [sr] [--offonly]"""
import sys, os, time, struct, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
import audio_metrics as AM
import numpy as np
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
args=[a for a in sys.argv[1:] if not a.startswith("--")]
patch=int(args[0]) if len(args)>0 else 0
note=int(args[1]) if len(args)>1 else 60
sr=float(args[2]) if len(args)>2 else 44100.0
OFFONLY="--offonly" in sys.argv
IDLE=12000

jp=J.JP8()
ok,fail=jp.run_static_init(log=log); f_static=jp.faults
log("static init ok=%d fail=%d skipped=%d faults=%d (template condition: ctor #1 cookie-decoded null ptr, JX identical)"%(ok,fail,jp.static_skipped,f_static))
mp=jp.host_map(); log("host map %d ids: %s"%(len(mp),dict(sorted(mp.items()))))
jp.build(); log("BUILD: 9 units of 0x%x, proc vptr == PROC_VPTR asserted"%J.STATE_SZ)
jp.set_ftz(); got=jp.set_sr(sr); log("SETSR %r (float in xmm1) landed at HOST+8"%got)
w,f=jp.host_init(log=log); log("host_init: %d effective writes, %d failed"%(w,f)); assert f==0
def nramps(u):
    st=jp.state[u]; b0=int.from_bytes(jp.uc.mem_read(st+0x70,8),'little'); e0=int.from_bytes(jp.uc.mem_read(st+0x78,8),'little'); return (e0-b0)//4
def latch(u): return struct.unpack("<i",jp.uc.mem_read(jp.state[u]+J.LATCH_OFF,4))[0]
log("latch per unit %s, active ramps %s"%([latch(u) for u in range(9)],[nramps(u) for u in range(9)]))
name=J.patch_name(J.bank_bytes(),patch)
jp.recall(patch); log("recall patch %d %r: %d pools x 9 units + assigner notify; ramps %s"%(patch,name,len(J.ACTIVE_POOLS),[nramps(u) for u in range(9)]))
jp.snap_ramps(); jp.clear_latch(); log("snap ramps + clear latch: ramps %s latch %s"%([nramps(u) for u in range(9)],[latch(u) for u in range(9)]))
f_boot=jp.faults-f_static
log("boot-phase faults (BUILD..latch) = %d"%f_boot)
# ---- step 3: idle
dry,Lw,Rw=jp.render_both(IDLE); L,nanL=AM.words_to_floats(Lw); R,nanR=AM.words_to_floats(Rw)
pk=float(np.abs(L).max()); dpk=max(abs(x) for x in dry)
f_idle=jp.faults-f_static
log("IDLE %d: master NaN L=%d R=%d peak %.3g | dry NaN %d peak %.3g | faults since static %d"%(IDLE,nanL,nanR,pk,jp.dry_nan,dpk,f_idle))
step3 = (f_idle==0 and nanL==0 and nanR==0 and pk<1e-5 and dpk<1e-5)
log("STEP 3 %s: faults==0 %s, master finite %s, idle silent %s"%("PASS" if step3 else "FAIL",f_idle==0,nanL+nanR==0,pk<1e-5 and dpk<1e-5))
if OFFONLY:
    jp.note_off(note,64); dry,Lw,Rw=jp.render_both(4096); L,_=AM.words_to_floats(Lw)
    log("CONTROL (NOTEOFF only, no NOTEON): dry peak %.3g master peak %.3g -> %s"%(max(abs(x) for x in dry),float(np.abs(L).max()),"SILENT (as required)" if max(abs(x) for x in dry)<1e-5 else "NOT SILENT: on/off swapped?"))
    sys.exit(0)
# ---- step 4
jp.enable_counter()
jp.note_on(note,100)
d1,L1,R1=jp.render_both(256,count=True); ic=jp._icount; log("NOTE %d vel 100: attack 256 samples = %d instr = %.0f instr/sample"%(note,ic,ic/256))
d2,L2,R2=jp.render_both(16384-256)
dry=np.array(d1+d2); Lm,nanL=AM.words_to_floats(L1+L2); Rm,nanR=AM.words_to_floats(R1+R2)
seg=slice(4096,16384)
okd,msgd=AM.verdict(dry[seg],sr,note); log("DRY    : %s"%msgd)
okm,msgm=AM.verdict(Lm[seg],sr,note); log("MASTER : %s  (NaN L %d R %d, dry NaN %d)"%(msgm,nanL,nanR,jp.dry_nan))
log("dry spectral peaks: %s"%[("%.1f Hz"%f,"%.3g"%m) for f,m in AM.spectral_peaks(dry[seg],sr,5)])
for k,rms,mx,zc in AM.block_profile(Lm,2048)[:8]: log("  master block %d rms %.4g max %.4g zc %d"%(k,rms,mx,zc))
d3,_,_=jp.render_both(256,count=True); ic2=jp._icount; log("sustained: 256 samples = %d instr = %.0f instr/sample"%(ic2,ic2/256))
jp.note_off(note,64)
dr,Lr,Rr=jp.render_both(24000); Lrf,nanr=AM.words_to_floats(Lr)
prof=AM.block_profile(Lrf,4000); log("RELEASE master rms per 4000: %s (NaN %d)"%(["%.3g"%p[1] for p in prof],nanr))
profd=AM.block_profile(np.array(dr),4000); log("RELEASE dry    rms per 4000: %s"%["%.3g"%p[1] for p in profd])
decays = prof[-1][1] < 0.05*max(prof[0][1],1e-12) and profd[-1][1] < 0.05*max(profd[0][1],1e-12)
d4,_,_=jp.render_both(256,count=True); ic3=jp._icount; log("post-release idle: 256 samples = %d instr = %.0f instr/sample"%(ic3,ic3/256))
f_end=jp.faults-f_static
step4 = okd and okm and nanL==0 and nanR==0 and jp.dry_nan==0 and nanr==0 and decays and f_end==0
log("STEP 4 %s: dry %s master %s, no NaN %s, release decays %s, faults since static %d"%("PASS" if step4 else "FAIL",okd,okm,(nanL+nanR+jp.dry_nan+nanr)==0,decays,f_end))
for lab,i in (("attack",ic/256),("sustain",ic2/256),("idle",ic3/256)):
    log("S3 estimate (%s): %.0f x86 instr/sample x 1.75 = %.0f cyc/sample = %.0f%% of 10,000 cyc/sample @48k (calibration INFERRED; count PROVEN on this oracle)"%(lab,i,i*1.75,i*1.75/100))
