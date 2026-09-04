#!/usr/bin/env python3
"""jx_nstore_seq.py -- shared note-store sequence (no unicorn, no ctypes)."""
import random


def make(seed=0x3B57, n=3000):
    r = random.Random(seed)
    ev, held = [], []
    for _ in range(n):
        k = r.random()
        if k < 0.45 or not held:
            note = r.randrange(0, 128)
            v = r.randrange(0, 128)
            ev.append(("on", note, v))       # vel 0 included: it is the
            if v: held.append(note)          # off path and must not count
        else:
            note = r.choice(held)
            held.remove(note)                # refcounted: one off per on
            ev.append(("off", note, 0x40))
        if r.random() < 0.02:                # mode poke: +0x2C gates the
            ev.append(("poke2c", r.randrange(0, 4), 0))   # drain epilogue
        if r.random() < 0.01:                # FULL drain: every outstanding
            for note in held:                # ref released -> 0x3F0F00's
                ev.append(("off", note, 0x40))   # epilogue + the 0x3EF210
            held = []                        # seam MUST fire
    return ev
