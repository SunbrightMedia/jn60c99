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
  4. any OK row whose JX gate no suite runs: each JX file named (several are
     joined by ' + ') must be invoked on a non-comment line of
     jx3p/tools/jx_verify.sh (2026-10-11, JX-26: five rows were "OK" on files
     that existed and that nothing ran).

BLOCKED rows (owed, waiting on an input the project does not have) are printed
as NOT DONE and do not fail the run: the work they owe cannot start; the
port is not finished while one stands (tools/status.sh lists them).

Exit 0 only when every class is OK, WAIVED with a reason, or BLOCKED with its input.

usage: gate_parity.py [--summary] [--self-test]
  --self-test: rules 1, 2 and 4 must each turn a planted row RED (a tooth that
  has never failed is not believed).
"""
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEDGER = os.path.join(REPO, "docs", "GATE_PARITY.tsv")
JX_SUITE = os.path.join(REPO, "jx3p", "tools", "jx_verify.sh")

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


def load(path=LEDGER):
    rows = []
    with open(path) as f:
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


def files(col):
    return [] if col.strip() == "-" else [p.strip() for p in col.split(" + ")]


def suite_runs():
    """the file names jx_verify.sh invokes: every token of its non-comment lines"""
    toks = set()
    for ln in open(JX_SUITE):
        ln = ln.split("#", 1)[0] if not ln.lstrip().startswith("#") else ""
        for t in ln.replace('"', " ").replace("'", " ").split():
            toks.add(os.path.basename(t))
    return toks


def check(rows, runs):
    bad, missing, blocked = [], [], []
    for r in rows:
        if r["status"] == "MISSING":
            missing.append(r)
            continue
        if r["status"] in ("WAIVED", "BLOCKED"):
            if not r["note"].strip():
                bad.append("%s: %s with no reason" % (r["cls"], r["status"]))
            if r["status"] == "BLOCKED":
                blocked.append(r)
            continue
        if r["status"] != "OK":
            bad.append("%s: unknown status %r" % (r["cls"], r["status"]))
            continue
        # OK rows must actually exist on disk, both sides
        for side in ("juno", "jx"):
            for p in files(r[side]):
                if not os.path.exists(os.path.join(REPO, p)):
                    bad.append("%s: %s side names %s, which does not exist"
                               % (r["cls"], side, p))
        # 4. and the JX side must be run by the JX suite
        for p in files(r["jx"]):
            if os.path.basename(p) not in runs:
                bad.append("%s: %s is not run by jx3p/tools/jx_verify.sh" % (r["cls"], p))
    return bad, missing, blocked


def self_test(rows, runs):
    """each rule must turn a planted row RED"""
    plant = [dict(cls="t_missing", juno="tools/verify/fuzz_diff.py", jx="x.py", status="MISSING", note=""),
             dict(cls="t_absent", juno="tools/verify/fuzz_diff.py", jx="jx3p/tools/no_such_gate.py", status="OK", note=""),
             dict(cls="t_unrun", juno="tools/verify/fuzz_diff.py", jx="jx3p/tools/fw_map.py", status="OK", note=""),
             dict(cls="t_waived", juno="tools/verify/fuzz_diff.py", jx="-", status="WAIVED", note="")]
    ok = True
    for p in plant:
        bad, missing, _ = check([p], runs)
        hit = bool(missing) if p["status"] == "MISSING" else bool(bad)
        print("  self-test %-10s %s" % (p["cls"], "RED (seen)" if hit else "NOT SEEN"))
        ok = ok and hit
    return ok


def main():
    rows = load()
    runs = suite_runs()
    if "--self-test" in sys.argv:
        ok = self_test(rows, runs)
        print("gate_parity --self-test: %s" % ("BITES" if ok else "DID NOT BITE"))
        return 0 if ok else 1
    bad, missing, blocked = check(rows, runs)

    # 3. every real gate in tools/verify must be classified somewhere
    classified = set()
    for r in rows:
        for side in ("juno", "jx"):
            for p in files(r[side]):
                classified.add(os.path.basename(p))
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

    print("GATE PARITY: %d classes -- %d OK, %d MISSING, %d WAIVED, %d BLOCKED"
          % (len(rows),
             sum(1 for r in rows if r["status"] == "OK"),
             len(missing),
             sum(1 for r in rows if r["status"] == "WAIVED"), len(blocked)))
    for r in missing:
        print("  MISSING  %-24s owed: %s" % (r["cls"], r["jx"]))
        if r["note"]:
            print("           %s" % r["note"])
    for r in blocked:
        print("  BLOCKED  %-24s NOT DONE -- %s" % (r["cls"], r["note"]))
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
    print("[gate parity] GREEN -- every gate class has both ports covered%s"
          % (" but %d BLOCKED (NOT DONE: the inputs above)" % len(blocked) if blocked else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
