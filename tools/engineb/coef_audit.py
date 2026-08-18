#!/usr/bin/env python3
"""coef_audit.py -- refuse any cell in eb_coefs.c that the VOICE FUNCTION writes.

WHY THIS EXISTS. eb_coefs.c caches per-voice cells as coefficients. A cell the
voice function writes every sample is NOT a coefficient, and caching one freezes
a moving value in a way the generation guard can never detect (eb_noisemix's
3536 is the documented example).

eb_coefs.c's own header claimed every cell had been checked for a writer. The
check was `JF(a1, N) =` -- and it MISSED cells 4736/4752/4768, the three DCO
oscillator levels, because src/voice_render.c copies them with JI, as ints.
Cached from a power-on state they are 0, so the DCO emitted silence and the
whole voice chain nulled at 0.0 dB rel. Found by running the 1b-0 gate, not by
reading. This script is that check, done properly and mechanically, so the same
class cannot come back: BOTH accessors, and it runs in the gate battery.

A cell may legitimately appear here after being written -- the FX cfgs gather
from MASTER cells, and src/master_render.c is a different translation unit --
so only PER-VOICE cells (the `a1` base) are audited against voice_render.c.
"""
import os, re, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
VOICE = os.path.join(REPO, "src", "voice_render.c")
COEFS = os.path.join(REPO, "engine_b", "eb_coefs.c")

def written_cells(path):
    """Every per-voice cell src/voice_render.c ASSIGNS, through either accessor.
    `= =` (a comparison) is excluded; `+=` etc. do not occur in this file."""
    s = open(path).read()
    out = {}
    for m in re.finditer(r"J([FI])\(\s*a1\s*,\s*(\d+)\s*\)\s*=(?!=)", s):
        line = s[:m.start()].count("\n") + 1
        out.setdefault(int(m.group(2)), []).append((m.group(1), line))
    return out

def read_cells(path):
    """Every per-voice cell the COEFFICIENT CONSTRUCTOR reads through CF(a1, N).

    Scoped to the COEFFICIENT CONSTRUCTORS. eb_render_state_seed reads WRITTEN
    cells by definition -- they are the port's per-sample state, which is
    exactly what a seed copies -- and eb_render_events_mirror re-reads cell 320
    at an event boundary for the documented reason at its site. Auditing either
    would report every one of those and the real findings would drown.

    ⚑ THE SCOPE USED TO EMPTY ITSELF SILENTLY. It took the slice from
    "void eb_render_coefs_build" to "void eb_render_state_seed" -- today
    eb_coefs.c:344-393. The per-voice coefficient construction is
    eb_coefs_voice, at :42, OUTSIDE that slice. So the audit reported
    "0 per-voice cells cached" about a file that caches many, and its own teeth
    case (plant CF(a1, 4736) at :161, require a refusal) planted into a region
    the scan never read: "NOT REFUSED -- the audit is blind", 2026-08-17.

    The defect was not the allow-list. It was that an allow-list which matches
    NOTHING still returns cleanly, and an audit over an empty scan passes. So
    the constructors are named explicitly, and every one of them MUST be found
    and MUST be non-empty -- otherwise this exits non-zero saying so. A check
    whose subject has moved must fail loudly, never report all-clear."""
    s = open(path).read()
    out = {}
    # ⚠ THE PAREN IS LOAD-BEARING. This read `key = "void " + fn` and counted
    # SUBSTRING occurrences, so when O2 split the constructor into
    # eb_render_coefs_build + eb_render_coefs_build_shared, the count for
    # "void eb_render_coefs_build" became 2 and the audit exited BROKEN on a
    # clean tree. It was right to stop -- its subject had moved -- but it named
    # the wrong reason. A prefix that swallows a longer name is the same defect
    # as a \b that cannot reach inside an identifier (playbook 59).
    #
    # eb_render_coefs_build is now three functions, and all three are named:
    # the per-voice constructor, the wrapper, and the shared tail. Only the
    # per-voice one is REQUIRED to contribute CF(a1, N) reads -- the other two
    # read base cells, not per-voice cells, so an empty contribution from them
    # is correct rather than the blindness this guard exists to catch.
    for fn in ("eb_coefs_voice", "eb_render_coefs_build",
               "eb_render_coefs_build_shared"):
        key = "void " + fn + "("
        if s.count(key) != 1:
            raise SystemExit(
                "COEFFICIENT AUDIT: BROKEN -- expected exactly one 'void %s' in "
                "%s, found %d. The constructor was renamed, removed or "
                "duplicated; fix this list rather than letting the audit scan "
                "an empty region and report PASS." % (fn, path, s.count(key)))
        lo = s.index(key)
        m = re.search(r"\nvoid ", s[lo + 1:])
        hi = lo + 1 + m.start() if m else len(s)
        seg, before = s[lo:hi], s[:lo]
        n0 = len(out)
        for m2 in re.finditer(r"CF\(\s*a1\s*,\s*(\d+)\s*\)", seg):
            out.setdefault(int(m2.group(1)),
                           []).append(before.count("\n") + 1
                                      + seg[:m2.start()].count("\n"))
        for m2 in re.finditer(r"CF\(\s*a1\s*,\s*(\d+)\s*\+\s*off\s*\)", seg):
            for off in (0, 480):
                out.setdefault(int(m2.group(1)) + off,
                               []).append(before.count("\n") + 1
                                          + seg[:m2.start()].count("\n"))
        if len(out) == n0 and fn == "eb_coefs_voice":
            raise SystemExit(
                "COEFFICIENT AUDIT: BROKEN -- %s contributed no CF(a1, N) reads. "
                "That is how this audit went blind before: it scanned a region "
                "with nothing in it and called that PASS." % fn)
    return out

def main():
    w = written_cells(VOICE)
    r = read_cells(COEFS)
    bad = []
    for cell in sorted(r):
        if cell in w:
            bad.append((cell, r[cell], w[cell]))
    if bad:
        print("COEFFICIENT AUDIT: FAIL -- %d cell(s) cached that the voice "
              "function WRITES" % len(bad))
        for cell, rl, wl in bad:
            print("  cell %-6d read by eb_coefs.c at %s; written in "
                  "voice_render.c at %s"
                  % (cell, rl, ", ".join("%s:%d" % x for x in wl)))
        print("  A written cell is per-sample state, not a coefficient. Find "
              "the cell it is copied FROM and cache that one.")
        return 1
    print("COEFFICIENT AUDIT: PASS -- %d per-voice cells cached, none of them "
          "written by src/voice_render.c (both JF and JI checked)" % len(r))
    return 0

if __name__ == "__main__":
    sys.exit(main())
