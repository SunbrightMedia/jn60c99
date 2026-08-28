#!/usr/bin/env python3
"""halfrate_t5_ab.py -- A/B the DELAY-HEAVY (DELAY TYPE 5) patches 5/16/21/49.

These four patches are the headroom worst case (b20/b21) and the user's named
delay-heavy patches. They are NOT in the standard scenario battery, so this
tool adds a note-on/hold/release/tail scenario for each and renders full-rate
vs the half-rate flag(s) under test, exactly as halfrate_ab.py does.

  --rev   reverb half rate (default)   --dly (reserved)   --both
Files: ref_<patch>.wav / half_<patch>.wav, same gain on both. NOT A GATE.
"""
import os, sys, tempfile
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
import ab_wavs

# patch -> a musical note pair, chosen to ring the delay out
T5 = [
    (5,  "p05_snowbell", [('render', 2000), ('on', 60, 100), ('on', 64, 100),
                          ('render', 30000), ('off', 60), ('off', 64),
                          ('render', 20000)]),
    (16, "p16",          [('render', 2000), ('on', 48, 100), ('on', 55, 100),
                          ('render', 30000), ('off', 48), ('off', 55),
                          ('render', 20000)]),
    (21, "p21",          [('render', 2000), ('on', 52, 100), ('on', 59, 100),
                          ('render', 30000), ('off', 52), ('off', 59),
                          ('render', 20000)]),
    (49, "p49",          [('render', 2000), ('on', 57, 100), ('on', 60, 100),
                          ('render', 30000), ('off', 57), ('off', 60),
                          ('render', 20000)]),
]


def main():
    rate = 44100.0
    extra = ["-DEB_REVERB_HALF=1"]
    if "--both" in sys.argv:
        extra = ["-DEB_REVERB_HALF=1", "-DEB_DELAY_HALF=1"]
    elif "--dly" in sys.argv:
        extra = ["-DEB_DELAY_HALF=1"]
    outdir = os.path.join(REPO, "scratchpad", "halfrate_ab")
    os.makedirs(outdir, exist_ok=True)

    import null_b
    null_b.SR = rate
    # append the four type-5 scenarios to the battery
    null_b.BASE_SCEN = list(null_b.BASE_SCEN) + [(p, ev, tag) for p, tag, ev in T5]
    tmp = tempfile.mkdtemp(prefix="t5ab_")

    print("building reference (full-rate fork) ...")
    ref = null_b.render_side(ab_wavs.build(tmp, "ref", ab_wavs.SHIP), False, tmp, "ref")
    print("building half fork: %s" % " ".join(extra))
    cand = null_b.render_side(ab_wavs.build(tmp, "half", ab_wavs.SHIP + extra), False, tmp, "half")

    print("\n%-16s %10s %10s %8s" % ("patch", "ref rms", "half rms", "d dB"))
    for p, tag, ev in T5:
        a = np.asarray(ref["streams"][tag], dtype=np.float64)
        b = np.asarray(cand["streams"][tag], dtype=np.float64)
        n = min(len(a), len(b)); a, b = a[:n], b[:n]
        ra = float(np.sqrt(np.mean(a * a))); rb = float(np.sqrt(np.mean(b * b)))
        pk = float(np.max(np.abs(a))); g = (0.891 / pk) if pk > 1e-9 else 1.0
        ab_wavs.write24(os.path.join(outdir, "ref_%s.wav" % tag), a, rate, g)
        ab_wavs.write24(os.path.join(outdir, "half_%s.wav" % tag), b, rate, g)
        d = 20.0 * np.log10(max(rb, 1e-30) / max(ra, 1e-30))
        print("  %-14s %10.5f %10.5f %+8.3f" % (tag, ra, rb, d))
    print("\n-> %s   flags: %s" % (outdir, " ".join(extra)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
