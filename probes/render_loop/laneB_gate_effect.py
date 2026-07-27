#!/usr/bin/env python3
"""LANE B part 4 — execute the real per-block render 0x3C7400 with ENGINE+56 == 0
(the value e2e_emu's hand-built HOST actually holds) and show the two observable
consequences: (a) the voice-count sync calls the assigner setter with 0 on all 8
units, wiping the allocator, (b) no voice buffer is rendered.

SAFETY: +56 == 0 makes the pool barrier `while (*(eng+1072) < *(eng+56))` false, so
this never waits on a condvar.  We deliberately do NOT run it with +56 > 0 (that
would wait for worker threads that do not exist under emulation).
"""
import sys, struct, json, time
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
from e2e_emu import E2E, IB, BUF_BASE
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX, \
                              UC_X86_REG_R8, UC_X86_REG_R9
T0=time.time()
def mark(m): print("[%6.1fs] %s"%(time.time()-T0,m),flush=True)
RENDER = IB + 0x3C7400
e=E2E(); e.build(48000.0); e.clear_latch(); mark("built")
uc=e.uc; H=e.HOST
def i32(a): return struct.unpack("<i",uc.mem_read(a,4))[0]
def u32(a): return struct.unpack("<I",uc.mem_read(a,4))[0]
def u64(a): return int.from_bytes(uc.mem_read(a,8),'little')
def asg(i): return u64(H+104+64*i)
def snap():
    return [dict(n=i32(asg(i)+8), mask=hex(u32(asg(i)+12)), n152=i32(asg(i)+152),
                 ctr168=u64(asg(i)+168)) for i in range(8)]
print("engine+56 as e2e_emu leaves it:", i32(H+56), flush=True)
for n in (60,64,67): e.note_on(n,100)
print("assigners after 3 note-ons:", json.dumps(snap()), flush=True)
# output buffers for a4 (two float* )
OL=BUF_BASE+0x100000; OR=BUF_BASE+0x110000; APTR=BUF_BASE+0x120000
uc.mem_write(OL, b"\x11"*4096); uc.mem_write(OR, b"\x11"*4096)
uc.mem_write(APTR, struct.pack("<QQ", OL, OR))
B=64
rsp=(0x200000000+0x2000000-0x20000)&~0xF
RET=0x100000+0x5000
# 6th arg goes on the stack: shadow space 32 bytes then arg5 @ +32, arg6 @ +40
frame = struct.pack("<Q",RET) + b"\x00"*32 + struct.pack("<qq",2,B) + b"\x00"*64
uc.mem_write(rsp, frame)
uc.reg_write(UC_X86_REG_RSP, rsp)
uc.reg_write(UC_X86_REG_RCX,H); uc.reg_write(UC_X86_REG_RDX,0)
uc.reg_write(UC_X86_REG_R8,0);  uc.reg_write(UC_X86_REG_R9,APTR)
try:
    uc.emu_start(RENDER, RET, count=200_000_000)
    rip=uc.reg_read(UC_X86_REG_RIP)
    print("render returned, rip==RET:", rip==RET, "rva 0x%x"%(rip-IB) if rip!=RET else "", flush=True)
except Exception as ex:
    print("render EXC", str(ex)[:80], "@rva 0x%x"%(uc.reg_read(UC_X86_REG_RIP)-IB), flush=True)
print("assigners AFTER 0x3C7400 with +56==0:", json.dumps(snap()), flush=True)
print("engine+1072 doneCounter:", i32(H+1072), " peakL", struct.unpack("<f",uc.mem_read(H+32,4))[0], flush=True)
L=struct.unpack("<%dI"%B, uc.mem_read(OL,4*B))
print("outL first 8 words:", [hex(x) for x in L[:8]], flush=True)
mark("done")
