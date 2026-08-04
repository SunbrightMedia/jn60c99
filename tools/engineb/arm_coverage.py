#!/usr/bin/env python3
"""arm_coverage.py -- which DISPATCH ARMS of the master chain does the gate reach?

WHY THIS EXISTS. src/master_render.c is not one signal path. Two host-selector
switches choose between whole alternative algorithms:

    v39  = juno_host_sel(a1, 136)   at :887   DELAY TYPE  (slot 1)
    v551 = juno_host_sel(a1, 112)   at :2378  EFFECT TYPE (slot 2)

Each arm is hundreds of lines of DIFFERENT code. A module written for an arm no
scenario reaches cannot be gated at all -- the null would compare two code paths
neither of which runs, and report EXACTLY 0 for the same reason a disconnected
meter reads zero. That is the standing warning in docs/trackb/PLAN.md ("NO
MODULE MAY BE REWRITTEN BEHIND A BLIND GATE") applied to the master chain.

MEASURED 2026-08-04, before any master module was written for an arm: the
thirty inherited scenarios reached DELAY 0/1/5 and EFFECT 2/3/5, and NEVER
DELAY 2, 3 or 4, nor EFFECT 0, 1 or 4 -- half of each switch. Three scenarios
built from real factory patches (11, 19 and 9) closed DELAY 2, DELAY 3 and
EFFECT 1. DELAY 4 and EFFECT 0 and 4 appear in no factory patch at all and
remain unreachable by any scenario; they need a synthetic-recall gate of the
tools/verify/etmode_ab.py kind before a module may be written for them.

Run this before claiming any master arm, and after any change to the scenario
set. It counts SAMPLES per arm through the port's own code -- no engine B
involved, so it measures the GATE and not the candidate.
"""
import sys, os, tempfile, shutil, glob, subprocess, ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "engineb"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import null_b, null_ab, truth


def build_counting_lib(tmp):
    for d in ("src", "gui", "engine_b"):
        shutil.copytree(os.path.join(REPO, d), os.path.join(tmp, d))
    p = os.path.join(tmp, "src", "master_render.c")
    s = open(p).read()
    s = s.replace('#include "juno_engine.h"',
                  '#include "juno_engine.h"\n'
                  'unsigned long EBARM39[8], EBARM551[8];\n', 1)
    for var, arr in (("v39", "EBARM39"), ("v551", "EBARM551")):
        a = "  %s = juno_host_sel(a1, %s);" % (var, "136" if var == "v39"
                                               else "112")
        if s.count(a) != 1:
            raise SystemExit(
                "arm_coverage: the %s selector read moved (matched %d times).\n"
                "  A counter that cannot find its own switch measures nothing."
                % (var, s.count(a)))
        s = s.replace(a, a + "\n  if ((unsigned)%s < 8) %s[%s]++;"
                      % (var, arr, var), 1)
    open(p, "w").write(s)
    srcs = sorted(glob.glob(os.path.join(tmp, "src", "*.c"))) + \
        [f for f in sorted(glob.glob(os.path.join(tmp, "engine_b", "*.c")))
         if not os.path.basename(f).startswith("test_")] + \
        [os.path.join(tmp, "gui", "juno_bridge.c")]
    so = os.path.join(tmp, "arm.so")
    r = subprocess.run(["cc"] + null_b.CFLAGS +
                       ["-I" + os.path.join(tmp, "src"),
                        "-I" + os.path.join(tmp, "engine_b"),
                        "-shared", "-fPIC", "-o", so] + srcs + ["-lm"],
                       capture_output=True)
    if r.returncode:
        sys.stderr.write(r.stderr.decode()[-3000:])
        raise SystemExit("arm_coverage: build failed")
    return so


def main():
    truth.require()
    tmp = tempfile.mkdtemp(prefix="armcov_")
    try:
        lib = ctypes.CDLL(build_counting_lib(tmp))
        bank = open(truth.BANK, "rb").read()
        scen = null_b.scenarios(False)
        for patch, script, tag in scen:
            null_ab.render_script(lib, bank, null_ab.SR, patch, script)
        t39 = list((ctypes.c_ulong * 8).in_dll(lib, "EBARM39"))
        t551 = list((ctypes.c_ulong * 8).in_dll(lib, "EBARM551"))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    bad = 0
    print("=== MASTER DISPATCH ARM COVERAGE (%d scenarios) ===" % len(scen))
    # Arms with no factory patch anywhere in the bank. Listed by name so an
    # unreached arm that SHOULD be reachable stands out from one that cannot be.
    NO_PATCH = {("DELAY", 4), ("EFFECT", 0), ("EFFECT", 4)}
    for name, tot in (("DELAY", t39), ("EFFECT", t551)):
        print("%s TYPE:" % name)
        for i in range(6):
            if tot[i]:
                print("   arm %d: %12d samples" % (i, tot[i]))
            elif (name, i) in NO_PATCH:
                print("   arm %d:            0   NOT REACHABLE -- no factory "
                      "patch selects it; needs a synthetic-recall gate" % i)
            else:
                print("   arm %d:            0   *** UNREACHED, and a patch "
                      "for it EXISTS -- the gate is blind here ***" % i)
                bad += 1
        for i in (6, 7):
            if tot[i]:
                print("   arm %d: %12d samples  (out of the documented range)"
                      % (i, tot[i]))
    print("ARM COVERAGE: %s" % ("PASS -- every arm a factory patch can select "
                                "is exercised" if bad == 0 else
                                "FAIL -- %d arm(s) blind" % bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
