#!/usr/bin/env python3
"""jx_ktrack_emu.py -- ORACLE side of the key-tracker A/B (process A).

The tracker objects live at unit+0x520 (one per note-manager unit; this gate
drives unit 0's). Entries: ON/OFF wrappers 0x357BC0 / 0x357B20. The seam is
the host vtable: [vt+0x48] parameter SET (stubbed + recorded) and [vt+0x50]
parameter GET (EXECUTED, then recorded with its result -- the C replays the
recorded answers, so both sides see identical inputs: the "get tape").

Writes: init.bin, final.bin, events.tsv (set48/get50 rows), seq is shared.
usage: jx_ktrack_emu.py <outdir>
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_emu as J
import jx_ktrack_seq
from unicorn.x86_const import (UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX,
                               UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9,
                               UC_X86_REG_RAX)
from unicorn import UC_HOOK_CODE

ON_W, OFF_W = 0x357BC0, 0x357B20
KT_SZ = 0xB0      # JXK_UNIT_SZ: last touched byte +0xA7


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build(); jx.set_ftz()
    uc = jx.uc
    unit = struct.unpack("<Q", uc.mem_read(jx.HOST + 0x78, 8))[0]
    obj = struct.unpack("<Q", uc.mem_read(unit + 0x520, 8))[0]
    vt = struct.unpack("<Q", uc.mem_read(obj, 8))[0]
    t48 = struct.unpack("<Q", uc.mem_read(vt + 0x48, 8))[0]
    t50 = struct.unpack("<Q", uc.mem_read(vt + 0x50, 8))[0]
    t70 = struct.unpack("<Q", uc.mem_read(vt + 0x70, 8))[0]

    open(os.path.join(outdir, "init.bin"), "wb").write(
        bytes(uc.mem_read(obj, KT_SZ)))
    events = []

    def h48(uc_, addr, size, user):     # SET: stub + record (r9d = value)
        pid = uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF
        val = uc_.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF
        events.append(("set48", pid, val, 0))
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        ret = struct.unpack("<Q", uc_.mem_read(rsp, 8))[0]
        uc_.reg_write(UC_X86_REG_RSP, rsp + 8)
        uc_.reg_write(UC_X86_REG_RIP, ret)

    pend = {}

    def h50(uc_, addr, size, user):     # GET: let it run, tape the answer
        pid = uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF
        out = uc_.reg_read(UC_X86_REG_R9)
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        ret = struct.unpack("<Q", uc_.mem_read(rsp, 8))[0]
        pend[ret] = (pid, out)

    def h50ret(uc_, addr, size, user):
        if addr in pend:
            pid, out = pend.pop(addr)
            al = uc_.reg_read(UC_X86_REG_RAX) & 0xFF
            val = struct.unpack("<i", uc_.mem_read(out, 4))[0] if al else 0
            events.append(("get50", val, pid, al))

    def h70(uc_, addr, size, user):     # CLOCK GET: run, tape on return
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        ret = struct.unpack("<Q", uc_.mem_read(rsp, 8))[0]
        pend70[ret] = 1

    def h70ret(uc_, addr, size, user):
        if addr in pend70:
            pend70.pop(addr)
            events.append(("get70",
                           uc_.reg_read(UC_X86_REG_RAX) & 0xFFFFFFFF, 0, 0))

    pend70 = {}
    uc.hook_add(UC_HOOK_CODE, h48, begin=t48, end=t48)
    uc.hook_add(UC_HOOK_CODE, h70, begin=t70, end=t70)
    uc.hook_add(UC_HOOK_CODE, h70ret)
    uc.hook_add(UC_HOOK_CODE, h50, begin=t50, end=t50)
    uc.hook_add(UC_HOOK_CODE, h50ret)     # global; filters on return addr

    for ev in jx_ktrack_seq.make():
        if ev[0] == "on":
            jx.call(J.IB + ON_W, rcx=obj, rdx=ev[1], r8=ev[2])
        elif ev[0] == "off":
            jx.call(J.IB + OFF_W, rcx=obj, rdx=ev[1])
        elif ev[0] == "mode":
            uc.mem_write(obj + 0x10, struct.pack("<i", ev[1]))
            events.append(("mode", ev[1], 0, 0))

    with open(os.path.join(outdir, "events.tsv"), "w") as f:
        for e in events:
            f.write("%s\t%d\t%d\t%d\n" % e)
    open(os.path.join(outdir, "final.bin"), "wb").write(
        bytes(uc.mem_read(obj, KT_SZ)))
    print("oracle: %d seam events" % len(events))


if __name__ == "__main__":
    main()
