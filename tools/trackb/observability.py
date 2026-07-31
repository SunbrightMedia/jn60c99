#!/usr/bin/env python3
"""observability.py — does this scenario set NOTICE if the subsystem is wrong?

THE QUESTION coverage_probe.py CANNOT ANSWER
--------------------------------------------
Line coverage of native/voice_render.c is ~98% in every null_ab scenario, yet
the first mutation planted in the fork -- a 0.1% error in the noise generator's
2^-24 output scale (src/voice_render.c:640) -- changed the output of exactly ONE
of the five. The other four did not report a small residual, they reported
EXACTLY 0. They were right to: their patches have DCO NOISE at zero, so the
mutated value is multiplied out downstream. The line RAN and the error was
UNOBSERVABLE.

So "the scenario executed the code" is necessary and not sufficient. What a
rewrite needs before it can trust a PASS is: for the cells this subsystem
produces, at least one scenario changes its output when those cells change. That
is what this tool measures, per scenario, by execution.

METHOD
  Build the candidate with -DTRACKB_PERTURB_CELLS="<offsets>". native/
  voice_render.c carries an #ifdef-guarded hook at the tail of the render that
  multiplies each listed per-voice cell by 1.00000012f (about 1 part in 8.4
  million, ~2 ULP) after the sample is computed. Then run the ordinary null A/B.
    residual EXACTLY 0  -> that scenario is BLIND to these cells
    residual anything   -> that scenario OBSERVES them; the dB figure is its
                           sensitivity, i.e. how much headroom a real error has
                           before the -90 dB gate would let it through.

  The perturbation is deliberately tiny. A large one would prove nothing useful:
  the point is to detect the propagation path, not to make noise.

IT IS ALSO AN EXECUTED CARRIED/SCRATCH CLASSIFIER
  --each perturbs the listed cells ONE AT A TIME. A cell whose perturbation no
  scenario can see is write-only scratch BY EXECUTION -- which is how the
  blueprint docs' CARRIED/SCRATCH tables should be checked, since they were
  produced by READING. Demonstrated both directions on first run: cells
  3520+4928 (the voice output) are observed by 5/5 scenarios at -129 dB, cells
  432+528 by 0/5.

CALIBRATION (MEASURED, and the number to quote when someone asks how tight the
-90 dB gate really is): a 2-ULP-per-sample error on the voice output lands at
-129 dB rel, i.e. 39 dB BELOW the threshold. So the gate ignores errors up to
roughly 200 ULP (~2.4e-5 relative) per sample and catches anything larger. That
is far under audibility and far over float noise, which is the band it was
chosen for -- but it is a measurement, not a hope.

USAGE
  observability.py --cells 3520,4928           per-scenario verdict for two cells
  observability.py --cells 3520 --require 3    fail unless >=3 scenarios observe
  observability.py --cells 320,336,352 --each  classify each cell separately
Offsets are per-voice cell offsets as used by JF(a1, N) -- take them from the
subsystem's "cells owned" table in docs/trackb/*.md.
"""
import sys, os, subprocess, math

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import null_ab

# A UNIQUE PATH PER BUILD. dlopen() caches by path: rebuilding at one path and
# re-loading it returns the ALREADY-LOADED library, so every cell after the first
# would silently report the first cell's result. That is a false-result generator
# of exactly the class this project keeps getting bitten by, so the path carries
# the cell list.
def cand_path(cells):
    return os.path.join(REPO, "juno_cand_perturb_%s.so"
                        % "_".join(str(int(c)) for c in cells))


def build(cells, dst):
    import glob
    native = sorted(glob.glob(os.path.join(REPO, "native", "*.c")))
    shadow = {os.path.join(REPO, "src", os.path.basename(n)) for n in native}
    src = [s for s in sorted(glob.glob(os.path.join(REPO, "src", "*.c")))
           if s not in shadow] + native
    cmd = ["cc", "-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
           "-I" + os.path.join(REPO, "src"),
           "-DTRACKB_PERTURB_CELLS=" + ",".join(str(int(c)) for c in cells),
           "-shared", "-fPIC", "-o", dst,
           os.path.join(REPO, "gui", "juno_bridge.c")] + src + ["-lm"]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        raise SystemExit("build failed:\n" + r.stderr[-1500:])
    if not any("TRACKB_PERTURB_CELLS" in open(n).read() for n in native):
        raise SystemExit("ABORT: no native/*.c carries the observability hook -- "
                         "the build would be unperturbed and every scenario would "
                         "report EXACTLY 0 for the WRONG reason.")


def main():
    argv = sys.argv[1:]
    if "--cells" not in argv:
        raise SystemExit(__doc__)
    cells = [int(x) for x in argv[argv.index("--cells") + 1].split(",") if x.strip()]
    need = int(argv[argv.index("--require") + 1]) if "--require" in argv else 1

    null_ab.truth.require()
    bank = open(null_ab.truth.BANK, "rb").read()
    ref = null_ab.load(os.path.join(REPO, "libjuno.so"))
    base = {tag: null_ab.render(ref, bank, p, n, w) for p, n, w, tag in null_ab.SCEN}

    if "--each" in argv:
        print("=== TRACK B CARRIAGE CLASSIFICATION BY EXECUTION (perturb one "
              "cell at a time) ===")
        print("  The hook fires AFTER the sample is rendered, so this measures"
              " CARRIAGE:\n  does the value survive to influence a later sample?"
              " NOT-CARRIED does NOT mean\n  unused -- a cell read and consumed"
              " within the same sample, or rewritten every\n  sample by the note"
              " path, is correctly NOT-CARRIED and still load-bearing.\n"
              "  NOT-CARRIED is exactly the property that makes a cell legal to"
              " keep in a\n  register instead of memory, which is the scratch"
              " lever the M7 needs.\n  Label: MEASURED over this scenario set --"
              " evidence, not a proof for all inputs.\n")
        rc = 0
        for cell in cells:
            so = cand_path([cell])
            build([cell], so)
            cand = null_ab.load(so)
            worst, seen = None, 0
            for p, n, w, tag in null_ab.SCEN:
                r = base[tag]
                c = null_ab.render(cand, bank, p, n, w)
                sig = math.sqrt(sum(v * v for v in r) / len(r))
                res = math.sqrt(sum((a - b) ** 2 for a, b in zip(r, c)) / len(r))
                if res:
                    seen += 1
                    rel = null_ab.db(res) - null_ab.db(sig)
                    worst = rel if worst is None else max(worst, rel)
            print("  cell %6d : %s  (%d/%d scenarios%s)"
                  % (cell, "CARRIED (survives the sample)" if seen
                     else "NOT-CARRIED (post-render change is invisible)",
                     seen, len(null_ab.SCEN),
                     "" if worst is None else ", loudest %.1f dB rel" % worst))
            os.unlink(so)
        return rc

    so = cand_path(cells)
    build(cells, so)
    cand = null_ab.load(so)

    print("=== TRACK B OBSERVABILITY: perturb cells %s by ~2 ULP, who notices? ==="
          % ",".join(map(str, cells)))
    seen = 0
    for patch, notes, warm, tag in null_ab.SCEN:
        r = base[tag]
        c = null_ab.render(cand, bank, patch, notes, warm)
        sig = math.sqrt(sum(v * v for v in r) / len(r))
        res = math.sqrt(sum((a - b) ** 2 for a, b in zip(r, c)) / len(r))
        if res == 0.0:
            print("  %-16s EXACTLY 0  -> BLIND to these cells (its PASS proves "
                  "nothing about them)" % tag)
        else:
            seen += 1
            print("  %-16s observes at %6.1f dB rel  (%.0f dB of margin over the "
                  "-90 dB gate)" % (tag, null_ab.db(res) - null_ab.db(sig),
                                    -90.0 - (null_ab.db(res) - null_ab.db(sig))))
    ok = seen >= need
    print("OBSERVABILITY: %d/%d scenario(s) observe these cells -- %s"
          % (seen, len(null_ab.SCEN),
             "PASS" if ok else "FAIL (needed %d)" % need))
    if seen == 0:
        print("  Nothing in the scenario set can see this subsystem. Any null it "
              "reports is vacuous FOR THIS SUBSYSTEM. Add a scenario (a patch that\n"
              "  actually uses it) before rewriting it.")
    try: os.unlink(so)
    except OSError: pass
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
