#!/usr/bin/env python3
"""midi_ctl_gate.py -- the MIDI CONTROLLER INTAKE, plugin vs port (CLAIMS B16,
docs/HOST_RENDER_LAYER.md). The plugin side is its own IAudioProcessor::process on the booted
plugin (tools/verify/host_process_emu.py, the oracle host_process_gate.py --control ties to the
engine path every gate trusts); the port side is juno_gui_process_ex. Every chain starts as the
product does (juno_gui_plugin_init / the plugin's boot, the default engine-rate setting unless
the chain names one), one muted prelude block, then a settle on both sides (the start-up
transient is CLAIMS B15).

What a chain sends through the host's parameter queues (VST3 MIDI mapping, ids from the
plugin's base 0x0FFFC100 + n): pitch bend (129) over the 14-bit edges and wild values (below 0,
NaN, above 1); the mod wheel (CC 1) and the expression (CC 11) over 0..1 and above it; EVERY CC
0..127 but 64 and 123 at several values -- the 51 the plugin's default map assigns to panel
parameters (an arpeggiator switch among them) and the 77 it does not; channel aftertouch (128);
ids past 129; host parameters below the base (parameter records: the voice count, the
engine-rate setting -- which must NOT switch the rate --, a float-bits parameter, ids the map
lacks); records at offsets inside, at and past the block, with notes at the same offsets;
patch loads and a voice-count state change after a bend (the stored values are not re-sent).
CC 64, the sustain (a HOLD in the keyboard object): on the voices and in the arp, across arp
switches, at the CC's rounding edges, with key 127 down at a release, with the key-trig flag, in
MONO and UNISON patches; CC 123, all notes off: held keys, held notes, a running arp; a voice
steal released down to the stolen key.

  --ref         (Unicorn) writes scratchpad/midi_ctl_ref.pkl (.partial, then renamed)
  --port        (libjuno) every sample of both channels must agree
  --port-tooth  the port check must FAIL on two harness defects: one parameter point one sample
                late on the port side; one bend value one 14-bit step off. The port's own
                mutations (mutated builds): probes/host_midi/midi_teeth.py
  --only=a,b    port check of the named chains only"""
import math
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.environ.get('MIDI_CTL_REF', os.path.join(REPO, 'scratchpad', 'midi_ctl_ref.pkl'))
HEADER, STRIDE, NAME = 23, 20223, 16
BASE = 0x0FFFC100
VOICES, SRATE = 0x0FFFC00E, 0x0FFFC015
PRELUDE = 256
NAN = float('nan')


def ev_on(off, pitch, vel, ch=0):
    return ('on', off, ch, pitch, vel)


def ev_off(off, pitch, vel=0.5, ch=0):
    return ('off', off, ch, pitch, vel)


def cc(n, v, off=0):
    return (BASE + n, off, v)


def bend(v, off=0):
    return (BASE + 129, off, v)


def chains():
    """(name, host rate, setting, steps); a step: ('blk', n, events, ctx, params) with params
    [(id, offset, value)] (at most one point per id per block: the point the plugin reads);
    ('patch', factory index); ('state', [(id, v)])."""
    T = (True, 120.0)
    out = []
    E = lambda n=256, ev=(), par=(): ('blk', n, list(ev), T, list(par))
    # 1. pitch bend: a held chord, the 14-bit edges at moving offsets, wild values, a patch load
    #    and a voice-count change after a bend, notes started while bent
    st = [('patch', 9), E(ev=[ev_on(10, 60, 0.8), ev_on(10, 64, 0.7)])] + [E()] * 4
    for k, v in enumerate([0.75, 1.0, 0.5, 0.0, 0.25, 8191 / 16383.0, 8192 / 16383.0, 8193 / 16383.0,
                           1.5, -0.25, NAN, 2.0, 1e10, 0.50003, 0.49997, 0.3]):
        st += [E(par=[bend(v, (37 * k) % 256)])] + [E()] * 2
    st += [('patch', 21)] + [E()] * 3 + [E(ev=[ev_on(0, 67, 0.6)])] + [E()] * 4
    st += [('state', [(VOICES, 4)])] + [E()] * 3 + [E(par=[bend(0.9, 100)])] + [E()] * 4
    st += [E(ev=[ev_off(0, 60), ev_off(3, 64), ev_off(5, 67)], par=[bend(0.5, 5)])] + [E()] * 6
    out.append(('bend', 48000.0, None, st))
    # 2. mod wheel: an LFO patch, 0..1 and above (CC bytes over 127 are dropped by the engine)
    st = [('patch', 40), E(ev=[ev_on(0, 57, 0.9), ev_on(0, 64, 0.9)])] + [E()] * 3
    for k, v in enumerate([0.2, 0.5, 1.0, 0.0, 0.75, 1.3, 2.01, 0.6, -1.0, 0.33]):
        st += [E(par=[cc(1, v, (53 * k) % 256)])] + [E()] * 3
    st += [('patch', 0)] + [E()] * 3
    st += [E(ev=[ev_off(0, 57), ev_off(0, 64)])] + [E()] * 6
    out.append(('mod', 44100.0, None, st))
    # 3. expression: ramps at time index 1, a new value inside a running ramp
    st = [('patch', 5), E(ev=[ev_on(0, 48, 1.0)])] + [E()] * 3
    for k, v in enumerate([0.5, 0.0, 1.0, 0.8, 0.79, 0.1, 1.2, 0.65]):
        st += [E(64, par=[cc(11, v, (11 * k) % 64)])] + [E(64)] * 2
    st += [E(ev=[ev_off(0, 48)])] + [E()] * 6
    out.append(('expr', 48000.0, None, st))
    # 4./5. every CC but 64 and 123, notes held, two value sets; the map's arpeggiator switch
    #       (CC 15) turns the arp on in the first set
    for name, rate, vals in (('ccall_a', 48000.0, (0.6, 0.0)), ('ccall_b', 44100.0, (1.0, 0.3, 1.7))):
        st = [('patch', 2), E(ev=[ev_on(0, 55, 0.8), ev_on(1, 62, 0.7), ev_on(2, 67, 0.6)])] + [E()] * 2
        for v in vals:
            for n in range(128):
                if n in (64, 123):
                    continue
                st += [E(64, par=[cc(n, v, n % 64)])]
            st += [E()] * 4
        st += [E(ev=[ev_off(0, 55), ev_off(0, 62), ev_off(0, 67)])] + [E()] * 6
        out.append((name, rate, None, st))
    # 6. host parameters through process() (parameter records, kind 1): the voice count, the
    #    engine-rate setting (no switch), a float-bits parameter, ids the map lacks, ids past the
    #    MIDI range (three zero bytes), aftertouch; several queues in one block, offsets past it
    st = [('patch', 9), E(ev=[ev_on(0, 60, 0.8), ev_on(0, 63, 0.8), ev_on(0, 67, 0.8)])] + [E()] * 2
    for par in ([(VOICES, 7, 0.0)], [(VOICES, 0, 1.0)], [(VOICES, 3, 0.5)], [(SRATE, 0, 1.0)],
                [(SRATE, 9, 0.0)], [(0x0060003A, 0, 0.3)], [(0x0060003A, 100, 0.9), (0x006001E0, 100, 1.0)],
                [(0x00A02802, 5, 0.25)], [(0x00A00000, 0, 0.7)], [(0x00600000, 0, 0.5)], [(0x80000001, 0, 0.5)],
                [(BASE - 1, 0, 0.5)], [(BASE + 130, 10, 0.5)], [(BASE + 200, 20, 0.9)], [(BASE + 128, 0, 0.7)],
                [(BASE + 128, 30, 1.0)], [(0x00600078, 300, 0.2)], [(0x00600066, 0, 1.0), bend(0.0, 0)],
                [(0x006001D8, 0, 1.0), bend(1.0, 50)], [(0x00600002, 255, 0.4), cc(3, 0.9, 255)]):
        st += [E(par=par)] + [E()] * 3
    st += [E(ev=[ev_off(0, 60), ev_on(0, 72, 0.5)], par=[bend(0.1, 0), cc(1, 0.9, 0), cc(74, 0.2, 0)])] + [E()] * 3
    st += [E(ev=[ev_off(0, 63), ev_off(0, 67), ev_off(0, 72)])] + [E()] * 6
    out.append(('records', 48000.0, None, st))
    # 8. the sustain on the voices (CLAIMS B16b): a HOLD -- released keys keep sounding; a new
    #    key with no key down frees the held notes first; a held key pressed again plays again;
    #    the pedal's release frees them; CC 64 values on / off at their rounding edges; key 127
    #    down at a release (the plugin clears its down state through index -1); the key-trig flag
    #    1 (descending release order); a voice steal released down to the stolen key
    ON, OFF = 1.0, 0.0
    SUSTAIN = [(0x00600048, 255), (0x00600052, 255), (0x0060004A, 90), (0x00600054, 90)]   # ENV1/2 SUSTAIN, RELEASE
    st = [('patch', 0), ('state', SUSTAIN), E(ev=[ev_on(0, 60, 0.8), ev_on(0, 64, 0.7), ev_on(0, 67, 0.6)])] + [E()] * 2
    st += [E(par=[cc(64, ON, 10)])] + [E()]
    st += [E(ev=[ev_off(20, 60), ev_off(21, 64), ev_off(22, 67)])] + [E()] * 3
    st += [E(ev=[ev_on(30, 72, 0.9)])] + [E()] * 2 + [E(ev=[ev_off(0, 72)])] + [E()] * 2
    st += [E(ev=[ev_on(5, 72, 0.5)])] + [E()] * 2 + [E(par=[cc(64, OFF, 0)])] + [E()] * 2
    st += [E(ev=[ev_off(0, 72)])] + [E()] * 2
    for v in (0.6, 0.0039, 0.004, 0.0, 1.5, 0.0):                    # on, off, on, off, on, off
        st += [E(ev=[ev_on(0, 55, 0.7)], par=[cc(64, v, 100)]), E(ev=[ev_off(50, 55)]), E()]
    st += [E(ev=[ev_on(0, 127, 0.8), ev_on(0, 50, 0.8)])] + [E()] + [E(par=[cc(64, ON, 0)])]
    st += [E(ev=[ev_off(0, 50)])] + [E()] + [E(par=[cc(64, OFF, 7)])] + [E()] * 2
    st += [E(par=[cc(64, ON, 0)]), E(ev=[ev_on(0, 60, 0.6)]), E(ev=[ev_off(0, 60)]), E()]
    st += [E(ev=[ev_on(0, 64, 0.6)])] + [E()] * 2 + [E(ev=[ev_off(0, 64), ev_off(0, 127)], par=[cc(64, OFF, 9)])]
    st += [E()] * 3
    st += [('state', [(0x0060000C, 1)]), E(ev=[ev_on(0, 48, 0.5)]), E(par=[cc(64, ON, 0)])]
    st += [E(ev=[ev_on(0, 52, 0.5), ev_on(0, 55, 0.5), ev_off(10, 48), ev_off(11, 52), ev_off(12, 55)])]
    st += [E()] * 2 + [E(par=[cc(64, OFF, 0)])] + [E()] * 3 + [('state', [(0x0060000C, 0)])]
    steal = [ev_on(k, n, 0.8) for k, n in enumerate((40, 43, 47, 50, 53, 57, 60, 64))]
    st += [E(ev=steal)] + [E()] * 2
    st += [E(ev=[ev_off(k, n) for k, n in enumerate((43, 47, 50, 53, 57, 60, 64))])] + [E()] * 3
    st += [E(ev=[ev_off(0, 40)])] + [E()] * 4
    # a key left held with no voice: six keys, a seventh steals the newest voice and goes up,
    # then the five voiced keys go up -- the held flag (1856) follows the gated voices
    st += [E(ev=[ev_on(k, n, 0.8) for k, n in enumerate((40, 43, 47, 50, 53, 57))])] + [E()] * 2
    st += [E(ev=[ev_on(0, 60, 0.8)])] + [E()] * 2 + [E(ev=[ev_off(0, 60)])] + [E()] * 2
    st += [E(ev=[ev_off(k, n) for k, n in enumerate((40, 43, 47, 50, 53))])] + [E()] * 6
    st += [E(ev=[ev_off(0, 57)])] + [E()] * 4
    out.append(('sus', 48000.0, None, st))
    # 9. the sustain in the arp route and across the arp switch: keys released under it keep
    #    the arp running; a new key with no key in the arp frees the held keys; the release frees
    #    them; the switch off with the pedal down (held arp keys become held notes) and on again
    #    (held notes become held arp keys)
    T2 = (True, 128.0)
    A = lambda n=256, ev=(), par=(): ('blk', n, list(ev), T2, list(par))
    st = [('patch', 0), ('state', SUSTAIN + [(0x00600108, 1)]), A(ev=[ev_on(0, 60, 0.8), ev_on(0, 64, 0.8)])] + [A()] * 6
    st += [A(par=[cc(64, ON, 0)]), A(ev=[ev_off(3, 60), ev_off(4, 64)])] + [A()] * 10
    st += [A(ev=[ev_on(0, 67, 0.7)])] + [A()] * 8 + [A(ev=[ev_off(0, 67)])] + [A()] * 6
    st += [A(par=[cc(64, OFF, 0)])] + [A()] * 6
    st += [A(ev=[ev_on(0, 62, 0.9), ev_on(0, 65, 0.9)], par=[cc(64, ON, 5)])] + [A()] * 3
    st += [A(ev=[ev_off(0, 65)])] + [A()] * 3
    st += [('state', [(0x00600108, 0)])] + [A()] * 6
    st += [A(ev=[ev_on(0, 69, 0.6)])] + [A()] * 3 + [A(ev=[ev_off(0, 69)])] + [A()] * 2
    st += [('state', [(0x00600108, 1)])] + [A()] * 60
    st += [A(par=[cc(64, OFF, 0)])] + [A()] * 4 + [A(ev=[ev_off(0, 62)])] + [A()] * 6
    st += [('state', [(0x00600108, 0)])] + [A()] * 3
    # the switch on with held notes and NO key down: the held notes become the arp's (a key down
    # would be moved in last and free the arp's held keys again)
    st += [A(ev=[ev_on(0, 72, 0.8), ev_on(0, 76, 0.7)], par=[cc(64, ON, 10)])] + [A()] * 2
    st += [A(ev=[ev_off(0, 72), ev_off(1, 76)])] + [A()] * 2
    st += [('state', [(0x00600108, 1)])] + [A()] * 60
    st += [A(par=[cc(64, OFF, 0)])] + [A()] * 8 + [('state', [(0x00600108, 0)])] + [A()] * 3
    out.append(('sus_arp', 44100.0, None, st))
    # 10. all notes off (CC 123): held keys, held notes (sustain), a running arp; keys released and
    #     played after it; a MONO and a UNISON patch with the pedal and CC 123
    st = [('patch', 0), ('state', SUSTAIN), E(ev=[ev_on(0, 60, 0.8), ev_on(0, 64, 0.8)])] + [E()] * 3
    st += [E(par=[cc(123, 0.0, 40)])] + [E()] * 3 + [E(ev=[ev_off(0, 60), ev_on(9, 67, 0.7)])] + [E()] * 3
    st += [E(par=[cc(64, ON, 0)]), E(ev=[ev_off(0, 64), ev_off(0, 67)]), E(), E(par=[cc(123, 0.5, 0)])]
    st += [E()] * 2 + [E(ev=[ev_on(0, 72, 0.6)])] + [E()] * 2 + [E(par=[cc(64, OFF, 0)])] + [E()] * 2
    st += [E(ev=[ev_off(0, 72)])] + [E()] * 2
    st += [('state', [(0x00600108, 1)]), ('blk', 256, [ev_on(0, 57, 0.8)], T2, [])] + [A()] * 6
    st += [A(par=[cc(123, 1.0, 100)])] + [A()] * 8 + [A(ev=[ev_off(0, 57)])] + [A()] * 4
    st += [('state', [(0x00600108, 0)])] + [E()] * 2
    st += [('patch', 15), ('state', SUSTAIN), E(ev=[ev_on(0, 40, 0.8)])] + [E()] * 2
    st += [E(par=[cc(123, 0.0, 0)])] + [E()] * 2 + [E(ev=[ev_on(0, 52, 0.8)])] + [E()] * 3
    st += [E(ev=[ev_off(0, 52)])] + [E()] * 6 + [E(ev=[ev_off(0, 40)])] + [E()] * 3
    for patch in (15, 61):
        st += [('patch', patch), ('state', SUSTAIN), E(ev=[ev_on(0, 48, 0.8), ev_on(0, 55, 0.8)])] + [E()] * 2
        st += [E(par=[cc(64, ON, 0)]), E(ev=[ev_off(0, 55)]), E(), E(ev=[ev_off(0, 48)]), E()]
        st += [E(ev=[ev_on(0, 52, 0.7)])] + [E()] * 2 + [E(par=[cc(123, 0.0, 0)])] + [E()] * 2
        st += [E(ev=[ev_on(0, 59, 0.7), ev_off(5, 52)])] + [E()] + [E(par=[cc(64, OFF, 0)])] + [E()] * 2
        st += [E(ev=[ev_off(0, 59)])] + [E()] * 3
    out.append(('cc123', 48000.0, None, st))
    # 7. identity render object (engine at the host rate) at 96000: everything once
    st = [('patch', 33), E(512, ev=[ev_on(0, 50, 0.9), ev_on(5, 57, 0.9)])] + [E(512)] * 2
    st += [E(512, par=[bend(0.8, 0), cc(1, 0.7, 0), cc(11, 0.4, 0), cc(74, 0.6, 0), cc(3, 0.1, 0)])] + [E(512)] * 4
    st += [E(512, par=[bend(0.2, 400), cc(1, 0.0, 300), cc(11, 1.0, 200)])] + [E(512)] * 4
    st += [E(512, ev=[ev_off(0, 50), ev_off(0, 57)])] + [E(512)] * 6
    out.append(('ident96', 96000.0, 0, st))
    return out


def build_ref():
    import host_process_emu as H
    import e2e_emu as E
    bank = E.bank_bytes()
    ref = {'_chains': chains()}
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if only and os.path.exists(REF_PKL):              # the other chains from the existing reference
        old = pickle.load(open(REF_PKL, 'rb'))
        for ci, ch in enumerate(ref['_chains']):
            for oi, och in enumerate(old['_chains']):
                if repr(och) == repr(ch) and oi in old:      # repr: a NaN value never equals itself
                    ref[ci] = old[oi]
                    ref.setdefault('_payload', {})[ci] = old['_payload'][oi]
    for ci, (name, rate, setting, steps) in enumerate(ref['_chains']):
        if only and name not in only[0]:
            continue
        h = H.HostProcess()
        h.start(rate, 4096, setting=setting)
        payload = h.get_state()
        h.process(PRELUDE)
        h.snap_all()
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
                _, n, evs, ctx, par = stp
                c = dict(tempo=ctx[1], playing=True)
                l, r = h.process(n, events=evs, params=par, ctx=c)
                PL += l
                PR += r
        ref[ci] = (PL, PR)
        ref.setdefault('_payload', {})[ci] = payload
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        sys.stderr.write('ref chain %d %s %g Hz: %d samples, peak %.5f\n' % (
            ci, name, rate, len(PL), max(abs(f(x)) for x in PL + PR)))
        sys.stderr.flush()
        del h
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))   # whole or nothing (playbook 142)
    os.replace(REF_PKL + '.partial', REF_PKL)
    print('wrote', REF_PKL)
    return 0


def check_port(tooth=None, only=None):
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

    class Param(ctypes.Structure):
        _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_rr_settle.argtypes = [V]
    lib.juno_gui_unported.argtypes = [V]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_destroy', [V]),
                   ('juno_gui_set_engine_rate_setting', [V, ctypes.c_int]),
                   ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Param), ctypes.c_int,
                                            ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                            ctypes.POINTER(ctypes.c_float), ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    import truth
    bankb = open(truth.BANK, 'rb').read()
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    bad = 0
    for ci, (name, rate, setting, steps) in enumerate(ref['_chains']):
        if only is not None and name not in only:
            continue
        if ci not in ref:
            print('chain %2d %-9s: no reference' % (ci, name))
            bad += 1
            continue
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_set_fp_oracle_mode(1)        # after create, which sets the production FTZ
        lib.juno_gui_plugin_init(c)
        pl = ref['_payload'][ci]
        lib.juno_gui_queue_state(c, pl, len(pl))
        L0, R0 = (ctypes.c_float * PRELUDE)(), (ctypes.c_float * PRELUDE)()
        lib.juno_gui_process_ex(c, (Note * 1)(), 0, (Param * 1)(), 0, 0, 120.0, L0, R0, PRELUDE)
        lib.juno_rr_settle(lib.juno_gui_state(c))
        PL, PR = [], []
        toothed = [False]
        for stp in steps:
            if stp[0] == 'patch':
                lib.juno_gui_queue_patch(c, bankb, len(bankb), stp[1])
            elif stp[0] == 'state':
                b = b''.join(struct.pack('>Ii', a, v) for a, v in stp[1])
                b = struct.pack('>I', len(b)) + b
                lib.juno_gui_queue_state(c, b, len(b))
            else:
                _, n, evs, ctx, par = stp
                par = list(par)
                if par and not toothed[0] and tooth == 'late_record':
                    pid, off, v = par[0]
                    par[0] = (pid, off + 1, v)
                    toothed[0] = True
                if par and not toothed[0] and tooth == 'bend_step' and par[0][0] == BASE + 129 \
                        and 0.0 < par[0][2] < 0.99:
                    pid, off, v = par[0]
                    par[0] = (pid, off, v + 1.0 / 16383.0)
                    toothed[0] = True
                arr = (Note * max(1, len(evs)))()
                for i, (k, off, ch, pch, vel) in enumerate(evs):
                    arr[i] = Note(off, 0 if k == 'on' else 1, ch, pch, vel)
                parr = (Param * max(1, len(par)))()
                for i, (pid, off, v) in enumerate(par):
                    parr[i] = Param(pid & 0xFFFFFFFF, off, v)
                L = (ctypes.c_float * n)()
                R = (ctypes.c_float * n)()
                lib.juno_gui_process_ex(c, arr, len(evs), parr, len(par), 1 if ctx[0] else 0, ctx[1], L, R, n)
                PL += list(struct.unpack('<%dI' % n, bytes(L)))
                PR += list(struct.unpack('<%dI' % n, bytes(R)))
        unp = lib.juno_gui_unported(c)
        lib.juno_gui_destroy(c)
        RL, RR = ref[ci]
        diff = [i for i in range(len(RL)) if RL[i] != PL[i] or RR[i] != PR[i]]
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        print('chain %2d %-9s %-7g %7d samples: %s%s' % (ci, name, rate, len(RL), 'BIT-EXACT' if not diff else
              '%d differ, first at %d (plugin %.6g, port %.6g)' % (len(diff), diff[0], f(RL[diff[0]]), f(PL[diff[0]])),
              '' if not unp else '  -- REACHED AN UNPORTED PATH (juno_gui_unported = %d): not graded' % unp))
        bad += bool(diff) or bool(unp)
    if tooth:
        return bad
    print('\n=== MIDI CONTROLLERS (CLAIMS A26 / B16b): bend, mod, expression, the CC map, parameter records, sustain, all notes off -- plugin vs port ===')
    print('GATE: %s' % ('FAIL' if bad else 'PASS'))
    return 1 if bad else 0


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return check_port(only=only[0] if only else None)
    if a == ['--port-tooth']:
        res = {}
        for t in ('late_record', 'bend_step'):
            print('--- tooth %s' % t)
            res[t] = check_port(tooth=t, only=only[0] if only else None)
        print()
        for t, b in res.items():
            print('%-12s %s (%d chains differ)' % (t, 'BITES' if b else 'DID NOT BITE', b))
        return 0 if all(res.values()) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
