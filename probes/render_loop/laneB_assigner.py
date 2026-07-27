#!/usr/bin/env python3
"""LANE B part 3 — assigner voice-count getter/setter behaviour, executed."""
import sys, struct, json, time
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
from e2e_emu import E2E, IB
T0=time.time()
def mark(m): print("[%6.1fs] %s"%(time.time()-T0,m),flush=True)
e=E2E(); e.build(48000.0); mark("built")
uc=e.uc; H=e.HOST
def i32(a): return struct.unpack("<i",uc.mem_read(a,4))[0]
def u32(a): return struct.unpack("<I",uc.mem_read(a,4))[0]
def u64(a): return int.from_bytes(uc.mem_read(a,8),'little')
a0=u64(H+104); vptr=u64(a0)
GET=u64(vptr+136); SET=u64(vptr+128)
print("assigner vptr rva 0x%x  GET rva 0x%x  SET rva 0x%x"%(vptr-IB,GET-IB,SET-IB),flush=True)
def snap(a):
    return dict(n_at8=i32(a+8), mask_at12=hex(u32(a+12)), q16=u64(a+16), q24=u64(a+24),
                d32=i32(a+32), d68=i32(a+68), d72=i32(a+72), q76=u64(a+76), q84=u64(a+84),
                d92=i32(a+92), n_at152=i32(a+152),
                order120=[i32(a+120+4*k) for k in range(8)],
                slotbytes98=[u32(a+96+4*k) for k in range(6)],
                ctr168=u64(a+168))
print("getter ->", e.call(GET,rcx=a0)&0xFFFFFFFF, flush=True)
print("BEFORE", json.dumps(snap(a0)), flush=True)
# allocate 3 notes first so the allocator has live state, then shrink
for n in (60,64,67):
    e.note_on(n,100)
print("after 3 noteons", json.dumps(snap(a0)), flush=True)
e.call(SET,rcx=a0,rdx=4)
print("AFTER set(4)", json.dumps(snap(a0)), flush=True)
print("getter ->", e.call(GET,rcx=a0)&0xFFFFFFFF, flush=True)
e.call(SET,rcx=a0,rdx=99)
print("AFTER set(99)", json.dumps(snap(a0)), flush=True)
e.call(SET,rcx=a0,rdx=0)
print("AFTER set(0)", json.dumps(snap(a0)), flush=True)
e.call(SET,rcx=a0,rdx=8)
print("AFTER set(8)", json.dumps(snap(a0)), flush=True)
mark("done")
