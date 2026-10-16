#!/usr/bin/env python3
"""jn_search_seq.py -- L6 of the JUNO lift (docs/JUNO_LIFT.md): the ONE vocabulary of host inputs and the seeded plan
generator the machine search uses. The SAME vocabulary feeds the L1 census (juno_lift_reach.py runs seeds below
CENSUS_SEEDS) and the search (seeds from SEARCH_SEED0 on), so the lift covers what the search drives and the two can
never drift apart. A plan is a list of ops (jn_ops.py executes them on the oracle and on the lifted host alike):
  ('proc', n, events, params, ctx)  one block through process(): n 0..512 (0 = the host's flush); events
                                    (kind, offset, channel, pitch, velocity); params (ref, offset, value) where ref is
                                    ('id', pid) or ('rec', record index); ctx None, ('play', tempo) or ('stop', tempo)
  ('rate', hz)                      a host-rate change (setActive 0, setupProcessing, setActive 1)
  ('active',)                       setActive(0) then setActive(1)
  ('uitick',)                       the plugin's UI timer
  ('learn', i) / ('forget', i)      the CC menu's Learn / Forget on record i's parameter
  ('commit',)                       the panel's commit
  ('getset',)                       getState, then setState of those bytes
  ('patch', idx)                    the patch browser's load of factory patch idx
  ('model', i, value)               the editor's set of record i (flag 1)
Values stay inside what the oracle has run (the census-proven envelope); a value outside it is a finding for the
census, not a guess here."""
import random

MIDI_BASE = 0x0FFFC100                     # the plugin's MIDI-mapping ids: CC n -> BASE + n; 128 aftertouch, 129 bend
VOICES, SRATE = 0x0FFFC00E, 0x0FFFC015     # the voice-count and engine-rate settings (host parameters)
CENSUS_SEEDS = 12                          # seeds 0..11 run inside the L1 census
SEARCH_SEED0 = 1000                        # the search's first seed (disjoint from the census's)
SIZES = (0, 1, 2, 3, 7, 16, 31, 64, 100, 128, 255, 256, 333, 500, 511, 512)
VELS = (0.0, 0.004, 0.25, 0.5, 0.75, 1.0)
UNIT = (0.0, 1.0, 0.5, 1 / 127.0, 126 / 127.0, 8191 / 16383.0, 8192 / 16383.0)
TEMPOS = (60.0, 90.0, 120.0, 133.7, 200.0)
MODEL_VALUES = (0, 1, 2, 5, 63, 64, 100, 126, 127)
RATES = (44100.0, 48000.0, 96000.0)
NREC = 95                                  # the panel's records (the editor gate: 95)
NPATCH = 64
WEIGHTS = (('proc', 56), ('model', 10), ('uitick', 7), ('patch', 5), ('getset', 4), ('learn', 3), ('forget', 3),
           ('commit', 4), ('rate', 3), ('active', 2))


def _proc(r):
    n = r.choice(SIZES)
    evs = []
    for _ in range(r.choice((0, 0, 1, 1, 2, 3, 6))):
        pitch = r.randint(36, 96) if r.random() < 0.85 else r.randint(0, 127)
        ch = 0 if r.random() < 0.9 else r.randint(1, 15)
        off = r.randint(0, n - 1) if n > 1 else 0
        vel = r.choice(VELS) if r.random() < 0.7 else round(r.random(), 6)
        evs.append(('on' if r.random() < 0.6 else 'off', off, ch, pitch, vel))
    evs.sort(key=lambda e: e[1])                                   # a host's event list is sorted by offset
    pars = []
    for _ in range(r.choice((0, 0, 0, 1, 1, 2, 4))):
        off = r.randint(0, n - 1) if n > 1 else 0
        kind = r.random()
        if kind < 0.45:                                            # a MIDI controller (CC 0..127, aftertouch, bend)
            cc = r.choice((1, 1, 11, 64, 64, 123, 129, 129, 128)) if r.random() < 0.6 else r.randint(0, 129)
            pars.append((('id', MIDI_BASE + cc), off, r.choice(UNIT) if r.random() < 0.6 else round(r.random(), 6)))
        elif kind < 0.85:                                          # host automation of a panel record
            pars.append((('rec', r.randrange(NREC)), off, r.choice(UNIT) if r.random() < 0.6 else round(r.random(), 6)))
        elif kind < 0.93:
            pars.append((('id', VOICES), off, float(r.choice((1, 6)))))
        else:
            pars.append((('id', SRATE), off, float(r.choice((0, 2, 3, 5)))))
    c = r.random()
    ctx = None if c < 0.15 else (('stop', r.choice(TEMPOS)) if c < 0.3 else ('play', r.choice(TEMPOS)))
    return ('proc', n, evs, pars, ctx)


def plan(seed, nops=120):
    """the seeded plan: a warm start past the 960-sample start mute, then nops random ops"""
    r = random.Random(seed)
    kinds = [k for k, w in WEIGHTS for _ in range(w)]
    ops = [('proc', 512, [], [], ('play', 120.0)), ('proc', 512, [], [], ('play', 120.0))]
    npatch = 0
    while len(ops) < nops + 2:
        k = r.choice(kinds)
        if k == 'proc':
            ops.append(_proc(r))
        elif k == 'model':
            ops.append(('model', r.randrange(NREC), r.choice(MODEL_VALUES)))
        elif k == 'patch':
            if npatch >= 8:                                        # the oracle's heap is a pure bump: keep loads few
                continue
            npatch += 1
            ops.append(('patch', r.randrange(NPATCH)))
        elif k in ('learn', 'forget'):
            ops.append((k, r.randrange(NREC)))
        elif k == 'rate':
            ops.append(('rate', r.choice(RATES)))
        else:
            ops.append((k,))
    return ops


def ctx_fields(ctx):
    """(state, ppq, cycle_start, cycle_end, tempo) of a ctx op field, or None (no ProcessContext)"""
    if ctx is None:
        return None
    return (0x402 if ctx[0] == 'play' else 0x400, 0.0, 0.0, 0.0, ctx[1])   # K_PLAYING 0x2 | K_TEMPO 0x400
