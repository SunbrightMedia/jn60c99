#!/usr/bin/env python3
"""boss_drive.py -- THE drive of the BOSS track: one list of steps that the census (boss_reach.py), the oracle reference
and the C port's gate all run, so they can never drift apart (the JUNO's jn_proc_seq rule).

A step is ('process', n, signal, params) or ('state',) -- the host calls a DAW makes on an effect. The input signal
is deterministic (a seeded LCG noise burst, a sine, silence, a full-scale square: the clip / gate / envelope paths),
as float32 bit patterns. Parameter ids are the controller's own (boss_host.params()), found by title, never typed in.
Normalized values follow the VST3 rule for a discrete parameter: plain / stepCount.

usage: import boss_drive as D; D.run(h, models=[0, 4], quick=True, log=print)
"""
import math
import struct

SHIPPED = [0, 4, 6, 19] + list(range(27, 48))      # the 25 models with art and a preset (boss/docs/S3_STATUS.md)


def f2b(x):
    return struct.unpack('<I', struct.pack('<f', x))[0]


def signal(kind, n, start=0, seed=1):
    if kind == 'silence':
        return [0] * n
    if kind == 'sine':
        return [f2b(0.5 * math.sin(2 * math.pi * 220.0 * (start + i) / 48000.0)) for i in range(n)]
    if kind == 'square':
        return [f2b(1.0 if ((start + i) // 109) % 2 else -1.0) for i in range(n)]
    if kind == 'noise':
        s = (seed * 2654435761 + start) & 0xFFFFFFFF
        out = []
        for _ in range(n):
            s = (s * 1664525 + 1013904223) & 0xFFFFFFFF
            out.append(f2b(((s >> 8) / float(1 << 24) - 0.5) * 0.8))
        return out
    raise ValueError(kind)


def find(params, *words):
    """the parameter whose title contains every word (case-folded); None when absent"""
    for p in params:
        t = p[1].lower()
        if all(w.lower() in t for w in words):
            return p
    return None


def norm(p, plain):
    return float(plain) / p[2] if p[2] > 0 else float(plain)


def steps(params, models, quick=False):
    """the step list for the given models (default: the 25 shipped). Per model: select it, play the four signals, then
    move every parameter the controller lists through 0, mid and max with a block after each (quick: the signals only)"""
    model = find(params, 'model')
    out = []
    pos = 0
    for m in models:
        out.append(('process', 256, 'silence', [(model[0], 0, norm(model, m))] if model else []))
        for kind in ('sine', 'noise', 'square', 'silence'):
            out.append(('process', 512, kind, []))
        if quick:
            continue
        for p in params:
            if model and p[0] == model[0]:
                continue
            if p[4] & 0x1 == 0:                   # kCanAutomate only (what a host sends through process())
                continue
            for v in (0.0, 0.5, 1.0):
                out.append(('process', 256, 'noise', [(p[0], 0, v)]))
        out.append(('state',))
        pos += 1
    return out


def run(h, models=None, quick=False, log=lambda m: None, rate=48000.0, block=512):
    """the drive on an oracle (or any object with the same calls). Returns the outputs, one (L, R) per process step."""
    if not getattr(h, 'nbus', None):
        h.setup(rate, max(block, 512))
    ps = h.params()
    log('%d parameters' % len(ps))
    outs = []
    t = 0
    for k, st in enumerate(steps(ps, models or SHIPPED, quick)):
        if st[0] == 'process':
            _, n, kind, par = st
            sig = signal(kind, n, t)
            outs.append(h.process(sig, sig, params=par))
            t += n
        elif st[0] == 'state':
            s = h.get_state()
            h.set_state(s)
        if k % 50 == 0:
            log('step %d' % k)
    return outs
