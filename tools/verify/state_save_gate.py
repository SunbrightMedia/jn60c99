#!/usr/bin/env python3
"""state_save_gate.py -- THE STATE SAVE, plugin vs port (CLAIMS A32): the bytes of
IComponent::getState (rva 0x349EA0 -> 0x31FD90) after every step of a chain of host and GUI calls,
plugin vs port (juno_gui_state_save). The payload is the parameter store -- the model's value of the
95 state entries -- and the core's CC map (128 entries 0x10000000 + n).

Steps (each followed by a save, both sides):
  ('state', entries)      IComponent::setState of a payload of these (id, value) entries
  ('state8', entries)     the same with 8-byte fields and a 4-byte count
  ('stream', bytes)       IComponent::setState of these bytes as the whole stream
  ('patch', idx)          the plugin's patch browser load (rva 0x335850) of factory patch idx
  ('patchrec', idx, o, b) the same of a crafted record: nibble pairs' second bytes | o, bytes = b
  ('proc', params, evs)   one 256-sample block through process(): host parameter queues (id,
                          offset, value) and note events -- the MIDI-mapped ids are CCs / bend
  ('drain',)              the UI timer's handler (the core's slot 1, rva 0x320120); the port's
                          juno_gui_ui_tick
  ('learn', id)           MIDI learn armed for the record of `id` (rva 0x31AA40 on core+24, as the
                          GUI's menu does); the port's juno_gui_cc_learn
  ('forget', id)          the menu's other choice (rva 0x3192E0); the port's juno_gui_cc_forget
  ('setting', v)          the plugin's own engine-rate setting: the model's set of vm.vs.sampleRate
                          (rva 0x283DB0 on the model, as its menu does); the port's
                          juno_gui_set_engine_rate_setting
  ('model', id, v)        a model edit as the plugin's GUI makes one (the same model set);
                          the port's juno_gui_model_set
The plugin side runs in Unicorn (host_process_emu.HostProcess: the booted plugin, its own calls);
the harness only calls the plugin's functions and reads its getState.

  --ref         (Unicorn) writes scratchpad/state_save_ref.pkl (.partial, then renamed)
  --port        (libjuno) every save must be byte-equal
  --port-tooth  the port check must FAIL on: the last CC map entry's value flipped in every save
Mutants of the port: probes/host_api/state_save_teeth.py."""
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.environ.get('STATE_SAVE_REF', os.path.join(REPO, 'scratchpad', 'state_save_ref.pkl'))
BASE = 0x0FFFC100                   # the MIDI-mapping base: base + n = CC n, + 129 = bend
MAP = 0x10000000
CUTOFF, RESO, LFO_RATE, VCA = 0x0060003A, 0x0060003E, 0x00600004, 0x00600078
CUT_H, LFO_H, TUNE, VOICES, SRATE = 0x00A02802, 0x00A00000, 0x00000002, 0x0FFFC00E, 0x0FFFC015
fb = lambda f: struct.unpack('<i', struct.pack('<f', f))[0]
# the deserializer's field width: 8 bytes when the payload is longer than (95 + 128) * 64 / 5 = 2854
# bytes, else 4 (rva 0x321F20). PAD (16-byte entries of an unknown id) makes an 8-byte payload long
# enough to be read as one; PAD4 makes a 4-byte payload of 357 entries (2856 bytes) that the plugin
# reads with 8-byte fields; one entry less (2848 bytes) is read with 4.
PAD = [(0x7777, 0)] * 180
PAD4 = [(0x7777, 0)] * 355


def chains():
    cc = lambda n, v, off=0: (BASE + n, off, v)
    P = lambda par=(), ev=(): ('proc', list(par), list(ev))
    out = []
    # 1. boot, patches, partial and wild states, the linked floats
    st = [('patch', 9), ('patch', 33), ('state', [(CUTOFF, 40)]), ('state', [(CUT_H, fb(0.25))]),
          ('state', [(CUT_H, fb(0.6)), (CUTOFF, 200)]), ('state', [(LFO_RATE, 0x1FF), (LFO_H, -1)]),
          ('state', [(e, v) for e, v in ((TUNE, 12345), (VOICES, 300), (SRATE, 0x85), (0x7777, 5))]),
          ('state', []), ('patch', 0), ('state8', [(RESO, 0x12345678), (LFO_RATE, 77), (MAP + 5, CUTOFF)]),
          ('state8', PAD + [(RESO, -7), (CUTOFF, 0x7FFFFF0F), (MAP + 5, CUTOFF), (MAP + 6, -1)]),
          ('state', PAD4 + [(RESO, 3), (CUTOFF, 4)]), ('state', PAD4[:-1] + [(RESO, 5), (CUTOFF, 6)])]
    out.append(('paths', 48000.0, st))
    # raw streams: the count's width by the stream's length (8 bytes above 2854), a payload the
    # stream does not hold in full (zeros past its end), a count <= 0, a stream of 2 bytes
    e4 = lambda ent: b''.join(struct.pack('>II', a & 0xFFFFFFFF, b & 0xFFFFFFFF) for a, b in ent)
    e8 = lambda ent: b''.join(struct.pack('>QQ', a & (2 ** 64 - 1), b & (2 ** 64 - 1)) for a, b in ent)
    long8 = e8(PAD + [(RESO, -7), (CUTOFF, 0x7FFFFF0F), (MAP + 5, CUTOFF), (MAP + 6, -1)])
    mid4 = e4([(0x7777, 0)] * 355 + [(RESO, 99)])              # 2848 bytes: 4-byte fields
    st = [('patch', 9),
          ('stream', struct.pack('>Q', len(long8)) + long8),                      # a long state, 8-byte count
          ('stream', struct.pack('>Q', len(mid4)) + mid4),                        # 8-byte count, 4-byte fields
          ('stream', struct.pack('>I', len(long8)) + long8),                      # long, 4-byte count: misread
          ('stream', struct.pack('>I', 64) + e4([(RESO, 17), (MAP + 9, CUTOFF)])),  # count past the data
          ('stream', struct.pack('>I', 4000) + e4([(CUTOFF, 33), (LFO_RATE, 44)])),  # 8-byte fields over 4-byte data
          ('stream', struct.pack('>I', 0x80000000) + e4([(CUTOFF, 55)])),          # a negative count
          ('stream', struct.pack('>I', 0) + e4([(CUTOFF, 66)])),
          ('stream', b'\x00\x00\x10'),                                            # 3 bytes: count 4096, all zeros
          ('stream', b''),
          ('stream', struct.pack('>I', 12) + e4([(RESO, 77)]) + b'\x00\x00\x00\x60'),  # a cut entry
          ('stream', struct.pack('>I', 9) + e4([(RESO, 88)]) + b'\x01')]
    out.append(('streams', 44100.0, st))
    # 2. every byte of the two linked entries (the float law over 0..255)
    st = [('state', [(CUTOFF, b), (LFO_RATE, 255 - b)]) for b in range(256)]
    out.append(('linked', 48000.0, st))
    # 3. CCs, host records and notes before and after drains; the store follows the CCs only
    st = [('patch', 12), P([cc(3, 0.75), (RESO, 0, 0.25)]), ('drain',),
          P([cc(3, 0.1, 10), cc(3, 0.9, 200), cc(9, 0.33)], [('on', 0, 0, 60, 0.8)]), ('drain',),
          P([cc(21, 0.5), (BASE + 129, 0, 0.7), cc(1, 0.4), cc(11, 0.6)], [('off', 5, 0, 60, 0.0)]), ('drain',),
          ('state', [(MAP + 30, LFO_RATE), (MAP + 31, LFO_H), (MAP + 32, VOICES), (MAP + 33, TUNE)]),
          P([cc(30, 0.5), cc(31, 0.25), cc(32, 1.0), cc(33, 0.2)]), ('drain',),
          P([cc(31, 0.75), cc(30, 0.3)]), ('drain',), ('drain',)]
    out.append(('drain', 48000.0, st))
    # 4. MIDI learn: armed, CCs queued before and after, >= 120 refused, re-learn, forget
    st = [('learn', RESO), P([cc(3, 0.6)]), P([cc(20, 0.5)]), ('drain',),
          ('learn', CUTOFF), P([cc(121, 0.5), cc(122, 0.5)]), ('drain',), P([cc(25, 0.4)]), ('drain',),
          ('learn', CUTOFF), P([cc(3, 0.2)]), ('drain',),
          ('learn', VCA), ('drain',), P([cc(25, 0.9)]), ('drain',),
          ('forget', RESO), ('forget', TUNE), P([cc(3, 0.8), cc(25, 0.1)]), ('drain',),
          ('learn', 0x7FFF0000), P([cc(7, 0.5)]), ('drain',), ('state', [(MAP + 7, RESO)]),
          ('learn', LFO_RATE), ('state', [(CUTOFF, 9)]), P([cc(7, 0.3)]), ('drain',),
          ('learn', VCA), P([cc(123, 0.0), cc(26, 0.5)]), ('drain',),            # 123 is passed over
          ('forget', VCA), P([cc(26, 0.9)]), ('drain',),
          ('state', [(MAP + 40, CUTOFF), (MAP + 41, CUTOFF), (MAP + 3, RESO), (MAP + 3, VCA)]),
          ('learn', CUTOFF), P([cc(42, 0.5)]), ('drain',), P([cc(40, 0.1), cc(41, 0.2), cc(42, 0.3)]), ('drain',)]
    out.append(('learn', 48000.0, st))
    # 5. patch records whose nibble and byte fields exceed their ranges (the model's set from
    #    bytes ORs a nibble pair's bytes; what the store keeps)
    st = [('patchrec', 9, 0x30, 0xFF), ('patchrec', 33, 0xF0, 0x80), ('patch', 9), ('patchrec', 0, 0x0F, 0x7F)]
    out.append(('craft', 48000.0, st))
    # 6. the plugin's own engine-rate setting through its model
    st = [('setting', 2), ('setting', 5), ('patch', 4), ('setting', 0), ('state', [(SRATE, 3)]), ('setting', 1),
          ('setting', 0x82), ('setting', 0x105),
          ('model', CUTOFF, 0x1F7), ('model', VOICES, 0x85), ('model', LFO_H, fb(0.4)), ('model', TUNE, -3)]
    out.append(('setting', 44100.0, st))
    return out


def crafted(bank, idx, ormask, bytev):
    """patch idx's record (the 16-byte name first) with every nibble pair's second byte OR-ed with
    `ormask` and every one-byte field set to `bytev` (src/juno_state_tables.h JUNO_PATCH_EV)"""
    import re
    import midi_ctl_gate as G
    hdr = open(os.path.join(REPO, 'src', 'juno_state_tables.h')).read()
    blk = hdr[hdr.index('JUNO_PATCH_EV[JUNO_PATCH_EV_N] = {'):]
    blk = blk[:blk.index('};')]
    rec = bytearray(bank[G.HEADER + idx * G.STRIDE: G.HEADER + (idx + 1) * G.STRIDE])
    for roff, dec in re.findall(r'\{ 0x[0-9A-F]+u, [-\w]+, (\d+)u, JUNO_DEC_(\w+) \}', blk):
        roff = int(roff)
        if dec == 'INT2X4':
            rec[roff + 1] |= ormask
        elif dec == 'INT1X7':
            rec[roff] = bytev
    return bytes(rec)


def payload(entries, w=4):
    f = '>II' if w == 4 else '>QQ'
    pl = b''.join(struct.pack(f, a & (2 ** (8 * w) - 1), b & (2 ** (8 * w) - 1)) for a, b in entries)
    return struct.pack('>I', len(pl)) + pl


def build_ref():
    import host_process_emu as H
    import e2e_emu as E
    import midi_ctl_gate as G
    bank = E.bank_bytes()
    ref = {'_chains': chains()}
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        h = H.HostProcess()
        h.start(rate, 4096)
        uc = h.uc
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        vb, ve = q(h.core + 24), q(h.core + 32)
        index = {}
        for i in range((ve - vb) // 24):
            index[h.call(H.IB + 0x319C50, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF] = i
        saves = [h.get_state()]
        for stp in steps:
            k = stp[0]
            if k in ('state', 'state8', 'stream'):
                r = h.set_state(stp[1] if k == 'stream' else payload(stp[1], 4 if k == 'state' else 8))
                if r not in (0, 1):
                    raise SystemExit('setState -> 0x%x' % r)
            elif k == 'patch':
                rec = bank[G.HEADER + stp[1] * G.STRIDE: G.HEADER + (stp[1] + 1) * G.STRIDE]
                h.load_patch(rec[G.NAME:])
            elif k == 'patchrec':
                h.load_patch(crafted(bank, *stp[1:])[G.NAME:])
            elif k == 'proc':
                h.process(256, events=stp[2], params=stp[1], ctx=dict(tempo=120.0, playing=True))
            elif k == 'drain':
                h.call(H.IB + 0x320120, rcx=h.core, count=2_000_000_000)
            elif k == 'learn':
                h.call(H.IB + 0x31AA40, rcx=h.core + 24, rdx=index.get(stp[1], 0xFFFFFFFF))
            elif k == 'forget':
                if stp[1] in index:
                    h.call(H.IB + 0x3192E0, rcx=h.core + 24, rdx=index[stp[1]])
            elif k in ('setting', 'model'):
                pid, v = (SRATE, stp[1]) if k == 'setting' else stp[1:]
                vm = q(q(h.core + 8))
                obj = q(vb + 24 * index[pid])
                h.call(H.IB + 0x283DB0, rcx=vm, rdx=obj, r8=v & 0xFFFFFFFF, r9=1)
            else:
                raise SystemExit('step %r' % (stp,))
            saves.append(h.get_state())
        ref[ci] = saves
        sys.stderr.write('ref chain %d %s: %d saves\n' % (ci, name, len(saves)))
        sys.stderr.flush()
        del h
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))
    os.replace(REF_PKL + '.partial', REF_PKL)
    print('wrote', REF_PKL)
    return 0


def check_port(tooth=None, only=None, title=None):
    import ctypes
    import freshlib
    import truth
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
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_destroy', [V]), ('juno_gui_ui_tick', [V]),
                   ('juno_gui_cc_learn', [V, ctypes.c_uint32]), ('juno_gui_cc_forget', [V, ctypes.c_uint32]),
                   ('juno_gui_set_engine_rate_setting', [V, ctypes.c_int]),
                   ('juno_gui_model_set', [V, ctypes.c_uint32, ctypes.c_int32]),
                   ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_state_save', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Param), ctypes.c_int,
                                            ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                            ctypes.POINTER(ctypes.c_float), ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    bankb = open(truth.BANK, 'rb').read()
    buf = ctypes.create_string_buffer(4096)
    bad = 0
    print('\n=== %s ===' % (title or 'THE STATE SAVE (CLAIMS A32): getState after host and GUI calls -- plugin vs port'))
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        if only is not None and name not in only:
            continue
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_set_fp_oracle_mode(1)
        lib.juno_gui_plugin_init(c)

        def save():
            n = lib.juno_gui_state_save(c, buf, 4096)
            b = buf.raw[:n] if n > 0 else b''
            if tooth == 'flip_last' and len(b) >= 8:
                b = b[:-1] + bytes([b[-1] ^ 1])
            return b
        got = [save()]
        for stp in steps:
            k = stp[0]
            if k in ('state', 'state8', 'stream'):
                pl = stp[1] if k == 'stream' else payload(stp[1], 4 if k == 'state' else 8)
                lib.juno_gui_queue_state(c, pl, len(pl))
            elif k == 'patch':
                lib.juno_gui_queue_patch(c, bankb, len(bankb), stp[1])
            elif k == 'patchrec':
                import midi_ctl_gate as G
                i0 = G.HEADER + stp[1] * G.STRIDE
                bk = bankb[:i0] + crafted(bankb, *stp[1:]) + bankb[i0 + G.STRIDE:]
                lib.juno_gui_queue_patch(c, bk, len(bk), stp[1])
            elif k == 'proc':
                evs = stp[2]
                last = {}
                for pid, off, v in stp[1]:            # one queue per id: the plugin reads its last point
                    last[pid] = (pid, off, v)
                par = list(last.values())
                arr = (Note * max(1, len(evs)))()
                for i, (kk, off, ch, pch, vel) in enumerate(evs):
                    arr[i] = Note(off, 0 if kk == 'on' else 1, ch, pch, vel)
                pa = (Param * max(1, len(par)))()
                for i, (pid, off, v) in enumerate(par):
                    pa[i] = Param(pid, off, v)
                L, R = (ctypes.c_float * 256)(), (ctypes.c_float * 256)()
                lib.juno_gui_process_ex(c, arr, len(evs), pa, len(par), 1, 120.0, L, R, 256)
            elif k == 'drain':
                lib.juno_gui_ui_tick(c)
            elif k == 'learn':
                lib.juno_gui_cc_learn(c, stp[1])
            elif k == 'forget':
                lib.juno_gui_cc_forget(c, stp[1])
            elif k == 'setting':
                lib.juno_gui_set_engine_rate_setting(c, stp[1])
            elif k == 'model':
                lib.juno_gui_model_set(c, stp[1], stp[2])
            got.append(save())
        lib.juno_gui_destroy(c)
        want = ref[ci]
        diff = [i for i in range(len(want)) if i >= len(got) or got[i] != want[i]]
        if diff:
            bad += 1
            i = diff[0]
            w, g = want[i], got[i] if i < len(got) else b''
            ent = lambda b: [struct.unpack('>Ii', b[4 + j:12 + j]) for j in range(0, len(b) - 4, 8)]
            de = [(hex(a[0]), a[1], bb[1]) for a, bb in zip(ent(w), ent(g)) if a != bb][:6]
            print('chain %d %-8s: %d of %d saves differ, first after step %d %r: %s' % (
                ci, name, len(diff), len(want), i, steps[i - 1] if i else 'boot', de or (len(w), len(g))))
        else:
            print('chain %d %-8s: %d saves BYTE-EQUAL' % (ci, name, len(want)))
    print('GATE: %s' % ('PASS' if not bad else 'FAIL'))
    return bad


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return 1 if check_port(only=only[0] if only else None) else 0
    if a == ['--port-tooth']:
        b = check_port(tooth='flip_last', only=only[0] if only else None)
        print('\nflip_last      %s (%d chains differ)' % ('BITES' if b else 'DID NOT BITE', b))
        return 0 if b else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
