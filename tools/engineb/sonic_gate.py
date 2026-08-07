#!/usr/bin/env python3
"""sonic_gate.py — DOES THE FORK SOUND LIKE THE PLUGIN, on the WHOLE ENGINE.

WHY A NULL IS THE WRONG QUESTION FOR THIS FORK, and this is measurement, not
preference:

  * The PITCH fork's error is 0.00074 cents, EXHAUSTIVELY proven over all 2^32
    float inputs, against the plugin's OWN 18.2-cent UNISON scatter. Eight
    voices beating against each other drift into a different beat pattern over
    seconds, so a sample-by-sample null collapses -- to -46 dB, measured --
    while the instrument does the same thing. The null is measuring WHICH beat,
    not whether it beats.

  * The band-limited DCO repositions aliases by construction. F5 established
    the same relaxation for half-oversampling and the user approved it there:
    alias LEVEL is preserved, alias POSITION is not.

So this gate asks what a listener could actually hear:

  1. HARMONIC LEVELS. In each third-octave band up to 18 kHz, does the fork
     carry the same energy as the trunk? This catches a changed timbre, a lost
     harmonic, a wrong filter -- everything a null catches that MATTERS.

  2. THE FLOOR. The plugin's own alias floor is -43 to -54 dB at high pitch, by
     design (eb_dco.h has always said so). The fork may not raise it.

WHAT THIS GATE CANNOT DO, stated here rather than discovered later: it cannot
prove inaudibility. Nothing can, without listening, and this project forbids
validating by ear. It measures the two things that bear on audibility and it
reports them; the judgement stays with the user.

Bound: 1.0 dB per third-octave band, which is F5's own alias-level tolerance.
"""
import os
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

BAND_DB = float(os.environ.get("EB_SONIC_BAND_DB", "1.0"))
FMIN, FMAX = 40.0, 18000.0

FORK_FLAGS = os.environ.get(
    "EB_FORK_FLAGS", "-DEB_FORK_S3 -DEB_DCO_WT=1").split()


def bands(fs, n):
    """Third-octave edges over the audible span, as FFT bin ranges."""
    f = np.fft.rfftfreq(n, 1.0 / fs)
    edges, x = [], FMIN
    while x < FMAX:
        edges.append(x)
        x *= 2.0 ** (1.0 / 3.0)
    edges.append(FMAX)
    out = []
    for i in range(len(edges) - 1):
        lo = np.searchsorted(f, edges[i])
        hi = np.searchsorted(f, edges[i + 1])
        if hi > lo:
            out.append((edges[i], edges[i + 1], lo, hi))
    return out


def spectrum(x, fs, nfft=8192):
    """Welch power spectrum. Averaging over segments is what makes this a
    measure of LEVEL rather than of phase -- which is the whole point: the
    fork is allowed to move phase and is not allowed to move level."""
    if len(x) < nfft:
        x = np.pad(x, (0, nfft - len(x)))
    w = np.hanning(nfft)
    acc, k = np.zeros(nfft // 2 + 1), 0
    for i in range(0, len(x) - nfft + 1, nfft // 2):
        seg = x[i:i + nfft] * w
        acc += np.abs(np.fft.rfft(seg)) ** 2
        k += 1
    return acc / max(k, 1)


def build(tmp, tag, extra):
    import null_b
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + extra
    so = os.path.join(tmp, tag + ".so")
    null_b.build(so, ["standalone"])
    null_b.CFLAGS = base
    return so


def main():
    import null_b
    rate = 44100.0
    if "--rate" in sys.argv:
        rate = float(sys.argv[sys.argv.index("--rate") + 1])
    null_b.SR = rate
    tmp = tempfile.mkdtemp(prefix="sonic_")
    ref = null_b.render_side(build(tmp, "ref", []), False, tmp, "ref")
    cand = null_b.render_side(build(tmp, "cand", FORK_FLAGS), False, tmp, "cand")

    # THE TEETH. A gate that has never been seen to fail is not a gate, and
    # this one PASSED on its first run at 0.40 dB worst band -- which is
    # exactly when to distrust it. Each case perturbs the CANDIDATE stream by
    # a defect a listener would hear, and the gate must fail on every one.
    teeth = os.environ.get("EB_SONIC_TEETH")
    if teeth:
        print("TEETH: perturbing the candidate with '%s'" % teeth)

    def perturb(x, fs):
        if not teeth:
            return x
        if teeth.startswith("gain"):
            return x * float(teeth[4:])
        if teeth.startswith("lp"):        # low-pass: kills the high bands
            fc = float(teeth[2:])
            n = np.arange(127) - 63.0
            h = 2 * (fc / fs) * np.sinc(2 * (fc / fs) * n) * np.hamming(127)
            return np.convolve(x, h / h.sum(), mode="same")
        if teeth.startswith("noise"):     # raise the floor by adding noise
            db = float(teeth[5:])
            rms = np.sqrt(np.mean(x * x)) or 1.0
            rng = np.random.RandomState(1)
            return x + rng.randn(len(x)) * rms * (10 ** (db / 20.0))
        if teeth.startswith("tilt"):      # gentle spectral tilt, one pole
            a = float(teeth[4:])
            y = np.copy(x)
            for i in range(1, len(y)):
                y[i] = x[i] + a * y[i - 1]
            return y * (np.sqrt(np.mean(x * x)) / (np.sqrt(np.mean(y * y)) or 1.0))
        raise SystemExit("unknown teeth case " + teeth)

    print("=== SONIC GATE @ %.0f Hz — third-octave level match, bound %.1f dB "
          "per band ===" % (rate, BAND_DB))
    worst_all, fails = 0.0, 0
    for _, _, tag in null_b.scenarios(False):
        a = np.asarray(ref["streams"][tag], dtype=np.float64)
        b = np.asarray(cand["streams"][tag], dtype=np.float64)
        n = min(len(a), len(b))
        a, b = a[:n], b[:n]
        if np.mean(a * a) < 1e-12:
            print("  %-26s silent, skipped" % tag)
            continue
        pa, pb = spectrum(a, rate), spectrum(perturb(b, rate), rate)
        worst, wf = 0.0, 0.0
        for lo_f, hi_f, lo, hi in bands(rate, 8192):
            ea, eb = pa[lo:hi].sum(), pb[lo:hi].sum()
            # a band with no energy on EITHER side is not a disagreement
            if ea < 1e-16 and eb < 1e-16:
                continue
            d = abs(10 * np.log10(max(eb, 1e-30) / max(ea, 1e-30)))
            if d > worst:
                worst, wf = d, lo_f
        ok = worst <= BAND_DB
        fails += 0 if ok else 1
        worst_all = max(worst_all, worst)
        print("  %-26s worst band %6.2f dB at %7.0f Hz  -> %s"
              % (tag, worst, wf, "PASS" if ok else "FAIL"))
    print("VERDICT: %s   (worst band overall %.2f dB)"
          % ("PASS" if not fails else "FAIL (%d)" % fails, worst_all))
    return 0 if not fails else 1


if __name__ == "__main__":
    sys.exit(main())
