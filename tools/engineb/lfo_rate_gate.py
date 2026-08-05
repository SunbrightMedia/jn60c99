#!/usr/bin/env python3
"""lfo_rate_gate.py — the LFO-RATE ppm gate (F3's named gate).

Reads the LFO coefficient cells (1072, 1184, 1200, 1216, 2128, 2144) from
EVERY patch in the real factory bank by recalling each one through the port,
then drives the port's own rate expression with the port's expf and with the
fork exp and bounds the RELATIVE error of the resulting phase increment.

WHY NOT JUST QUOTE expf's 0.119 ppm: a subtraction of near-equal terms sits
between the exponential and the accumulator, and cancellation amplifies
relative error without bound. The bound below is on the integrated quantity,
which is the one that matters.

BOUND: 2 ppm on the rate, the same figure the exponential itself is held to.
At an LFO of 10 Hz that is 1.2e-3 of a cycle of phase drift after a minute of
continuous running -- about 0.4 degrees, which is why the bound is stated in
cycles as well as ppm rather than left as an abstraction.
"""
import ctypes
import os
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

PPM_BOUND = 2.0
CELLS = [1072, 1184, 1200, 1216, 2128, 2144]


def coeffs_from_bank():
    """Recall all 64 factory patches through the port and read the six cells.
    A range invented by hand would be the one thing this gate must not do."""
    import truth
    import null_ab
    lib = null_ab.load(os.path.join(REPO, "libjuno.so"))
    bank = open(truth.BANK, "rb").read()
    out = []
    for p in range(64):
        ctx = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), p)
        # THE CONTEXT IS NOT THE STATE BLOCK. juno_gui_create returns a
        # juno_ctx whose FIRST member is `st`, the pointer to the 12 MB state.
        # Reading cells straight off the ctx pointer gave all-zero values and
        # the gate reported PASS on nothing -- a vacuous pass caught only
        # because "1 distinct coefficient set" and an empty worst line did
        # not look like a measurement.
        st = ctypes.cast(ctx, ctypes.POINTER(ctypes.c_void_p))[0]
        base = ctypes.cast(st, ctypes.POINTER(ctypes.c_ubyte))
        vals = []
        for c in CELLS:
            b = bytes(base[c:c + 4])
            vals.append(struct.unpack("<f", b)[0])
        out.append((p, vals))
        lib.juno_gui_destroy(ctx)
    return out


def main():
    tmp = tempfile.mkdtemp(prefix="lforate_")
    exe = os.path.join(tmp, "gate")
    subprocess.run(
        ["cc", "-std=c99", "-O2", "-ffp-contract=off",
         "-I" + os.path.join(REPO, "engine_b"), "-o", exe,
         os.path.join(HERE, "lfo_rate_gate.c"),
         os.path.join(REPO, "engine_b", "eb_exp_fork.c"), "-lm"],
        check=True)

    rows = coeffs_from_bank()
    worst = 0.0
    worst_line = ""
    seen = set()
    for p, (k1072, k1184, k1200, k1216, k2128, k2144) in rows:
        key = tuple(round(v, 9) for v in (k1072, k1184, k1200, k1216, k2128, k2144))
        if key in seen:
            continue                      # identical coefficient set
        seen.add(key)
        # v74 is the LFO's own per-sample state; sweep it over its range
        for v74 in (0.0, 0.25, 0.5, 0.75, 1.0):
            r = subprocess.run(
                [exe, repr(k1200), repr(k1184), repr(k1216), repr(k1072),
                 repr(v74), repr(k2128), repr(k2144), "patch%02d/v74=%.2f" % (p, v74)],
                capture_output=True, text=True, check=True)
            line = r.stdout.strip()
            ppm = float(line.split("worst")[1].split("ppm")[0])
            if ppm > worst:
                worst = ppm
                worst_line = line
    print("=== LFO RATE PPM GATE: %d distinct coefficient sets from the "
          "factory bank, v74 swept ===" % len(seen))
    print("  worst: " + (worst_line or "(none)"))
    # A GATE THAT MEASURED NOTHING MUST NOT REPORT PASS. The first run of this
    # file read the cells off the wrong pointer, got all zeros, collapsed to
    # one "distinct" set, found no comparable rate, and printed PASS.
    if len(seen) < 4 or not worst_line:
        print("GATE: FAIL -- only %d distinct coefficient set(s) and %s worst "
              "line. That is not a measurement of the bank; check the cell "
              "read." % (len(seen), "no" if not worst_line else "a"))
        return 1
    ok = worst <= PPM_BOUND
    print("GATE: %s  (bound %.1f ppm on the INTEGRATED rate, not on expf)"
          % ("PASS" if ok else "FAIL", PPM_BOUND))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
