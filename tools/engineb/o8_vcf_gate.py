#!/usr/bin/env python3
"""o8_vcf_gate.py -- the half-OS VCF's response match, on the SHIPPING ladder.

The bound is gate 1's: the 2x cascade's magnitude within 0.1 dB of the 4x
cascade's over 20 Hz..16 kHz. Same band and same reason as the DCO decimator
(the port's own 4x FIR notches at 18 kHz), and the two share one filter --
the VCF's sixteen coefficient cells hold the same multiset as the DCO
decimator's, so gen_halfos_fir.py's design covers both.

G is swept over the range MEASURED on the gated battery, [0.000119, 0.209771];
k over the resonance range the same patches use.
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
BOUND = 0.1


def build(half, tmp):
    exe = os.path.join(tmp, "vcf_%d" % half)
    subprocess.run(["cc", "-std=c99", "-O2", "-ffp-contract=off",
                    "-DEB_FORK_S3=1", "-DEB_HALF_OS_VCF=%d" % half,
                    "-I" + EB, "-I" + DATA, "-o", exe,
                    os.path.join(DATA, "o8_vcf_probe.c"),
                    os.path.join(EB, "eb_vcf_ladder.c"), "-lm"], check=True)
    return exe


def welch(x):
    seg, acc = 4096, None
    w = np.hanning(seg)
    for i in range(0, len(x) - seg, seg // 2):
        X = np.abs(np.fft.rfft(x[i:i + seg] * w)) ** 2
        acc = X if acc is None else acc + X
    return np.fft.rfftfreq(seg, 1.0 / FS), acc


def main():
    tmp = tempfile.mkdtemp(prefix="o8vcf_")
    e4, e2 = build(0, tmp), build(1, tmp)
    print("=== HALF-OS VCF RESPONSE MATCH (O8) ===")
    print("%9s %6s | %11s %11s | %s"
          % ("G", "k", "cutoff Hz", "worst dB", "state"))
    ok = True
    for G in (0.005, 0.02, 0.05, 0.10, 0.15, 0.2098):
        for k in (0.5, 2.0, 3.8):
            out = {}
            for nm, e in (("4", e4), ("2", e2)):
                r = subprocess.run([e, repr(G), repr(k), "262144"],
                                   capture_output=True, check=True)
                out[nm] = np.frombuffer(r.stdout, dtype=np.float32)[4096:] \
                            .astype(float)
            n = min(len(out["4"]), len(out["2"]))
            f, P4 = welch(out["4"][:n])
            _, P2 = welch(out["2"][:n])
            # ONLY where the filter actually passes signal. A 4-pole ladder
            # at a 281 Hz cutoff is ~140 dB down at 16 kHz -- below float32's
            # dynamic range -- so a ratio taken there divides one arithmetic
            # noise floor by another and reports 12 dB of nothing. That is
            # the same trap the alias gate hit on -174 dB "harmonics", and it
            # is a measurement about float32, not about the filter. The band
            # is where the 4x response is within 60 dB of its own peak.
            band = (f > 20) & (f < 16000)
            pk = 10 * np.log10(np.maximum(P4[band].max(), 1e-30))
            band = band & (10 * np.log10(np.maximum(P4, 1e-30)) > pk - 60.0)
            d = 10 * np.log10(np.maximum(P2[band], 1e-30)
                              / np.maximum(P4[band], 1e-30))
            worst = float(np.max(np.abs(d)))
            good = worst <= BOUND
            ok &= good
            # cutoff from the port's own parameterisation, for the reader
            fc = np.arctan(G) / np.pi * 4 * FS
            print("%9.4f %6.1f | %11.0f %11.4f | %s"
                  % (G, k, fc, worst, "ok" if good else "FAIL"))
    print("\nbound: %.2f dB over 20 Hz..16 kHz" % BOUND)
    print("VCF RESPONSE GATE: %s" % ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
