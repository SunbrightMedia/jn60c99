#!/usr/bin/env python3
"""lastmile_wav.py — render the WORST scenarios of a fork build as WAVs, next
to the trunk and to the audible build the user already holds.

WHY THIS EXISTS. The sonic gate reports third-octave band energy, and band
energy is not audibility -- the gate's own header says so and says nothing can
prove audibility without listening. The charter's answer is that the judgement
stays with the user, so the gate's worst rows have to arrive as SOUND, not as
a number. This writes three files per scenario:

    <tag>_trunk.wav     the plugin's behaviour, EXACTLY 0 against the port
    <tag>_audible.wav   the build already on the user's board (3.17 dB)
    <tag>_lastmile.wav  the build under judgement

Same scenario, same rate, same length, so the three line up sample for sample
in any editor.

The scenarios chosen are the WORST rows of the candidate's own gate run, not
a pleasant demonstration: a listening test on the cases a build handles well
answers nothing.
"""
import os
import struct
import sys
import tempfile
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

AUDIBLE = ("-DEB_FORK_S3 -DEB_DCO_WT=1 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 "
           "-DEB_VCF_RES_LUT=256 -DEB_ATREST_O1=1 -DEB_ATREST_O1_MIN=1 "
           "-DEB_ZEROCOEF=1 -DEB_EXP_MEMO=1 -DEB_HALF_OS_VCF=1").split()


def build(tmp, tag, extra):
    import null_b
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + extra
    so = os.path.join(tmp, tag + ".so")
    null_b.build(so, ["standalone"])
    null_b.CFLAGS = base
    return so


def write_wav(path, x, rate):
    """16-bit mono. The scale is SHARED across the three files of a scenario --
    normalising each on its own would hide exactly the level differences the
    listener is being asked about."""
    y = np.clip(np.asarray(x, dtype=np.float64), -1.0, 1.0)
    d = (y * 32767.0).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(int(rate))
        w.writeframes(d.tobytes())


def main():
    import null_b
    rate = 44100.0
    null_b.SR = rate
    out = sys.argv[1] if len(sys.argv) > 1 else "/tmp/lastmile_wav"
    tags = os.environ.get("LM_TAGS", "idle noise 441|long LFO+tail|"
                          "DCO neg warm chorus|MONO retrigger").split("|")
    cand_flags = os.environ["LM_FLAGS"].split()
    os.makedirs(out, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix="lmwav_")

    sides = {}
    for name, flags in (("trunk", []), ("audible", AUDIBLE),
                        ("lastmile", AUDIBLE + cand_flags)):
        print("rendering %s ..." % name, flush=True)
        sides[name] = null_b.render_side(build(tmp, name, flags), False,
                                         tmp, name)["streams"]

    for tag in tags:
        if tag not in sides["trunk"]:
            print("  %-24s NOT A SCENARIO, skipped" % tag)
            continue
        n = min(len(sides[s][tag]) for s in sides)
        peak = max(float(np.max(np.abs(np.asarray(sides[s][tag][:n]))))
                   for s in sides) or 1.0
        g = 0.891 / peak                 # -1 dBFS on the loudest of the three
        for s in sides:
            f = os.path.join(out, "%s_%s.wav"
                             % (tag.replace(" ", "_"), s))
            write_wav(f, np.asarray(sides[s][tag][:n]) * g, rate)
        print("  %-24s %6.2f s, common gain %.3f" % (tag, n / rate, g))
    print("\nwrote %s" % out)


if __name__ == "__main__":
    main()
