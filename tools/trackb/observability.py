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
  Build a throwaway probe library: the candidate sources plus
  tools/trackb/perturb_rt.c, with -DTRACKB_PERTURB_CELLS. native/voice_render.c
  carries an #ifdef-guarded hook at the tail of the render that multiplies each
  selected per-voice cell by 1.00000012f (~2 ULP) after the sample is complete.
  The cell list is a RUNTIME global, so a full sweep costs one build.
    residual EXACTLY 0  -> that scenario is BLIND to these cells
    residual anything   -> that scenario OBSERVES them; the dB figure is its
                           sensitivity, i.e. how much headroom a real error has
                           before the -90 dB gate would let it through.
  The perturbation is deliberately tiny: the point is to detect the propagation
  path, not to make noise.

  SELF-CHECK, run before any result is reported: with the cell list EMPTY the
  probe library must reproduce the reference EXACTLY. "The perturbation did
  nothing" and "the perturbation never happened" look identical in the output,
  and this project has been bitten too often by the second wearing the first's
  clothes.

IT IS ALSO AN EXECUTED CARRIAGE CLASSIFIER
  --each perturbs the listed cells ONE AT A TIME; --sweep does every cell
  native/voice_render.c writes. Because the hook fires AFTER the sample, a cell
  no scenario can see does not survive the sample boundary. NOT-CARRIED does not
  mean unused -- a cell consumed within the same sample, or rewritten every
  sample by the note path, is correctly NOT-CARRIED and still load-bearing. It
  is precisely the property that makes a cell legal to hold in a register
  instead of memory, which is the scratch lever the Cortex-M7 needs, and it
  cross-checks blueprint tables that were produced by READING.
  Label the result MEASURED over this scenario set: evidence, not proof for all
  inputs.

CALIBRATION (MEASURED): a 2-ULP-per-sample error on the voice output lands at
-129 dB rel, i.e. 39 dB BELOW the -90 dB threshold. So the null gate ignores
errors up to roughly 200 ULP (~2.4e-5 relative) per sample and catches anything
larger -- far under audibility, far over float noise.

USAGE
  observability.py --cells 3520,4928           per-scenario verdict for two cells
  observability.py --cells 3520 --require 3    fail unless >=3 scenarios observe
  observability.py --cells 320,336,352 --each  classify each cell separately
  observability.py --sweep [--out map.tsv]     classify EVERY written cell
Offsets are per-voice cell offsets as used by JF(a1, N) -- take them from the
subsystem's "cells owned" table in docs/trackb/*.md.
"""
import sys, os, re, glob, math, ctypes, hashlib, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import null_ab

PROBE = os.path.join(REPO, "juno_tb_probe.so")
GATE_DB = -90.0           # the threshold the null A/B enforces, for margin reporting


def build(dst=PROBE):
    native = sorted(glob.glob(os.path.join(REPO, "native", "*.c")))
    if not native:
        raise SystemExit("ABORT: native/ is empty -- nothing forked to probe.")
    if not any("TRACKB_PERTURB_CELLS" in open(n).read() for n in native):
        raise SystemExit("ABORT: no native/*.c carries the observability hook; the "
                         "build would be unperturbed and every cell would report "
                         "invisible for the WRONG reason.")
    shadow = {os.path.join(REPO, "src", os.path.basename(n)) for n in native}
    src = [s for s in sorted(glob.glob(os.path.join(REPO, "src", "*.c")))
           if s not in shadow] + native
    cmd = ["cc", "-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
           "-I" + os.path.join(REPO, "src"), "-DTRACKB_PERTURB_CELLS",
           "-shared", "-fPIC", "-o", dst,
           os.path.join(REPO, "gui", "juno_bridge.c"),
           os.path.join(HERE, "perturb_rt.c")] + src + ["-lm"]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        raise SystemExit("build failed:\n" + r.stderr[-1500:])
    lib = null_ab.load(dst)
    lib.juno_tb_set_cells.argtypes = [ctypes.POINTER(ctypes.c_int), ctypes.c_int]
    return lib


def scen_fingerprint():
    """Hash of the scenario set. A carriage map is only valid for the scenarios
    that produced it: a cell reads NOT-CARRIED whenever nothing exercised it, so
    a map swept under a smaller SCEN silently over-reports register-legal cells.
    Written into the TSV header; consumers must refuse a map whose fingerprint
    does not match the SCEN they are running under."""
    return hashlib.sha256(repr(null_ab.SCEN).encode()).hexdigest()[:16]


def set_cells(lib, cells):
    arr = (ctypes.c_int * max(len(cells), 1))(*cells) if cells else (ctypes.c_int * 1)()
    lib.juno_tb_set_cells(arr, len(cells))


def written_cells(path):
    """Per-voice offsets the forked render WRITES (JF/JI(a1, N) = ...)."""
    out = set()
    for line in open(path):
        for m in re.finditer(r'\bJ[FI]\(\s*a1\s*,\s*(\d+)\s*\)\s*(?:[-+*/]?=)(?!=)', line):
            out.add(int(m.group(1)))
    return sorted(out)


def residuals(lib, base, bank):
    """[(tag, rel_dB or None)] for the currently-selected cell set."""
    out = []
    for p, sc, tag in null_ab.SCEN:
        r = base[tag]
        c = null_ab.render(lib, bank, p, sc)
        res = math.sqrt(sum((a - b) ** 2 for a, b in zip(r, c)) / len(r))
        if res == 0.0:
            out.append((tag, None))
        else:
            sig = math.sqrt(sum(v * v for v in r) / len(r))
            out.append((tag, null_ab.db(res) - null_ab.db(sig)))
    return out


def main():
    argv = sys.argv[1:]
    null_ab.truth.require()
    bank = open(null_ab.truth.BANK, "rb").read()
    ref = null_ab.load(os.path.join(REPO, "libjuno.so"))
    base = {tag: null_ab.render(ref, bank, p, sc) for p, sc, tag in null_ab.SCEN}

    lib = build()
    set_cells(lib, [])
    if any(rel is not None for _, rel in residuals(lib, base, bank)):
        raise SystemExit("ABORT: the probe library differs from the reference with "
                         "an EMPTY cell list. The probe build is not neutral, so no "
                         "result from it can be believed.")
    print("probe self-check: empty cell list reproduces the reference EXACTLY")

    if "--sweep" in argv:
        cells = written_cells(os.path.join(REPO, "native", "voice_render.c"))
        out_path = argv[argv.index("--out") + 1] if "--out" in argv else None
        print("=== TRACK B CARRIAGE SWEEP: %d written per-voice cells ===" % len(cells))
        print("  CARRIED  = a ~2 ULP nudge after the sample changes later output")
        print("  NOT-CARR = invisible; legal to keep in a register (MEASURED over"
              " %d scenarios)\n" % len(null_ab.SCEN))
        rows, carried = [], 0
        for i, cell in enumerate(cells):
            set_cells(lib, [cell])
            rr = residuals(lib, base, bank)
            seen = [t for t, rel in rr if rel is not None]
            worst = max([rel for _, rel in rr if rel is not None], default=None)
            carried += 1 if seen else 0
            rows.append((cell, len(seen), worst))
            if (i + 1) % 25 == 0:
                print("  ... %d/%d cells (%d carried so far)"
                      % (i + 1, len(cells), carried), flush=True)
        print("\nSWEEP: %d cells, %d CARRIED, %d NOT-CARRIED (%.1f%% register-legal)"
              % (len(cells), carried, len(cells) - carried,
                 100.0 * (len(cells) - carried) / max(len(cells), 1)))
        if out_path:
            with open(out_path, "w") as fh:
                fh.write("# scenarios=%d fingerprint=%s  (a map is only valid "
                         "for the scenario set that produced it)\n"
                         % (len(null_ab.SCEN), scen_fingerprint()))
                fh.write("cell\tclass\tscenarios_observing\tloudest_dB_rel\n")
                for cell, seen, worst in rows:
                    fh.write("%d\t%s\t%d\t%s\n"
                             % (cell, "CARRIED" if seen else "NOT-CARRIED", seen,
                                "" if worst is None else "%.1f" % worst))
            print("wrote %s" % out_path)
        return 0

    if "--cells" not in argv:
        raise SystemExit(__doc__)
    cells = [int(x) for x in argv[argv.index("--cells") + 1].split(",") if x.strip()]
    need = int(argv[argv.index("--require") + 1]) if "--require" in argv else 1

    if "--each" in argv:
        print("=== TRACK B CARRIAGE CLASSIFICATION BY EXECUTION (one cell at a time) ===")
        for cell in cells:
            set_cells(lib, [cell])
            rr = residuals(lib, base, bank)
            seen = [t for t, rel in rr if rel is not None]
            worst = max([rel for _, rel in rr if rel is not None], default=None)
            print("  cell %6d : %-42s (%d/%d scenarios%s)"
                  % (cell,
                     "CARRIED (survives the sample)" if seen else
                     "NOT-CARRIED (post-render change invisible)",
                     len(seen), len(null_ab.SCEN),
                     "" if worst is None else ", loudest %.1f dB rel" % worst))
        return 0

    set_cells(lib, cells)
    print("=== TRACK B OBSERVABILITY: perturb cells %s by ~2 ULP, who notices? ==="
          % ",".join(map(str, cells)))
    seen = 0
    for tag, rel in residuals(lib, base, bank):
        if rel is None:
            print("  %-16s EXACTLY 0  -> BLIND to these cells (its PASS proves "
                  "nothing about them)" % tag)
        else:
            seen += 1
            print("  %-16s observes at %6.1f dB rel  (%.0f dB of margin over the "
                  "%.0f dB gate)" % (tag, rel, GATE_DB - rel, GATE_DB))
    ok = seen >= need
    print("OBSERVABILITY: %d/%d scenario(s) observe these cells -- %s"
          % (seen, len(null_ab.SCEN), "PASS" if ok else "FAIL (needed %d)" % need))
    if seen == 0:
        print("  Nothing in the scenario set can see these cells. Any null it "
              "reports is vacuous FOR THEM.\n  Add a scenario (a patch that "
              "actually uses the subsystem) before rewriting it.")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        rc = main()
    finally:
        try: os.unlink(PROBE)
        except OSError: pass
    sys.exit(rc)
