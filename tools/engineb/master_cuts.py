#!/usr/bin/env python3
"""master_cuts.py -- where src/master_render.c can be CUT into modules, measured.

Engine B's voice modules were not carved by eye. Each boundary was chosen by a
LIVE-VARIABLE analysis: a range that has few values crossing its edges lifts
into a function cleanly, and one that has many does not. eb_lfo's range had four
live-in and ZERO live-out, and that is why it lifted.

The master chain (task 1b-1) needs the same treatment before a line of it is
written, so this reports the CUT WIDTH at every line of juno_master_render: the
number of decompiler locals assigned before that line and read after it. A low
cut width is a candidate boundary; a high one is a place a module boundary would
have to marshal a dozen values and would not be a module at all.

This measures ONLY the local-variable crossing. It says nothing about which
cells carry state, and a low-cut-width range can still be a bad module if its
cells are shared -- the read-before-write classification and THE FOUR WAYS THE
SCRIPT LIES (CLAUDE.md) still apply to every cell inside a chosen range.
"""
import re, sys, os

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(REPO, "src", "master_render.c")
BODY_LO, BODY_HI = 826, 2945          # first executable line .. last

DECL = re.compile(r"\s*(float|double|int|signed|unsigned|bool|_DWORD|_BYTE|"
                  r"char|long)[ *].*v\d+;")


def main():
    lines = open(SRC).read().split("\n")
    body = [(i + 1, l) for i, l in enumerate(lines)
            if BODY_LO <= i + 1 <= BODY_HI and not DECL.match(l)]
    # first assignment line and last use line of every local
    first_asg, last_use = {}, {}
    for ln, l in body:
        for m in re.finditer(r"\b(v\d+)\s*=(?!=)", l):
            first_asg.setdefault(m.group(1), ln)
        for m in re.finditer(r"\bv\d+\b", l):
            last_use[m.group(0)] = ln
    width = {}
    for ln, _ in body:
        width[ln] = sum(1 for n, a in first_asg.items()
                        if a < ln and last_use.get(n, 0) >= ln)
    if "--width" in sys.argv:
        for ln, _ in body:
            print("%d\t%d" % (ln, width[ln]))
        return 0
    # report the narrowest cuts, spread out so they are candidate BOUNDARIES
    cand = sorted(width.items(), key=lambda kv: (kv[1], kv[0]))
    chosen, used = [], []
    for ln, w in cand:
        if all(abs(ln - c) >= 40 for c in used):
            chosen.append((ln, w)); used.append(ln)
        if len(chosen) >= 25:
            break
    print("juno_master_render: %d executable lines, %d locals"
          % (len(body), len(first_asg)))
    print("narrowest cut points, >=40 lines apart (line, locals crossing):")
    for ln, w in sorted(chosen):
        print("  :%-5d  %2d crossing   %s" % (ln, w, lines[ln - 1].strip()[:58]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
