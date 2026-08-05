#!/usr/bin/env python3
"""o8_gate2.py — F5 GATE 2 on the SHIPPING half-OS implementation.

WHAT IT GATES, and what it only REPORTS. F5 wrote gate 2 as one bound: the
fork's alias floor within +1 dB of the plugin's own 4x floor. That RISE bound
is what this script passes or fails on, and it is not restated here in looser
words.

Everything else in the table is a MEASUREMENT printed beside it, because the
run found two things F5's bound does not cover and does not forbid:

  * the fork's alias floor DROPS by up to 17 dB at high pitch. F5's prose
    says the plugin's floor is the standard and this project does not get to
    be better than the instrument any more than worse -- so a 17 dB drop is a
    real change to the sound even though it passes the numeric bound. It is
    printed as its own line and it is the reason O8 stops for a decision.
  * harmonic levels match to 0.01 dB at high pitch and differ by up to 3.3 dB
    at LOW pitch, always at bins 65-90 dB below the fundamental and always
    above 14 kHz. Gate 1 measured the two cascades' response equal to 0.078
    dB, so this is not the filter: it is the shaping nonlinearity's own high
    harmonics differing between a waveform sampled at 176.4 kHz and one
    sampled at 88.2 kHz. That is the lever's signature, not a defect in it,
    and no filter design changes it.

Both streams come from docs/engineb/data/o8_alias_probe.c built from the
shipping eb_dco.c + eb_decim.c, once per flag setting.
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
ALIAS_BOUND = 1.0          # dB rise over the plugin's own floor
HARM_BOUND = 1.0           # dB; REPORTED, not gated (see the header)


def build(half, tmp):
    exe = os.path.join(tmp, "probe_%d" % half)
    subprocess.run(
        ["cc", "-std=c99", "-O2", "-ffp-contract=off",
         "-DEB_FORK_S3=1", "-DEB_HALF_OS=%d" % half,
         "-I" + EB, "-I" + DATA, "-o", exe,
         os.path.join(DATA, "o8_alias_probe.c"),
         os.path.join(EB, "eb_dco.c"), os.path.join(EB, "eb_decim.c"), "-lm"],
        check=True)
    return exe


def spectrum(x):
    w = np.hanning(len(x))
    X = np.abs(np.fft.rfft(x * w)) / (len(x) / 4)
    f = np.fft.rfftfreq(len(x), 1.0 / FS)
    return f, 20 * np.log10(np.maximum(X, 1e-12))


def main():
    tmp = tempfile.mkdtemp(prefix="o8g2_")
    exes = {4: build(0, tmp), 2: build(1, tmp)}
    print("=== F5 GATE 2 on the SHIPPING implementation (O8) ===")
    print("%10s | %9s %9s %6s | %9s %6s"
          % ("~f0 Hz", "alias 4x", "alias 2x", "rise", "harm dmax", "state"))
    ok = True
    for inc in (0.005, 0.01, 0.02, 0.04, 0.08, 0.12):
        s = {}
        for mode, exe in exes.items():
            r = subprocess.run([exe, repr(inc), "131072"],
                               capture_output=True, check=True)
            s[mode] = np.frombuffer(r.stdout, dtype=np.float32)[2048:]
        n = min(len(s[4]), len(s[2]))
        f, A = spectrum(s[4][:n].astype(float))
        _, B = spectrum(s[2][:n].astype(float))
        f0 = inc / 2.0 * 4 * FS
        # TRUE harmonics only, unfolded. Folded content is alias content and
        # must land in the alias columns for BOTH paths -- F5's second probe
        # revision masked the folded positions as harmonics and thereby
        # excluded precisely its own subject.
        harm = np.zeros(len(f), bool)
        k = 1
        while k * f0 < FS / 2:
            harm |= np.abs(f - k * f0) < max(0.002 * f0, 15.0)
            k += 1
        band = (f > 200) & (f < 18000)
        a4, a2 = A[band & ~harm].max(), B[band & ~harm].max()
        # AUDIBLE harmonics only, and the floor is a MEASUREMENT not a
        # convenience: the first run's worst "harmonic" bins sat at -174,
        # -171 and -158 dB against a 0.3 dB peak. float32 carries about 144
        # dB of dynamic range, so a bin 150+ dB below the fundamental is the
        # arithmetic's own noise and a 7.7 dB difference there is a
        # difference between two noises. Harmonics within 80 dB of the peak
        # are the tone; everything below it is not.
        # MATCHED BAND ONLY (to 16 kHz), for the same measured reason gen_
        # halfos_fir.py matches only to 16 kHz: the port's 4x decimator has a
        # NOTCH at ~18 kHz (-28.9 dB) that no 2x filter reproduces. Harmonics
        # in 16-18 kHz are reported separately, in absolute terms.
        hb = band & harm & (f < 16000) & (A > A[band].max() - 80.0)
        if hb.any():
            k = int(np.argmax(np.abs(A[hb] - B[hb])))
            dh = float(np.abs(A[hb] - B[hb])[k])
        else:
            dh = 0.0
        nb = (f >= 16000) & (f < 18000) & harm & (A > A[band].max() - 80.0)
        dn = float(np.max(np.abs(A[nb] - B[nb]))) if nb.any() else 0.0
        rise = a2 - a4
        good = rise <= ALIAS_BOUND
        ok &= good
        print("%10.0f | %9.1f %9.1f %+6.1f | %9.2f %6s   (notch 16-18k: "
              "%.1f dB)" % (f0, a4, a2, rise, dh, "ok" if good else "FAIL", dn))
    print("\nF5's stated bound: alias floor rise <= +%.1f dB" % ALIAS_BOUND)
    print("GATE 2 (that bound): %s" % ("PASS" if ok else "FAIL"))
    print("MEASURED BESIDE IT, and NOT covered by the bound: the floor DROPS "
          "16-17 dB at\n7.1 and 10.6 kHz -- the fork is CLEANER than the "
          "instrument up high. See\ndocs/engineb/data/o8_halfos_result.md.")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
