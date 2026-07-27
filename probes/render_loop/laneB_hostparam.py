#!/usr/bin/env python3
"""LANE B part 2 — execute the host param entry 0x3C7AE0 with the magic
paramID 268419086 (0x0FFFC00E) and observe ENGINE+56.  Instruction-capped so a
spin cannot hang; on cap we report the RVA we stopped at."""
import sys, struct, json, time
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
from e2e_emu import E2E, IB
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8
T0 = time.time()
def mark(m): print("[%7.1fs] %s" % (time.time()-T0, m), flush=True)

HOSTPARAM = IB + 0x3C7AE0
e = E2E(); mark("ctor"); e.build(48000.0); mark("built")
uc = e.uc; H = e.HOST
def i32(a): return struct.unpack("<i", uc.mem_read(a, 4))[0]
def u32(a): return struct.unpack("<I", uc.mem_read(a, 4))[0]
SCRATCH = 0x100000
def capped_call(fn, rcx=0, rdx=0, r8=0, cnt=3_000_000):
    rsp = (0x200000000 + 0x2000000 - 0x10000) & ~0xF; rsp -= 8
    uc.reg_write(UC_X86_REG_RSP, rsp)
    uc.reg_write(UC_X86_REG_RCX, rcx); uc.reg_write(UC_X86_REG_RDX, rdx & 0xFFFFFFFFFFFFFFFF); uc.reg_write(UC_X86_REG_R8, r8)
    RET = SCRATCH + 0x5000
    uc.mem_write(rsp, struct.pack("<Q", RET))
    try:
        uc.emu_start(fn, RET, count=cnt)
    except Exception as ex:
        return "EXC %s @rva 0x%x" % (str(ex)[:60], uc.reg_read(UC_X86_REG_RIP) - IB)
    rip = uc.reg_read(UC_X86_REG_RIP)
    return "ok" if rip == RET else "CAPPED @rva 0x%x" % (rip - IB)

print("engine+56 before:", i32(H + 56), "lock+64:", hex(u32(H + 64)), flush=True)
for v in (4, 1, 8):
    r = capped_call(HOSTPARAM, rcx=H, rdx=268419086, r8=v)
    print("send %d -> %s ; engine+56 = %d ; lock+64 = %s" % (v, r, i32(H + 56), hex(u32(H + 56 + 8))), flush=True)
mark("done")
