#!/usr/bin/env python3
"""ccmap_state_gate.py -- THE MIDI CC MAP IN THE PLUGIN'S STATE, plugin vs port (task #36, CLAIMS
A31 when closed). The plugin's getState writes, after the 95 parameter entries, 128 entries
0x10000000 + n: the parameter id CC n controls, or -1 (EXECUTED: the default map, 51 CCs). These
chains load a state whose map differs (an unassigned CC given a parameter, an assigned CC moved or
cleared, a CC given a wild id, one CC given twice, two CCs on one parameter) and then send those
CCs through process() while notes sound; one chain loads no state (the boot's map, every CC). The
runner is midi_ctl_gate.py's. Mutants of the port's map: probes/host_api/ccmap_teeth.py.

  --ref / --port / --port-tooth (a late note)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import midi_ctl_gate as G                                   # noqa: E402

REF_PKL = os.environ.get('CCMAP_REF', os.path.join(REPO, 'scratchpad', 'ccmap_state_ref.pkl'))
TITLE = 'THE MIDI CC MAP IN THE STATE: setState of the 128 map entries, then the CCs -- plugin vs port'
MAP = 0x10000000
CUTOFF, RESO, VCA = 0x0060003A, 0x0060003E, 0x00600078
VOICES, TUNE = 0x0FFFC00E, 0x00000002


def chains():
    T = (True, 120.0)
    E = lambda n=256, ev=(), par=(): ('blk', n, list(ev), T, list(par))
    on, off, cc = G.ev_on, G.ev_off, G.cc
    out = []
    # CC 1 (unassigned by default: the mod wheel) given VCF CUTOFF; CC 3 (cutoff by default) cleared;
    # CC 20 given RESONANCE; CC 21 given a wild id
    st = [('patch', 9), ('state', [(MAP + 1, CUTOFF), (MAP + 3, -1), (MAP + 20, RESO), (MAP + 21, 0x7FFF0000)]),
          E(ev=[on(0, 57, 0.8), on(0, 64, 0.8)])] + [E()] * 4
    for v in (0.0, 0.3, 1.0):
        st += [E(par=[cc(1, v, 10)])] + [E()] * 3 + [E(par=[cc(3, v, 0)])] + [E()] * 3
        st += [E(par=[cc(20, v, 5)])] + [E()] * 3 + [E(par=[cc(21, v, 0)])] + [E()] * 2
    st += [E(ev=[off(0, 57), off(0, 64)])] + [E()] * 6
    out.append(('remap', 48000.0, None, st))
    # the default map kept but CC 7 moved to VCA LEVEL and CC 74 cleared; a second state restores
    st = [('patch', 0), ('state', [(MAP + 7, VCA), (MAP + 74, -1)]), E(ev=[on(0, 60, 0.8)])] + [E()] * 3
    for v in (0.2, 0.9):
        st += [E(par=[cc(7, v, 0), cc(74, v, 50)])] + [E()] * 4
    st += [('state', [(MAP + 7, -1)])] + [E(par=[cc(7, 0.1, 0)])] + [E()] * 4
    st += [E(ev=[off(0, 60)])] + [E()] * 6
    out.append(('move', 44100.0, None, st))
    # no state load at all: the boot's map. Every CC 0..119 once, two per block, keys held; the
    # patch reloaded after each pair (a patch load leaves the map alone), so a CC that silences
    # the sound hides no later one. The CCs of the engine controllers (1, 11, 64) are left out,
    # their own gates hold them.
    st = [('raw',), ('patch', 9), E(ev=[on(0, 57, 0.8), on(0, 64, 0.8), on(0, 69, 0.8)])] + [E()] * 40
    ccs = [n for n in range(120) if n not in (1, 11, 64)]
    for k in range(0, len(ccs), 2):
        st += [E(par=[cc(n, ((n * 37) % 128) / 127.0, 64 * j) for j, n in enumerate(ccs[k:k + 2])])] + [E()]
        st += [('patch', 9), E()]
    st += [E(ev=[off(0, 57), off(0, 64), off(0, 69)])] + [E()] * 6
    out.append(('boot', 48000.0, None, st))
    # one CC given twice (the later entry wins), two CCs on one parameter, a CC on a vm.vs
    # setting (VOICES) and on MASTER TUNE (id 2)
    st = [('patch', 12), ('state', [(MAP + 30, CUTOFF), (MAP + 30, RESO), (MAP + 31, VCA), (MAP + 32, VCA),
                                    (MAP + 33, VOICES), (MAP + 35, TUNE)]),
          E(ev=[on(0, k, 0.7) for k in (48, 55, 60, 64, 67)])] + [E()] * 3
    for v in (0.9, 0.1, 0.6):
        st += [E(par=[cc(30, v, 0), cc(31, 1.0 - v, 64)])] + [E()] * 2 + [E(par=[cc(32, v, 128)])] + [E()] * 2
    st += [E(par=[cc(33, 0.0, 0)])] + [E()] * 4 + [E(par=[cc(33, 1.0, 0)])] + [E()] * 2
    st += [E(par=[cc(35, 0.8, 30)])] + [E()] * 4
    st += [E(ev=[off(0, k) for k in (48, 55, 60, 64, 67)])] + [E()] * 6
    out.append(('dups', 48000.0, None, st))
    # the state may assign the controller and channel-mode CCs too (the learn refuses 120..127,
    # setState does not): CC 64 (sustain) on VCA LEVEL, CC 120 (all sound off) on RESONANCE,
    # CC 123 (all notes off) on VCF CUTOFF -- the record, then the message's own action
    st = [('patch', 9), ('state', [(MAP + 64, VCA), (MAP + 120, RESO), (MAP + 123, CUTOFF)]),
          E(ev=[on(0, 60, 0.8), on(0, 67, 0.8)])] + [E()] * 3
    st += [E(par=[cc(64, 1.0, 0)])] + [E()] * 2 + [E(ev=[off(0, 60)])] + [E()] * 2 + [E(par=[cc(64, 0.3, 40)])] + [E()] * 3
    st += [E(ev=[on(0, 62, 0.8)])] + [E()] * 2 + [E(par=[cc(120, 0.6, 10)])] + [E()] * 3
    st += [E(ev=[on(0, 65, 0.8)])] + [E()] * 2 + [E(par=[cc(123, 0.2, 0)])] + [E()] * 4
    st += [E(ev=[off(0, 62), off(0, 65), off(0, 67)])] + [E()] * 4
    out.append(('modes', 48000.0, None, st))
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return G.build_ref(chain_fn=chains, ref_pkl=REF_PKL)
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return G.check_port(only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
    if a == ['--port-tooth']:
        b = G.check_port(tooth='late_note', only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
        print('\nlate_note      %s (%d chains differ)' % ('BITES' if b else 'DID NOT BITE', b))
        return 0 if b else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
