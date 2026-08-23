#!/usr/bin/env python3
"""forkbit_gate.py -- FORK-vs-FORK BIT compare at SHIP flags (b24 SS5.4).

The tool the lever plan found missing: sonic_gate compares trunk-vs-fork and
null_b's scenarios carry no mid-stream program change. This builds the
shipping fork TWICE -- once at SHIP, once at SHIP + the candidate's extra
-D's -- renders every null_b scenario PLUS a mid-note program-change
scenario, and compares the streams BYTE FOR BYTE. An EXACTLY-0 lever must
read 0 differing floats on every scenario.

usage: python3 tools/engineb/forkbit_gate.py -DEB_LFO_TAIL_CR=1 [more -D...]
       add --quick for the reduced scenario set.
exit 0 = bit-identical everywhere. Anything else = the lever is not EXACTLY 0.
"""
import os, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "trackb"))
import null_b, null_ab
from ab_wavs import SHIP, build

# the scenario null_b never had: a PROGRAM CHANGE while a note is held --
# the exact path L-A/L-B change (re-seed vs hot path). Patch 5 -> 20 mid-hold.
PROGCHANGE = [
    (5, [('on', 60, 100), ('render', 8000), ('prog', 20),
         ('render', 8000), ('off', 60), ('render', 8000)],
        "mid-note program change 5->20"),
    (20, [('render', 2000), ('on', 48, 100), ('on', 55, 100),
          ('render', 6000), ('prog', 2), ('render', 6000), ('prog', 20),
          ('render', 6000), ('off', 48), ('off', 55), ('render', 8000)],
         "double program change under a chord"),
]

def main():
    extra = [a for a in sys.argv[1:] if a.startswith("-D")]
    quick = "--quick" in sys.argv
    if not extra:
        raise SystemExit("give the candidate's -D flags")
    scen = null_b.scenarios(quick=quick) + PROGCHANGE
    null_b.SCEN_OVERRIDE = scen
    tmp = tempfile.mkdtemp(prefix="forkbit_")
    print("[forkbit] SHIP vs SHIP + %s   (%d scenarios)" % (" ".join(extra), len(scen)))
    ref  = build(tmp, "ref",  list(SHIP))
    cand = build(tmp, "cand", list(SHIP) + extra)
    sys.path.insert(0, os.path.join(HERE, "..", "verify"))
    import truth
    bank = open(truth.BANK, "rb").read()
    fails = 0
    for (patch, ops, name) in scen:
        a = null_ab.render_script(null_ab.load(ref),  bank, 44100.0, patch, ops)
        b = null_ab.render_script(null_ab.load(cand), bank, 44100.0, patch, ops)
        if len(a) != len(b):
            print("  %-38s LENGTH MISMATCH %d vs %d" % (name, len(a), len(b)))
            fails += 1; continue
        nd = sum(1 for x, y in zip(a, b) if x != y)
        if nd:
            print("  %-38s %d/%d floats differ" % (name, nd, len(a)))
            fails += 1
        else:
            print("  %-38s bit-identical (%d floats)" % (name, len(a)))
    print("FORKBIT: %s" % ("EXACTLY 0" if fails == 0 else "%d scenarios DIFFER" % fails))
    return 0 if fails == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
