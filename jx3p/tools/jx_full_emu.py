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

SNAP_V, SNAP_M = 0x60000, 0xAAD000
# The boot is jx_emu.boot(): BUILD -> SETSR(float in xmm1, ABI ledger) ->
# FTZ. Ramps stay LIVE and the latch runs down as shipped (snap=False): the
# C twin reproduces both from the template's wrap records. Recall is the
# plugin's own pool dispatch (jx_emu.recall); notify=False keeps the oracle
# on the same path the shipping bridge takes today.


def main():
    outdir = sys.argv[1]
    patches = [int(x) for x in
               (sys.argv[2] if len(sys.argv) > 2 else "0,5,20,49").split(",")]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 1200
    os.makedirs(outdir, exist_ok=True)
    bank = J.bank_bytes()
    for patch in patches:
        jx = J.JX().boot(44100.0, snap=True, host_init=True); uc = jx.uc
        jx.recall(patch, bank=bank, notify=False)
        # IDLE PREFIX (2026-09-06): the listen proof flagged a -60 dBFS floor
        # on the master before any note. An absolute threshold cannot say
        # whether that is a defect or the instrument -- only EQUALITY WITH THE
        # PLUGIN can. So the gate now renders `idle` samples BEFORE note-on and
        # compares them too: whatever the plugin's own idle floor is, the port
        # must reproduce it bit-for-bit.
        idle = int(os.environ.get("JX_FULL_IDLE", "4096"))
        Li, Ri = jx.render(idle) if idle else ([], [])
        jx.note_on(60, 100)
        L, R = jx.render(n)
        L, R = list(Li) + list(L), list(Ri) + list(R)
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
