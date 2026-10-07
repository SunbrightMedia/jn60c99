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

--ref / --port  THE RENDER DRIVER (CLAIMS B14): chains of host blocks through the plugin's own
           process() and through the port's juno_gui_process -- the arp running, keys at every
           kind of offset (two in one block, note-off and note-on at one offset, offsets past the
           block), several block sizes, host tempos valid (integer, x.5, x.3, below 40 BPM) and
           absent, factory arp patches loaded through the plugin's patch load and the arp switch
           / TYPE / STEP changed through setState, all with the identity render object (the
           engine-rate setting matched to the host rate, 44100 / 48000 / 96000). Every sample
           of both channels must agree. Two-process rule: --ref (Unicorn) writes
           scratchpad/host_process_ref.pkl, --port (libjuno) reads it.
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


REF_PKL = os.environ.get('HOST_PROCESS_REF', os.path.join(REPO, 'scratchpad', 'host_process_ref.pkl'))
ARP_SW, ARP_TYPE, ARP_STEP = 0x600108, 0x600110, 0x600118
HEADER, STRIDE, NAME = 23, 20223, 16


def ev_on(off, pitch, vel, ch=0):
    return ('on', off, ch, pitch, vel)


def ev_off(off, pitch, vel=0.5, ch=0):
    return ('off', off, ch, pitch, vel)


SETTLE = [('blk', 512, [], None)] * 12     # 6144 samples: the plugin's start-up ramps finish (CLAIMS B15)


def chains():
    """(name, host rate, steps); a step: ('blk', n, events, ctx) with ctx None (no
    ProcessContext) or (valid, tempo); ('patch', factory index); ('state', [(id, v)]).
    Every chain begins with SETTLE: the plugin starts with ~274 ramps per unit in flight
    (its build and sample-rate setup, no settle), the port from the settled engine; that
    start-up transient is CLAIMS B15, graded separately."""
    out = []
    for rate in (48000.0, 44100.0, 96000.0):
        B = 512
        T1 = (True, 120.0)
        st = [('blk', B, [], T1)] * 4 + [('patch', 1)]
        st += [('blk', B, [ev_on(100, 60, 100 / 127.0)], T1)] + [('blk', B, [], T1)] * 12
        st += [('blk', B, [ev_on(0, 64, 0.9), ev_on(255, 67, 0.3)], T1)] + [('blk', B, [], T1)] * 10
        st += [('blk', B, [ev_off(300, 60)], T1)] + [('blk', B, [], T1)] * 8
        st += [('blk', B, [ev_off(0, 64), ev_off(0, 67)], T1)] + [('blk', B, [], T1)] * 6
        T2 = (True, 128.5)
        st += [('blk', B, [], T2), ('blk', B, [ev_on(17, 72, 0.7)], T2)] + [('blk', B, [], T2)] * 16
        st += [('blk', B, [ev_off(50, 72), ev_on(50, 72, 0.6)], T2)] + [('blk', B, [], T2)] * 10
        st += [('blk', B, [ev_off(0, 72)], T2)] + [('blk', B, [], T2)] * 6
        st += [('patch', 33), ('blk', B, [ev_on(0, 55, 0.8), ev_on(0, 62, 0.8), ev_on(1, 67, 0.8)], T2)]
        st += [('blk', B, [], T2)] * 12
        st += [('state', [(ARP_SW, 0)])] + [('blk', B, [], T2)] * 4
        st += [('state', [(ARP_SW, 1)])] + [('blk', B, [], T2)] * 10
        st += [('state', [(ARP_TYPE, 2), (ARP_STEP, 2)])] + [('blk', B, [], T2)] * 10
        st += [('blk', B, [ev_off(5, 55), ev_off(6, 62), ev_off(7, 67)], T2)] + [('blk', B, [], T2)] * 6
        out.append(('main', rate, SETTLE + st))
    # odd block sizes, tempos x.3 / absent / below 40 BPM / 300+, offsets past the block
    for rate in (48000.0, 44100.0):
        st = [('patch', 9)]
        T = (True, 97.3)
        st += [('blk', 333, [ev_on(332, 48, 0.75)], T)] + [('blk', 333, [], T)] * 20
        st += [('blk', 64, [ev_on(70, 52, 0.5)], T)] + [('blk', 64, [], T)] * 40      # past the block: next block, offset 0
        st += [('blk', 1024, [ev_off(1000, 48), ev_on(3, 57, 1.0)], None)] + [('blk', 1024, [], None)] * 8
        T3 = (True, 33.3)
        st += [('blk', 1024, [], T3)] * 10
        T4 = (True, 300.04)
        st += [('blk', 777, [ev_on(1, 60, 0.4)], T4)] + [('blk', 777, [], T4)] * 10
        st += [('blk', 512, [ev_off(0, 52), ev_off(0, 57), ev_off(0, 60)], (False, 150.0))] + [('blk', 512, [], (False, 150.0))] * 6
        out.append(('odd', rate, SETTLE + st))
    return out


def build_ref():
    import host_process_emu as H
    import e2e_emu as E
    bank = E.bank_bytes()
    ref = {'_chains': chains()}
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        h = H.HostProcess()
        h.start(rate, 4096, setting=SETTING[rate])
        payload = h.get_state()
        PL, PR = [], []
        for stp in steps:
            if stp[0] == 'patch':
                rec = bank[HEADER + stp[1] * STRIDE: HEADER + (stp[1] + 1) * STRIDE]
                h.load_patch(rec[NAME:])
            elif stp[0] == 'state':
                pl = b''.join(struct.pack('>Ii', a, b) for a, b in stp[1])
                if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
                    raise SystemExit('setState failed')
            else:
                _, n, evs, ctx = stp
                c = None if ctx is None else (dict(tempo=ctx[1], playing=True) if ctx[0] else dict(state=0x2, tempo=ctx[1]))
                l, r = h.process(n, events=evs, ctx=c)
                PL += l
                PR += r
        ref[ci] = (PL, PR)
        ref.setdefault('_payload', {})[ci] = payload
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        sys.stderr.write('ref chain %d %s %g Hz: %d samples, peak %.5f, engine renders %d\n' % (
            ci, name, rate, len(PL), max(abs(f(x)) for x in PL + PR), len(h.renders)))
        sys.stderr.flush()
        del h
    pickle.dump(ref, open(REF_PKL, 'wb'))
    print('wrote', REF_PKL)
    return 0


def check_port(verbose=False):
    import ctypes
    import freshlib
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    lib = freshlib.load()
    V = ctypes.c_void_p

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_destroy', [V]),
                   ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_process', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.c_int, ctypes.c_double,
                                         ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float), ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    import truth
    bankb = open(truth.BANK, 'rb').read()
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    lib.juno_set_fp_oracle_mode(1)            # the oracle's FP mode: DAZ, no FTZ (playbook 120)
    bad = 0
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_plugin_init(c)
        pl = ref['_payload'][ci]
        lib.juno_gui_queue_state(c, pl, len(pl))
        PL, PR = [], []
        for stp in steps:
            if stp[0] == 'patch':
                lib.juno_gui_queue_patch(c, bankb, len(bankb), stp[1])
            elif stp[0] == 'state':
                b = b''.join(struct.pack('>Ii', a, v) for a, v in stp[1])
                b = struct.pack('>I', len(b)) + b
                lib.juno_gui_queue_state(c, b, len(b))
            else:
                _, n, evs, ctx = stp
                arr = (Note * max(1, len(evs)))()
                for i, (k, off, ch, pch, vel) in enumerate(evs):
                    arr[i] = Note(off, 0 if k == 'on' else 1, ch, pch, vel)
                L = (ctypes.c_float * n)()
                R = (ctypes.c_float * n)()
                valid, tempo = (0, 120.0) if ctx is None else (1 if ctx[0] else 0, ctx[1])
                lib.juno_gui_process(c, arr, len(evs), valid, tempo, L, R, n)
                PL += list(struct.unpack('<%dI' % n, bytes(L)))
                PR += list(struct.unpack('<%dI' % n, bytes(R)))
        lib.juno_gui_destroy(c)
        RL, RR = ref[ci]
        diff = [i for i in range(len(RL)) if RL[i] != PL[i] or RR[i] != PR[i]]
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        print('chain %d %-5s %-7g %7d samples: %s' % (ci, name, rate, len(RL), 'BIT-EXACT' if not diff else
              '%d differ, first at %d (plugin %.6g, port %.6g)' % (len(diff), diff[0], f(RL[diff[0]]), f(PL[diff[0]]))))
        bad += bool(diff)
    print('\n=== HOST PROCESS (CLAIMS B14): the render driver -- arp clock, tempo, events at offsets -- plugin vs port ===')
    print('GATE: %s' % ('FAIL' if bad else 'PASS'))
    return 1 if bad else 0


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
    if a == ['--ref']:
        return build_ref()
    if a == ['--port']:
        return check_port('-v' in sys.argv)
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
