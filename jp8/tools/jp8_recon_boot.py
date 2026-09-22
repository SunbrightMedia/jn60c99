#!/usr/bin/env python3
"""jp8_recon_boot.py -- PROVE the generated constants by execution, one at a
time, printing what each step found. Stage A: static initializers with a
per-ctor log (discovers the SKIP set). Stage B: BUILD + PROC_VPTR + SETSR
+ host map + latch + ramp header. Bounded: every ctor count-capped, the
discovery pass also wall-clock capped (discovery only)."""
import sys, os, time, struct, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jp8_emu as J
from unicorn import *
from unicorn.x86_const import *
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)

jp=J.JP8(); IB=J.IB; uc=jp.uc
a,b=J.XC_TABLE
ptrs=struct.unpack("<%dQ"%((b-a)//8), uc.mem_read(IB+a, b-a))
log("XC table %d entries, skip set %s"%(len(ptrs), sorted(hex(x) for x in jp.SKIP_CTORS)))
ok=fail=0; fails=[]
for i,p in enumerate(ptrs):
    if not p: continue
    if (p-IB) in jp.SKIP_CTORS: continue
    f0=jp.faults
    try:
        jp.call(p, count=2_000_000, timeout_us=3_000_000); ok+=1
    except Exception as e:
        fail+=1; fails.append((i,p-IB,str(e)[:70]))
        log("ctor #%d rva 0x%x FAILED: %s (faults now %d, stray %d)"%(i,p-IB,str(e)[:70],jp.faults,getattr(jp,'_stray',0)))
    if jp.faults!=f0:
        log("ctor #%d rva 0x%x mapped %d stray page(s)"%(i,p-IB,jp.faults-f0))
log("static init: ok=%d fail=%d faults=%d unhandled imports=%s"%(ok,fail,jp.faults,jp.unhandled.most_common(12)))
nz,tot=jp.bss_fill(); log(".data tail nonzero %d/%d"%(nz,tot))
try:
    mp=jp.host_map(); log("host map: %d ids; 0..5 -> %s; hid 2 -> eng %s"%(len(mp), {k:mp[k] for k in sorted(mp)[:6]}, mp.get(2)))
except Exception as e: log("host map FAILED: %s"%e)

# ---- stage B
before=len(jp.allocs)
jp.HOST=jp.bump(0x8000); uc.mem_write(jp.HOST,b"\x00"*0x8000)
try:
    jp.call(J.BUILD, rcx=jp.HOST, count=200_000_000); log("BUILD returned")
except Exception as e: log("BUILD stopped: %s"%e)
sizes=collections.Counter(s for _,s in jp.allocs[before:])
log("BUILD allocs=%d big=%s faults=%d"%(len(jp.allocs)-before,[(hex(s),n) for s,n in sizes.items() if s>0x10000],jp.faults))
def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
jp.state=[rq(jp.HOST+0xA0+64*i) for i in range(9)]
jp.proc =[rq(jp.HOST+0xB0+64*i) for i in range(9)]
jp.assign=[rq(jp.HOST+0xB8+64*i) for i in range(9)]
for i in range(9):
    st,pr,asg=jp.state[i],jp.proc[i],jp.assign[i]
    vs=rq(st) if st else 0; vp=rq(pr) if pr else 0; va=rq(asg) if asg else 0
    log("unit %d state 0x%x vptr rva 0x%x | proc 0x%x vptr rva 0x%x %s | assign 0x%x vptr rva 0x%x"%(
        i,st,vs-IB,pr,vp-IB,"==PROC_VPTR" if vp==J.PROC_VPTR else "MISMATCH",asg,va-IB))
# HOST header scan: which slots hold heap pointers
log("HOST+8 float = %r"%struct.unpack("<f",uc.mem_read(jp.HOST+8,4))[0])
jp.set_ftz()
try:
    got=jp.set_sr(44100.0); log("SETSR landed HOST+8=%r"%got)
except Exception as e: log("SETSR FAILED: %s"%e)
# latch + ramp header
for u in (0,8):
    st=jp.state[u]
    latch=struct.unpack("<i",uc.mem_read(st+J.LATCH_OFF,4))[0]
    arr=rq(st+0x58); b0=rq(st+0x70); e0=rq(st+0x78)
    log("unit %d latch(st+0x%x)=%d  ramp arr 0x%x list [0x%x,0x%x) n=%d"%(u,J.LATCH_OFF,latch,arr,b0,e0,(e0-b0)//4 if e0>=b0 else -1))
    if e0>b0 and e0-b0<4000:
        ids=struct.unpack("<%di"%((e0-b0)//4), uc.mem_read(b0,e0-b0))
        for i in ids[:4]:
            a=arr+40*i; tgt=rq(a); lim=struct.unpack("<f",uc.mem_read(a+0x14,4))[0]; act=uc.mem_read(a+0x1c,1)[0]
            log("   ramp id %d: target 0x%x (%s) limit %r active %d"%(i,tgt,"in-state" if st<=tgt<st+J.STATE_SZ else "elsewhere",lim,act))
# scan the latch neighbourhood for the JX '960' idiom
for u in (0,):
    st=jp.state[u]; tail=uc.mem_read(st+J.STATE_SZ-64,64)
    log("unit 0 state tail (last 64 B as i32): %s"%list(struct.unpack("<16i",tail)))
log("faults total %d"%jp.faults)
