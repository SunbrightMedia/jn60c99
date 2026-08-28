#!/usr/bin/env python3
"""halfrate_ab.py -- RENDER FULL-RATE vs HALF-RATE FX A/B WAVs, FOR THE EAR.

This is ab_wavs.py's sibling for the half-rate FX levers. It renders the SAME
scenario twice at the SHIPPING FORK's flags, the two sides differing ONLY by the
half-rate flag(s) under test:

  ref_<tag>.wav    shipping fork, FULL-rate FX (the reference: the fork the
                   gates certify sonically today).
  half_<tag>.wav   the same fork PLUS the half-rate flag(s) -- the real thing,
                   depths halved, coefficients rescaled, decimate/interpolate.

BOTH SIDES ARE SCALED BY THE SAME GAIN, taken from the reference's peak. A level
or timbre difference between the two is the trade the user is being asked to
judge; a per-file normalise would hide it. 24-bit, same reasoning as ab_wavs.py.

  --rev        add -DEB_REVERB_HALF=1   (default if neither given)
  --dly        add -DEB_DELAY_HALF=1
  --both       add both
  --only SUB   render only scenarios whose tag contains SUB
  --out DIR    output directory (default scratchpad/halfrate_ab)

THIS IS NOT A GATE. No verdict is returned and nothing may be tuned from what
is heard. The reference file is the fork the sonic gate already bounds; the
half file is the candidate the user's ear judges at F2.
"""
import os
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

import ab_wavs  # reuse SHIP flags and write24


def main():
    rate = 44100.0
    extra = []
    if "--both" in sys.argv:
        extra = ["-DEB_REVERB_HALF=1", "-DEB_DELAY_HALF=1"]
    else:
        if "--dly" in sys.argv:
            extra.append("-DEB_DELAY_HALF=1")
        if "--rev" in sys.argv or not extra:
            extra.append("-DEB_REVERB_HALF=1")

    outdir = os.path.join(REPO, "scratchpad", "halfrate_ab")
    if "--out" in sys.argv:
        outdir = sys.argv[sys.argv.index("--out") + 1]
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    os.makedirs(outdir, exist_ok=True)

    import null_b
    null_b.SR = rate
    tmp = tempfile.mkdtemp(prefix="halfab_")

    print("building reference (full-rate fork) ...")
    print("  flags: %s" % " ".join(ab_wavs.SHIP))
    ref = null_b.render_side(ab_wavs.build(tmp, "ref", ab_wavs.SHIP),
                             False, tmp, "ref")
    print("building half-rate fork ...")
    print("  flags: %s" % " ".join(ab_wavs.SHIP + extra))
    cand = null_b.render_side(ab_wavs.build(tmp, "half", ab_wavs.SHIP + extra),
                              False, tmp, "half")

    print("\n%-28s %10s %10s %8s" % ("scenario", "ref rms", "half rms", "d dB"))
    n = 0
    for _, _, tag in null_b.scenarios(False):
        if only and only not in tag:
            continue
        a = np.asarray(ref["streams"][tag], dtype=np.float64)
        b = np.asarray(cand["streams"][tag], dtype=np.float64)
        m = min(len(a), len(b))
        a, b = a[:m], b[:m]
        ra = float(np.sqrt(np.mean(a * a)))
        if ra < 1e-6:
            print("  %-26s silent, skipped" % tag)
            continue
        rb = float(np.sqrt(np.mean(b * b)))
        pk = float(np.max(np.abs(a)))
        g = (0.891 / pk) if pk > 1e-9 else 1.0
        safe = "".join(c if c.isalnum() else "_" for c in tag)
        ab_wavs.write24(os.path.join(outdir, "ref_%s.wav" % safe), a, rate, g)
        ab_wavs.write24(os.path.join(outdir, "half_%s.wav" % safe), b, rate, g)
        d = 20.0 * np.log10(max(rb, 1e-30) / max(ra, 1e-30))
        print("  %-26s %10.5f %10.5f %+8.3f" % (tag, ra, rb, d))
        n += 1

    print("\n%d scenario(s) -> %s" % (n, outdir))
    print("flags under test: %s" % " ".join(extra))
    print("\nNOT A GATE. ref = full-rate fork (sonic-gated today); half = the")
    print("candidate for the user's ear at F2.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
