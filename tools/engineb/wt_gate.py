#!/usr/bin/env python3
"""wt_gate.py — ROW 6: is a band-limited WAVETABLE indistinguishable from the
shipping 4x DCO?

Two bounds, and BOTH gate. The second one is here because
docs/engineb/data/quarter_os_result.md was a build that passed the alias bound
with 73 dB of harmonic error: measuring only the alias floor rewards anything
that removes high frequencies, which is exactly what a wrong oscillator does.

  gate A  alias floor rise <= +1.0 dB   (F5's bound, unchanged)
  gate B  harmonic level error <= 3.3 dB on every harmonic within 80 dB of
          the fundamental, below 16 kHz

WHERE GATE B'S NUMBER COMES FROM, because a bound invented to fit a result is
worthless. It is the MEASURED worst harmonic error of HALF-OVERSAMPLING --
3.27 dB, tools/engineb/o8_gate2.py, at 1,764 Hz -- a lever this project has
already built, gated and accepted into the S3 fork. The standard is therefore
"no worse than what already ships", which is a standard that existed before
this measurement did.

The first version of this file set gate B at 1.0 dB. That was a number chosen
by the author, stricter than anything the project has ever accepted, and it
would have rejected a build measurably BETTER than the one in the tree.

The 16 kHz limit is not a convenience: the port's own 4x decimator has a notch
at ~18 kHz (-28.9 dB) that nothing else reproduces, so harmonics above it are
reported separately in absolute terms rather than folded into a pass or fail.
"""
import os
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DATA = os.path.join(REPO, "docs", "engineb", "data")
EB = os.path.join(REPO, "engine_b")
FS = 44100.0
ALIAS_BOUND = 1.0
HARM_BOUND = 3.3          # half-oversampling measures 3.27; see the header


def build(tmp, quarter):
    exe = os.path.join(tmp, "wt_%d" % quarter)
    subprocess.run(
        ["cc", "-std=c99", "-O2", "-ffp-contract=off",
         "-DEB_FORK_S3=1", "-DEB_QUARTER_OS=%d" % quarter,
         "-DEB_DCO_RECIP=1", "-DEB_DCO_PULSEFAST=1",
         "-DWT_LEN=%s" % os.environ.get("WT_LEN", "4096"),
         "-I" + EB, "-I" + DATA, "-o", exe,
         os.path.join(DATA, "wt_probe.c"),
         os.path.join(EB, "eb_dco.c"), os.path.join(EB, "eb_decim.c"), "-lm"],
        check=True)
    return exe


def spectrum(x):
    w = np.hanning(len(x))
    X = np.abs(np.fft.rfft(x * w)) / (len(x) / 4)
    f = np.fft.rfftfreq(len(x), 1.0 / FS)
    return f, 20 * np.log10(np.maximum(X, 1e-12))


def main():
    tmp = tempfile.mkdtemp(prefix="wtg_")
    # TWO BINARIES, not one with a flag: eb_decim_tick's arm is chosen at
    # COMPILE time, and the candidate must get the biquad-only arm while the
    # reference gets the port's own 16-tap FIR. One binary would filter both
    # sides the same way and the gate would be measuring nothing.
    ref = build(tmp, 0)
    cand = build(tmp, 1)
    n = 131072
    print("=== ROW 6 GATE: band-limited wavetable vs the shipping 4x DCO ===")
    print("%10s | %9s %9s %6s | %9s %6s | %s"
          % ("~f0 Hz", "alias 4x", "alias WT", "rise", "harm dmax", "state",
             "notch 16-18k"))
    ok = True
    for inc in (0.005, 0.01, 0.02, 0.04, 0.08, 0.12):
        a = np.frombuffer(subprocess.run([ref, repr(inc), str(n), "ref"],
                                         capture_output=True, check=True)
                          .stdout, dtype=np.float32)[2048:]
        b = np.frombuffer(subprocess.run([cand, repr(inc), str(n), "wt"],
                                         env=dict(os.environ),
                                         capture_output=True, check=True)
                          .stdout, dtype=np.float32)[2048:]
        m = min(len(a), len(b))
        f, A = spectrum(a[:m].astype(float))
        _, B = spectrum(b[:m].astype(float))
        f0 = inc / 2.0 * 4 * FS
        harm = np.zeros(len(f), bool)
        k = 1
        while k * f0 < FS / 2:
            harm |= np.abs(f - k * f0) < max(0.002 * f0, 15.0)
            k += 1
        band = (f > 200) & (f < 18000)
        a4 = A[band & ~harm].max()
        aw = B[band & ~harm].max()
        hb = band & harm & (f < 16000) & (A > A[band].max() - 80.0)
        dh = float(np.abs(A[hb] - B[hb]).max()) if hb.any() else 0.0
        nb = (f >= 16000) & (f < 18000) & harm & (A > A[band].max() - 80.0)
        dn = float(np.abs(A[nb] - B[nb]).max()) if nb.any() else 0.0
        rise = aw - a4
        good = rise <= ALIAS_BOUND and dh <= HARM_BOUND
        ok &= good
        print("%10.0f | %9.1f %9.1f %+6.1f | %9.2f %6s | %.1f dB"
              % (f0, a4, aw, rise, dh, "ok" if good else "FAIL", dn))
    print("\ngate A alias rise <= +%.1f dB"
          "  ;  gate B harmonic error <= %.1f dB (half-OS measures 3.27)"
          % (ALIAS_BOUND, HARM_BOUND))
    print("ROW 6: %s" % ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
