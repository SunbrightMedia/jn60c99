#!/usr/bin/env python3
"""host_process_gate.py -- the HOST RENDER LAYER, plugin vs port (docs/HOST_RENDER_LAYER.md,
CLAIMS B13/B14). The plugin side is its own IAudioProcessor::process on the booted plugin
(tools/verify/host_process_emu.py).

--control  (Unicorn only) THE ISOLATION CONTROL (mantra 5): the process() oracle must equal the
           path every engine gate trusts. Identity render object (vm.vs.sampleRate set to the
           host rate) at 44100 / 48000 / 96000, no ProcessContext, notes at block starts: the
           plugin's own process() vs the e2e engine (BUILD + SETSR, settled ramps, the param
           database populated) fed the same queue records through the host entry and the same
           notes. Every sample must agree.
--control-tooth  the control must FAIL on two named defects: the harness delivering a note one
           sample late; the e2e side built without the ramp settle (the boot's own settle is
           part of what the control asserts).
"""
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
SETTING = {96000.0: 0, 88200.0: 1, 48000.0: 2, 44100.0: 3}
APPLY_RVA, POPULATE_RVA = 0x3C7AE0, 0xAD5A0


def midi_vel(v):
    """process()'s velocity conversion (rva 0x34A380): (int)(float)(v * 127.0) & 0x7F"""
    f32 = lambda x: struct.unpack('<f', struct.pack('<f', x))[0]
    return int(f32(f32(v) * 127.0)) & 0x7F


def control_chain(rate, tooth=None, nb=24, block=512):
    import host_process_emu as H
    import e2e_emu as E
    notes = {4: [('on', 0, 0, 60, 100 / 127.0)], 9: [('on', 0, 0, 64, 77 / 127.0)],
             14: [('off', 0, 0, 60, 0.5)], 18: [('off', 0, 0, 64, 0.5)]}
    h = H.HostProcess()
    h.start(rate, block, setting=SETTING[rate])
    init = [(struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0]) for k, o, r in h.queue()]
    PL, PR = [], []
    for b in range(nb):
        ev = notes.get(b, [])
        if tooth == 'late_event':
            ev = [(k, off + 1, ch, p, v) for k, off, ch, p, v in ev]
        l, r = h.process(block, events=ev)
        PL += l
        PR += r
    del h
    e = E.E2E()
    e.build(rate)
    if tooth != 'no_snap':
        e.snap_all()
    e.call(E.IB + POPULATE_RVA, count=200_000_000)
    e.set_ftz()
    for pid, v in init:
        e.call(E.IB + APPLY_RVA, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=60_000_000)
    EL, ER = [], []
    for b in range(nb):
        for k, off, ch, p, v in notes.get(b, []):
            if k == 'on':
                e.note_on(p, midi_vel(v))
            else:
                e.note_off(p)
        l, r = e.render(block, block=block)
        EL += l
        ER += r
    del e
    diff = [i for i in range(len(PL)) if PL[i] != EL[i] or PR[i] != ER[i]]
    f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
    peak = max(abs(f(x)) for x in PL + PR)
    return diff, peak, len(PL)


def control(tooth=None):
    bad = 0
    for rate in (44100.0, 48000.0, 96000.0):
        diff, peak, n = control_chain(rate, tooth)
        print('%-8g %d samples, peak %.6f: %s' % (rate, n, peak, 'BIT-EXACT' if not diff else
                                                    '%d differ, first at %d' % (len(diff), diff[0])))
        bad += bool(diff) or peak == 0.0
    return bad


def main():
    a = sys.argv[1:2]
    if a == ['--control']:
        bad = control()
        print('\n=== HOST PROCESS CONTROL: the plugin\'s own process() == the trusted engine path (identity, block-start notes) ===')
        print('GATE: %s' % ('FAIL' if bad else 'PASS'))
        return 1 if bad else 0
    if a == ['--control-tooth']:
        res = {}
        for t in ('late_event', 'no_snap'):
            print('--- tooth %s' % t)
            res[t] = control(t)
        print()
        for t, b in res.items():
            print('%-12s %s' % (t, 'BITES' if b else 'DID NOT BITE'))
        return 0 if all(res.values()) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
