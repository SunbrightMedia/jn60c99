#!/usr/bin/env python3
"""halfos_gate.py — F5 gate 3: the BAND-LIMITED null for half-oversampling.

WHY NOT null_b's -100/-80. Half-oversampling repositions aliases by design
(the user-approved relaxation: level matched, positions not). Above ~18 kHz
the two paths therefore differ by construction, and a full-band null would
measure that difference and call it a defect. It would also measure the 2x
decimator's extra 1.87 samples of PURE DELAY, which is not a defect either.

So this gate does two things a plain null does not, and states both:
  1. ALIGNS: cross-correlates the two streams over +/-8 samples and removes
     the delay INCLUDING ITS FRACTIONAL PART, then reports the lag it removed.
     A lag other than the designed ~1.87 samples is itself a finding.
     Integer-only alignment leaves 0.87 of a sample of pure delay, which is
     -35 dB of phase error on its own -- the first version of this gate
     measured exactly that and blamed the lever.
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


def align(a, b, span=8, step=1.0 / 32.0):
    """Remove the delay between the two streams -- INCLUDING ITS FRACTIONAL
    PART -- and return (b_shifted, lag).

    WHY FRACTIONAL, and it is a measurement not a refinement. F5's design says
    the 2x decimator is 1.87 output samples longer than the port's. An
    INTEGER-only alignment therefore leaves 0.87 of a sample of PURE DELAY in
    the residual, and a pure delay of d samples costs 2*pi*f*d/fs radians of
    phase -- about 1.8 % at 1 kHz and 18 % at 10 kHz. That is -35 dB, and
    -35.7 dB is exactly what this gate reported for half-oversampling.

    So the first version of this gate was measuring its own missing 0.87 of a
    sample and calling it a defect in the lever. A gate that cannot remove the
    delay it was written to ignore is not a gate.

    The shift is done in the frequency domain, which gives an exact fractional
    delay rather than an interpolated approximation of one."""
    n = min(len(a), len(b))
    a, b = a[:n], b[:n]
    seg = slice(n // 4, n // 4 + min(200000, n // 2))
    F = np.fft.rfft(b)
    w = 2.0 * np.pi * np.fft.rfftfreq(n)
    best, blag, bshift = None, 0.0, b
    lag = -span
    while lag <= span + 1e-9:
        bb = np.fft.irfft(F * np.exp(-1j * w * lag), n) if lag else b
        c = float(np.dot(a[seg], bb[seg]))
        if best is None or c > best:
            best, blag, bshift = c, lag, bb
        lag += step
    return bshift, blag


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
        print("  %-26s lag %+6.3f  global %7.1f dB  block %7.1f dB  -> %s"
              % (tag, lag, g, blk, "PASS" if ok else "FAIL"))
    print("VERDICT: %s" % ("PASS" if not fails else "FAIL (%d)" % fails))
    return 0 if not fails else 1


# THE WHOLE FORK, not one lever. Every fork lever has been gated ALONE, on one
# module, and the composite has never been measured with a metric that is valid
# for it -- which is precisely the hole this project has found twice already
# ("the defect only a composite could find", "a gate that has never been seen
# to fail"). EB_FORK_FLAGS carries the full shipping flag set so this gate can
# answer "does the fork sound right" rather than "does one lever".
FORK_FLAGS = os.environ.get(
    "EB_FORK_FLAGS",
    "-DEB_FORK_S3 -DEB_HALF_OS=1").split()


def _build(tmp, tag, mods):
    import null_b
    so = os.path.join(tmp, tag + ".so")
    n = 0
    if "halfos" in mods:
        n = len(FORK_FLAGS)
        null_b.CFLAGS = null_b.CFLAGS + FORK_FLAGS
    null_b.build(so, ["standalone"])
    if n:
        null_b.CFLAGS = null_b.CFLAGS[:-n]
    return so


if __name__ == "__main__":
    sys.exit(main())
