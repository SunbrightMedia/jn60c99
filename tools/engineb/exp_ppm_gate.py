#!/usr/bin/env python3
"""exp_ppm_gate.py — run the exhaustive fork-exponential ppm gate (F3).

Bounds, applied over ALL 2^32 float inputs against the port's expf:
    tails (|x| outside [-87,88]) : BIT-IDENTICAL (fork delegates; verified)
    expf(x) >= 1e-30             : relative error <= 2 ppm
    expf(x) <  1e-30             : <= 4 ULP (relative measure is
                                    quantization there, stated not hidden)
For scale: the fork PITCH bound of 0.05 cents is 29 ppm.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

PPM_BOUND = 2.0
ULP_BOUND = 4

def main():
    tmp = tempfile.mkdtemp(prefix="expgate_")
    exe = os.path.join(tmp, "gate")
    subprocess.run(
        ["cc", "-std=c99", "-O2", "-ffp-contract=off",
         "-I" + os.path.join(REPO, "engine_b"), "-o", exe,
         os.path.join(HERE, "exp_ppm_gate.c"),
         os.path.join(REPO, "engine_b", "eb_exp_fork.c"), "-lm"],
        check=True)
    ncpu = os.cpu_count() or 4
    total = 1 << 32
    step = total // ncpu
    procs = [subprocess.Popen(
        [exe, str(i * step), str(total if i == ncpu - 1 else (i + 1) * step)],
        stdout=subprocess.PIPE, text=True) for i in range(ncpu)]
    wppm = 0.0; wat = "-"; wulp = 0; wulp_at = "-"; n = 0; tailmis = 0
    for p in procs:
        out, _ = p.communicate()
        if p.returncode:
            print(out); print("GATE: FAIL (worker)"); return 1
        for line in out.splitlines():
            f = line.split()
            if f[0] == "RANGE":
                n += int(f[2].split("=")[1]); tailmis += int(f[3].split("=")[1])
            elif f[0] == "WPPM" and float(f[1]) > wppm:
                wppm = float(f[1]); wat = f[3]
            elif f[0] == "WULP" and int(f[1]) > wulp:
                wulp = int(f[1]); wulp_at = f[3]
    print("=== FORK EXP, EXHAUSTIVE PPM GATE: %d float inputs ===" % n)
    ok = True
    t = tailmis == 0; ok &= t
    print("  tails      : %d mismatches  %s" % (tailmis, "ok" if t else "FAIL"))
    t = wppm <= PPM_BOUND; ok &= t
    print("  ppm region : worst %.4f ppm at %s  %s" % (wppm, wat, "ok" if t else "FAIL"))
    t = wulp <= ULP_BOUND; ok &= t
    print("  tiny region: worst %d ULP at %s  %s" % (wulp, wulp_at, "ok" if t else "FAIL"))
    if n != total:
        print("GATE: FAIL -- covered %d of 2^32" % n); return 1
    print("GATE: %s  (bounds: %.1f ppm, %d ULP, tails bit-identical)"
          % ("PASS" if ok else "FAIL", PPM_BOUND, ULP_BOUND))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
