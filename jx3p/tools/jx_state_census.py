#!/usr/bin/env python3
"""jx_state_census.py -- oracle-only census (JX-17): the JX-3P's DAW state as the plugin's own code handles it.

The JX's VST3 wrapper is the JUNO-60's machine code (jx3p/tools/fw_map.py: getState rva 0x349EA0 -> JUNO
0x349FE0, setState and its deserializer the same), so this is the JUNO's census (probes/b6/state_load_census.py,
state_mask_census.py) on the JX: the plugin booted as a VST3 host boots it (jx_host_emu.JXHost: createInstance,
initialize, the edit controller created, connected both ways and given the component state, setupProcessing,
setActive), then

  1. the engine event queue initialize and setActive left (the state parameters' defaults in list order,
     writePatch, the all-sound-off record -- its three MIDI bytes too);
  2. IComponent::getState: the plugin's own payload (the parameter list, then the 128 CC map entries);
  3. IComponent::setState with payloads -- every parameter at each TEST value (the model's storage law per
     entry: what the queued record carries and what getState gives back), an unknown id, a shuffled subset, an
     empty payload, the CC map entries alone, CC map entries assigning, moving and removing parameters --
     recording the queue records each one adds and the getState after it.

Each queue record is the plugin's own 24-byte event: kind 2 = (model id, raw value) for the engine's host entry
at the start of the next block (the render driver), kind 0 a MIDI message, kind 1 a host parameter.
Writes scratchpad/jx_state/state_census.pkl (gitignored; jx_gen_state_tables.py reads it).
    python3 jx3p/tools/jx_state_census.py      (Unicorn only: the two-process rule)
"""
import os
import pickle
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jx_host_emu as X                               # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'jx_state', 'state_census.pkl')
TEST = (0x12345678, -1, 0x1FF, 256, 0x100, 0x7FFFFFFF, -0x80000000, 0x10000, 0xFFFF, 0xFF, 0x80, 0x7F, 300, -129)
CC_BASE = 0x10000000


def payload(state):
    n = struct.unpack('>I', state[:4])[0]
    pl = state[4:4 + n]
    return [list(struct.unpack('>Ii', pl[i:i + 8])) for i in range(0, len(pl), 8)]


def build(entries):
    pl = b''.join(struct.pack('>Ii', i, v) for i, v in entries)
    return struct.pack('>I', len(pl)) + pl


def decode(q):
    return [(kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0]) for kind, off, rec in q]


def main():
    t0 = time.time()
    h = X.JXHost()
    h.start(48000.0, 512)
    init = decode(h.queue())
    s0 = h.get_state()
    ent0 = payload(s0)
    npar = sum(1 for i, _ in ent0 if not CC_BASE <= i < CC_BASE + 128)
    # initialize's MIDI record(s): the three message bytes (the core queue record +8; decode() keeps ids and values)
    midi = [list(raw[8:11]) for kind, off, raw in h.queue() if kind == 0]
    res = dict(init_queue=init, init_midi=midi, state0=s0, npar=npar, cases=[])
    print('initialize + setActive: %d queue records; getState: %d entries (%d parameters, %d CC map)' % (
        len(init), len(ent0), npar, len(ent0) - npar), flush=True)

    def run(name, ent):
        n0 = len(h.queue())
        r = h.set_state(build(ent))
        qq = decode(h.queue()[n0:])
        res['cases'].append(dict(name=name, ret=r, payload=ent, queue=qq, state=h.get_state()))
        print('%-28s setState 0x%x: %d events' % (name, r, len(qq)), flush=True)
    for v in TEST:
        run('all=%d' % v, [[i, v] for i, _ in ent0[:npar]] + [list(e) for e in ent0[npar:]])
    run('unknown id', [[0x7777, 5]] + [list(e) for e in ent0])
    run('params only, shuffled', [list(ent0[k]) for k in (12, 3, 70, 0, 61, 55, 57, 81, 76)])
    run('empty', [])
    run('cc map only', [list(e) for e in ent0[npar:]])
    # the CC map's state entries: CC n -> a model id (assign, move, remove), out-of-range values
    ccs = [list(e) for e in ent0[npar:]]
    moved = [[i, v] for i, v in ccs]
    moved[7] = [CC_BASE + 7, 0x600060]        # CC 7 -> PORTAMENTO (CC 5 keeps it too)
    moved[5] = [CC_BASE + 5, -1]              # CC 5 forgotten
    moved[20] = [CC_BASE + 20, 0x600062]      # CC 20 -> LEGATO
    moved[100] = [CC_BASE + 100, 0x7777]      # an id that is no parameter
    moved[101] = [CC_BASE + 101, 0x0FFFC00E]  # a host setting
    run('cc map moved', [list(e) for e in ent0[:npar]] + moved)
    run('cc map tail only', [[CC_BASE + 30, 0x600062], [CC_BASE + 200, 0x600060], [CC_BASE - 1, 3]])
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    pickle.dump(res, open(OUT, 'wb'))
    print('wrote %s (%.0fs)' % (OUT, time.time() - t0))


if __name__ == '__main__':
    main()
