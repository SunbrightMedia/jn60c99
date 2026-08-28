#!/usr/bin/env python3
"""ladder3.py -- 3-way ladder for the ear: PLUGIN vs FULL-rate fork vs HALF-rate.

trunk_<tag>.wav = engine B, no flags = BIT-EXACT to the .vst3 (null 0, 64/64).
fork_<tag>.wav  = the shipping fork, full-rate FX.
half_<tag>.wav  = the shipping fork + EB_REVERB_HALF.
ALL THREE at the SAME gain (trunk peak), so any difference heard is real.
"""
import os, sys, tempfile
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
import ab_wavs

TAGS = sys.argv[1:] or ["chorus pad", "DCO neg pitch sweep"]


def main():
    rate = 44100.0
    outdir = os.path.join(REPO, "scratchpad", "ladder3")
    os.makedirs(outdir, exist_ok=True)
    import null_b
    null_b.SR = rate
    tmp = tempfile.mkdtemp(prefix="ladder3_")
    print("trunk (plugin bit-exact) ...")
    trunk = null_b.render_side(ab_wavs.build(tmp, "trunk", []), False, tmp, "trunk")
    print("fork (full-rate) ...")
    fork = null_b.render_side(ab_wavs.build(tmp, "fork", ab_wavs.SHIP), False, tmp, "fork")
    print("half (reverb half-rate) ...")
    half = null_b.render_side(ab_wavs.build(tmp, "half", ab_wavs.SHIP + ["-DEB_REVERB_HALF=1"]),
                              False, tmp, "half")
    for _, _, tag in null_b.scenarios(False):
        if tag not in TAGS:
            continue
        a = np.asarray(trunk["streams"][tag], dtype=np.float64)
        f = np.asarray(fork["streams"][tag], dtype=np.float64)
        h = np.asarray(half["streams"][tag], dtype=np.float64)
        n = min(len(a), len(f), len(h)); a, f, h = a[:n], f[:n], h[:n]
        pk = max(float(np.max(np.abs(a))), 1e-9); g = 0.891 / pk
        safe = "".join(c if c.isalnum() else "_" for c in tag)
        ab_wavs.write24(os.path.join(outdir, "trunk_%s.wav" % safe), a, rate, g)
        ab_wavs.write24(os.path.join(outdir, "fork_%s.wav" % safe), f, rate, g)
        ab_wavs.write24(os.path.join(outdir, "half_%s.wav" % safe), h, rate, g)
        df = 20*np.log10(np.sqrt(np.mean(f*f))/np.sqrt(np.mean(a*a)+1e-30))
        dh = 20*np.log10(np.sqrt(np.mean(h*h))/np.sqrt(np.mean(a*a)+1e-30))
        print("  %-22s fork %+.3f dB   half %+.3f dB  (vs plugin)" % (tag, df, dh))
    print("-> %s" % outdir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
