#!/usr/bin/env python3
"""d4_trace.py -- where does the engine consume VCO1/VCO2 RANGE, VCO2 FINE TUNE, SUB RANGE?
step 1: hook every memory WRITE during dispatch(unit0, id, val) after a full boot; report cells.
step 2: hook READS of those cells during note_on + a few rendered samples; report reader RIPs."""
import sys, os, struct, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
from unicorn import *
from unicorn.x86_const import *
patch=int(sys.argv[1]); ids=[int(x) for x in sys.argv[2].split(",")]; vals=[int(x) for x in sys.argv[3].split(",")]
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
uc=jp.uc
def where(a):
    for u in range(9):
        if jp.state[u]<=a<jp.state[u]+J.STATE_SZ: return "state[%d]+0x%x"%(u,a-jp.state[u])
    for u in range(9):
        if jp.proc[u]<=a<jp.proc[u]+0x4000: return "proc[%d]+0x%x"%(u,a-jp.proc[u])
    if J.STACK_BASE<=a<J.STACK_BASE+J.STACK_SIZE: return "STACK"
    if J.IB<=a<J.IB+J.IMGSZ: return "IMG+0x%x"%(a-J.IB)
    return "heap 0x%x"%a
for pid,val in zip(ids,vals):
    writes=[]
    def hw(uc_,acc,addr,size,value,user):
        w=where(addr)
        if w!="STACK": writes.append((addr,size,value,uc_.reg_read(UC_X86_REG_RIP)-J.IB))
    h=uc.hook_add(UC_HOOK_MEM_WRITE,hw)
    jp.dispatch(0,pid,val,flag=1)
    uc.hook_del(h)
    print("== dispatch(unit0, id %d, val %d): %d non-stack writes"%(pid,val,len(writes)))
    cells=collections.OrderedDict()
    for addr,size,value,rip in writes:
        print("   %-22s size %d value 0x%x (f=%r) by rva 0x%x"%(where(addr),size,value,struct.unpack("<f",struct.pack("<I",value&0xffffffff))[0] if size==4 else None,rip))
        cells[addr]=size
    # step 2: who reads these cells during note_on + render?
    readers=collections.Counter()
    def hr(uc_,acc,addr,size,value,user):
        if addr in cells: readers[(addr,uc_.reg_read(UC_X86_REG_RIP)-J.IB)]+=1
    hs=[uc.hook_add(UC_HOOK_MEM_READ,hr,begin=a,end=a+cells[a]-1) for a in cells]
    jp.note_on(60,100); jp.render_both(4)
    for hh in hs: uc.hook_del(hh)
    print("   readers during note_on(60)+render(4):")
    for (addr,rip),n in sorted(readers.items()):
        print("     %-22s read %5d x by rva 0x%x"%(where(addr),n,rip))
    jp.note_off(60,64); jp.render_both(2000)
