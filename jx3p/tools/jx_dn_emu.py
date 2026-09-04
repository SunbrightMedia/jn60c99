#!/usr/bin/env python3
"""jx_dn_emu.py -- ORACLE side of the note/gate handler A/B (process A).
Drives DISPATCH 0x3EBB00 on proc[0] with ids 433+v / 450+v, then snapshots
the proc header (0x700) and the full unit state (0x60000).
Also exports the seam constants: [o110+0x58], [o110+0x5C], and the 23-dword
temper window at RVA 0x9BF2F4.  usage: jx_dn_emu.py <outdir>
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_emu as J
import jx_dn_seq

DISPATCH = 0x3EBB00
PROC_SZ, STATE_SZ = 0x700, 0x60000


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build(); jx.set_ftz()
    uc = jx.uc
    proc, state = jx.proc[0], jx.state[0]
    o110 = struct.unpack("<Q", uc.mem_read(proc + 0x110, 8))[0]
    seam = struct.pack("<ii",
                       struct.unpack("<i", uc.mem_read(o110 + 0x58, 4))[0],
                       struct.unpack("<i", uc.mem_read(o110 + 0x5C, 4))[0])
    open(os.path.join(outdir, "seam.bin"), "wb").write(
        seam + bytes(uc.mem_read(J.IB + 0x9BF2F4, 23 * 4)))
    open(os.path.join(outdir, "proc_init.bin"), "wb").write(
        bytes(uc.mem_read(proc, PROC_SZ)))
    open(os.path.join(outdir, "state_init.bin"), "wb").write(
        bytes(uc.mem_read(state, STATE_SZ)))

    for ev in jx_dn_seq.make():
        pid = (433 if ev[0] == "note" else 450) + ev[1]
        jx.call(J.IB + DISPATCH, rcx=proc, rdx=pid, r8=2, r9=ev[2])

    open(os.path.join(outdir, "proc_final.bin"), "wb").write(
        bytes(uc.mem_read(proc, PROC_SZ)))
    open(os.path.join(outdir, "state_final.bin"), "wb").write(
        bytes(uc.mem_read(state, STATE_SZ)))
    print("oracle: %d dispatches" % len(jx_dn_seq.make()))


if __name__ == "__main__":
    main()
