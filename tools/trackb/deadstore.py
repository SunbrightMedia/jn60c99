#!/usr/bin/env python3
"""deadstore.py — decide, BY EXECUTION, whether a store in src/voice_render.c is dead.

WHY THIS EXISTS
---------------
Engine B has to drop work that the sealed engine does. The cheapest work to drop
is a store nothing reads. But this project's recurring failure mode is a gate
that is green and wrong, and "dead store" has been asserted here on three
different and unequal grades of evidence:

    src/voice_render.c:974    a mutant was built and the full evidence set ran
    src/voice_render.c:1132   "overwritten two lines later" -- read off the page
    src/voice_render.c:1143   "no readers"                  -- read off the page
    src/voice_render.c:1720   "executes 240k-737k times"    -- reach, not liveness

Only the first is a proof. Reading a C file cannot tell you a store is dead in
this engine: the state array is a flat 12 MB byte block addressed by numeric
offset from `base`, aliased by two macros (JF/JI) over the SAME memory, shared
between voice_render, master_render, recall and the probes, and several cells
have register-promoted shadow locals (`_s4656` and friends) that make the memory
store and the value the code actually consumes two different things. A grep for
an offset finds textual matches, not readers.

WHAT THIS TOOL DOES
-------------------
For a given line it builds four candidate engines and runs the FULL evidence set
against each -- 30 scenarios + 384 full-bank comparisons + 24 fuzz seeds, the
same set null_ab.py --all uses -- but scored EXACTLY, not against a threshold:

  1. CONTROL      an unmutated rebuild. Must be bit-identical everywhere. If it
                  is not, the build path or the reference is broken and every
                  other result this run produces is meaningless. This is here
                  because a mutation harness that quietly compiles the wrong tree
                  reports every mutant as "no effect" -- i.e. reports everything
                  as DEAD.

  2. REACH        the line is left alone and instrumented: a counter is bumped
                  where it stands, and the voice output is perturbed by 0.1% for
                  every sample after the counter is non-zero. This mutant MUST
                  FAIL. If it passes, the line never executed in this evidence
                  set, and a "no effect" result from the mutants below says
                  nothing about liveness -- it only says the experiment never
                  happened. Reach and liveness are different questions and this
                  tool answers them separately, on purpose.

  3-5. VALUE      the stored value is replaced with three absurd constants:
                  12345.0, -7.7e18 and 0.0. The RHS is still evaluated and any
                  shadow-local assignment on the same line still receives the
                  REAL value, so only the MEMORY STORE is corrupted. Three
                  values, not one, because a consumer can saturate: the canary
                  work already measured a cell where multiplying by 3 changed
                  nothing and adding 1 changed everything. One probe value is a
                  one-sided test.

VERDICT
    DEAD       control clean, REACH failed (line executes), and all three value
               mutants bit-identical across all 438 comparisons.
    LIVE       some value mutant changed some output. The differing count is
               reported, because "caught by 1 of 438" and "caught by 438 of 438"
               are different facts.
    UNREACHED  REACH passed: the line did not execute. NOT a dead-store result.
    BROKEN     the control was not bit-identical.

"Bit-identical" here means the float sample streams compare equal element by
element -- not RMS residual == 0, and not a dB threshold. A dead store must not
move the output by one ULP.

USAGE
    deadstore.py 974 1132 1143 1720          # full evidence set, all lines
    deadstore.py --quick 1720                # scenarios only, for iterating
    deadstore.py --file src/voice_render.c 974
"""
import sys, os, ctypes, re, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth
import null_ab as N

DEFAULT_FILE = "src/voice_render.c"

# The three probe values. See the header: one value cannot distinguish "nothing
# reads this" from "something reads it and saturates".
PROBES = [("big", "12345.0f"), ("huge", "-7.7e18f"), ("zero", "0.0f")]

STORE_RE = re.compile(r"^(\s*)J([FI])\(a1,\s*(\d+)\)\s*=\s*(.*);\s*$")

# The unique output line, shared with null_ab's "tailquiet" mutation.
OUT_ANCHOR = "  *outL = JF(a1, 10672);"
# Byte offset of the reach counter: past the highest cell any engine source
# touches (~11,022,xxx), inside the calloc-zeroed 12 MB context. Same slot
# null_ab's "idleskip" mutation uses, for the same reason -- no aliasing, no
# leakage between scenarios.
COUNTER = 11900000


def parse_store(path, lineno):
    """Return (indent, kind, cell, locals, expr, raw) for the target line."""
    lines = open(path).read().split("\n")
    if not (1 <= lineno <= len(lines)):
        raise SystemExit("%s has no line %d" % (path, lineno))
    raw = lines[lineno - 1]
    m = STORE_RE.match(raw)
    if not m:
        raise SystemExit(
            "line %d of %s is not a recognised state store:\n    %s\n"
            "This tool only handles `JF(a1, N) = ...;` / `JI(a1, N) = ...;`, "
            "optionally with shadow-local assignments chained on the same line. "
            "Anything else would need a hand-written mutation, and a hand-written "
            "mutation that does not do what it claims is how a dead-store result "
            "goes green and wrong." % (lineno, path))
    indent, kind, cell, rhs = m.group(1), m.group(2), int(m.group(3)), m.group(4)
    parts = [p.strip() for p in rhs.split("=")]
    locs, expr = parts[:-1], parts[-1]
    for l in locs:
        if not re.match(r"^_s\d+$", l):
            raise SystemExit("line %d: unexpected chained assignment target %r "
                             "-- refusing to guess its semantics" % (lineno, l))
    return indent, kind, cell, locs, expr, raw


def _strip_native(tmp):
    """Remove the native/ shadow so src/<file> is what actually compiles.

    THIS IS LOAD-BEARING. null_ab.build() reproduces `make juno_cand.so`, in
    which native/voice_render.c SHADOWS src/voice_render.c. That fork is
    functionally identical today but is not textually identical -- it carries a
    31-line header, so its line numbers are offset from src/'s by 31. Mutating
    "line 974" of the file that really compiles would therefore corrupt a
    DIFFERENT statement than the one this tool prints, and the result would be a
    confident, precise, wrong answer about a line nobody tested. The claim being
    made here is about the SEALED file, so the sealed file is what gets built --
    for the control and for every mutant alike.
    """
    import shutil
    nat = os.path.join(tmp, "native")
    if os.path.isdir(nat):
        shutil.rmtree(nat)


def _replace_line(tmp, lineno, new_text):
    path = N._mut_target(tmp, os.path.basename(DEFAULT_FILE))
    lines = open(path).read().split("\n")
    lines[lineno - 1] = new_text
    open(path, "w").write("\n".join(lines))
    return path


def make_value_mutation(lineno, target, value):
    """Corrupt ONLY the memory store; RHS still evaluated, shadow locals still
    get the real value. Returns a callable for null_ab.build()."""
    indent, kind, cell, locs, expr, raw = target
    ctype = "float" if kind == "F" else "int32_t"
    body = ["{ %s _ds_v = (%s)(%s);" % (ctype, ctype, expr)]
    for l in locs:
        body.append(" %s = _ds_v;" % l)
    body.append(" (void)_ds_v; J%s(a1, %d) = %s; }" % (kind, cell, value))
    new = indent + "".join(body)

    def mutate(tmp):
        _strip_native(tmp)
        path = N._mut_target(tmp, os.path.basename(DEFAULT_FILE))
        lines = open(path).read().split("\n")
        assert lines[lineno - 1] == raw, (
            "deadstore: line %d of the build tree is not the line that was "
            "parsed. Refusing to mutate a line I have not read." % lineno)
        _replace_line(tmp, lineno, new)
    return mutate, new


def make_reach_mutation(lineno, target):
    """Leave the store alone; prove the line executes by making its execution
    audible. MUST fail the gate, or the value mutants prove nothing."""
    indent, kind, cell, locs, expr, raw = target
    new = indent + "JI(base, %d) = JI(base, %d) + 1; " % (COUNTER, COUNTER) + raw.strip()

    def mutate(tmp):
        _strip_native(tmp)
        path = N._mut_target(tmp, os.path.basename(DEFAULT_FILE))
        s = open(path).read()
        assert s.count(OUT_ANCHOR) == 1, "output anchor not unique"
        s = s.replace(OUT_ANCHOR,
                      "  if ( JI(base, %d) ) JF(a1, 10672) = JF(a1, 10672) * 1.001f;\n"
                      % COUNTER + OUT_ANCHOR, 1)
        lines = s.split("\n")
        assert lines[lineno - 1] == raw, (
            "deadstore: reach probe target line moved after the output-anchor "
            "edit -- aborting rather than instrumenting the wrong line.")
        lines[lineno - 1] = new
        open(path, "w").write("\n".join(lines))
    return mutate


# --------------------------------------------------------------- exact scoring
# The reference side of every comparison is the SAME libjuno.so for every mutant,
# so it is rendered once and cached as raw bytes. Cheap, but it also removes a
# failure mode: with the reference re-rendered per mutant, a reference that
# drifted mid-run (a rebuild racing the tool) would show up as a mutant effect.
_REFCACHE = {}


def _cases(quick):
    """The evidence set, as a list of (sr, patch, script, label)."""
    cases = [(N.SR, p, sc, "scen:" + t) for p, sc, t in N.SCEN]
    if quick:
        return cases
    for sr in N.FULL_RATES:
        for patch in range(64):
            for name, script in sorted(N.FULL_SCRIPTS.items()):
                cases.append((sr, patch, script, "full:%g/%d/%s" % (sr, patch, name)))
    os.environ['FUZZ_PARAMS'] = '1'
    import fuzz_diff as F
    if not F.INCLUDE_PARAMS:
        raise SystemExit("ABORT: fuzz_diff imported without FUZZ_PARAMS, so this "
                         "run would drop live parameter edits and report a weaker "
                         "gate as the stronger one.")
    for seed in range(24):
        rate, patch, ev, total = F.gen_script(seed)
        cases.append((rate, patch, ev, "fuzz:%d" % seed))
    return cases


def _refbytes(ref, bank, cases):
    import array
    out = []
    for i, (sr, patch, script, label) in enumerate(cases):
        if i not in _REFCACHE:
            _REFCACHE[i] = array.array('f', N.render_script(ref, bank, sr, patch,
                                                            script)).tobytes()
        out.append(_REFCACHE[i])
    return out


def exact_score(ref, cand, bank, cases):
    """EXACT, bytewise. Returns (ndiff, ntotal, first_few_labels)."""
    import array
    refs = _refbytes(ref, bank, cases)
    diff = 0; where = []
    for i, (sr, patch, script, label) in enumerate(cases):
        c = array.array('f', N.render_script(cand, bank, sr, patch, script)).tobytes()
        if c != refs[i]:
            diff += 1
            if len(where) < 4:
                where.append(label)
    return diff, len(cases), where


def evaluate(ref, bank, mutate, cases):
    """Build a candidate and score it EXACTLY. Returns (ndiff, ntotal, where)."""
    fd, so = tempfile.mkstemp(suffix=".so", prefix="deadstore_")
    os.close(fd)
    try:
        N.build(so, mutate=mutate)
        return exact_score(ref, N.load(so), bank, cases)
    finally:
        os.unlink(so)


def run_line(ref, bank, path, lineno, quick):
    target = parse_store(path, lineno)
    indent, kind, cell, locs, expr, raw = target
    print("\n=== %s:%d  ->  cell %d ===" % (path, lineno, cell))
    print("    %s" % raw.strip())
    if locs:
        print("    NOTE: shadow local(s) %s on this line keep the REAL value; "
              "only the memory store is corrupted." % ", ".join(locs))

    cases = _cases(quick)
    ctl_d, ctl_n, _ = evaluate(ref, bank, _strip_native, cases)
    print("  CONTROL  (clean rebuild)     %d/%d differ" % (ctl_d, ctl_n))
    if ctl_d:
        print("  VERDICT: BROKEN -- the unmutated rebuild is not bit-identical to "
              "the reference. Nothing else this run reports is meaningful.")
        return "BROKEN", ctl_n

    rch_d, rch_n, _ = evaluate(ref, bank, make_reach_mutation(lineno, target), cases)
    print("  REACH    (line instrumented) %d/%d differ" % (rch_d, rch_n))
    if rch_d == 0:
        print("  VERDICT: UNREACHED -- the line never executed in this evidence "
              "set, so 'the mutants changed nothing' is vacuous. NOT a dead store "
              "result; extend the scenario set first.")
        return "UNREACHED", rch_n

    worst = 0
    for name, val in PROBES:
        mut, new = make_value_mutation(lineno, target, val)
        d, n, where = evaluate(ref, bank, mut, cases)
        print("  VALUE %-5s -> %-9s      %d/%d differ%s"
              % (name, val, d, n, "" if not where else "   e.g. " + ", ".join(where)))
        worst = max(worst, d)
    if worst == 0:
        print("  VERDICT: DEAD (PROVEN by execution) -- the line executes, and "
              "corrupting the stored value with three different absurd constants "
              "changes NOTHING across %d comparisons." % rch_n)
        return "DEAD", rch_n
    print("  VERDICT: LIVE -- the store is read. Worst probe changed %d of %d "
          "comparisons." % (worst, rch_n))
    return "LIVE", rch_n


def main():
    argv = sys.argv[1:]
    quick = "--quick" in argv
    argv = [a for a in argv if a != "--quick"]
    path = DEFAULT_FILE
    if "--file" in argv:
        i = argv.index("--file"); path = argv[i + 1]; del argv[i:i + 2]
    lines = [int(a) for a in argv if a.isdigit()]
    if not lines:
        raise SystemExit(__doc__)

    truth.require()
    bank = open(truth.BANK, "rb").read()
    import freshlib
    freshlib.check()
    ref = N.load(os.path.join(REPO, "libjuno.so"))

    print("=== DEAD STORE PROOF: %s ===" % ("SCENARIOS ONLY (--quick): a result "
          "here is SUSPECTED, never DEAD" if quick else
          "30 scenarios + 384 full-bank + 24 fuzz, scored EXACTLY"))
    res = [(l, run_line(ref, bank, os.path.join(REPO, path), l, quick)) for l in lines]

    print("\n%-8s %-8s %-10s %s" % ("LINE", "CELL", "VERDICT", "EVIDENCE"))
    bad = 0
    for l, (v, n) in res:
        cell = parse_store(os.path.join(REPO, path), l)[2]
        if quick and v == "DEAD":
            v = "SUSPECTED"
        print("%-8d %-8d %-10s %d comparisons" % (l, cell, v, n))
        if v in ("BROKEN",):
            bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
