#!/usr/bin/env python3
"""ladder3.py -- 3-way ladder for the ear: PLUGIN vs FULL-rate fork vs HALF-rate.

trunk = engine B, no flags = BIT-EXACT to the .vst3 (null 0, 64/64).
fork  = the shipping fork, full-rate FX.
half  = the shipping fork + EB_REVERB_HALF.
ALL THREE at the SAME gain (trunk peak), so any difference heard is real, and
the output is proper 24-bit STEREO.

Each file is named  pNN_<factory name>_<layer>.wav  and the exact patch number
and its factory-bank name are printed. Notes are held LONG (default ~3.5 s) with
a long release tail, so the sustain and the reverb tail are both audible.

  usage: ladder3.py [patch:notes[:hold_s]] ...
         default: 20 (PD Saturate Pad) chord, and 2 (KY Delicate Keys) chord.
"""
import os, sys, tempfile
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import ab_wavs
import truth

HDR, STRIDE = 23, 20223


def patch_name(bank, p):
    off = HDR + p * STRIDE
    raw = bank[off:off + 24]
    return "".join(chr(b) if 32 <= b < 127 else "" for b in raw).strip()


# (patch, [notes], hold_seconds). Musical chords, long hold.
JOBS = [
    (20, [48, 55, 64], 3.5),      # PD Saturate Pad -- a three-note pad
    (2,  [50, 57, 62], 3.5),      # KY Delicate Keys -- a triad
]


def parse_args(bank):
    if len(sys.argv) <= 1:
        return JOBS
    out = []
    for a in sys.argv[1:]:
        parts = a.split(":")
        patch = int(parts[0])
        notes = [int(x) for x in parts[1].split(",")] if len(parts) > 1 and parts[1] else [60]
        hold = float(parts[2]) if len(parts) > 2 else 3.5
        out.append((patch, notes, hold))
    return out


def main():
    rate = 44100.0
    outdir = os.path.join(REPO, "scratchpad", "ladder3")
    os.makedirs(outdir, exist_ok=True)
    bank = open(truth.BANK, "rb").read()
    jobs = parse_args(bank)

    import null_b, null_ab
    null_b.SR = rate
    tmp = tempfile.mkdtemp(prefix="ladder3_")
    print("building trunk (plugin bit-exact) ...")
    lib_t = null_ab.load(ab_wavs.build(tmp, "trunk", []))
    print("building fork (full-rate) ...")
    lib_f = null_ab.load(ab_wavs.build(tmp, "fork", ab_wavs.SHIP))
    print("building half (reverb half-rate) ...")
    lib_h = null_ab.load(ab_wavs.build(tmp, "half", ab_wavs.SHIP + ["-DEB_REVERB_HALF=1"]))

    def render(lib, patch, notes, hold):
        nh = int(hold * rate)
        ev = [('on', n, 100) for n in notes] + [('render', nh)] \
             + [('off', n) for n in notes] + [('render', int(2.0 * rate))]
        return np.asarray(null_ab.render_script(lib, bank, rate, patch, ev),
                          dtype=np.float64)

    print()
    for patch, notes, hold in jobs:
        nm = patch_name(bank, patch)
        a = render(lib_t, patch, notes, hold)
        f = render(lib_f, patch, notes, hold)
        h = render(lib_h, patch, notes, hold)
        n = min(len(a), len(f), len(h)); a, f, h = a[:n], f[:n], h[:n]
        pk = max(float(np.max(np.abs(a))), 1e-9); g = 0.891 / pk
        safe = "".join(c if c.isalnum() else "_" for c in nm)
        stem = "p%02d_%s" % (patch, safe)
        ab_wavs.write24(os.path.join(outdir, "%s_trunk.wav" % stem), a, rate, g)
        ab_wavs.write24(os.path.join(outdir, "%s_fork.wav" % stem), f, rate, g)
        ab_wavs.write24(os.path.join(outdir, "%s_half.wav" % stem), h, rate, g)
        df = 20*np.log10(np.sqrt(np.mean(f*f))/np.sqrt(np.mean(a*a)+1e-30))
        dh = 20*np.log10(np.sqrt(np.mean(h*h))/np.sqrt(np.mean(a*a)+1e-30))
        print("patch %d = %r  notes %s  hold %.1f s" % (patch, nm, notes, hold))
        print("   fork %+.3f dB   half %+.3f dB  (rms vs plugin)   -> %s_*.wav" % (df, dh, stem))
    print("\n-> %s" % outdir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
