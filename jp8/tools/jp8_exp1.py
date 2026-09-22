#!/usr/bin/env python3
"""jp8_exp1.py -- MEASURE the step-4 failure (playbook 7: measure, do not deduce).
modes: count | keys <patch> <sr> | fxoff <patch> <sr> | offonly <patch>"""
import sys, os, time, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
from unicorn import *; from unicorn.x86_const import *
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
mode=sys.argv[1]; patch=int(sys.argv[2]) if len(sys.argv)>2 else 0; sr=float(sys.argv[3]) if len(sys.argv)>3 else 44100.0
def boot():
    jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(sr); w,f=jp.host_init(); assert f==0
    jp.recall(patch); jp.snap_ramps(); jp.clear_latch(); log("booted patch %d %r sr %g faults %d"%(patch,J.patch_name(J.bank_bytes(),patch),sr,jp.faults)); return jp
def fresh_note(jp,note,n=12288,pre=0):
    if pre: jp.render_both(pre)
    jp.note_on(note,100); d,Lw,Rw=jp.render_both(n); L,nan=AM.words_to_floats(Lw); d=np.array(d)
    jp.note_off(note,64); dr,Lr,Rr=jp.render_both(8000); Lr,nanr=AM.words_to_floats(Lr)
    seg=slice(4096,n)
    f0d=AM.f0_autocorr(d[seg],sr); hd=AM.harmonicity(d[seg],sr,f0d) if f0d>0 else 0
    f0m=AM.f0_autocorr(L[seg],sr); hm=AM.harmonicity(L[seg],sr,f0m) if f0m>0 else 0
    import math
    cd=1200*math.log2(f0d/AM.midi_hz(note)) if f0d>0 else float('nan'); cm=1200*math.log2(f0m/AM.midi_hz(note)) if f0m>0 else float('nan')
    pr=AM.block_profile(Lr,2000); prd=AM.block_profile(np.array(dr),2000)
    log("note %3d: DRY f0 %8.2f Hz (%+6.0f c) harm %.2f peak %.3g | MASTER f0 %8.2f Hz (%+6.0f c) harm %.2f peak %.3g nan %d | release master rms %s dry rms %s"%(
        note,f0d,cd,hd,float(np.abs(d).max()),f0m,cm,hm,float(np.abs(L).max()),nan+nanr,["%.3g"%p[1] for p in pr],["%.3g"%p[1] for p in prd]))
    return f0d
if mode=="count":
    jp=boot(); jp.enable_counter()
    n=[0]
    def code(uc,a,s,u): n[0]+=1
    jp.uc.hook_add(UC_HOOK_CODE, code)
    for lab in ("idle","idle2"):
        n[0]=0; jp.render_both(16,count=True); log("%s 16 samples: block-hook %d instr, code-hook %d instr (ratio %.3f)"%(lab,jp._icount,n[0],jp._icount/max(n[0],1)))
    jp.note_on(60,100); jp.render_both(2000)
    n[0]=0; jp.render_both(16,count=True); log("note 16 samples: block-hook %d instr, code-hook %d instr -> %.0f / %.0f instr per sample"%(jp._icount,n[0],jp._icount/16,n[0]/16))
    # per-unit split with the code hook: count per stub run
    per=[]
    for v in range(9):
        n[0]=0
        if v<8:
            jp.uc.mem_write(J.PB_VOICE, struct.pack("<QQQQQ", jp.state[v], v, J.BUF_BASE, J.BUF_BASE+0x1000, 1)); jp._run(jp.SVOICE)
        else:
            a2=b"".join(struct.pack("<Q",J.BUF_BASE+0x100*k) for k in range(16))
            jp.uc.mem_write(J.PB_MASTER, struct.pack("<QQQQ", jp.state[8], J.BUF_BASE+0x2000, J.BUF_BASE+0x2100, 1)+b"\x00"*16+a2); jp._run(jp.SMASTER)
        per.append(n[0])
    log("one sample, instr per unit (v0..v7, master): %s"%per)
elif mode=="keys":
    jp=boot()
    for note in (48,60,72): fresh_note(jp,note)
elif mode=="fxoff":
    jp=boot()
    for pid,name in ((794,"EFFECT LEVEL"),(795,"REVERB LEVEL"),(796,"DELAY LEVEL")):
        for u in range(9): jp.dispatch(u,pid,0)
    jp.notify(); jp.snap_ramps(); log("FX levels 794/795/796 := 0 on all units (control arm)")
    fresh_note(jp,60)
elif mode=="offonly":
    jp=boot(); jp.note_off(60,64); d,Lw,Rw=jp.render_both(4096); L,_=AM.words_to_floats(Lw)
    log("CONTROL NOTEOFF-only: dry peak %.3g master peak %.3g"%(max(abs(x) for x in d),float(np.abs(L).max())))
