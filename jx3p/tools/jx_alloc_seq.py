#!/usr/bin/env python3
"""jx_alloc_seq.py -- the ONE deterministic event sequence both sides of the
allocator A/B replay. Imports neither unicorn nor ctypes (two-process rule:
the sides share only this generator and the files they write).

Event tuples:
  ("on",  note, vel)      ("off", note, vel)
  ("sus", unit, v)        ("hold", unit, v)
  ("poly", unit, v)       ("pend", unit, m)      ("mode8", unit, m)
"""
import random


def make(seed=0x1AC0, n=4000):
    r = random.Random(seed)
    ev, held = [], set()
    for _ in range(n):
        k = r.random()
        if k < 0.40:
            note = r.randrange(0, 128); vel = r.randrange(1, 128)
            ev.append(("on", note, vel)); held.add(note)
        elif k < 0.75 and held:
            note = r.choice(sorted(held)); held.discard(note)
            ev.append(("off", note, 0x40))
        elif k < 0.80:
            ev.append(("sus", r.randrange(9), r.randrange(2)))
        elif k < 0.85:
            ev.append(("hold", r.randrange(9), r.randrange(2)))
        elif k < 0.90:
            ev.append(("poly", r.randrange(9), r.randrange(2)))
        elif k < 0.95:
            ev.append(("pend", r.randrange(9), r.randrange(4)))
        else:
            ev.append(("mode8", r.randrange(9), r.randrange(4)))
    return ev
