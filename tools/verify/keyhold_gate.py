#!/usr/bin/env python3
"""keyhold_gate.py -- THE KEYBOARD'S NOTE VALUE AND KEY HOLD, plugin vs port (CLAIMS A36).

The plugin keeps one model value for its panel keyboard, ms.ch[vm.ks.ch].note: a state per key
(on: the velocity, off: minus the velocity, 0 never or released). Two writers (EXECUTED,
probes in docs/KEY_HOLD.md): the UI timer's drain (rva 0x320120 -> 0x29FF40) writes every note
the wrapper's push queued for it (any channel, straight into the states, no engine record); the
panel keyboard's send (rva 0x2D47E0) writes (key, value) and, on a change only, the core's
listener (rva 0x321B30) queues a MIDI record for the engine. And one release: the core's model
handler (rva 0x31C820), for a set of model values that holds KEY HOLD reading 0 -- changed or
not -- first sets every key above 0 to 0, and the listener queues a note-off at velocity 0 for
each, in key order, before that set's own records. A patch load is such a set (KEY HOLD's tree
node begins with ARPEGGIO SW), so is each setState entry, a model set from the GUI, a drained
store record of a CC learned to KEY HOLD (at its place in the drain's queue). Not such a set: the
host's own parameter KEY HOLD through process() -- no release (EXECUTED, chain 'host').

Chains (the product boot, host 48000, one muted prelude, the settle): the seed-4 scenario of the
.exe check (pedal down, keys held and released, a drain, a patch load, a new key); patch loads
with keys drained / not drained, arp patches; a crafted record with KEY HOLD = 1 (no release);
setState with KEY HOLD 0 among other entries, with KEY HOLD 1, without it; GUI model sets of
KEY HOLD 0 -> 0, 0 -> 1, 1 -> 0; a CC learned to KEY HOLD with notes queued before and after its
record; keyboard writes (press, the same value again, a key held by MIDI at the same and at
another velocity, releases at -offVel), the velocity switch off (the UI's vm.vs.velSense set to
0 in the model: the listener's flag); host notes on channels 0, 5, 9, 15; a note-on at
velocity 0; the host's KEY HOLD through process() at 0 and 1, before and after drains. Graded: every sample of both channels, and at every ('check',) the 128 states and the
queue the next block's render driver applies (each record's kind, a MIDI record's bytes; in a chain
with GUI model sets its MIDI records only: the port's model set carries the host's round trip as a
record of its own, which the plugin's bare set does not queue).

  --ref           (Unicorn) writes scratchpad/keyhold_ref.pkl (.partial, then renamed), every chain
                  from the plugin; --ref --keep: a chain whose steps did not change keeps its reference
  --port          (libjuno) every sample and every state must agree
  --port-tooth    the port check must FAIL on the port's own defects, built from the bridge
                  with -DKS_TOOTH=n: 1 no release (the port before A36), 2 the drain's notes not
                  kept, 3 the drain's release at its end, 4 a patch load's release after its
                  records, 5 a release's entries never sent again, 6 no commit empties the
                  change list, 7 a keyboard write without the change test, 8 the host's KEY HOLD
                  through process() releases
"""
import os
import pickle
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.environ.get('KEYHOLD_REF', os.path.join(REPO, 'scratchpad', 'keyhold_ref.pkl'))
HEADER, STRIDE, NAME = 23, 20223, 16
BASE = 0x0FFFC100
KH, ARPSW, CUT, RESO, OCT = 0x00600138, 0x00600108, 0x0060003A, 0x0060003E, 0x00600130
PRELUDE = 256
CRAFT = 63                      # the factory record crafted with KEY HOLD = 1 (patch 63's slot)


def on(p, v=0.75, ch=0, off=0):
    return ('on', off, ch, p, v)


def off(p, v=0.5, ch=0, off_=0):
    return ('off', off_, ch, p, v)


def blk(evs=(), par=(), n=128):
    return ('blk', n, list(evs), list(par))


def cc(n, v):
    return (BASE + n, 0, v)


def bank_bytes():
    """the factory bank, record CRAFT with KEY HOLD = 1 (INT8X4 at record offset 340)"""
    import truth
    b = bytearray(open(truth.BANK, 'rb').read())
    r = HEADER + CRAFT * STRIDE
    b[r + 340: r + 348] = bytes([0, 0, 0, 0, 0, 0, 0, 1])
    return bytes(b)


def chains():
    W = [blk()] * 3
    C = [('check',)]
    out = []
    # 1. the .exe seed-4 scenario: the pedal, keys held and released under it, a drain, a load, a new key
    s = [('patch', 46)] + W + [blk(par=[cc(64, 1.0)]), blk([on(46), on(48), on(55, 0.6)]), blk(), ('drain',)] + C
    s += [blk([off(55)]), blk([on(60), on(62)]), blk([off(60), off(62)]), ('drain',)] + C
    s += [blk([on(89)]), blk()] + [('patch', 31)] + C + [blk(), blk([on(76, 0.64)])] + W * 4 + C
    out.append(('seed4', s))
    # 2. loads: keys drained, keys not drained, a key released before the drain, KEY HOLD 1, the arp
    s = [('patch', 0)] + W + [blk([on(60), on(64), on(67)]), ('drain',), blk([on(72)]), blk([off(64)])] + C
    s += [('patch', 5)] + C + W * 3 + [blk([on(48)]), ('drain',), ('patch', CRAFT)] + C + W * 3
    s += [('patch', 1), blk([on(50), on(53)])] + W + [('drain',), ('patch', 9)] + C + W * 6
    s += [blk([off(50), off(53), off(72)]), ('drain',), ('patch', 17)] + C + W * 3
    out.append(('loads', s))
    # 3. setState: KEY HOLD 0 among others, KEY HOLD 1, none, KEY HOLD as given (5)
    s = [('patch', 12)] + W + [blk([on(60), on(64)]), ('drain',), ('state', [(CUT, 40), (KH, 1), (RESO, 9)])] + C + W
    s += [('state', [(CUT, 90)])] + C + W + [('state', [(CUT, 60), (KH, 0), (RESO, 30)])] + C + W * 2
    s += [blk([on(70)]), ('drain',), ('state', [(KH, 5)])] + C + W + [('state', [(KH, 0)])] + C + W * 2
    out.append(('state', s))
    # 4. the GUI's model set of KEY HOLD: 0 -> 0, 0 -> 1, 1 -> 1, 1 -> 0
    s = [('patch', 20)] + W + [blk([on(60), on(64), on(67)]), ('drain',), ('model', KH, 0)] + C + W
    s += [blk([on(72)]), ('drain',), ('model', KH, 1)] + C + W + [('model', KH, 1), blk([on(74)]), ('drain',)] + C
    s += [('model', KH, 0)] + C + W * 3
    out.append(('model', s))
    # 5. a CC learned to KEY HOLD: notes before and after its store record in the drain's queue
    s = [('patch', 3), ('learn', KH), blk(par=[cc(20, 1.0)]), ('drain',)] + W + [blk([on(60), on(67)]), ('drain',)]
    s += [blk([on(64, 0.5, 5), off(60, 0.4, 9)], [cc(20, 0.0)]), blk([on(72, 0.8)])] + C + [('drain',)] + C + W * 3
    s += [blk(par=[cc(20, 0.0)]), blk([on(48)]), blk(par=[cc(20, 0.0)]), ('drain',)] + C + W * 3
    # several KEY HOLD records before one drain: each its own value, each its release (EXECUTED)
    s += [blk([on(60), on(67)]), ('drain',), blk([on(70)], [cc(20, 0.0)]), blk([on(71)], [cc(20, 1.0)]), ('drain',)] + C + W
    s += [blk([off(70), off(71)]), ('drain',), blk([on(52)], [cc(20, 1.0)]), blk([on(53)], [cc(20, 0.0)]), blk([on(55)], [cc(20, 0.0)])]
    s += [('drain',)] + C + W * 3
    out.append(('learn', s))
    # 6. the panel keyboard's writes
    s = [('patch', 7)] + W + [('kb', 60, 90)] + C + W + [('kb', 60, 90), ('kb', 60, -64), ('kb', 64, 33)] + C + W
    s += [blk([on(67, 0.6)]), ('drain',), ('kb', 67, 76), ('kb', 67, 100)] + C + W + [('kb', 67, -64), ('kb', 48, 1)] + C
    s += W + [('kb', 64, -64), ('patch', 8)] + C + W * 2 + [('kb', 52, 127), ('kb', 55, 64)] + W
    s += [('velsw', 0), ('kb', 59, 30), blk([on(62, 0.3)]), ('drain',)] + C + W + [('kb', 59, -20)] + C + W
    s += [('model', KH, 0)] + C + [('velsw', 1)] + W * 2
    out.append(('keybed', s))
    # 7. the change list: a load's release goes again at the next keyboard write, or at a second load's;
    #    a drain, a panel commit, setState empty it; a model set alone does not (OCTAVE SHIFT: a GUI
    #    set of a parameter the engine uses would reach the plugin's engine only through the host)
    s = [('patch', 13)] + W + [blk([on(60), on(64), on(67, 0.6)]), ('drain',), ('patch', 14), blk(), ('kb', 50, 90)] + C + W
    s += [('kb', 50, -64), blk([on(70), on(72)]), ('drain',), ('patch', 15), blk(), ('drain',), ('kb', 52, 80)] + C + W
    s += [blk([on(74)]), ('drain',), ('patch', 16), blk(), ('patch', 17), blk(), ('kb', 55, 70)] + C + W
    s += [('kb', 55, -64), blk([on(60), on(62)]), ('drain',), ('model', KH, 0), blk(), ('model', OCT, 1), ('kb', 57, 99)] + C + W
    s += [('kb', 57, -64), blk([on(65)]), ('drain',), ('model', KH, 0), ('commit',), blk(), ('kb', 59, 99)] + C + W
    s += [('kb', 59, -64), blk([on(67)]), ('drain',), ('state', [(CUT, 50), (KH, 0)]), blk(), ('kb', 61, 99)] + C + W * 2
    out.append(('changes', s))
    # 8. the reach of two rules: a keyboard write of the value the drain left, the host's release not
    #    yet drained (no change: nothing); an arp patch loaded over drained keys (the release comes
    #    before ARPEGGIO SW: the keys leave the voices before the arp could take them)
    s = [('patch', 2)] + W + [blk([on(67, 0.6)]), ('drain',), blk([off(67)]), ('kb', 67, 76)] + C + W * 2
    s += [blk([on(48), on(52)]), ('drain',), ('patch', 1)] + C + W + [blk([on(60), on(64)])] + W * 6
    s += [blk([off(60), off(64)]), ('drain',), ('patch', 2)] + C + W * 2
    out.append(('reach', s))
    # 9. channels and velocity 0
    s = [('patch', 10)] + W + [blk([on(60, 0.7, 0), on(64, 0.7, 5), on(67, 0.7, 9), on(71, 0.7, 15)]), ('drain',)] + C
    s += [blk([off(64, 0.3, 2), on(72, 0.0)]), ('drain',)] + C + [('patch', 11)] + C + W * 3
    out.append(('channels', s))
    # 10. the host's own parameter KEY HOLD through process(): the plugin releases nothing (EXECUTED)
    hp = lambda v, o=0: (KH, o, v)
    s = [('patch', 20)] + W + [blk([on(60), on(64), on(67)]), ('drain',)] + C
    s += [blk(par=[hp(0.0)])] + C + W
    s += [blk([on(72)]), ('drain',), blk(par=[hp(1.0)])] + C + W
    s += [blk([on(74)]), ('drain',), blk(par=[hp(0.0, 30)])] + C + W * 2
    s += [blk([on(76)]), blk(par=[hp(0.0)]), ('drain',)] + C + W * 2
    s += [blk(par=[hp(1.0)]), ('drain',), blk([on(48)]), ('drain',), blk(par=[hp(0.0)]), ('drain',)] + C + W * 2
    out.append(('host', s))
    return [(name, 48000.0, steps) for name, steps in out]


def states_of(get):
    return tuple(get(k) for k in range(128))


def build_ref():
    import host_process_emu as H
    bank = bank_bytes()
    ref = {'_chains': chains()}
    keep = set()
    if os.path.exists(REF_PKL) and '--keep' in sys.argv:   # --keep: an unchanged chain keeps its reference
        old = pickle.load(open(REF_PKL, 'rb'))
        for ci, ch in enumerate(ref['_chains']):
            for oi, och in enumerate(old['_chains']):
                if repr(och) == repr(ch) and oi in old:
                    ref[ci] = old[oi]
                    keep.add(ci)
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        if ci in keep:
            continue
        h = H.HostProcess()
        h.start(rate, 4096)
        uc = h.uc
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        vb, ve = q(h.core + 24), q(h.core + 32)
        rec, idx = {}, {}
        for i in range((ve - vb) // 24):
            pid = h.call(H.IB + 0x319C50, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF
            rec[pid], idx[pid] = q(vb + 24 * i), i
        model = q(q(h.core + 8))
        ring = q(model + 128)
        nv, vs = h.vcall(ring, 6), h.vcall(ring, 8)
        arr = h.vcall(nv, 24)
        state = lambda: struct.unpack('<128i', bytes(uc.mem_read(arr, 512)))
        h.process(PRELUDE)
        h.snap_all()
        PL, PR, checks = [], [], []
        for stp in steps:
            k = stp[0]
            if k == 'patch':
                h.load_patch(bank[HEADER + stp[1] * STRIDE + NAME: HEADER + (stp[1] + 1) * STRIDE])
            elif k == 'state':
                pl = b''.join(struct.pack('>Ii', a, b) for a, b in stp[1])
                if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
                    raise SystemExit('setState failed')
            elif k == 'model':
                h.call(H.IB + 0x283DB0, rcx=model, rdx=rec[stp[1]], r8=stp[2] & 0xFFFFFFFF, r9=1)
            elif k == 'velsw':                        # the UI's vm.vs.velSense in the model
                h.call(H.IB + 0x283DB0, rcx=model, rdx=vs, r8=stp[1], r9=1)
                if uc.mem_read(h.core + 572, 1)[0] != stp[1]:
                    raise SystemExit('velSense %d did not reach the switch byte' % stp[1])
            elif k == 'learn':
                h.call(H.IB + 0x31AA40, rcx=h.core + 24, rdx=idx[stp[1]])
            elif k == 'drain':
                h.call(H.IB + 0x320120, rcx=h.core, count=2_000_000_000)
            elif k == 'commit':                       # a panel control's notifies and commit after its set
                for rva in (0x285320, 0x2853C0, 0x283120):
                    h.call(H.IB + rva, rcx=model, count=500_000_000)
            elif k == 'kb':                           # the panel keyboard's send (rva 0x2D47E0's write)
                buf = h.alloc_com(16)
                uc.mem_write(buf, struct.pack('<ii', stp[1], stp[2]))
                h.call(H.IB + 0x2838C0, rcx=model, rdx=nv, r8=buf, count=500_000_000)
                for rva in (0x285320, 0x2853C0, 0x283120):
                    h.call(H.IB + rva, rcx=model, count=500_000_000)
            elif k == 'check':                        # the states, and the queue the next block applies
                checks.append((state(), tuple((kk, r[8:11].hex() if kk == 0 else '') for kk, o, r in h.queue())))
            elif k == 'blk':
                _, n, evs, par = stp
                l, r = h.process(n, events=evs, params=par, ctx=dict(tempo=120.0, playing=True))
                PL += l
                PR += r
        ref[ci] = (PL, PR, checks)
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        sys.stderr.write('ref chain %d %s: %d samples, peak %.5f, %d checks\n' % (
            ci, name, len(PL), max(abs(f(x)) for x in PL + PR), len(checks)))
        sys.stderr.flush()
        del h
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))       # whole or nothing (playbook 142)
    os.replace(REF_PKL + '.partial', REF_PKL)
    print('wrote', REF_PKL)
    return 0


def check_port(libpath=None, quiet=False):
    import ctypes
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    if libpath is None:
        import freshlib
        lib = freshlib.load()
    else:
        lib = ctypes.CDLL(libpath)
    V = ctypes.c_void_p

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]

    class Param(ctypes.Structure):
        _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]
    for fn, at, rt in (('juno_gui_create', [ctypes.c_float, ctypes.c_int], V), ('juno_gui_state', [V], V),
                       ('juno_rr_settle', [V], None), ('juno_gui_plugin_init', [V], ctypes.c_int),
                       ('juno_gui_destroy', [V], None), ('juno_gui_unported', [V], ctypes.c_int),
                       ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_model_set', [V, ctypes.c_uint32, ctypes.c_int32], ctypes.c_int),
                       ('juno_gui_cc_learn', [V, ctypes.c_uint32], ctypes.c_int), ('juno_gui_ui_tick', [V], None),
                       ('juno_gui_commit', [V], None),
                       ('juno_gui_set_kbd_velocity', [V, ctypes.c_int], None),
                       ('juno_gui_keybed_write', [V, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_keybed_state', [V, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_queue_peek', [V, V, V, ctypes.c_int], ctypes.c_int),
                       ('juno_set_fp_oracle_mode', [ctypes.c_int], None),
                       ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Param), ctypes.c_int,
                                                ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                                ctypes.POINTER(ctypes.c_float), ctypes.c_int], ctypes.c_int)):
        getattr(lib, fn).argtypes = at
        getattr(lib, fn).restype = rt
    bank = bank_bytes()
    bad = 0
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_set_fp_oracle_mode(1)        # after create, which sets the production FTZ
        lib.juno_gui_plugin_init(c)
        L0, R0 = (ctypes.c_float * PRELUDE)(), (ctypes.c_float * PRELUDE)()
        lib.juno_gui_process_ex(c, (Note * 1)(), 0, (Param * 1)(), 0, 0, 120.0, L0, R0, PRELUDE)
        lib.juno_rr_settle(lib.juno_gui_state(c))
        PL, PR, checks = [], [], []
        for stp in steps:
            k = stp[0]
            if k == 'patch':
                lib.juno_gui_queue_patch(c, bank, len(bank), stp[1])
            elif k == 'state':
                b = b''.join(struct.pack('>Ii', a, v) for a, v in stp[1])
                b = struct.pack('>I', len(b)) + b
                lib.juno_gui_queue_state(c, b, len(b))
            elif k == 'model':
                lib.juno_gui_model_set(c, stp[1], stp[2])
            elif k == 'velsw':
                lib.juno_gui_set_kbd_velocity(c, stp[1])
            elif k == 'learn':
                lib.juno_gui_cc_learn(c, stp[1])
            elif k == 'drain':
                lib.juno_gui_ui_tick(c)
            elif k == 'commit':
                lib.juno_gui_commit(c)
            elif k == 'kb':
                lib.juno_gui_keybed_write(c, stp[1], stp[2])
            elif k == 'check':
                kinds = (ctypes.c_int * 4096)()
                midi = (ctypes.c_ubyte * (3 * 4096))()
                nq = lib.juno_gui_queue_peek(c, kinds, midi, 4096)
                q = tuple((kinds[i], bytes(midi[3 * i:3 * i + 3]).hex() if kinds[i] == 0 else '') for i in range(min(nq, 4096)))
                checks.append((states_of(lambda key: lib.juno_gui_keybed_state(c, key)), q))
            elif k == 'blk':
                _, n, evs, par = stp
                arr = (Note * max(1, len(evs)))()
                for i, (kk, o, ch, p, v) in enumerate(evs):
                    arr[i] = Note(o, 0 if kk == 'on' else 1, ch, p, v)
                parr = (Param * max(1, len(par)))()
                for i, (pid, o, v) in enumerate(par):
                    parr[i] = Param(pid & 0xFFFFFFFF, o, v)
                L = (ctypes.c_float * n)()
                R = (ctypes.c_float * n)()
                lib.juno_gui_process_ex(c, arr, len(evs), parr, len(par), 1, 120.0, L, R, n)
                PL += list(struct.unpack('<%dI' % n, bytes(L)))
                PR += list(struct.unpack('<%dI' % n, bytes(R)))
        unp = lib.juno_gui_unported(c)
        lib.juno_gui_destroy(c)
        RL, RR, RC = ref[ci]
        diff = [i for i in range(len(RL)) if RL[i] != PL[i] or RR[i] != PR[i]]
        sdiff = [i for i in range(len(RC)) if tuple(RC[i][0]) != checks[i][0]]
        bare = any(st[0] == 'model' for st in steps)
        qsel = (lambda q: tuple(x for x in q if x[0] == 0)) if bare else (lambda q: tuple(q))
        qdiff = [i for i in range(len(RC)) if qsel(RC[i][1]) != qsel(checks[i][1])]
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        if not quiet:
            print('chain %d %-8s %6d samples: %s; states %s; queues %s%s' % (
                ci, name, len(RL), 'BIT-EXACT' if not diff else '%d differ, first at %d (plugin %.6g, port %.6g)' % (
                    len(diff), diff[0], f(RL[diff[0]]), f(PL[diff[0]])),
                'equal at %d checks' % len(RC) if not sdiff else 'DIFFER at check %d: plugin %s port %s' % (
                    sdiff[0], {k: v for k, v in enumerate(RC[sdiff[0]][0]) if v},
                    {k: v for k, v in enumerate(checks[sdiff[0]][0]) if v}),
                'equal' if not qdiff else 'DIFFER at check %d: plugin %s port %s' % (
                    qdiff[0], [x for x in RC[qdiff[0]][1] if x[0] == 0][:8], [x for x in checks[qdiff[0]][1] if x[0] == 0][:8]),
                '' if not unp else '  -- REACHED AN UNPORTED PATH'))
        bad += bool(diff) or bool(sdiff) or bool(qdiff) or bool(unp)
    return bad


TEETH = [(1, 'no release (the port before A36)'), (2, "the drain's notes not kept"),
         (3, "the drain's release at its end"), (4, "a patch load's release after its records"),
         (5, "a release's entries never sent again"), (6, 'no commit empties the change list'),
         (7, 'a keyboard write without the change test'),
         (8, "the host's KEY HOLD through process() releases")]


def tooth_lib(n):
    work = os.path.join(REPO, 'scratchpad', 'keyhold_teeth')
    os.makedirs(work, exist_ok=True)
    out = os.path.join(work, 'libjuno_t%d.so' % n)
    src = os.path.join(REPO, 'src')
    subprocess.check_call(['gcc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DKS_TOOTH=%d' % n, '-o', out, os.path.join(REPO, 'gui', 'juno_bridge.c')] +
                          sorted(os.path.join(src, f) for f in os.listdir(src) if f.endswith('.c')) + ['-lm'])
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    if a == ['--port']:
        bad = check_port()
        print('\n=== KEY HOLD AND THE KEYBOARD NOTE VALUE (CLAIMS A36): plugin vs port ===')
        print('GATE: %s' % ('FAIL' if bad else 'PASS'))
        return 1 if bad else 0
    if a == ['--port-tooth']:
        res = []
        for n, what in TEETH:
            b = check_port(tooth_lib(n), quiet=True)
            print('tooth %d %-42s %s (%d chains differ)' % (n, what, 'BITES' if b else 'DID NOT BITE', b))
            res.append(b)
        return 0 if all(res) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
