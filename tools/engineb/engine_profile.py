#!/usr/bin/env python3
"""engine_profile.py -- WHERE EVERY INSTRUCTION GOES, for the S3 fork.

engine_price.py gives the MODULE total. This drills inside: for every module
on the per-sample path it lists each function the compiler emitted, its static
Xtensa size, and -- where a call rate has been MEASURED (the DCO's arms) --
the executed cost rather than the body size.

It exists because "the DCO is 31 %" is not actionable and "p_pulse is 45 % of
the DCO and runs every step" is. The engine has never been profiled below
module granularity, and the two facts that fell out of doing it are that the
pulse block costs 5x the saw block and that eb_triangle_wrap -- a fixed
one-variable nonlinearity, tabulatable -- is 53 instructions inside it.
"""
import os, re, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if not os.path.isdir(os.path.join(REPO, "engine_b")):
    REPO = "/home/user/jn60c99"
GCC = ("/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/"
       "xtensa-esp-elf/bin/xtensa-esp32s3-elf-gcc")
OD = GCC[:-3] + "objdump"
CF = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
      "-mlongcalls", "-DEB_FORK_S3", "-DEB_LFO_SHARED=1", "-DEB_PITCH_FAST=1",
      "-DEB_DCO_RECIP=1", "-I" + os.path.join(REPO, "engine_b"),
      "-I" + os.path.join(REPO, "src")]

# module -> calls per audio sample at 6 voices
CALLS = {
    "eb_dco": 24, "eb_vcf_res": 6, "eb_vcf_ladder": 6, "eb_vcf_cv": 6,
    "eb_vca_hpf": 6, "eb_glide": 6, "eb_envgen": 12, "eb_decim": 6,
    "eb_dcoprep": 6, "eb_pwm_cv": 6, "eb_cvgate": 6, "eb_noise_svf": 6,
    "eb_pitch_fork": 6, "eb_lfo": 1, "eb_notecv": 1, "eb_noisemix": 6,
    "eb_master_in": 1, "eb_master_out": 1, "eb_chorus": 1, "eb_delay": 1,
    "eb_reverb": 1, "eb_dsp": 0,
}

def funcs(src):
    o = "/tmp/prof_%s.o" % os.path.basename(src)[:-2]
    r = subprocess.run([GCC] + CF + ["-c", src, "-o", o],
                       capture_output=True, text=True)
    if r.returncode:
        return None
    d = subprocess.run([OD, "-d", o], capture_output=True, text=True).stdout
    out, cur = {}, None
    for line in d.split("\n"):
        m = re.match(r"^[0-9a-f]+ <(\w+)>:", line)
        if m:
            cur = m.group(1); out[cur] = 0
        elif cur and re.match(r"^\s+[0-9a-f]+:", line):
            out[cur] += 1
    return out

def main():
    rows = []
    for f in sorted(os.listdir(os.path.join(REPO, "engine_b"))):
        if not f.startswith("eb_") or not f.endswith(".c"):
            continue
        mod = f[:-2]
        fs = funcs(os.path.join(REPO, "engine_b", f))
        if not fs:
            continue
        tot = sum(fs.values())
        rows.append((mod, tot, CALLS.get(mod, 0), fs))

    print("=== ENGINE B PROFILE -- static Xtensa, S3 fork, 6 voices ===")
    print("%-16s %7s %6s %10s   biggest functions inside"
          % ("module", "bytes*", "calls", "per sample"))
    print("  (*sum of all function bodies in the TU, not the entry alone)\n")
    grand = 0
    for mod, tot, calls, fs in sorted(rows, key=lambda r: -r[1] * max(r[2], 0)):
        per = tot * calls
        grand += per
        if calls == 0 and tot < 60:
            continue
        big = sorted(fs.items(), key=lambda kv: -kv[1])[:3]
        big = "  ".join("%s:%d" % (k.replace("eb_", ""), v) for k, v in big)
        print("%-16s %7d %6d %10d   %s" % (mod[3:], tot, calls, per, big))
    print("\nNOTE: this is a STATIC upper bound per call -- every arm counted.")
    print("The DCO's real cost uses MEASURED branch rates (dco_price.py):")
    print("  p_pulse 165 / p_fixed 87 / p_sub 50 / p_saw 31 = 363 per step")
    print("  x4 substeps x 6 voices = 8,712 ... the largest line in the engine")
    return 0

if __name__ == "__main__":
    sys.exit(main())
