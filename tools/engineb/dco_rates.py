#!/usr/bin/env python3
"""dco_rates.py — P3: what does the DCO ACTUALLY cost on the ESP32-S3?

THE PROBLEM THIS SOLVES. `docs/engineb/data/qemu_instr_counts.md` puts
eb_dco_step4 at 17,581 instructions per sample, and that figure has two known
defects. First, the QEMU harness drove it with SYNTHETIC coefficients whose
three waveform levels are all non-zero and whose signal never sits at the
saturator's clamp -- so both of the module's big branch savings were switched
off, and the number is a worst case. Second, the harness's per-call spans are
untrustworthy at all (CCOUNT advances 25 instructions at a time at translation
block boundaries; two builds differing only in EB_PITCH_FAST disagree by exactly
500,000 units on functions that did not change).

THE METHOD HERE USES NEITHER QEMU NOR ITS COUNTER. It is MEASURED x STATIC:

  MEASURED (this script): how often each branch in eb_dco_step_i is TAKEN while
  rendering the real gated scenario set, on real recalled factory patches,
  through the real port render path. Counters are compiled in with
  -DEB_DCO_COUNT; they are write-only and the DSP never reads them, so an
  instrumented build computes the same samples as a clean one.

  STATIC (tools/engineb/dco_paths.c + this script's pricing table): what each
  path costs in Xtensa instructions, counted from `objdump` of a real
  cross-compile at the shipping flags.

Neither half can be moved by a counter quantisation artefact, because neither
half involves a counter on the target.

WHAT THIS DOES NOT CLAIM. Instructions are not cycles. On an in-order LX7 the
cycles-per-instruction factor is >= 1 and is not known until silicon. Every
figure printed here is an INSTRUCTION count and is labelled as one.
"""
import os
import sys
import ctypes
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "tools", "engineb"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import null_b
import null_ab
import truth

NAMES = ["steps", "wrap_slow", "saw_on", "pulse_on", "sub_on",
         "saw_full", "saw_short", "pulse_full", "pulse_short",
         "sub_full", "sub_short", "subcnt_bump"]


def measure(rate, quick=False):
    """Build the dco module with counters and render every scenario."""
    null_b.CFLAGS = null_b.CFLAGS + ["-DEB_DCO_COUNT"]
    tmp = tempfile.mkdtemp(prefix="dco_rates_")
    so = os.path.join(tmp, "libjuno_dco.so")
    shadowed, _cmd = null_b.build(so, modules=("dco",))
    if "voice_render.c" not in shadowed:
        raise SystemExit("the dco shim did not shadow voice_render.c -- this "
                         "build does not contain engine B's DCO, so its "
                         "counters would all read zero and mean nothing.")
    lib = null_ab.load(so)
    ctr = (ctypes.c_ulonglong * 12).in_dll(lib, "eb_dco_ctr")
    bank = open(truth.BANK, "rb").read()

    for patch, script, _tag in null_b.scenarios(quick):
        null_ab.render_script(lib, bank, rate, patch, script)

    got = [int(ctr[i]) for i in range(12)]
    if got[0] == 0:
        raise SystemExit("ZERO STEPS COUNTED. The instrumented DCO never ran, "
                         "so every rate below would be a division by zero "
                         "dressed as a measurement.")
    return got


def report(c):
    steps = c[0]
    print("=== DCO BRANCH RATES, MEASURED over the full gated scenario set ===")
    print("sub-sample steps executed: %,d".replace(",", ",") % steps
          if False else "sub-sample steps executed: {:,}".format(steps))
    print()
    print("  %-14s %14s  %8s" % ("branch", "count", "rate"))
    for i in range(1, 12):
        print("  %-14s %14s  %7.3f%%"
              % (NAMES[i], "{:,}".format(c[i]), 100.0 * c[i] / steps))
    print()
    # Per-waveform shortcut rates are conditional on the waveform being ON --
    # a shortcut rate expressed over ALL steps would look small simply because
    # the level gate was off, which is a different saving already counted.
    for w, full, short in (("saw", 5, 6), ("pulse", 7, 8), ("sub", 9, 10)):
        tot = c[full] + c[short]
        if tot:
            print("  %-5s saturator: %.2f%% took the CLAMP SHORTCUT "
                  "(%s of %s calls)"
                  % (w, 100.0 * c[short] / tot,
                     "{:,}".format(c[short]), "{:,}".format(tot)))
        else:
            print("  %-5s saturator: never called (level gate always off)" % w)
    return steps


def main():
    rate = 48000.0
    a = sys.argv[1:]
    if "--rate" in a:
        rate = float(a[a.index("--rate") + 1])
    quick = "--quick" in a
    truth.require()
    print("rendering the gated scenario set at %.0f Hz ..." % rate)
    c = measure(rate, quick)
    steps = report(c)
    print()
    print("Raw counters (for the pricing step): %s"
          % dict(zip(NAMES, c)))
    # Sub-samples per audio sample per voice is 4, and the scenario set has 8
    # voices; the pricing is done in tools/engineb/dco_price.py against static
    # Xtensa counts so that this script stays a pure MEASUREMENT.
    print("\nNOTE: this script measures RATES ONLY. Pricing them in Xtensa "
          "instructions is dco_price.py, deliberately separate: a measurement "
          "that also does its own arithmetic is hard to check.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
