#!/usr/bin/env python3
"""jx_alloc_emu.py -- ORACLE side of the note-manager A/B (process A).

Builds the plugin under Unicorn, finds the 9 note-manager units at
HOST+0x78+0x40*i, snapshots their blobs, STUBS the four sinks (the seam to
the voice layer -- 0x3F5100, 0x3F0EF0, and the +0x520 vtable's +0x10/+0x18)
so only THIS layer executes, then replays the shared sequence through the
plugin's own entries:
  NOTEON 0x3F9150  NOTEOFF 0x3F90F0  (rcx = HOST)
  setters per unit: 0x3F61C0 0x3F61E0 0x3F6200 0x3F6210 0x3F6230

Writes to <outdir>: init_%d.bin, final_%d.bin, events.tsv.

usage: jx_alloc_emu.py <outdir>
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_emu as J
import jx_alloc_seq
from unicorn.x86_const import (UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX,
                               UC_X86_REG_RDX, UC_X86_REG_R8)
from unicorn import UC_HOOK_CODE

NOTEON, NOTEOFF = 0x3F9150, 0x3F90F0
SET_PEND, SET_SUS, SET_POLY, SET_HOLD, SET_M8 = \
    0x3F61C0, 0x3F61E0, 0x3F6200, 0x3F6210, 0x3F6230
S518_ON, S518_OFF = 0x3F5100, 0x3F0EF0
UNIT_SZ = 0x7A8


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build()
    jx.set_ftz()
    uc = jx.uc

    units = [struct.unpack("<Q", uc.mem_read(jx.HOST + 0x78 + 0x40 * i, 8))[0]
             for i in range(9)]
    s518 = {struct.unpack("<Q", uc.mem_read(u + 0x518, 8))[0]: i
            for i, u in enumerate(units)}
    s520 = {struct.unpack("<Q", uc.mem_read(u + 0x520, 8))[0]: i
            for i, u in enumerate(units)}

    for i, u in enumerate(units):
        open(os.path.join(outdir, "init_%d.bin" % i), "wb").write(
            bytes(uc.mem_read(u, UNIT_SZ)))

    events = []

    def stub(kind, by):
        def h(uc_, addr, size, user):
            rcx = uc_.reg_read(UC_X86_REG_RCX)
            unit = by.get(rcx, -1)
            note = uc_.reg_read(UC_X86_REG_RDX) & 0xFF
            vel = uc_.reg_read(UC_X86_REG_R8) & 0xFF
            events.append((kind, unit, note, vel))
            rsp = uc_.reg_read(UC_X86_REG_RSP)
            ret = struct.unpack("<Q", uc_.mem_read(rsp, 8))[0]
            uc_.reg_write(UC_X86_REG_RSP, rsp + 8)
            uc_.reg_write(UC_X86_REG_RIP, ret)
        return h

    uc.hook_add(UC_HOOK_CODE, stub("A_on", s518),
                begin=J.IB + S518_ON, end=J.IB + S518_ON)
    uc.hook_add(UC_HOOK_CODE, stub("A_off", s518),
                begin=J.IB + S518_OFF, end=J.IB + S518_OFF)
    # the +0x520 sinks are virtual: read each unit's vtable entries
    seen = set()
    for obj, i in s520.items():
        vt = struct.unpack("<Q", uc.mem_read(obj, 8))[0]
        t10 = struct.unpack("<Q", uc.mem_read(vt + 0x10, 8))[0]
        t18 = struct.unpack("<Q", uc.mem_read(vt + 0x18, 8))[0]
        for t, kind in ((t10, "B_off"), (t18, "B_on")):
            if t not in seen:
                seen.add(t)
                uc.hook_add(UC_HOOK_CODE, stub(kind, s520), begin=t, end=t)

    for ev in jx_alloc_seq.make():
        if ev[0] == "on":
            jx.call(J.IB + NOTEON, rcx=jx.HOST, rdx=ev[1], r8=ev[2])
        elif ev[0] == "off":
            jx.call(J.IB + NOTEOFF, rcx=jx.HOST, rdx=ev[1], r8=ev[2])
        elif ev[0] == "sus":
            jx.call(J.IB + SET_SUS, rcx=units[ev[1]], rdx=ev[2])
        elif ev[0] == "hold":
            jx.call(J.IB + SET_HOLD, rcx=units[ev[1]], rdx=ev[2])
        elif ev[0] == "poly":
            jx.call(J.IB + SET_POLY, rcx=units[ev[1]], rdx=ev[2])
        elif ev[0] == "pend":
            jx.call(J.IB + SET_PEND, rcx=units[ev[1]], rdx=ev[2])
        elif ev[0] == "mode8":
            jx.call(J.IB + SET_M8, rcx=units[ev[1]], rdx=ev[2])

    with open(os.path.join(outdir, "events.tsv"), "w") as f:
        for e in events:
            f.write("%s\t%d\t%d\t%d\n" % e)
    for i, u in enumerate(units):
        open(os.path.join(outdir, "final_%d.bin" % i), "wb").write(
            bytes(uc.mem_read(u, UNIT_SZ)))
    print("oracle: %d seam events, 9 unit blobs of 0x%X" %
          (len(events), UNIT_SZ))


if __name__ == "__main__":
    main()
