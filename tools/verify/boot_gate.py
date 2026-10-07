#!/usr/bin/env python3
"""boot_gate.py -- THE START-UP TRANSIENT, plugin vs port, FROM THE FIRST SAMPLE (CLAIMS B15,
docs/HOST_RENDER_LAYER.md). Every other host-layer gate settles both sides after a prelude; this
one does not: the plugin as a host boots it (its constructor's build at 96000 leaves 274 ramps
per unit in flight, src/boot_ramps.h) and the port as juno_gui_plugin_init starts it, and every
sample from the first is compared. The runner is midi_ctl_gate.py's ('raw' chains).

Chains: host 48000 / 44100 (converter) and 96000 (identity), the default engine-rate setting:
silence through the 960-sample start-up mute and the ramps; notes inside the mute and right
after it; a patch load and a host edit while the boot ramps run; the voice count raised to 8
after the start (the two units it had stopped resume their boot ramps); the arp from the start;
and six starts at an engine-rate setting (2, 3, 1, 2 at host 96000, 5 automatic, 6: rate 0) --
the first block's switch on the boot state, from the first sample (CLAIMS A30).

  --ref         (Unicorn) writes scratchpad/boot_ref.pkl (.partial, then renamed)
  --port        (libjuno) every sample of both channels must agree
  --port-tooth  the port check must FAIL on: one note one sample late (after the mute); the
                port started settled (juno_rr_settle right after juno_gui_plugin_init: the port
                before CLAIMS B15)
Mutants of the port's boot (probes/boot/boot_teeth.py): every boot ramp at time index 0, the
record's target not set apart before the arm, the pump stepping the units the voice count stops
-- each bites; every start 0 does not: the 22 starts other than 0 are CONDITION's scatter cells
(5520 / 7600 / 10320 + 10512 v), all at time index 0, so their ramps end inside the unit's
960-sample mute, before its DSP reads them (equivalent on the output, INFERRED)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import midi_ctl_gate as G                                   # noqa: E402

REF_PKL = os.environ.get('BOOT_REF', os.path.join(REPO, 'scratchpad', 'boot_ref.pkl'))
TITLE = 'THE START-UP TRANSIENT (CLAIMS B15): the plugin\'s boot ramps, from the first sample -- plugin vs port'
VOICES = 0x0FFFC00E


def chains():
    T = (True, 120.0)
    E = lambda n=128, ev=(), par=(): ('blk', n, list(ev), T, list(par))
    on, off = G.ev_on, G.ev_off
    out = []
    for name, rate in (('b48', 48000.0), ('b44', 44100.0), ('b96', 96000.0)):
        st = [('raw',)] + [E()] * 6                                   # the mute, the ramps
        st += [E(ev=[on(0, 60, 0.8)])] + [E()] * 3 + [E(ev=[on(5, 64, 0.7)])] + [E()] * 6
        st += [E(ev=[off(0, 60), off(3, 64)])] + [E()] * 8
        out.append((name, rate, None, st))
    # a note inside the mute (block 0), one right after it
    st = [('raw',), E(ev=[on(3, 57, 0.9)]), E(), E(), E(), E(ev=[on(100, 62, 0.6)])] + [E()] * 8
    st += [E(ev=[off(0, 57), off(0, 62)])] + [E()] * 6
    out.append(('mute', 48000.0, None, st))
    # a patch load and a host edit (VCF CUTOFF) while the boot ramps run
    st = [('raw',), E(), ('patch', 9), E(ev=[on(0, 48, 0.8)]), ('state', [(0x0060003A, 100)])] + [E()] * 10
    st += [E(ev=[off(0, 48)])] + [E()] * 6
    out.append(('edit', 48000.0, None, st))
    # the voice count raised to 8 after the start: units 6 and 7 resume their boot ramps and their
    # start-up mute. The chord waits one block: the render's preamble that applies a new count
    # resets every assigner, so a note in the block of the change is lost (the plugin's own
    # behaviour: this chain's first reference, the chord in that block, was silent on both sides)
    st = [('raw',)] + [E()] * 20 + [('state', [(VOICES, 8)]), E()]
    st += [E(ev=[on(0, k, 0.7) for k in (48, 52, 55, 59, 62, 65, 69, 72)])] + [E()] * 10
    st += [E(ev=[off(0, k) for k in (48, 52, 55, 59, 62, 65, 69, 72)])] + [E()] * 6
    out.append(('vc8', 48000.0, None, st))
    # an engine-rate setting from the start (a DAW state that carries one): the plugin's first block
    # switches its built engine -- setSampleRate on the boot state, ramps in flight, before
    # initialize's defaults (CLAIMS A30) -- then the defaults and the state apply
    for name, rate, setting in (('s2', 48000.0, 2), ('s3', 44100.0, 3), ('s1', 44100.0, 1),
                                ('s2u', 96000.0, 2), ('s5', 48000.0, 5), ('s6', 48000.0, 6)):
        st = [('raw',)] + [E()] * 6 + [E(ev=[on(0, 60, 0.8)])] + [E()] * 3 + [E(ev=[on(5, 64, 0.7)])] + [E()] * 6
        st += [E(ev=[off(0, 60), off(3, 64)])] + [E()] * 8
        out.append((name, rate, setting, st))
    # the arp from the start
    A = lambda n=256, ev=(): ('blk', n, list(ev), (True, 128.0), [])
    st = [('raw',), ('patch', 1), A(ev=[on(0, 60, 0.8), on(0, 64, 0.8)])] + [A()] * 20
    st += [A(ev=[off(0, 60), off(0, 64)])] + [A()] * 4
    out.append(('arp', 44100.0, None, st))
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return G.build_ref(chain_fn=chains, ref_pkl=REF_PKL)
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return G.check_port(only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
    if a == ['--port-tooth']:
        res = {}
        for t in ('late_note', 'settled_start'):
            print('--- tooth %s' % t)
            res[t] = G.check_port(tooth=t, only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
        print()
        for t, b in res.items():
            print('%-14s %s (%d chains differ)' % (t, 'BITES' if b else 'DID NOT BITE', b))
        return 0 if all(res.values()) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
