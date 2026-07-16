#!/usr/bin/env python3
"""provenance_check.py -- structural checker for PROVENANCE.tsv, the ledger of what
is proven. It does NOT run the gates (that's `make verify`); it enforces that the
ledger is well-formed and honest, and prints the finish-line metric.

Rules:
  - every row has a valid status: PROVEN | RECONSTRUCTED | CAPTURED | UNVERIFIED
  - every referenced gate file (col 'gate') exists, or is '-'
  - CAPTURED is a self-proving-mandate VIOLATION (a value from a runtime capture,
    not the plugin's own recall) -> exit nonzero until replaced
  - "done" = zero rows that are not PROVEN

Exit 0 only when the ledger is well-formed AND no CAPTURED rows remain.
"""
import sys, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
LEDGER = os.path.join(ROOT, 'PROVENANCE.tsv')
VALID = {'PROVEN', 'RECONSTRUCTED', 'CAPTURED', 'UNVERIFIED'}


def main():
    rows, errs = [], []
    with open(LEDGER) as f:
        for n, line in enumerate(f, 1):
            line = line.rstrip('\n')
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            cols = line.split('\t')
            if cols[0] == 'subsystem':
                continue
            if len(cols) < 5:
                errs.append("line %d: expected 5 tab-separated columns, got %d" % (n, len(cols)))
                continue
            subsystem, scope, status, gate, note = cols[:5]
            if status not in VALID:
                errs.append("line %d: bad status %r (want %s)" % (n, status, '/'.join(sorted(VALID))))
            if gate != '-':
                for g in gate.split('+'):
                    g = g.strip()
                    if g and not os.path.exists(os.path.join(ROOT, g)):
                        errs.append("line %d: gate not found: %s" % (n, g))
            rows.append((subsystem, status))

    from collections import Counter
    c = Counter(s for _, s in rows)
    print("=== PROVENANCE ledger (%d rows) ===" % len(rows))
    for st in ('PROVEN', 'RECONSTRUCTED', 'CAPTURED', 'UNVERIFIED'):
        print("  %-14s %d" % (st, c.get(st, 0)))
    captured = [s for s, st in rows if st == 'CAPTURED']
    notproven = [(s, st) for s, st in rows if st != 'PROVEN']
    if notproven:
        print("\nOPEN (not yet PROVEN) -- the finish line:")
        for s, st in notproven:
            print("  [%-13s] %s" % (st, s))
    if errs:
        print("\n*** STRUCTURAL ERRORS ***")
        for e in errs:
            print("  " + e)
    ok = not errs and not captured
    print("\nCHECK:", "PASS" if ok else ("FAIL (%d captured, %d structural)" % (len(captured), len(errs))))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
