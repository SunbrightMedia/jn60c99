#!/usr/bin/env python3
"""forkbit.py -- FORK vs FORK, BIT FOR BIT. The tool b24 said was missing.

WHY IT EXISTS. The headroom levers (b29) change the SHIPPING FORK, not the
trunk, so `make engineb` cannot judge them: it proves the TRUNK is bit-exact
against the plugin, and every one of these levers is compiled out of the trunk.
The fork's own gate (`sonic_gate.py`) is SPECTRAL -- it bounds an approved
audible relaxation in dB and can never say "EXACTLY 0".

So a lever that claims to change NOTHING on the fork had no gate at all. b24
wrote it down: "The fork-vs-fork bit compare does not exist as a named tool.
I looked." It still did not exist on 2026-08-27. This is it.

WHAT IT DOES. Builds the SHIPPING FORK twice -- once with the lever's keep-alive
flag forced on (the BEFORE), once as it ships (the AFTER) -- renders the same
scenarios through both, and compares the sample streams BYTE FOR BYTE.
0 differing samples, or the lever is not what it claims.

WHY BYTE-FOR-BYTE AND NOT dB. These levers assert EXACT equality: a dead store
removed, a value nothing reads, a recompute that yields the identical bits. A
dB threshold would pass a lever that is subtly wrong, and "subtly wrong" in a
bit-exact engine is the whole class of defect this project exists to prevent.
There is no threshold here. The count of differing samples must be 0.

THE OFF-SWITCH CONVENTION. Each lever's guard carries `|| EB_HEADROOM_KEEP_DEAD`
(or its own named keep flag), so the BEFORE side is the SAME SOURCE compiled
with the work kept. That is deliberate: comparing against a git revision would
compare two different trees and confound the lever with anything else that
moved.

usage:
  forkbit.py --keep EB_HEADROOM_KEEP_DEAD          one lever
  forkbit.py --keep EB_HEADROOM_KEEP_DEAD --keep EB_LFO_TAIL_CR=0 --on EB_LFO_TAIL_CR=1
  forkbit.py --selftest                            SEEN TO FAIL (must report differences)
"""
import sys, os, argparse, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import null_b
from ab_wavs import SHIP


def build_side(tmp, tag, extra):
    """One .so at SHIPPING FORK flags plus `extra`. Mirrors ab_wavs.build."""
    so = os.path.join(tmp, "lib_%s.so" % tag)
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + list(SHIP) + list(extra)
    try:
        null_b.build(so, ["standalone"])
    finally:
        null_b.CFLAGS = base
    return so


def compare(before, after, quick):
    """Render both sides over every scenario; count DIFFERING SAMPLES."""
    tmp = tempfile.mkdtemp(prefix="forkbit_")
    try:
        # render_side returns the worker's whole pickle; the audio lives under
        # "streams" keyed by scenario tag (null_b.py:1142).
        b = null_b.render_side(before, quick, tmp, "before")["streams"]
        a = null_b.render_side(after, quick, tmp, "after")["streams"]
        total_diff = 0
        total_samp = 0
        rows = []
        for _, _, tag in null_b.scenarios(quick):
            xb, xa = b[tag], a[tag]
            if len(xb) != len(xa):
                rows.append((tag, -1, len(xb), len(xa)))
                total_diff += max(len(xb), len(xa))
                continue
            d = sum(1 for i in range(len(xb)) if xb[i] != xa[i])
            rows.append((tag, d, len(xb), len(xa)))
            total_diff += d
            total_samp += len(xb)
        return rows, total_diff, total_samp
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--keep", action="append", default=[],
                    help="define(s) for the BEFORE side (work kept alive)")
    ap.add_argument("--on", action="append", default=[],
                    help="define(s) for the AFTER side (lever active)")
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--selftest", action="store_true",
                    help="prove the runner CAN see a difference")
    args = ap.parse_args()

    if args.selftest:
        # SEEN TO FAIL. Compare the ship fork against the fork with a knob that
        # genuinely changes arithmetic. If this reports 0 differing samples the
        # runner is blind and every green from it is worthless.
        keep, on = [], ["-DEB_CR_NP=2"]
        print("SELFTEST: ship fork vs the same fork with EB_CR_NP=2")
        print("          (a real arithmetic change; MUST report differences)")
    else:
        keep = ["-D%s" % k if "=" not in k else "-D%s" % k for k in args.keep] or \
               ["-DEB_HEADROOM_KEEP_DEAD=1"]
        on = ["-D%s" % k for k in args.on]

    tmp = tempfile.mkdtemp(prefix="forkbit_build_")
    try:
        print("BEFORE flags: SHIP + %s" % (" ".join(keep) or "(none)"))
        print("AFTER  flags: SHIP + %s" % (" ".join(on) or "(none)"))
        before = build_side(tmp, "before", keep)
        after = build_side(tmp, "after", on)
        rows, diff, samp = compare(before, after, args.quick)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    bad = [r for r in rows if r[1] != 0]
    for tag, d, lb, la in rows:
        if d != 0:
            print("  %-28s %s" % (tag, "LENGTH %d vs %d" % (lb, la) if d < 0
                                  else "%d differing samples" % d))
    print("\n%d scenario(s), %d samples compared, %d differing"
          % (len(rows), samp, diff))

    if args.selftest:
        if diff == 0:
            print("[forkbit] SELFTEST FAILED -- the runner sees NOTHING. "
                  "Any green it reports is worthless.")
            return 1
        print("[forkbit] SELFTEST PASS -- the runner detects a real change "
              "(%d samples). A 0 from it therefore means something." % diff)
        return 0

    if diff:
        print("[forkbit] RED -- the lever is NOT bit-exact on the fork. "
              "%d differing samples across %d scenario(s)." % (diff, len(bad)))
        return 1
    print("[forkbit] GREEN -- EXACTLY 0 differing samples over %d scenarios. "
          "The lever changes no output bit on the shipping fork." % len(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
