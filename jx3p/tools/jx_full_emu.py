#!/usr/bin/env python3
"""jx_full_emu.py -- ORACLE side of the FULL-CHAIN standalone gate
(charter 7b, the finish line): the plugin does EVERYTHING through its own
entries -- BUILD, SETSR, per-unit recall, NOTEON/NOTEOFF fan-out, render.
NO pokes: the warm-up latch runs down exactly as shipped.
Writes L/R streams + final states per patch.
usage: jx_full_emu.py <outdir> [patches=0,5,20,49] [n=1200]
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
SETSR, NOTEON, NOTEOFF = 0x3F9970, 0x3F9150, 0x3F90F0
SNAP_V, SNAP_M = 0x60000, 0xAAD000
ACTIVE = [10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 24, 25, 26, 28, 29, 30, 31,
          32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
          49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65]


def decode(blob, pool):
    p = 2 * pool + 8
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)


def main():
    outdir = sys.argv[1]
    patches = [int(x) for x in
               (sys.argv[2] if len(sys.argv) > 2 else "0,5,20,49").split(",")]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 1200
    os.makedirs(outdir, exist_ok=True)
    bank = open(os.path.join(J.REPO, "jx3p", "truth",
                             "preset_bank_1.bin"), "rb").read()
    for patch in patches:
        jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
        jx.call(J.IB + SETSR, rcx=jx.HOST,
                rdx=struct.unpack("<Q", struct.pack("<d", 44100.0))[0])
        blob = bank[HEADER + patch * STRIDE + BLOB_OFF:]
        for u in range(J.N_UNITS):
            for pool in ACTIVE:
                jx.dispatch(u, pool + 740, decode(blob, pool))
        jx.call(J.IB + NOTEON, rcx=jx.HOST, rdx=60, r8=100)
        L, R = jx.render(n)
        d = os.path.join(outdir, "p%d" % patch)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, "louts.bin"), "wb").write(
            b"".join(struct.pack("<II", l, r) for l, r in zip(L, R)))
        for v in range(8):
            open(os.path.join(d, "vstate_ref_%d.bin" % v), "wb").write(
                bytes(uc.mem_read(jx.state[v], SNAP_V)))
        open(os.path.join(d, "mstate_ref.bin"), "wb").write(
            bytes(uc.mem_read(jx.state[8], SNAP_M)))
        nz = sum(1 for l in L if l)
        print("p%d: %d samples, %d nonzero L" % (patch, n, nz))
    print("FULL EMU REFERENCE WRITTEN to %s" % outdir)


if __name__ == "__main__":
    main()
