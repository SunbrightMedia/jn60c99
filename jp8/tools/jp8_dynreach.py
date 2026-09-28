#!/usr/bin/env python3
"""jp8_dynreach.py -- DYNAMIC reach of the lifted entries on the oracle, on DRIVE2 (S3_STATUS D7: HOST built by the
plugin's FACTORY 0x444FE0, BUILD, FTZ, SETSR, host_init and the recall through HOSTPARAM 0x4465B0, NO snap: the
plugin's own walker settles the ramps). For each patch: the drive2 boot, SETTLE samples, then idle, note-on 60, a
second key 67 while 60 is held, both released -- every executed instruction address and, at every indirect call/jmp
site, the target reached are recorded.
With --recall <patch B>, the judged window ALSO covers a second recall (B) through HOSTPARAM (the per-id switch:
756 LFO KEY TRIG direct setter 0x442c30, 769 v-36, the generic DISPATCH flag 0 + assigner notify) and 8*N samples
of the walker settling it, then a note.
With --boot, the hook is installed BEFORE the factory (right after the static initializers), so the construction
path (FACTORY + ctor 0x444000, BUILD, SETSR, HOSTPARAM, recall) is in the reach too, and every IMPORT STUB reached
is recorded by name so the C runtime shims exactly those.
Method (2026-09-23): a BLOCK hook, not a code hook -- a translation block ends at every branch, so the last
instruction of the previous block is the indirect site and the current block start is its target; the executed set
is every instruction of every executed block. Same facts, ~10x cheaper (BUILD alone runs 49M blocks). The TB cache
is flushed before the hook is added (PORT_LESSONS 8).
usage: jp8_dynreach.py <out.json> <patches e.g. 2,63,10> [samples=64] [--recall B] [--boot] [--settle S]"""
import sys, os, json, collections, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, capstone
from capstone import x86
from unicorn import UC_HOOK_BLOCK
out=sys.argv[1]; patches=[int(x) for x in sys.argv[2].split(",")]
N=int(sys.argv[3]) if len(sys.argv)>3 and not sys.argv[3].startswith("--") else 64
recall_b=int(sys.argv[sys.argv.index("--recall")+1]) if "--recall" in sys.argv else None
SETTLE=int(sys.argv[sys.argv.index("--settle")+1]) if "--settle" in sys.argv else 2200
boot="--boot" in sys.argv
imports=collections.Counter()
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
executed=set(); indirect=collections.defaultdict(set); t0=time.time()
STUB_LO=J.STUB_BASE; STUB_HI=J.STUB_BASE+8*len(J.IMPORTS)+8
bcache={}          # (addr,size) -> (tuple of instruction rvas, last-is-indirect)
prev=[None]        # rva of the previous block's last instruction when it was an indirect call/jmp
def block(uc,address,size,user):
    rva=address-J.IB
    if prev[0] is not None:
        indirect[prev[0]].add(rva); prev[0]=None
    if STUB_LO<=address<STUB_HI:
        imports[(address-STUB_LO)//8]+=1; return
    if not (0<=rva<J.IMGSZ): return
    k=(address,size); e=bcache.get(k)
    if e is None:
        rvas=[]; last=None
        for ins in md.disasm(bytes(J.IMG[rva:rva+size]),address):
            rvas.append(ins.address-J.IB); last=ins
        ind=(last is not None and last.mnemonic in ("call","jmp") and last.operands[0].type!=x86.X86_OP_IMM)
        e=(tuple(rvas), rvas[-1] if ind else None); bcache[k]=e
    executed.update(e[0])
    if e[1] is not None: prev[0]=e[1]
counts={}
for patch in patches:
    jp=J.JP8(); assert not jp.legacy, "dynreach runs DRIVE2 only"
    ok,fail=jp.run_static_init(); assert fail==0, "static init failed %d"%fail
    h=None
    if boot: jp.uc.ctl_flush_tb(); h=jp.uc.hook_add(UC_HOOK_BLOCK,block)
    jp.build(); jp.set_ftz(); jp.set_sr(44100.0)
    w,f=jp.host_init(); assert f==0
    jp.recall(patch)
    jp.render_both(SETTLE)                        # the plugin's walker settles the recalled ramps (no snap on drive2)
    if not boot: jp.uc.ctl_flush_tb(); h=jp.uc.hook_add(UC_HOOK_BLOCK,block)
    n0=len(executed); jp.render_both(8)            # idle: all 8 voices + master
    jp.note_on(60,100); jp.render_both(N)          # note: all 8 voices + master
    jp.note_on(67,100); jp.render_both(N)          # a second key while the first is held (a second voice allocation)
    jp.note_off(60,64); jp.note_off(67,64); jp.render_both(N)   # release
    if recall_b is not None:
        jp.recall(recall_b); jp.render_both(8*N)   # the HOSTPARAM recall path + the walker settling
        jp.note_on(60,100); jp.render_both(N); jp.note_off(60,64); jp.render_both(N)
    jp.uc.hook_del(h); jp.uc.ctl_flush_tb()
    counts[patch]=len(executed)-n0
    print("[%6.1fs] patch %d: executed set now %d addresses (+%d), %d indirect sites"%(time.time()-t0,patch,len(executed),len(executed)-n0,len(indirect)),flush=True)
stubnames={i:(name) for i,(rva,(dll,name)) in enumerate(sorted(J.IMPORTS.items()))}
json.dump(dict(drive="drive2",patches=patches,samples=N,settle=SETTLE,boot=boot,recall=recall_b,executed=sorted("%x"%a for a in executed),
               indirect={"%x"%s:sorted("%x"%t for t in ts) for s,ts in indirect.items()},
               imports={str(i):[stubnames.get(i,"?"),n] for i,n in sorted(imports.items())}),open(out,"w"))
if imports: print("imports reached: "+", ".join("%s x%d"%(stubnames.get(i,"?"),n) for i,n in sorted(imports.items())))
print("wrote %s"%out)
