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

    Scoped to eb_render_coefs_build alone. eb_render_state_seed reads WRITTEN
    cells by definition -- they are the port's per-sample state, which is
    exactly what a seed copies -- so auditing it would report every one of them
    and the real findings would drown."""
    s = open(path).read()
    start = s.index("void eb_render_coefs_build")
    end = s.index("void eb_render_state_seed")
    body = s[start:end]
    out = {}
    for m in re.finditer(r"CF\(\s*a1\s*,\s*(\d+)\s*\)", body):
        out.setdefault(int(m.group(1)),
                       []).append(s[:start + m.start()].count("\n") + 1)
    for m in re.finditer(r"CF\(\s*a1\s*,\s*(\d+)\s*\+\s*off\s*\)", body):
        for off in (0, 480):
            out.setdefault(int(m.group(1)) + off,
                           []).append(s[:start + m.start()].count("\n") + 1)
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
