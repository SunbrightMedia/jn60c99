#!/usr/bin/env python3
"""ab_wavs.py -- RENDER THE TRUNK AND THE SHIPPING FORK TO WAVs, FOR THE EAR.

WHY THIS EXISTS. FINAL_GUIDE track A4 is the last open item in track A, and it
is the one thing no gate can close: whether the fork sounds the same to the
user. `sonic_gate.py` measures the two properties that BEAR on audibility --
third-octave level match and the alias floor -- and its own header says it
cannot prove inaudibility. Only listening can, and the project forbids
validating BY ear. So the division is:

    the gates decide whether the fork is CORRECT;
    the user decides whether it is ACCEPTABLE.

This tool exists to make the second question askable. It is not a gate, it
returns no verdict, and nothing may be tuned from what anyone hears.

WHAT IT RENDERS.

  trunk_<tag>.wav   engine B at TRUNK flags. The trunk is BIT-EXACT to the
                    plugin (null gate, residual EXACTLY 0, all 64 patches), so
                    this file IS the plugin's own sound.
  fork_<tag>.wav    the SAME scenario at the SHIPPING FORK's flags -- the exact
                    set esp32s3/main/CMakeLists.txt and the M1 build pass, not
                    a convenient subset. That matters: `lastmile_run.sh`'s BASE
                    omits EB_NOLIBM, EB_VCF_MAPFAST, EB_FPDIV and all five
                    control-rate flags, so a comparison built on it would be of
                    a fork nobody ships.

BOTH FILES ARE SCALED BY THE SAME GAIN, taken from the trunk's peak. A level
difference between the two is a real difference and must stay audible; a
per-file normalise would hide exactly the defect most worth hearing.

24-bit, because the point is to hear the FORK's error and 16-bit truncation
sits at -72.5 dB -- which is above some of what is being compared.
"""
import os
import sys
import wave
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

# THE SHIPPING FORK'S FLAGS, verbatim.
#   esp32s3/main/CMakeLists.txt target_compile_options: EB_FORK_S3,
#     EB_LFO_SHARED=1, EB_VCF_RES_LUT=256
#   the M1 build's S3_EXTRA_DEFS: everything else
# EB_LFO_FREERUN is NOT listed because eb_fork_config.h defaults it to
# EB_LFO_SHARED; setting it here would be a second source of truth.
SHIP = [
    "-DEB_FORK_S3", "-DEB_LFO_SHARED=1", "-DEB_VCF_RES_LUT=256",
    "-DEB_DCO_WT=1", "-DEB_VCF_DEADCOEF=1", "-DEB_ATREST_BLOCK=1",
    "-DEB_ATREST_O1=1", "-DEB_ZEROCOEF=1", "-DEB_EXP_MEMO=1",
    "-DEB_HALF_OS_VCF=1", "-DEB_NOLIBM=1", "-DEB_VCF_MAPFAST=1",
    "-DEB_FPDIV=1", "-DEB_CR_PITCH=1", "-DEB_CR_MODCV=1", "-DEB_CR_VCFCV=1",
    "-DEB_CR_ENV=1", "-DEB_CR_N=4", "-DEB_CR_NP=4", "-DEB_CR_NC=2",
    "-DEB_CR_NE=2", "-DEB_ENV_CR=2",
]


def write24(path, x, rate, gain):
    """24-bit STEREO WAV. `x` is the engine's INTERLEAVED stereo stream
    (L,R,L,R...), exactly as render_script returns it; this is written as a
    2-channel file. Writing it as mono (the original bug) played every clip at
    2x speed, an octave high, with a Nyquist buzz from the alternating channels.
    `gain` is supplied by the caller and is the SAME for both sides on purpose --
    see the header."""
    x = np.asarray(x)
    nch = 2 if (x.size % 2 == 0) else 1
    y = np.clip(x * gain, -1.0, 1.0)
    q = np.round(y * 8388607.0).astype(np.int32)
    b = bytearray()
    for v in q:
        v = int(v) & 0xFFFFFF
        b += bytes((v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF))
    with wave.open(path, "wb") as w:
        w.setnchannels(nch)
        w.setsampwidth(3)
        w.setframerate(int(rate))
        w.writeframes(bytes(b))


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
    outdir = os.path.join(REPO, "scratchpad", "ab_wavs")
    if "--out" in sys.argv:
        outdir = sys.argv[sys.argv.index("--out") + 1]
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    os.makedirs(outdir, exist_ok=True)
    null_b.SR = rate

    tmp = tempfile.mkdtemp(prefix="abwav_")
    print("building trunk ...")
    ref = null_b.render_side(build(tmp, "trunk", []), False, tmp, "trunk")
    print("building shipping fork ...")
    print("  flags: %s" % " ".join(SHIP))
    cand = null_b.render_side(build(tmp, "fork", SHIP), False, tmp, "fork")

    print("\n%-28s %10s %10s %8s" % ("scenario", "trunk rms", "fork rms", "d dB"))
    n_written = 0
    for _, _, tag in null_b.scenarios(False):
        if only and only not in tag:
            continue
        a = np.asarray(ref["streams"][tag], dtype=np.float64)
        b = np.asarray(cand["streams"][tag], dtype=np.float64)
        n = min(len(a), len(b))
        a, b = a[:n], b[:n]
        ra = float(np.sqrt(np.mean(a * a)))
        if ra < 1e-6:
            print("  %-26s silent, skipped" % tag)
            continue
        rb = float(np.sqrt(np.mean(b * b)))
        pk = float(np.max(np.abs(a)))
        # -1 dBFS on the TRUNK, and the fork gets the identical gain.
        g = (0.891 / pk) if pk > 1e-9 else 1.0
        safe = "".join(c if c.isalnum() else "_" for c in tag)
        write24(os.path.join(outdir, "trunk_%s.wav" % safe), a, rate, g)
        write24(os.path.join(outdir, "fork_%s.wav" % safe), b, rate, g)
        d = 20.0 * np.log10(max(rb, 1e-30) / max(ra, 1e-30))
        print("  %-26s %10.5f %10.5f %+8.3f" % (tag, ra, rb, d))
        n_written += 1

    print("\n%d scenario(s) -> %s" % (n_written, outdir))
    print("\nTHIS IS NOT A GATE. No verdict is returned and nothing may be")
    print("tuned from what is heard. The trunk file is the plugin's own sound")
    print("(bit-exact, 64/64); the fork file is what the ESP32-S3 runs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
