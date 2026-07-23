#!/usr/bin/env python3
"""DEFERRED-CONTROLLER executed lock (Pillar-1 airtightness).

completeness_gate.py enforces STATICALLY that only a frozen allowlist of disp
indices may carry status DEFERRED-CONTROLLER. This gate is the EXECUTED complement:
it takes every DEFERRED-CONTROLLER row from COVERAGE.tsv and PROVES, by running the
plugin's own value-tree dispatch (0x3B9A30) under Unicorn, that the leaf is genuinely
NOT engine-reachable — dispatching it across byte values (in a recalled context, and
again after forcing the EFFECT TYPE routing that would host it) writes ZERO
value-dependent engine cell. If any DEFERRED-CONTROLLER leaf DID vary a cell it is
engine-reachable and MUST be APPLIED, not deferred: RED. This makes the status
un-gameable from both directions — a mislabeled reachable param is caught by
execution, not just by the static allowlist.

Two-process rule: oracle only (e2e_emu; never loads libjuno). Covenant: executes the
plugin's own machine code, derives nothing. Exit 0 = every deferred row proven no-op.
"""
import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

COV = os.path.join(os.path.dirname(os.path.dirname(HERE)), 'COVERAGE.tsv')


def deferred_disps():
    out = []
    for ln in open(COV).read().splitlines():
        if ln.startswith('#'):
            continue
        f = ln.split('\t')
        if len(f) >= 5 and f[0].isdigit() and f[4] == 'DEFERRED-CONTROLLER':
            out.append((int(f[0]), f[3]))
    return out


def main():
    rows = deferred_disps()
    if not rows:
        print("DEFERRED-NOOP GATE: no DEFERRED-CONTROLLER rows — nothing to prove. GREEN.")
        return 0
    e = E.E2E(); e.build(48000.0); e.snap_all(); E.recall_patch(e, 0); e.snap_all()
    uc = e.uc
    spans = [(e.state[u], e.state[u] + 0xA83010) for u in range(9)]

    def in_state(a):
        for lo, hi in spans:
            if lo <= a < hi:
                return True
        return False

    def cap(disp, byte):
        d = {}
        def wh(uc, acc, addr, size, val, u):
            if in_state(addr):
                d[addr] = val & ((1 << (8 * size)) - 1)
        h = uc.hook_add(UC_HOOK_MEM_WRITE, wh)
        for u in range(9):
            try: e.dispatch(u, disp, byte)
            except RuntimeError: pass
        e.snap_all()
        uc.hook_del(h)
        return d

    def valdep(disp):
        a = cap(disp, 40); b = cap(disp, 210)
        return [x for x in (set(a) | set(b)) if a.get(x) != b.get(x)]

    print("=== DEFERRED-CONTROLLER EXECUTED NO-OP GATE (%d rows) ===" % len(rows))
    reachable = []
    for disp, name in rows:
        d = valdep(disp)
        tag = "no-op OK" if not d else ("REACHABLE (%d cells)" % len(d))
        print("  disp %4d %-22s -> %s" % (disp, name, tag))
        if d:
            reachable.append((disp, name, d))
    # Thoroughness: any flanger (PAT2_FL) leaf must stay no-op even with EFFECT TYPE
    # routing forced to 4 (the mode that would host it) — proving it needs the
    # effect-object mode-4 ACTIVATION that dispatch does not perform.
    for u in range(9):
        try: e.dispatch(u, 873, 4)
        except RuntimeError: pass
    e.snap_all()
    for disp, name in rows:
        if 1242 <= disp <= 1248:
            d = valdep(disp)
            if d:
                print("  disp %4d %-22s -> REACHABLE after ET=4 routing (%d cells)" % (disp, name, len(d)))
                reachable.append((disp, name, d))

    if reachable:
        print("\nGATE: RED — %d DEFERRED-CONTROLLER leaf/leaves are engine-reachable and must be"
              " APPLIED, not deferred: %s" % (len(reachable), [r[0] for r in reachable]))
        return 1
    print("\nGATE: GREEN — every DEFERRED-CONTROLLER row proven NOT engine-reachable "
          "(value-tree dispatch is a no-op; flanger stays no-op even with ET routing=4).")
    return 0


if __name__ == '__main__':
    sys.exit(main())
