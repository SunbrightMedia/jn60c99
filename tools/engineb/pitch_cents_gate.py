#!/usr/bin/env python3
"""pitch_cents_gate.py — run the EXHAUSTIVE fork-pitch cents gate (F3).

Compiles pitch_cents_gate.c FRESH (a stale gate binary has produced a false
green in this project before), splits the whole 2^32 float bit-space across
worker processes, merges the per-band worsts, and applies the bounds:

    |Pd| >= 1e-3 :  worst cents <= 0.05          (the user-signed fork bound)
    |Pd| <  1e-3 :  worst |Pf - Pd| <= 2e-6      (the plugin's own amplified
                     rounding scale: 2^-53 x 2^37 x margin — a region where a
                     RELATIVE bound would grade the plugin's noise, not us)

Exit 0 only if both hold. Prints every band either way.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

CENTS_BOUND = 0.05
ABS_BOUND = 2e-6

def main():
    tmp = tempfile.mkdtemp(prefix="centsgate_")
    exe = os.path.join(tmp, "gate")
    subprocess.run(
        ["cc", "-std=c99", "-O2", "-ffp-contract=off",
         "-I" + os.path.join(REPO, "engine_b"), "-I" + os.path.join(REPO, "src"),
         "-o", exe,
         os.path.join(HERE, "pitch_cents_gate.c"),
         os.path.join(REPO, "engine_b", "eb_pitch_fork.c"),
         os.path.join(REPO, "src", "juno_dsp.c"), "-lm"],
        check=True)

    ncpu = os.cpu_count() or 4
    total = 1 << 32
    step = total // ncpu
    procs = []
    for i in range(ncpu):
        lo = i * step
        hi = total if i == ncpu - 1 else (i + 1) * step
        procs.append(subprocess.Popen([exe, str(lo), str(hi)],
                                      stdout=subprocess.PIPE, text=True))
    worst = [0.0] * 5
    wat = [""] * 5
    wabs = 0.0
    wabs_line = ""
    n = 0
    for p in procs:
        out, _ = p.communicate()
        if p.returncode:
            sys.stdout.write(out)
            print("GATE: FAIL (worker error / sign failure)")
            return 1
        for line in out.splitlines():
            f = line.split()
            if f[0] == "RANGE":
                n += int(f[2].split("=")[1])
            elif f[0] == "BAND":
                k, c = int(f[1]), float(f[3])
                if c > worst[k]:
                    worst[k] = c
                    wat[k] = f[5]
            elif f[0] == "SUB":
                a = float(f[2])
                if a > wabs:
                    wabs = a
                    wabs_line = line
    print("=== FORK PITCH, EXHAUSTIVE CENTS GATE: %d float inputs ===" % n)
    names = ["|P|>=1", "0.3..1", "0.1..0.3", "1e-2..0.1", "1e-3..1e-2"]
    ok = True
    for k in range(5):
        good = worst[k] <= CENTS_BOUND
        ok &= good
        print("  band %-10s worst %.6f cents at %s  %s"
              % (names[k], worst[k], wat[k] or "-", "ok" if good else "FAIL"))
    good = wabs <= ABS_BOUND
    ok &= good
    print("  |P|<1e-3     worst abs %.3g  (%s)  %s"
          % (wabs, wabs_line, "ok" if good else "FAIL"))
    print("GATE: %s  (bounds: %.2f cents, %.0e abs)"
          % ("PASS" if ok else "FAIL", CENTS_BOUND, ABS_BOUND))
    if n != total:
        print("GATE: FAIL -- covered %d of 2^32 inputs; exhaustive means "
              "exhaustive." % n)
        return 1
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
