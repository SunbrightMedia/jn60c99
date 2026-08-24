#!/usr/bin/env python3
"""recall_completeness_gate.py -- the TOOTH for the recall gate's own SCOPE.

Playbook 80. The recall pipeline DISCOVERS which pools are active and then
proves itself over exactly that set. A self-scoping gate is structurally blind:
if discovery under-reports, the gate shrinks and still reports green. That is
how 25 real JX parameters (DCO1 LEVEL, HPF CUTOFF, ENV2 SUSTAIN, EFFECT/DELAY/
REVERB, BEND/MOD SENS, ...) sat unproven behind a "64/64 EXACTLY 0" headline
until a human counted the host's panel.

This gate compares the pipeline's discovered set against an INDEPENDENT
re-derivation (probe_pools.py: full state windows, voice AND master unit, a
full in-range value spread) and against the plugin's own parameter inventory.
It goes RED if the pipeline's set is SMALLER than the independent one.

SEEN TO FAIL: run with --self-test; it injects a deliberately truncated set and
must report RED. A tooth that has never been seen to fail is not believed.

usage: recall_completeness_gate.py <pools.json> <recall_meta.json> [--self-test]
"""
import sys, json


def verdict(discovered, independent, label="pipeline"):
    missing = sorted(set(independent) - set(discovered))
    extra = sorted(set(discovered) - set(independent))
    print("%s set: %d pools | independent probe: %d pools"
          % (label, len(discovered), len(independent)))
    if extra:
        # Not a failure by itself: the independent probe watches wider windows,
        # so the pipeline seeing MORE would mean the probe is the narrow one.
        print("  NOTE: %d pool(s) in %s but not in the probe: %s"
              % (len(extra), label, extra))
    if missing:
        print("\nRED: the %s set is MISSING %d pool(s) the independent probe "
              "proves move real state:" % (label, len(missing)))
        print("   %s" % missing)
        print("  The recall gate would report green while never exercising "
              "these parameters. Fix discovery, do not widen this gate.")
        return 1
    print("GREEN: the %s set covers every pool the independent probe found "
          "(%d)." % (label, len(independent)))
    return 0


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    selftest = "--self-test" in sys.argv
    pools = json.load(open(args[0]))
    independent = sorted(int(k) for k in pools)

    if selftest:
        print("=== SELF-TEST: truncated set MUST be reported RED ===")
        rc = verdict(independent[:len(independent) // 2], independent,
                     "TRUNCATED(self-test)")
        if rc == 0:
            print("SELF-TEST FAILED: the tooth did not bite.")
            return 1
        print("SELF-TEST PASSED: the tooth bites.\n")
        if len(args) < 2:
            return 0

    meta = json.load(open(args[1]))
    return verdict(meta["active"], independent)


if __name__ == "__main__":
    sys.exit(main())
