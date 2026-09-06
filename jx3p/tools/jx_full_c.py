#!/usr/bin/env python3
"""jx_full_c.py -- C side of the FULL-CHAIN standalone gate (process B).
The STANDALONE engine (libjx3p.so): clean-boot template + recall + the
transcribed control plane + the proven renders. Same inputs, no pokes.
Compares the raw L/R bit streams; state divergence is reported separately
(informative -- pointer cells and unwritten scratch differ by construction).
exit 0 = L/R EXACTLY 0 on every patch.
usage: jx_full_c.py <refdir> <libjx3p.so> [patches] [n]
"""
import sys, os, ctypes, struct
REPO = os.path.abspath(os.path.join(os.path.dirname(
    os.path.abspath(__file__)), "..", ".."))


def main():
    refdir, so = sys.argv[1], sys.argv[2]
    patches = [int(x) for x in
               (sys.argv[3] if len(sys.argv) > 3 else "0,5,20,49").split(",")]
    n = int(sys.argv[4]) if len(sys.argv) > 4 else 1200
    fails = 0
    lib = ctypes.CDLL(so)
    if not hasattr(lib, "jx_enable_hw_ftz"):
        raise SystemExit("REFUSE: no jx_enable_hw_ftz -- link jx_ftz.c")
    lib.jx_enable_hw_ftz()
    for patch in patches:
        # jx3p_init re-copies every region from the template: a full reset
        ok = lib.jx3p_init(
            os.path.join(REPO, "jx3p", "gen", "jx_template.bin").encode(),
            os.path.join(REPO, "jx3p", "truth", "preset_bank_1.bin").encode(),
            os.path.join(REPO, "jx3p", "gen", "jx_master_recall.bin").encode())
        if not ok:
            raise SystemExit("jx3p_init failed")
        lib.jx3p_recall(patch)
        idle = int(os.environ.get("JX_FULL_IDLE", "4096"))
        if idle:                      # idle prefix -- see jx_full_emu.py
            Li = (ctypes.c_float * idle)(); Ri = (ctypes.c_float * idle)()
            lib.jx3p_render(Li, Ri, idle)
        L = (ctypes.c_float * n)(); R = (ctypes.c_float * n)()
        lib.jx3p_note_on(60, 100)
        lib.jx3p_render(L, R, n)
        # WHY a separate name: mutating the loop-invariant `n` here made the
        # SECOND patch render idle+n_of_the_first_patch samples and overrun
        # the reference buffer (caught by the gate, 2026-09-06).
        L = list(Li) + list(L) if idle else list(L)
        R = list(Ri) + list(R) if idle else list(R)
        ntot = len(L)
        ref = open(os.path.join(refdir, "p%d" % patch, "louts.bin"),
                   "rb").read()
        mm = first = -1
        mm = 0
        for s in range(ntot):
            rl, rr = struct.unpack_from("<II", ref, 8 * s)
            cl = struct.unpack("<I", struct.pack("<f", L[s]))[0]
            cr = struct.unpack("<I", struct.pack("<f", R[s]))[0]
            if cl != rl or cr != rr:
                if first < 0: first = s
                mm += 1
        if mm:
            fails += 1
            print("  p%d: L/R %d/%d mismatched, first at sample %d"
                  % (patch, mm, ntot, first))
            s = first
            rl, rr = struct.unpack_from("<II", ref, 8 * s)
            cl = struct.unpack("<I", struct.pack("<f", L[s]))[0]
            print("    s%d L C=0x%08x ref=0x%08x" % (s, cl, rl))
        else:
            print("  p%d: L/R %d samples EXACTLY 0" % (patch, ntot))
    if fails:
        print("FULL CHAIN: %d/%d patches FAIL" % (fails, len(patches)))
        sys.exit(1)
    print("FULL CHAIN: %d/%d patches EXACTLY 0 -- THE PORT PLAYS"
          % (len(patches), len(patches)))


if __name__ == "__main__":
    main()
