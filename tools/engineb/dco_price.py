#!/usr/bin/env python3
"""dco_price.py — P3 part two: price the MEASURED DCO branch rates in Xtensa
instructions.

Input A (MEASURED): the branch rates printed by tools/engineb/dco_rates.py,
counted while rendering the real gated scenario set on real recalled patches.
Input B (STATIC): instruction counts of tools/engineb/dco_paths.c, cross-
compiled for the ESP32-S3 at the shipping flags and counted with objdump.

Neither input comes from QEMU, so neither can carry its counter-quantisation
defect. The output is INSTRUCTIONS, never cycles: on an in-order LX7 the
cycles-per-instruction factor is >= 1 and is unknown until silicon.
"""
import os
import re
import subprocess
import sys
import glob

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
XT = glob.glob("/root/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin")
if not XT:
    raise SystemExit("no Xtensa toolchain found -- this script measures the "
                     "TARGET's instruction counts and cannot guess them.")
XT = XT[0]
GCC = os.path.join(XT, "xtensa-esp32s3-elf-gcc")
OBJDUMP = os.path.join(XT, "xtensa-esp32s3-elf-objdump")

CFLAGS = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
          "-I" + os.path.join(REPO, "engine_b"),
          "-I" + os.path.join(REPO, "src")]

# MEASURED by tools/engineb/dco_rates.py at 48,000 Hz over the full 30-scenario
# gated set, 60,989,440 sub-sample steps. Recorded here rather than re-run so
# the pricing is reproducible from the numbers that were actually published.
RATES = {
    "steps": 60989440, "wrap_slow": 0,
    "saw_on": 32541440, "pulse_on": 60989440, "sub_on": 23523200,
    "saw_full": 112270, "saw_short": 32429170,
    "pulse_full": 504893, "pulse_short": 60484547,
    "sub_full": 84871, "sub_short": 23438329,
    "subcnt_bump": 25143,
}


def counts(extra=()):
    """Instructions per function symbol in dco_paths.c, plus eb_dco_step4."""
    out = {}
    obj = "/tmp/dco_paths_xt.o"
    src = os.path.join(REPO, "tools", "engineb", "dco_paths.c")
    subprocess.run([GCC] + CFLAGS + list(extra) + ["-c", src, "-o", obj],
                   check=True)
    obj2 = "/tmp/eb_dco_xt.o"
    subprocess.run([GCC] + CFLAGS + list(extra) +
                   ["-c", os.path.join(REPO, "engine_b", "eb_dco.c"),
                    "-o", obj2], check=True)
    for o in (obj, obj2):
        dis = subprocess.run([OBJDUMP, "-d", o], capture_output=True,
                             check=True).stdout.decode()
        cur = None
        for ln in dis.splitlines():
            m = re.match(r"^[0-9a-f]+ <([^>]+)>:", ln)
            if m:
                cur = m.group(1)
                out.setdefault(cur, 0)
                continue
            if cur and re.match(r"^\s+[0-9a-f]+:\s", ln):
                out[cur] += 1
    return out


def main():
    recip = "--recip" in sys.argv[1:]
    c = counts(["-DEB_DCO_RECIP=1"] if recip else ())
    need = ["p_fixed", "p_sat", "p_sat_short", "p_saw", "p_pulse", "p_sub",
            "p_mix"]
    missing = [n for n in need if n not in c]
    if missing:
        raise SystemExit("probe(s) missing from the object: %s -- the "
                         "optimiser deleted them, so they were never priced."
                         % missing)

    print("=== DCO PATH COSTS, STATIC Xtensa instructions (%s) ==="
          % ("EB_DCO_RECIP=1" if recip else "default, division kept"))
    for n in need:
        print("  %-12s %5d" % (n, c[n]))
    if "eb_dco_step4" in c:
        print("  %-12s %5d   (the REAL function, whole body, all arms present)"
              % ("eb_dco_step4", c["eb_dco_step4"]))
    print()

    s = float(RATES["steps"])
    r = {k: RATES[k] / s for k in RATES}

    # LIBGCC HELPER BODIES. objdump counts a call as ONE instruction, so a probe
    # that calls __divsf3 is under-priced by that helper's whole body unless it
    # is added here. MEASURED from this toolchain's own libgcc.a: __divsf3 is 30
    # instructions. The ESP32-S3 has no FPU divider, which is the entire reason
    # EB_DCO_RECIP exists.
    #
    # It is added at its EXECUTED rate, not its call-site count: p_pulse
    # contains three __divsf3 call sites because the ternary and the inlined
    # triangle each produced one, but exactly ONE of them runs per call.
    DIVSF3 = 30
    div_per_step = 0.0 if recip else r["pulse_on"]

    # fmodf appears in p_fixed (the out-of-range phase wrap) and in p_pulse (the
    # triangle's own wrap). MEASURED: the eb_dco_wrap slow arm was taken 0 times
    # in 60,989,440 steps, so it is priced at zero. Its call instructions are
    # still inside the static counts below, which makes those counts slightly
    # generous rather than slightly short -- the safe direction.
    per = c["p_fixed"]
    per += r["saw_on"] * (c["p_saw"] + c["p_sat_short"])
    per += r["pulse_on"] * (c["p_pulse"] + c["p_sat_short"])
    per += r["sub_on"] * (c["p_sub"] + c["p_sat_short"])
    # the full polynomial only on the calls that did NOT take the shortcut
    per += (r["saw_full"] + r["pulse_full"] + r["sub_full"]) * c["p_sat"]
    per += div_per_step * DIVSF3
    per += c["p_mix"]

    print("MEASURED branch rates applied:")
    print("  saw arm on     %6.2f %%" % (100 * r["saw_on"]))
    print("  pulse arm on   %6.2f %%" % (100 * r["pulse_on"]))
    print("  sub arm on     %6.2f %%" % (100 * r["sub_on"]))
    print("  full saturator %6.2f %% of steps (the clamp shortcut takes the rest)"
          % (100 * (r["saw_full"] + r["pulse_full"] + r["sub_full"])))
    print("  fmodf wrap     %6.2f %%" % (100 * r["wrap_slow"]))
    print()
    print("  => %.0f instructions per SUB-SAMPLE step" % per)
    print("  => %.0f per voice per audio sample (4 sub-samples)" % (per * 4))
    print("  => %.0f per audio sample for 8 voices" % (per * 4 * 8))
    print()

    # The worst case the QEMU table reported, recomputed on the same prices, to
    # show the difference is the BRANCH RATES and not a different cost model.
    worst = (c["p_fixed"] + c["p_saw"] + c["p_pulse"] + c["p_sub"]
             + 3 * c["p_sat"] + c["p_mix"]
             + (0 if recip else DIVSF3))
    print("For comparison, the WORST CASE these same prices give -- all three")
    print("levels on, saturator shortcut never taken, which is what the QEMU")
    print("harness's synthetic coefficients produced:")
    print("  => %.0f per step, %.0f per audio sample for 8 voices"
          % (worst, worst * 4 * 8))
    print("  (QEMU reported 17,581 for that configuration; these static prices")
    print("   give %.0f, so the two methods agree to within %.0f %% on the SAME"
          % (worst * 4 * 8, abs(worst * 4 * 8 - 17581) * 100.0 / 17581))
    print("   configuration -- the real-patch saving below is a rate effect.)")
    print()
    print("SAVING vs that worst case: %.0f instructions per audio sample "
          "(%.0f %%)" % (worst * 4 * 8 - per * 4 * 8,
                         100.0 * (worst - per) / worst))
    return 0


if __name__ == "__main__":
    sys.exit(main())
