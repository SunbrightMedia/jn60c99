#!/usr/bin/env python3
"""host_rate_gate.py -- a HOST-RATE CHANGE ON A RUNNING INSTANCE, plugin vs port (CLAIMS B13c,
docs/HOST_RENDER_LAYER.md). A host that changes its sample rate calls setActive(false),
setupProcessing(new rate), setActive(true) on the running plugin. READ (rva 0x34AA50 setActive,
0x3CB150 setupProcessing, 0x321AC0 the core's setup, 0x3442D0 the render object's rate): the
plugin keeps its engine and looks its render object up again for (engine rate, new host rate);
found, the converter starts from zeros and the arp tick phase and the note count go to 0; then an
all-sound-off record (CC 120, which this engine ignores). The port: juno_gui_setup_processing,
juno_gui_set_active.

The plugin side is its own process() / setActive / setupProcessing on the booted plugin
(tools/verify/host_process_emu.py); the runner is midi_ctl_gate.py's (steps 'active', 'setup').
Chains: the default setting (engine 96000) through host 48000 -> 44100 -> 96000 (identity) ->
88200 -> 22050 (no object: silence) -> 48000 with keys held across every change; a setActive off /
on at one rate with the arp running (the tick grid starts again); the engine-rate setting 2 (engine
48000) moved from identity to an upsampling converter; the automatic setting (5).

  --ref         (Unicorn) writes scratchpad/host_rate_ref.pkl (.partial, then renamed)
  --port        (libjuno) every sample of both channels must agree
  --port-tooth  the port check must FAIL on two harness defects: one note one sample late; the
                setActive dropped on the port side (the old converter kept)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import midi_ctl_gate as G                                   # noqa: E402

REF_PKL = os.environ.get('HOST_RATE_REF', os.path.join(REPO, 'scratchpad', 'host_rate_ref.pkl'))
TITLE = ('HOST-RATE CHANGE ON A RUNNING INSTANCE (CLAIMS B13c): setActive / setupProcessing, the engine kept, '
         'the render object swapped -- plugin vs port')
ARP_SW = 0x00600108
SUSTAIN = [(0x00600048, 255), (0x00600052, 255), (0x0060004A, 90), (0x00600054, 90)]


def rate_change(sr):
    return [('active', 0), ('setup', sr), ('active', 1)]


def chains():
    T = (True, 120.0)
    E = lambda n=256, ev=(), par=(): ('blk', n, list(ev), T, list(par))
    on, off = G.ev_on, G.ev_off
    out = []
    # 1. the default engine (96000) through five host rates, keys held across every change
    st = [('patch', 0), ('state', SUSTAIN), E(ev=[on(10, 60, 0.8), on(10, 64, 0.7)])] + [E()] * 6
    for sr in (44100.0, 96000.0, 88200.0, 22050.0, 48000.0):
        st += rate_change(sr) + [E()] * 3 + [E(333, ev=[on(17, 67, 0.6)])] + [E()] * 3
        st += [E(ev=[off(5, 67)])] + [E()] * 3
    st += [E(ev=[off(0, 60), off(1, 64)])] + [E()] * 6
    out.append(('chg', 48000.0, None, st))
    # 2. setActive off / on at one rate with the arp running and keys held: the tick grid
    #    restarts, the note count is 0 (a later key-off takes it below 0), and a rate change
    A = lambda n=256, ev=(), par=(): ('blk', n, list(ev), (True, 128.0), list(par))
    st = [('patch', 9), ('state', [(ARP_SW, 1)]), A(ev=[on(0, 55, 0.8), on(3, 62, 0.8)])] + [A()] * 12
    st += [('active', 0), ('active', 1)] + [A()] * 12
    st += [A(ev=[off(40, 55)])] + [A()] * 4 + [A(ev=[on(100, 67, 0.8)])] + [A()] * 10
    st += rate_change(44100.0) + [A()] * 12
    st += [A(ev=[off(0, 62), off(0, 67)])] + [A()] * 4 + [('state', [(ARP_SW, 0)])] + [A()] * 3
    out.append(('react', 48000.0, None, st))
    # 3. the engine-rate setting 2 (engine 48000): identity at 48000, an upsampling converter at
    #    96000 and 192000, back to identity
    st = [('patch', 2), E(ev=[on(0, 57, 0.8), on(0, 64, 0.8)])] + [E()] * 4
    for sr in (96000.0, 192000.0, 48000.0):
        st += rate_change(sr) + [E()] * 4 + [E(ev=[on(7, 69, 0.5), off(200, 69)])] + [E()] * 2
    st += [E(ev=[off(0, 57), off(0, 64)])] + [E()] * 4
    out.append(('set2', 48000.0, 2, st))
    # 4. the automatic setting (5): the engine's own rate kept at every change
    st = [('patch', 5), E(ev=[on(0, 52, 0.8)])] + [E()] * 3
    for sr in (44100.0, 48000.0):
        st += rate_change(sr) + [E()] * 4
    st += [E(ev=[off(0, 52)])] + [E()] * 4
    out.append(('auto', 44100.0, 5, st))
    return out


def main():
    a = sys.argv[1:2]
    G.PRELUDE = 256
    if a == ['--ref']:
        return G.build_ref(chain_fn=chains, ref_pkl=REF_PKL)
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return G.check_port(only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
    if a == ['--port-tooth']:
        res = {}
        for t in ('late_note', 'no_active'):
            print('--- tooth %s' % t)
            res[t] = G.check_port(tooth=t, only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
        print()
        for t, b in res.items():
            print('%-12s %s (%d chains differ)' % (t, 'BITES' if b else 'DID NOT BITE', b))
        return 0 if all(res.values()) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
