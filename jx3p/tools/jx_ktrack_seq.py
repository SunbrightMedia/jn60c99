#!/usr/bin/env python3
"""jx_ktrack_seq.py -- the shared key-tracker event sequence (both sides).
Imports neither unicorn nor ctypes."""
import random


def make(seed=0x7C4A, n=3000):
    r = random.Random(seed)
    ev, held = [], set()
    for _ in range(n):
        k = r.random()
        if k < 0.42:
            note = r.randrange(0, 128)
            ev.append(("on", note, r.randrange(1, 128))); held.add(note)
        elif k < 0.90 and held:
            note = r.choice(sorted(held)); held.discard(note)
            ev.append(("off", note))
        elif k < 0.94:
            ev.append(("mode", r.randrange(0, 4)))
        else:
            note = r.randrange(0, 128)
            ev.append(("on", note, r.randrange(1, 128))); held.add(note)
    return ev
