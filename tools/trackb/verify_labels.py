#!/usr/bin/env python3
"""verify_labels.py — does a module range actually contain the module it claims?

WHY THIS EXISTS. docs/trackb/MODULE_ORDER.md and PLAN.md labelled
src/voice_render.c:964-1021 "M2 DCO" and 1718-1830 "M8 VCA/output". Checked
against the cells those ranges touch, 964-1021 is the ENV1 ADSR and 1718-1830 is
the DCO. The labels were not merely imprecise -- they were swapped between two
different subsystems, and a rewrite scheduled from them would have been driven
by DCO.md while editing envelope code.

Nobody noticed because no tool ever compared a label to evidence. This does.

METHOD, and its limits. For each declared range, extract every JF/JI cell offset
it touches, then ask which blueprint document claims each cell. A range is
CONSISTENT when the document matching its label claims a clear plurality of its
cells. This is evidence, not proof: a cell may appear in more than one document,
and a document may be incomplete. It is designed to catch a label pointing at the
wrong SUBSYSTEM, which is the error that actually occurred.

    python3 tools/trackb/verify_labels.py
"""
import os, re, sys, collections

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC  = os.path.join(REPO, "src", "voice_render.c")
DOCS = os.path.join(REPO, "docs", "trackb")

# The declared ranges, from MODULE_ORDER.md. Edit here when a module is added.
RANGES = [
    ("654-693",   "conditioner+gate", None),
    ("964-1021",  "ENV1 ADSR",        "ENV.md"),
    ("1022-1075", "ENV2 ADSR",        "ENV.md"),
    ("1076-1128", "PWM",              "DCO.md"),
    ("1129-1149", "noise SVF",        None),
    ("1150-1229", "mix",              None),
    ("1298-1400", "envelope",         "ENV.md"),
    ("1516-1640", "VCF",              "VCF.md"),
    ("1718-1830", "DCO",              "DCO.md"),
]

CELL = re.compile(r"J[FIU]\(a1,\s*(\d+)\)")

def cells_in(lo, hi):
    with open(SRC) as f:
        lines = f.readlines()
    out = set()
    for ln in range(lo - 1, min(hi, len(lines))):
        out.update(int(m) for m in CELL.findall(lines[ln]))
    return out

def doc_cells():
    """cell -> set of documents that mention it."""
    owner = collections.defaultdict(set)
    for fn in os.listdir(DOCS):
        if not fn.endswith(".md"):
            continue
        try:
            txt = open(os.path.join(DOCS, fn), errors="replace").read()
        except OSError:
            continue
        for m in re.findall(r"\b(\d{3,6})\b", txt):
            owner[int(m)].add(fn)
    return owner

def main():
    owner = doc_cells()
    bad = 0
    print("=== MODULE LABEL VERIFICATION (evidence, not proof) ===\n")
    for rng, label, expect in RANGES:
        lo, hi = (int(x) for x in rng.split("-"))
        cs = cells_in(lo, hi)
        if not cs:
            print("  %-12s %-18s no cells found -- cannot verify" % (rng, label))
            continue
        tally = collections.Counter()
        for c in cs:
            for d in owner.get(c, ()):
                tally[d] += 1
        top = tally.most_common(3)
        best = top[0][0] if top else "(none)"
        status = "ok"
        if expect:
            hit = tally.get(expect, 0)
            if hit == 0:
                status = "*** MISMATCH: no cell of this range appears in %s ***" % expect
                bad += 1
            elif top and top[0][0] != expect and top[0][1] > hit * 2:
                status = ("*** SUSPECT: %s claims %d cells, %s only %d ***"
                          % (top[0][0], top[0][1], expect, hit))
                bad += 1
        print("  %-12s %-18s %2d cells   top: %-28s %s"
              % (rng, label, len(cs),
                 ", ".join("%s:%d" % (d, n) for d, n in top) or "-", status))
    print("\n%s" % ("ALL LABELS CONSISTENT WITH THE CELLS THEY TOUCH"
                    if not bad else "*** %d LABEL(S) INCONSISTENT ***" % bad))
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
