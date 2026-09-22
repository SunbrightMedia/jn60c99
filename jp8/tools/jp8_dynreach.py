#!/usr/bin/env python3
"""jp8_dynreach.py -- DYNAMIC reach of the voice render on the oracle: boot (corrected drive), for each patch in the list
note-on key 60 and drive VOICE_WRAP for voice 0 through N samples with a code hook that records every executed
instruction address and, at every indirect call/jmp site, the target reached. Also idle samples before the note.
Writes <out>.json: executed (sorted hex rvas), indirect {site: [targets]}, per-sample instruction count.
With --recall <patch B>, the judged window ALSO covers the recall path: after the note phases, recall(B) through
DISPATCH (flag 0) + notify on every unit, then N*8 samples so the plugin's own ramp walker settles the new cells
(layer 2's reach: DISPATCH 0x437630, the proc/child setters, ASG_NOTIFY 0x37CD80, the walker).
usage: jp8_dynreach.py <out.json> <patches e.g. 2,63,10> [samples=64] [--recall B]"""
import sys, os, json, struct, collections, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, capstone
from capstone import x86
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RIP
out=sys.argv[1]; patches=[int(x) for x in sys.argv[2].split(",")]; N=int(sys.argv[3]) if len(sys.argv)>3 and not sys.argv[3].startswith("--") else 64
recall_b=int(sys.argv[sys.argv.index("--recall")+1]) if "--recall" in sys.argv else None
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
executed=set(); indirect=collections.defaultdict(set); ind_sites={}; t0=time.time()
def is_indirect(rva):
    if rva in ind_sites: return ind_sites[rva]
    r=None
    for ins in md.disasm(bytes(J.IMG[rva:rva+16]),J.IB+rva):
        if ins.mnemonic in ("call","jmp") and ins.operands[0].type!=x86.X86_OP_IMM: r=ins.size
        break
    ind_sites[rva]=r; return r
pending=[None]
def hook(uc,address,size,user):
    rva=address-J.IB
    if pending[0] is not None:
        indirect[pending[0]].add(rva); pending[0]=None
    if 0<=rva<J.IMGSZ:
        executed.add(rva)
        if is_indirect(rva): pending[0]=rva
counts={}
for patch in patches:
    jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
    jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
    jp.uc.ctl_flush_tb()                      # D5: a code hook added after a block was JIT-cached never fires for it
    h=jp.uc.hook_add(UC_HOOK_CODE,hook)
    n0=len(executed); jp.render_both(8)            # idle: all 8 voices + master
    jp.note_on(60,100); jp.render_both(N)          # note: all 8 voices + master
    jp.note_on(67,100); jp.render_both(N)          # a second key while the first is held (a second voice allocation)
    jp.note_off(60,64); jp.note_off(67,64); jp.render_both(N)   # release
    if recall_b is not None:
        jp.recall(recall_b); jp.render_both(8*N)   # recall path + the walker settling
        jp.note_on(60,100); jp.render_both(N); jp.note_off(60,64); jp.render_both(N)
    jp.uc.hook_del(h); jp.uc.ctl_flush_tb()
    counts[patch]=len(executed)-n0
    print("[%5.1fs] patch %d: executed set now %d addresses (+%d), %d indirect sites"%(time.time()-t0,patch,len(executed),len(executed)-n0,len(indirect)),flush=True)
json.dump(dict(patches=patches,samples=N,executed=sorted("%x"%a for a in executed),
               indirect={"%x"%s:sorted("%x"%t for t in ts) for s,ts in indirect.items()}),open(out,"w"))
print("wrote %s"%out)
