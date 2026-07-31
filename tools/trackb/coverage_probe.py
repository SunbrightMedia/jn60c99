#!/usr/bin/env python3
"""coverage_probe.py — prove the null A/B scenarios actually EXECUTE the code
under test. The answer to "how do we know the test isn't lying".

WHY THIS EXISTS
---------------
The very first mutation planted in the Track B fork (a 0.1% DCO frequency error)
was caught by exactly ONE of null_ab.py's five scenarios. The other four did not
report a small residual -- they reported EXACTLY 0, i.e. the mutated arithmetic
never ran at all in those renders. A scenario that never reaches the code under
test cannot fail, so its PASS carries no information; five such scenarios look
like five times the evidence and are none.

null_ab.py's existing non-vacuity check (reference RMS above a floor) only proves
the ENGINE made sound. This proves the SUBSYSTEM was reached: gcov line counts
from the candidate build, per scenario, restricted to the lines the rewrite
touches.

USAGE
    coverage_probe.py                    coverage of native/*.c, per scenario
    coverage_probe.py --lines A-B[,C-D]  require these line ranges to be covered
                                         (the range you actually rewrote); exits
                                         non-zero naming any scenario that misses
                                         them, and any line no scenario reaches
    coverage_probe.py --json out.json    machine-readable, for the ledger

METHOD (all executed, nothing inferred)
  1. Build the candidate with -fprofile-arcs -ftest-coverage at -O1 (coverage
     needs recognisable line boundaries; the null itself is always run on the
     shipping -O2 build -- this build is ONLY for the question "was this line
     reached", which optimisation level cannot change).
  2. Run each null_ab scenario in its OWN subprocess with its own GCOV_PREFIX,
     so the .gcda counters are per scenario rather than accumulated.
  3. gcov -i each run, keep the per-line execution counts for the file(s) under
     test.
Two-process rule is respected trivially: no Unicorn anywhere in this tool.
"""
import sys, os, glob, json, gzip, shutil, subprocess, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import null_ab                                   # scenario set, single source of truth

CFLAGS = ["-std=c99", "-O1", "-ffp-contract=off", "-fno-strict-aliasing",
          "-fprofile-arcs", "-ftest-coverage", "-fPIC", "-I" + os.path.join(REPO, "src")]

DRIVER = r'''
import ctypes, sys, os
sys.path.insert(0, %(here)r)
import null_ab
lib = null_ab.load(%(so)r)
bank = open(%(bank)r, "rb").read()
patch, script, tag = null_ab.SCEN[%(i)d]
null_ab.render(lib, bank, patch, script)
'''


def build(dst_dir):
    """Compile the candidate (native/*.c substituted) with coverage into dst_dir."""
    srcs = sorted(glob.glob(os.path.join(REPO, "src", "*.c")))
    native = sorted(glob.glob(os.path.join(REPO, "native", "*.c")))
    shadowed = {os.path.join(REPO, "src", os.path.basename(n)) for n in native}
    srcs = [s for s in srcs if s not in shadowed] + native
    srcs.append(os.path.join(REPO, "gui", "juno_bridge.c"))
    objs = []
    for s in srcs:
        o = os.path.join(dst_dir, os.path.basename(s)[:-2] + ".o")
        subprocess.run(["cc"] + CFLAGS + ["-c", s, "-o", o], check=True,
                       capture_output=True)
        objs.append(o)
    so = os.path.join(dst_dir, "juno_cov.so")
    subprocess.run(["cc", "-shared", "-fprofile-arcs", "-o", so] + objs + ["-lm"],
                   check=True, capture_output=True)
    return so, [n for n in native]


def run_scenario(so, i, prefix):
    os.makedirs(prefix, exist_ok=True)
    env = dict(os.environ, GCOV_PREFIX=prefix, GCOV_PREFIX_STRIP="0")
    src = DRIVER % {"here": HERE, "so": so, "bank": null_ab.truth.BANK, "i": i}
    r = subprocess.run([sys.executable, "-c", src], env=env, capture_output=True,
                       text=True)
    if r.returncode:
        raise SystemExit("scenario %d failed: %s" % (i, r.stderr[-800:]))


def gcov_lines(prefix, build_dir, want_files):
    """{basename: {line: count}} for this scenario's .gcda set."""
    gcda = glob.glob(os.path.join(prefix, "**", "*.gcda"), recursive=True)
    out = {}
    if not gcda:
        return out
    work = tempfile.mkdtemp(prefix="gcovwork_")
    for g in gcda:                                # gcov wants .gcno beside .gcda
        base = os.path.basename(g)[:-5]
        shutil.copy(g, os.path.join(work, base + ".gcda"))
        gcno = os.path.join(build_dir, base + ".gcno")
        if os.path.exists(gcno):
            shutil.copy(gcno, os.path.join(work, base + ".gcno"))
    subprocess.run(["gcov", "-i", "-b"] + sorted(glob.glob(os.path.join(work, "*.gcda"))),
                   cwd=work, capture_output=True)
    for j in glob.glob(os.path.join(work, "*.gcov.json.gz")):
        with gzip.open(j, "rt") as fh:
            d = json.load(fh)
        for f in d.get("files", []):
            name = os.path.basename(f["file"])
            if name not in want_files:
                continue
            per = out.setdefault(name, {})
            for L in f.get("lines", []):
                per[L["line_number"]] = per.get(L["line_number"], 0) + L.get("count", 0)
    shutil.rmtree(work, ignore_errors=True)
    return out


def parse_ranges(spec):
    rs = []
    for part in spec.split(","):
        part = part.strip()
        if not part: continue
        if "-" in part:
            a, b = part.split("-", 1); rs.append((int(a), int(b)))
        else:
            rs.append((int(part), int(part)))
    return rs


def main():
    argv = sys.argv[1:]
    ranges = parse_ranges(argv[argv.index("--lines") + 1]) if "--lines" in argv else None
    json_out = argv[argv.index("--json") + 1] if "--json" in argv else None

    native = sorted(glob.glob(os.path.join(REPO, "native", "*.c")))
    if not native:
        print("no native/*.c -- nothing under test (the candidate is the sealed "
              "engine itself, whose coverage is not the question)")
        return 0
    want = {os.path.basename(n) for n in native}

    tmp = tempfile.mkdtemp(prefix="trackb_cov_")
    print("=== TRACK B COVERAGE PROBE: does each scenario reach the code under test? ===")
    print("under test: %s" % ", ".join(sorted(want)))
    so, _ = build(tmp)

    per_scen, union = {}, {}
    for i, (patch, script, tag) in enumerate(null_ab.SCEN):
        prefix = os.path.join(tmp, "run%d" % i)
        run_scenario(so, i, prefix)
        cov = gcov_lines(prefix, tmp, want)
        per_scen[tag] = cov
        for f, lines in cov.items():
            u = union.setdefault(f, {})
            for L, c in lines.items():
                u[L] = u.get(L, 0) + c

    rc = 0
    for f in sorted(want):
        u = union.get(f, {})
        exec_lines = {L for L, c in u.items() if c > 0}
        print("\n%s: %d instrumented lines, %d executed by at least one scenario"
              % (f, len(u), len(exec_lines)))
        for tag in [s[2] for s in null_ab.SCEN]:
            lines = per_scen.get(tag, {}).get(f, {})
            hit = {L for L, c in lines.items() if c > 0}
            note = ""
            if ranges:
                want_lines = {L for a, b in ranges for L in range(a, b + 1)} & set(u)
                miss = sorted(want_lines - hit)
                if miss:
                    note = "  *** MISSES %d of %d target lines (first %s) ***" % (
                        len(miss), len(want_lines), miss[:6])
                    rc = 1
                else:
                    note = "  covers all %d target lines" % len(want_lines)
            print("  %-16s %5d lines executed%s" % (tag, len(hit), note))
        if ranges:
            want_lines = {L for a, b in ranges for L in range(a, b + 1)} & set(u)
            dead = sorted(want_lines - exec_lines)
            if dead:
                print("  *** %d target line(s) reached by NO scenario: %s ***"
                      % (len(dead), dead[:12]))
                print("  A rewrite of those lines cannot be validated by this "
                      "scenario set. Add a scenario that reaches them, or state "
                      "them as out of scope in the EQUIVALENCE ledger.")
                rc = 1

    if json_out:
        with open(json_out, "w") as fh:
            json.dump({tag: {f: {str(k): v for k, v in lines.items()}
                             for f, lines in cov.items()}
                       for tag, cov in per_scen.items()}, fh, indent=1)
        print("\nwrote %s" % json_out)
    shutil.rmtree(tmp, ignore_errors=True)
    print("\nCOVERAGE PROBE: %s" % ("PASS" if rc == 0 else
                                    "FAIL -- the scenario set does not exercise "
                                    "everything it claims to validate"))
    return rc


if __name__ == "__main__":
    sys.exit(main())
