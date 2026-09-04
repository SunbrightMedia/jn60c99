#!/usr/bin/env python3
"""jx_dn_seq.py -- shared dispatch note/gate sequence (no unicorn/ctypes).
Events: ("note", v, val) / ("gate", v, val). Values cover the full byte and
the signed-remainder transpose edge (large vals -> negative %12 in-plugin)."""
import random


def make(seed=0xD15A, n=2500):
    r = random.Random(seed)
    ev = []
    for _ in range(n):
        v = r.randrange(8)
        if r.random() < 0.5:
            val = r.choice([r.randrange(0, 128), r.randrange(0, 256),
                            r.randrange(0, 128)])
            ev.append(("note", v, val))
        else:
            ev.append(("gate", v, r.choice([0, 1, r.randrange(0, 128)])))
    return ev
