#!/usr/bin/env python3
"""juno_scope_probe.py -- INDEPENDENT parameter-scope probe for the JUNO port.

Playbook 80 caught the JX gates proving less than they claimed because their
active-parameter set was DISCOVERED by a narrow probe. e2e_emu.load_leaves()
selects the JUNO's leaves with two HARDCODED pool ranges (19<=ml<=71 and
88<=ml<=135); every pool outside them is skipped by construction. That is the
same defect shape, so it must be measured, not assumed.

This probe sweeps EVERY dispatch index over a full in-range value spread and
records which ones MOVE engine state, watching the full per-unit state of a
voice unit AND the master unit. Its output is compared against load_leaves().
An index that moves state but is not a ledgered leaf is a scope hole.

usage: juno_scope_probe.py <out.json> [pool_lo=0] [pool_hi=200]
"""
import sys, os, json, hashlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__))))
import e2e_emu as E

VALUES = (0, 255, 1, 64, 128, 192)


def main():
    out = sys.argv[1]
    lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    hi = int(sys.argv[3]) if len(sys.argv) > 3 else 200

    e = E.E2E(); e.build(44100.0)
    uc = e.uc
    SZ = E.STATE_SZ
    st0, st8 = e.state[0], e.state[8]
    b0 = bytes(uc.mem_read(st0, SZ)); b8 = bytes(uc.mem_read(st8, SZ))
    h0 = hashlib.blake2b(b0, digest_size=16).digest()
    h8 = hashlib.blake2b(b8, digest_size=16).digest()

    res = {}
    for ml in range(lo, hi):
        idx = ml + 740
        mv = mm = False
        for v in VALUES:
            if not mv:
                e.dispatch(0, idx, v)
                if hashlib.blake2b(bytes(uc.mem_read(st0, SZ)),
                                   digest_size=16).digest() != h0:
                    mv = True
                uc.mem_write(st0, b0)
            if not mm:
                e.dispatch(8, idx, v)
                if hashlib.blake2b(bytes(uc.mem_read(st8, SZ)),
                                   digest_size=16).digest() != h8:
                    mm = True
                uc.mem_write(st8, b8)
            if mv and mm:
                break
        if mv or mm:
            res[ml] = {"voice": mv, "master": mm}
        sys.stderr.write("pool %3d voice=%d master=%d\n" % (ml, mv, mm))

    json.dump(res, open(out, "w"), indent=0, sort_keys=True)

    ledger = {p[0] - 2 for p in []}  # placeholder, filled below
    leaves = E.load_leaves()
    ledgered = set()
    for (p, nm, idx, bb) in leaves:
        ledgered.add(idx - 740)
    moved = sorted(res)
    holes = [m for m in moved if m not in ledgered]
    print("pools that MOVE state: %d" % len(moved))
    print("ledgered by load_leaves(): %d" % len(ledgered))
    print("SCOPE HOLES (move state, NOT ledgered): %d" % len(holes))
    if holes:
        for m in holes:
            print("   pool %3d  voice=%d master=%d" % (m, res[m]["voice"], res[m]["master"]))
    return 1 if holes else 0


if __name__ == "__main__":
    sys.exit(main())
