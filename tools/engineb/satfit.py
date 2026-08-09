#!/usr/bin/env python3
"""satfit.py — fit the 2x path's saturation drive against the TRUNK ORACLE.

WHY THIS EXISTS. EB_HALF_OS_VCF halves the ladder's oversampling and measures
3.17 dB on the sonic gate. The record says the residual is IN-BAND HARMONICS
from half-rate waveshaping, and all three ADAA orders (2.22 / 5.77 / 33.94 dB,
centred 3.25) failed against it. Every one of those attacked ALIASING. At 2x
the saturator is evaluated TWICE per output sample instead of four times, so
the same signal traverses the curve half as often and generates a different
harmonic LEVEL. Level is a gain question. Gain questions are fitted.

THE COVENANT LINE. Constants are fitted against the TRUNK's own rendered
output -- the trunk is the plugin's behaviour, proven EXACTLY 0. NEVER against
the user's DAW bounces: a constant fitted to a bounce is CAPTURED and poisons
the fork (CLAUDE.md, diagnostic-capture covenant).

THE METRIC IS THE GATE'S OWN. Third-octave band energy, 1.0 dB, the same
bands() and spectrum() the sonic gate uses -- imported, not reimplemented, so
a fit that scores well here cannot score differently there. The final verdict
still comes from a full sonic_gate.py run: this searches, that decides.
"""
import os
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HERE)),
                                "tools", "trackb"))
from sonic_gate import bands, spectrum          # the gate's own metric

BASE = ["-DEB_FORK_S3", "-DEB_DCO_WT=1", "-DEB_VCF_DEADCOEF=1",
        "-DEB_VCF_RES_LUT=256", "-DEB_LFO_SHARED=1"]


def build(tmp, tag, extra):
    import null_b
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + extra
    so = os.path.join(tmp, tag + ".so")
    null_b.build(so, ["standalone"])
    null_b.CFLAGS = base
    return so


def worst_band(ref, cand, rate):
    """Worst third-octave band error over every scenario, both channels."""
    w, wtag, wf = 0.0, "", 0.0
    for tag in ref:
        if tag not in cand:
            continue
        for ch in (0,):
            a = np.asarray(ref[tag], dtype=np.float64)
            b = np.asarray(cand[tag], dtype=np.float64)
            n = min(len(a), len(b))
            if n < 8192 or np.mean(a[:n] * a[:n]) < 1e-12:
                continue
            A, B = spectrum(a[:n], rate), spectrum(b[:n], rate)
            for lo, hi, i0, i1 in bands(rate, 8192):
                pa, pb = A[i0:i1].sum(), B[i0:i1].sum()
                if pa <= 0 or pb <= 0:
                    continue
                d = abs(10.0 * np.log10(pb / pa))
                if d > w:
                    w, wtag, wf = d, tag, lo
    return w, wtag, wf


def streams(side):
    """render_side's payload. The sonic gate reads side["streams"][tag] and
    that is the shape used here too -- an earlier draft guessed at an L/R pair
    and fed the build's BANNER STRING into numpy, which is the failure mode of
    inventing a data layout instead of reading the consumer that already
    works."""
    return side["streams"]


def main():
    import null_b
    rate = 44100.0
    null_b.SR = rate
    tmp = tempfile.mkdtemp(prefix="satfit_")

    print("building the trunk oracle once ...", flush=True)
    ref = streams(null_b.render_side(build(tmp, "ref", []), False, tmp, "ref"))
    print("  %d scenarios" % len(ref), flush=True)

    # THE GRID. Coarse first; `a` is the drive into the curve (the harmonic
    # level knob) and `m` the makeup. a = m = 1 is the identity, and it is in
    # the grid ON PURPOSE: it reproduces the recorded 3.17 dB and so proves the
    # harness is measuring the thing it claims to measure.
    grid_a = [float(x) for x in os.environ.get("SATFIT_A", "1.0,1.15,1.3,1.5,1.8").split(",")]
    grid_m = [float(x) for x in os.environ.get("SATFIT_M", "1.0").split(",")]

    best = None
    for a in grid_a:
        for m in grid_m:
            tag = "a%.3f_m%.3f" % (a, m)
            extra = BASE + ["-DEB_HALF_OS_VCF=1", "-DEB_VCF_SATFIT=1",
                            "-DEB_VCF_SATFIT_A=%.6ff" % a,
                            "-DEB_VCF_SATFIT_M=%.6ff" % m]
            try:
                cand = streams(null_b.render_side(build(tmp, tag, extra),
                                                  False, tmp, tag))
            except SystemExit as e:
                print("  a=%.3f m=%.3f  BUILD/RENDER FAILED (%s)" % (a, m, e),
                      flush=True)
                continue
            w, wtag, wf = worst_band(ref, cand, rate)
            mark = ""
            if best is None or w < best[0]:
                best = (w, a, m, wtag, wf)
                mark = "  <- best"
            print("  a=%.3f m=%.3f  worst band %6.2f dB  (%s @ %.0f Hz)%s"
                  % (a, m, w, wtag, wf, mark), flush=True)

    if best:
        print("\nBEST a=%.3f m=%.3f -> %.2f dB (%s @ %.0f Hz)  %s"
              % (best[1], best[2], best[0], best[3], best[4],
                 "UNDER the 1.0 dB bound" if best[0] <= 1.0 else "still over"))
        print("This SEARCHES. tools/engineb/sonic_gate.py DECIDES.")


if __name__ == "__main__":
    main()
