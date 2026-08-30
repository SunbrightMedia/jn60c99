#!/usr/bin/env python3
"""zc_t5_gate.py -- EB_ZEROCOEF_T5 must change NOTHING, and the gate must be
able to see a t5 change at all.

Three builds over null_b's full scenario battery:
  A  trunk verbatim
  B  trunk + EB_ZEROCOEF_T5=1          -> every stream BITWISE equal to A
  T  trunk + EB_ZC_T5_TOOTH=1          -> at least one stream MUST differ
     (the tooth also zeroes k6497232, a LIVE t5 FIR coefficient, inside the
     same #if structure -- so it proves both that the battery REACHES delay
     type 5 and that this comparison can see a t5 change: playbook 80, the
     gate states its own reach.)

Exit nonzero on any B mismatch or on a blind tooth.
"""
import os
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)

import null_b  # noqa: E402


def build(tmp, tag, extra):
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + extra
    so = os.path.join(tmp, tag + ".so")
    null_b.build(so, ["standalone"])
    null_b.CFLAGS = base
    return so


def main():
    tmp = tempfile.mkdtemp(prefix="zct5_")
    print("building A (trunk) ...")
    A = null_b.render_side(build(tmp, "a", []), False, tmp, "a")
    print("building B (trunk + EB_ZEROCOEF_T5) ...")
    B = null_b.render_side(build(tmp, "b", ["-DEB_ZEROCOEF_T5=1"]), False, tmp, "b")
    print("building T (tooth: also deletes LIVE k6497232) ...")
    T = null_b.render_side(build(tmp, "t", ["-DEB_ZEROCOEF_T5=1",
                                            "-DEB_ZC_T5_TOOTH=1"]), False, tmp, "t")

    bad = 0
    bite = 0
    for tag in A["streams"]:
        a = np.asarray(A["streams"][tag], dtype=np.float32)
        b = np.asarray(B["streams"][tag], dtype=np.float32)
        t = np.asarray(T["streams"][tag], dtype=np.float32)
        n = min(len(a), len(b), len(t))
        d = int(np.count_nonzero(a[:n] != b[:n]))
        if d:
            print("FAIL %-30s %d differing samples (flag changed audio)" % (tag, d))
            bad += 1
        if np.count_nonzero(a[:n] != t[:n]):
            bite += 1
    print("streams: %d   B-mismatches: %d   tooth bit on %d stream(s)"
          % (len(A["streams"]), bad, bite))
    if bad:
        print("VERDICT: FAIL -- EB_ZEROCOEF_T5 is NOT exact")
        return 1
    if not bite:
        print("VERDICT: BLIND -- the battery never reached a live t5 "
              "coefficient; a PASS here would prove nothing")
        return 1
    print("VERDICT: PASS -- EXACTLY 0 on every stream, tooth SEEN TO BITE")
    return 0


if __name__ == "__main__":
    sys.exit(main())
