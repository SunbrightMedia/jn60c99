#!/usr/bin/env python3
"""halfos_gate.py — F5 gate 3: the BAND-LIMITED null for half-oversampling.

WHY NOT null_b's -100/-80. Half-oversampling repositions aliases by design
(the user-approved relaxation: level matched, positions not). Above ~18 kHz
the two paths therefore differ by construction, and a full-band null would
measure that difference and call it a defect. It would also measure the 2x
decimator's extra 1.87 samples of PURE DELAY, which is not a defect either.

So this gate does two things a plain null does not, and states both:
  1. ALIGNS: cross-correlates the two streams over +/-8 samples and removes
     the integer lag, then reports the lag it removed. A lag other than the
     designed ~2 samples is itself a finding.
  2. BAND-LIMITS: both streams through the same 18 kHz FIR low-pass before
     the residual is computed, so the comparison covers what the relaxation
     did NOT license.
Bound: -80 dB global, -60 dB worst 1024-block, all 36 scenarios, both rates.
"""
import os
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

GLOBAL_DB, BLOCK_DB = -80.0, -60.0


def lowpass(x, fs, fc=18000.0, ntap=127):
    n = np.arange(ntap) - (ntap - 1) / 2.0
    h = 2 * (fc / fs) * np.sinc(2 * (fc / fs) * n) * np.hamming(ntap)
    h /= h.sum()
    return np.convolve(x, h, mode="same")


def align(a, b, span=8):
    """Remove the integer lag between the two streams; return (b_shifted, lag)."""
    n = min(len(a), len(b))
    a, b = a[:n], b[:n]
    seg = slice(n // 4, n // 4 + min(200000, n // 2))
    best, blag = None, 0
    for lag in range(-span, span + 1):
        bb = np.roll(b, -lag)
        c = float(np.dot(a[seg], bb[seg]))
        if best is None or c > best:
            best, blag = c, lag
    return np.roll(b, -blag), blag


def main():
    import null_b
    rate = 48000.0
    if "--rate" in sys.argv:
        rate = float(sys.argv[sys.argv.index("--rate") + 1])
    tmp = tempfile.mkdtemp(prefix="halfos_")
    null_b.SR = rate
    ref = null_b.render_side(_build(tmp, "ref", []), False, tmp, "ref")
    cand = null_b.render_side(_build(tmp, "cand", ["halfos"]), False, tmp, "cand")

    print("=== HALF-OS BAND-LIMITED NULL @ %.0f Hz "
          "(bounds %.0f / %.0f dB, 18 kHz LP, delay-aligned) ==="
          % (rate, GLOBAL_DB, BLOCK_DB))
    fails = 0
    for _, _, tag in null_b.scenarios(False):
        a = np.asarray(ref["streams"][tag], dtype=np.float64)
        b = np.asarray(cand["streams"][tag], dtype=np.float64)
        b, lag = align(a, b)
        n = min(len(a), len(b))
        a, b = lowpass(a[:n], rate), lowpass(b[:n], rate)
        e = a - b
        g = 10 * np.log10(max(np.mean(e * e), 1e-30) / max(np.mean(a * a), 1e-30))
        nb = n // 1024
        blk = -999.0
        for i in range(nb):
            sl = slice(i * 1024, (i + 1) * 1024)
            den = np.mean(a[sl] * a[sl])
            if den > 1e-12:
                blk = max(blk, 10 * np.log10(max(np.mean(e[sl] * e[sl]), 1e-30) / den))
        ok = g <= GLOBAL_DB and blk <= BLOCK_DB
        fails += 0 if ok else 1
        print("  %-26s lag %+d  global %7.1f dB  block %7.1f dB  -> %s"
              % (tag, lag, g, blk, "PASS" if ok else "FAIL"))
    print("VERDICT: %s" % ("PASS" if not fails else "FAIL (%d)" % fails))
    return 0 if not fails else 1


def _build(tmp, tag, mods):
    import null_b
    so = os.path.join(tmp, tag + ".so")
    if "halfos" in mods:
        null_b.CFLAGS = null_b.CFLAGS + ["-DEB_FORK_S3", "-DEB_HALF_OS=1"]
    null_b.build(so, ["standalone"])
    if "halfos" in mods:
        null_b.CFLAGS = null_b.CFLAGS[:-2]
    return so


if __name__ == "__main__":
    sys.exit(main())
