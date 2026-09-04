#!/usr/bin/env python3
"""jx_nstore_emu.py -- ORACLE side of the note-store A/B (process A).
Object: unit0's +0x518. Entries 0x3F5100 (on) / 0x3F0EF0 (off).
Seam: the tail jmp to 0x3EF210 (drain) -- stubbed + recorded.
Writes init.bin/final.bin/events.tsv.  usage: jx_nstore_emu.py <outdir>
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_emu as J
import jx_nstore_seq
from unicorn.x86_const import (UC_X86_REG_RIP, UC_X86_REG_RSP,
                               UC_X86_REG_RAX)
from unicorn import UC_HOOK_CODE

ON, OFF, SEAM = 0x3F5100, 0x3F0EF0, 0x3EF210
SZ = 0xDB0


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build(); jx.set_ftz()
    uc = jx.uc
    unit = struct.unpack("<Q", uc.mem_read(jx.HOST + 0x78, 8))[0]
    obj = struct.unpack("<Q", uc.mem_read(unit + 0x518, 8))[0]
    open(os.path.join(outdir, "init.bin"), "wb").write(
        bytes(uc.mem_read(obj, SZ)))
    events = []

    def seam(uc_, addr, size, user):
        events.append(("drain", 0, 0, 0))
        rsp = uc_.reg_read(UC_X86_REG_RSP)   # tail-jmp: return to caller's ra
        ret = struct.unpack("<Q", uc_.mem_read(rsp, 8))[0]
        uc_.reg_write(UC_X86_REG_RSP, rsp + 8)
        uc_.reg_write(UC_X86_REG_RIP, ret)

    uc.hook_add(UC_HOOK_CODE, seam, begin=J.IB + SEAM, end=J.IB + SEAM)

    for ev in jx_nstore_seq.make():
        if ev[0] == "poke2c":
            uc.mem_write(obj + 0x2C, struct.pack("<i", ev[1]))
            events.append(("poke2c", ev[1], 0, 0))
        elif ev[0] == "on":
            jx.call(J.IB + ON, rcx=obj, rdx=ev[1], r8=ev[2])
            events.append(("ron", ev[1], ev[2],
                           jx.uc.reg_read(UC_X86_REG_RAX) & 0xFF))
        else:
            jx.call(J.IB + OFF, rcx=obj, rdx=ev[1], r8=ev[2])
            events.append(("roff", ev[1], ev[2],
                           jx.uc.reg_read(UC_X86_REG_RAX) & 0xFF))

    with open(os.path.join(outdir, "events.tsv"), "w") as f:
        for e in events:
            f.write("%s\t%d\t%d\t%d\n" % e)
    open(os.path.join(outdir, "final.bin"), "wb").write(
        bytes(uc.mem_read(obj, SZ)))
    print("oracle: %d events" % len(events))


if __name__ == "__main__":
    main()
