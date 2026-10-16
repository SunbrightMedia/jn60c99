#!/usr/bin/env python3
"""jn_proc_seq.py -- the ONE process() drive shared by the L1 census, the oracle reference and the lifted C side, so
all three exercise the IDENTICAL set of process() calls (no "where no gate looked" gap). Each step is a dict:
  n       : block size (0 = a flush)
  events  : list of (kind, offset, channel, pitch, velocity); kind 'on' / 'off'
  params  : list of (param_id, offset, value) parameter-queue points
  ctx     : None (no ProcessContext) or dict(state=<raw flags>, tempo=, ppq=, cs=, ce=)
The set covers: no-context AND context blocks (different code paths), a chord, a release, a flush, several block
sizes, a low note. host_process_emu.process reads ctx['state'] directly when present, so both sides use the same raw
flags. Extend this list to widen coverage; the census, the reference and the gate all follow it."""

K_PLAYING, K_TEMPO, K_PPQ = 0x2, 0x400, 0x200


def _on(off, p, v=0.8):
    return ('on', off, 0, p, v)


def _off(off, p):
    return ('off', off, 0, p, 0.0)


def steps():
    T = dict(state=K_PLAYING | K_TEMPO | K_PPQ, tempo=120.0, ppq=1.5, cs=0.0, ce=0.0)
    return [
        dict(n=64,  events=[_on(0, 60, 0.8)],                         params=[], ctx=None),   # the no-context path
        dict(n=64,  events=[],                                        params=[], ctx=None),
        dict(n=64,  events=[_off(0, 60)],                             params=[], ctx=None),
        dict(n=256, events=[_on(0, 60, 0.8), _on(0, 64, 0.7), _on(0, 67, 0.9)], params=[], ctx=T),   # a chord, with context
        dict(n=256, events=[],                                        params=[], ctx=T),
        dict(n=256, events=[_off(0, 60), _off(0, 64), _off(0, 67)],   params=[], ctx=T),      # release
        dict(n=128, events=[],                                        params=[], ctx=T),
        dict(n=0,   events=[],                                        params=[], ctx=T),      # a flush (no samples)
        dict(n=512, events=[_on(0, 48, 1.0)],                         params=[], ctx=None),   # a bigger block, low note
        dict(n=512, events=[_off(0, 48)],                             params=[], ctx=None),
    ]


def oracle_ctx(ctx):
    """host_process_emu.process ctx dict: it reads ctx['state'] directly when present."""
    if ctx is None:
        return None
    return dict(state=ctx['state'], tempo=ctx['tempo'], ppq=ctx['ppq'], cycle=(ctx['cs'], ctx['ce']))
