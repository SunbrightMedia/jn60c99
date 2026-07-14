#!/usr/bin/env python3
"""probe93.py — seed 93 (44.1k, patch 63) diverges @frame 10 of the FIRST render.
Full dual-side state diff after the 5 pre-render events, then a per-sample
microscope over frames 0..12. Prints every differing uint32 cell (voice blocks,
aux latch rows, master region)."""
import struct, ctypes, sys
import numpy as np
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
sys.path.insert(0, '/home/user/jn60c99/tools/verify/triage')
from ft3 import PluginRun, PortRun, gen_script, STRIDE, f32

def diff_all(P, Q, tag, limit=40):
    nd = 0
    for v in range(8):
        pb, pa = P.snap_voice(v); qb, qa = Q.snap_voice(v)
        for name, a, b in (("blk", pb, qb), ("aux", pa, qa)):
            ua = np.frombuffer(a, dtype=np.uint32); ub = np.frombuffer(b, dtype=np.uint32)
            for i in np.nonzero(ua != ub)[0].tolist():
                nd += 1
                if nd <= limit:
                    print(f"  [{tag}] v{v} {name} rel {4*i}: plug {ua[i]:08x} ({f32(ua[i]):.9g})"
                          f"  port {ub[i]:08x} ({f32(ub[i]):.9g})")
    pm = np.frombuffer(P.snap_master(), dtype=np.uint32)
    qm = np.frombuffer(Q.snap_master(), dtype=np.uint32)
    for i in np.nonzero(pm != qm)[0].tolist():
        nd += 1
        if nd <= limit:
            print(f"  [{tag}] MASTER off {84272+4*i}: plug {pm[i]:08x} ({f32(pm[i]):.9g})"
                  f"  port {qm[i]:08x} ({f32(qm[i]):.9g})")
    print(f"  [{tag}] total diffs: {nd}", flush=True)
    return nd

def main():
    rate, patch, ev, _ = gen_script(93)
    pre = ev[:5]                      # on 38, on 42, on 39, param(18,16), off 39
    print(f"seed 93 rate={rate} patch={patch} pre-render events: {pre}", flush=True)
    P = PluginRun(rate, patch); Q = PortRun(rate, patch)
    print("== state diff AFTER RECALL, BEFORE ANY EVENT ==")
    diff_all(P, Q, "recall")
    for x in pre:
        P.do(x); Q.do(x)
    print("== state diff AFTER pre-render events, BEFORE render ==")
    diff_all(P, Q, "pre")
    for s in range(13):
        P.do(('render', 1), block=1); Q.do(('render', 1))
        a = (P.L[s], P.R[s]); b = (Q.L[s], Q.R[s])
        m = "" if a == (Q.L[s], Q.R[s]) else "   <<< AUDIO DIFF"
        print(f"frame {s}: plug {a[0]:08x}/{a[1]:08x} port {b[0]:08x}/{b[1]:08x}{m}", flush=True)
        if a != b:
            print(f"== state diff at first audio div (frame {s}) ==")
            diff_all(P, Q, f"f{s}")
            break
    Q.close()

if __name__ == '__main__':
    main()
