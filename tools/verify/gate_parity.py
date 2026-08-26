#!/usr/bin/env python3
"""gate_parity.py -- RED whenever one port has a gate class the other lacks.

THE DEFECT THIS EXISTS TO PREVENT
On 2026-08-26 a random-seeded A/B found that the JX-3P port computed in a
DIFFERENT FLOATING-POINT MODE from the plugin (no FTZ/DAZ). The JUNO port had
had that fix for months. The JX had also never had a seeded fuzz gate, while
the JUNO had `fuzz_diff` all along. Both facts were WRITTEN DOWN -- SCOPE_AUDIT
row 5 said "JUNO has fuzz_diff; JX has no equivalent" -- and nothing happened,
because a sentence in a document cannot turn red.

So: the ledger docs/GATE_PARITY.tsv names every gate CLASS and both ports'
implementations. This tooth fails on

  1. any row marked MISSING            -- an owed gate, named and counted
  2. any row whose named file is absent -- a gate that was deleted or renamed
  3. any tools/verify gate not classified in the ledger at all -- so a NEW
     JUNO gate must be classified for the JX before it can be forgotten. This
     is charter rule 2 (a tooth on the scope) applied to the SUITE ITSELF: the
     ledger cannot shrink silently.

Exit 0 only when every class is OK or WAIVED with a reason.

usage: gate_parity.py [--summary]
"""
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEDGER = os.path.join(REPO, "docs", "GATE_PARITY.tsv")

# Files under tools/verify that are NOT gates and so need no parity row:
# helpers, generators, one-shot probes, and the shared oracle machinery.
NOT_A_GATE_PREFIX = (
    "gen_", "dump_", "extract_", "enumerate_", "build_", "index_", "leaf_",
    "param_cell_", "plugin_", "real_", "rev_", "scen", "seedgen", "bundle_",
    "translate_", "flag_", "cov_", "finefx_", "chorus_", "reverb_", "delay",
    "latch_", "port_", "cross_", "frozen_", "full_recall_", "pathcheck",
    "freshlib", "feet_", "rate88_", "selfband", "synth_", "shadow_",
    "recall_ref", "recall_full", "verify_dropped", "completeness_scan",
    "random_attribute", "hostmod_", "etmode_", "temposync_", "arp_",
    "deferred_", "coldwarm_", "cold_regress", "delaytype_",
)
NOT_A_GATE_EXACT = {
    "truth.py", "e2e_emu.py", "jx_emu.py", "real_recall.py", "__init__.py",
    "gate_parity.py", "mutation_gate.py", "unordered_audit.py", "nan_ab.py",
    "census_exhaustive_ref.py", "fxsweep_ref.py", "recall_exhaustive_ref.py",
}


def load():
    rows = []
    with open(LEDGER) as f:
        for ln in f:
            ln = ln.rstrip("\n")
            if not ln.strip() or ln.lstrip().startswith("#"):
                continue
            parts = ln.split("\t")
            if len(parts) < 4:
                raise SystemExit("MALFORMED ledger row (need 4+ tab fields): %r" % ln)
            rows.append(dict(cls=parts[0], juno=parts[1], jx=parts[2],
                             status=parts[3],
                             note=parts[4] if len(parts) > 4 else ""))
    return rows


def main():
    rows = load()
    bad = []
    missing = []

    for r in rows:
        if r["status"] == "MISSING":
            missing.append(r)
            continue
        if r["status"] == "WAIVED":
            if not r["note"].strip():
                bad.append("%s: WAIVED with no reason" % r["cls"])
            continue
        if r["status"] != "OK":
            bad.append("%s: unknown status %r" % (r["cls"], r["status"]))
            continue
        # OK rows must actually exist on disk, both sides
        for side in ("juno", "jx"):
            p = r[side]
            if p == "-":
                continue
            if not os.path.exists(os.path.join(REPO, p)):
                bad.append("%s: %s side names %s, which does not exist"
                           % (r["cls"], side, p))

    # 3. every real gate in tools/verify must be classified somewhere
    classified = set()
    for r in rows:
        classified.add(os.path.basename(r["juno"]))
        classified.add(os.path.basename(r["jx"]))
    unclassified = []
    vdir = os.path.join(REPO, "tools", "verify")
    for fn in sorted(os.listdir(vdir)):
        if not fn.endswith(".py"):
            continue
        if fn in NOT_A_GATE_EXACT or fn.startswith(NOT_A_GATE_PREFIX):
            continue
        if fn in classified:
            continue
        if "gate" in fn or fn.endswith("_ab.py") or "audit" in fn or "fuzz" in fn:
            unclassified.append(fn)

    print("GATE PARITY: %d classes -- %d OK, %d MISSING, %d WAIVED"
          % (len(rows),
             sum(1 for r in rows if r["status"] == "OK"),
             len(missing),
             sum(1 for r in rows if r["status"] == "WAIVED")))
    for r in missing:
        print("  MISSING  %-24s owed: %s" % (r["cls"], r["jx"]))
        if r["note"]:
            print("           %s" % r["note"])
    for fn in unclassified:
        print("  UNCLASSIFIED gate not in the ledger: tools/verify/%s" % fn)
    for b in bad:
        print("  BROKEN   %s" % b)

    if "--summary" in sys.argv:
        return 0
    if missing or unclassified or bad:
        print("[gate parity] RED -- %d owed, %d unclassified, %d broken"
              % (len(missing), len(unclassified), len(bad)))
        return 1
    print("[gate parity] GREEN -- every gate class has both ports covered")
    return 0


if __name__ == "__main__":
    sys.exit(main())
