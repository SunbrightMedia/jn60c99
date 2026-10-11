#!/usr/bin/env python3
"""jx_state_gate.py -- THE DAW STATE, plugin vs port (JX-17): after every step of a chain of host calls, the bytes
of IComponent::getState and the records the step queued for the engine, the plugin (jx_host_emu.JXHost: the booted
plugin, its own calls; Unicorn) against the port (jx3p_state_save / jx3p_product_pending; ctypes). The payload is
the model's parameter store (82 entries, jx3p/src/jx_state_tables.h) and the core's CC map (128 entries
0x10000000 + n); setState queues writePatch = 126, the payload's parameters, writePatch = 127.

Steps (each followed by a save and the queue's new records, both sides):
  ('state', entries)      IComponent::setState of a payload of these (id, value) entries (4-byte fields)
  ('state8', entries)     the same with 8-byte fields and a 4-byte count
  ('stream', bytes)       IComponent::setState of these bytes as the whole stream
  ('patch', idx)          the plugin's patch browser load of factory patch idx (the port: jx3p_product_load_patch)
  ('proc', params, evs)   one 256-sample block through process(): host parameter queues (id, offset, value) and
                          note events -- the queued records are applied, the queues empty on both sides
  ('drain',)              the UI timer's handler (the core's slot 1, rva 0x320000): the store from the CCs, the
                          keyboard's note value from the notes, a MIDI learn's CC (JX-17b); the port's jx3p_ui_tick
  ('learn', id)           MIDI learn armed for the record of `id` (rva 0x31A920 on core+24); jx3p_cc_learn
  ('forget', id)          its CC forgotten (rva 0x3191C0); jx3p_cc_forget
  ('model', id, v)        a panel control's set through the model (rva 0x283C90, JX-18); jx3p_model_set -- the host
                          edits it makes (beginEdit / performEdit / endEdit) compared too (jx3p_host_edits)
  ('commit',)             the control's notifies and commit (rva 0x285200, 0x2852A0, 0x283000); jx3p_model_commit
  ('roundtrip',)          one block whose host parameter points are the performEdit values since the last round
                          trip -- what a host sends back (each side its own)
The queued records compare as (0, offset, status, data1, data2) for a MIDI one -- the note-offs a KEY HOLD at 0
makes for the keys the drain has seen -- and (kind, offset, id, value) for a parameter one.
    python3 jx3p/tools/jx_state_gate.py [--chains 0,1,...]      the reference (Unicorn, a child) and the port
    python3 jx3p/tools/jx_state_gate.py --tooth                 the port's save with its last CC entry flipped: RED
    python3 jx3p/tools/jx_state_gate.py --mutants               the port built with JX_STATE_TOOTH 1 (no float
        link), 2 (the framing limit from the state list: 2688), 3 (the store unmasked), JX_KS_TOOTH 1 (KEY HOLD at
        0 releases nothing), JX_EDIT_TOOTH 1 (performEdit's value the stored value / max): each must be RED
exit 0 = every save and every step's queued records equal.
"""
import atexit
import ctypes
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
BASE = 0x0FFFC100                    # the MIDI-mapping base: base + n = CC n
MAP = 0x10000000
P1, P2, P3, P4 = 0x0060003A, 0x0060003E, 0x00600004, 0x00600078     # CC 3's, CC 9's, LFO rate, CC 110's records
F1, F2, TUNE, VOICES, SRATE = 0x00A02802, 0x00A00000, 0x00000002, 0x0FFFC00E, 0x0FFFC015
NAME0 = 0x00600080                   # the patch name's first word
KH = 0x00600138                      # KEY HOLD
UI_DRAIN, LEARN, FORGET, CC_INDEX = 0x320000, 0x31A920, 0x3191C0, 0x319B30      # == the JUNO's (fw_map --pair)
CC_OF = 0x319A50                     # the CC a control's menu shows (= the JUNO's 0x319B70; JX-23)
MODEL_SET, MODEL_COMMIT = 0x283C90, (0x285200, 0x2852A0, 0x283000)          # == the JUNO's 0x283DB0, ... (--pair)
fb = lambda f: struct.unpack('<i', struct.pack('<f', f))[0]
# the deserializer's field width (the JUNO's code): 8 bytes when the stream / the count is longer than (83 + 128) *
# 64 / 5 = 2700 bytes (83: the CC map's records, rva 0x322210), else 4. PAD (16-byte entries of an unknown id)
# makes an 8-byte payload long enough to be read as one; PAD4 + 2 = 338 4-byte entries (a 2708-byte stream) are
# read with 8-byte fields, one less (2700) with 4 -- the two sides of the limit.
PAD = [(0x7777, 0)] * 170
PAD4 = [(0x7777, 0)] * 336


def chains():
    cc = lambda n, v, off=0: (BASE + n, off, v)
    P = lambda par=(), ev=(): ('proc', list(par), list(ev))
    e4 = lambda ent: b''.join(struct.pack('>II', a & 0xFFFFFFFF, b & 0xFFFFFFFF) for a, b in ent)
    e8 = lambda ent: b''.join(struct.pack('>QQ', a & (2 ** 64 - 1), b & (2 ** 64 - 1)) for a, b in ent)
    out = []
    # 0. patches, partial and wild states, the floats, the host settings, an unknown id, the widths
    st = [('patch', 9), ('patch', 33), ('state', [(P1, 40)]), ('state', [(F1, fb(0.25))]),
          ('state', [(F1, fb(0.6)), (P1, 200)]), ('state', [(P3, 0x1FF), (F2, -1)]),
          ('state', [(TUNE, 12345), (VOICES, 300), (SRATE, 0x85), (0x7777, 5), (NAME0, 0x41424344)]),
          ('state', []), ('patch', 0), ('state8', [(P2, 0x12345678), (P3, 77), (MAP + 5, P1)]),
          ('state8', PAD + [(P2, -7), (P1, 0x7FFFFF0F), (MAP + 5, P1), (MAP + 6, -1)]),
          ('state', PAD4 + [(P2, 3), (P1, 4)]), ('state', PAD4[:-1] + [(P2, 5), (P1, 6)])]
    out.append(('paths', 48000.0, st))
    # 1. raw streams: the count's width by the stream's length, a payload the stream does not hold in full, a
    #    count <= 0, a stream of 3 bytes, an empty one, cut entries
    long8 = e8(PAD + [(P2, -7), (P1, 0x7FFFFF0F), (MAP + 5, P1), (MAP + 6, -1)])
    mid4 = e4([(0x7777, 0)] * 336 + [(P2, 99)])              # 2696 bytes: 4-byte fields
    st = [('patch', 9),
          ('stream', struct.pack('>Q', len(long8)) + long8),
          ('stream', struct.pack('>Q', len(mid4)) + mid4),
          ('stream', struct.pack('>I', len(long8)) + long8),
          ('stream', struct.pack('>I', 64) + e4([(P2, 17), (MAP + 9, P1)])),
          ('stream', struct.pack('>I', 4000) + e4([(P1, 33), (P3, 44)])),
          ('stream', struct.pack('>I', 0x80000000) + e4([(P1, 55)])),
          ('stream', struct.pack('>I', 0) + e4([(P1, 66)])),
          ('stream', b'\x00\x00\x10'),
          ('stream', b''),
          ('stream', struct.pack('>I', 12) + e4([(P2, 77)]) + b'\x00\x00\x00\x60'),
          ('stream', struct.pack('>I', 9) + e4([(P2, 88)]) + b'\x01')]
    out.append(('streams', 44100.0, st))
    # 2. the CC map: assigned, moved, freed, unknown and host-setting ids; CCs through process() before and after
    st = [('patch', 12), P([cc(3, 0.75), (P2, 0, 0.25)]),
          ('state', [(MAP + 30, P3), (MAP + 31, F2), (MAP + 32, VOICES), (MAP + 33, TUNE), (MAP + 3, -1)]),
          P([cc(30, 0.5), cc(31, 0.25), cc(32, 1.0), cc(33, 0.2), cc(3, 0.9)], [('on', 0, 0, 60, 0.8)]),
          ('state', [(MAP + 40, P1), (MAP + 41, P1), (MAP + 3, P2), (MAP + 3, P4), (MAP + 127, 0x7777)]),
          P([cc(40, 0.1), cc(41, 0.2), cc(3, 0.3)], [('off', 5, 0, 60, 0.0)]),
          ('patch', 61), P([cc(41, 0.6)]), ('state', [(P1, 9)]), P()]
    out.append(('ccmap', 48000.0, st))
    # 3. every value of three entries of each storage law
    st = [('state', [(P1, b), (P3, 255 - b), (TUNE, b * 37 - 4000)]) for b in range(0, 256, 5)]
    out.append(('laws', 48000.0, st))
    # 4. KEY HOLD (JX-17b): keys the UI timer has seen, released by a patch load (KEY HOLD 0 in every factory patch),
    #    by setState entries (0 alone, among others, after a 1), by a drained CC that sets KEY HOLD to 0
    on3 = [('on', 0, 0, 60, 0.8), ('on', 7, 0, 64, 0.5), ('on', 9, 0, 67, 0.3)]
    off3 = [('off', 0, 0, 60, 0.0), ('off', 1, 0, 64, 0.0), ('off', 2, 0, 67, 0.0)]
    st = [P([], on3), ('drain',), ('patch', 5), P([], off3), P([], on3), ('drain',),
          ('state', [(KH, 0)]), P([], [('on', 3, 0, 72, 1.0)]), ('drain',),
          ('state', [(P1, 40), (KH, 1), (P3, 9)]), ('state', [(KH, 1), (P2, 7), (KH, 0)]), P([], on3), ('drain',),
          ('state', [(MAP + 70, KH), (MAP + 71, P2)]), P([cc(70, 1.0), cc(71, 0.4)], on3), ('drain',),
          P([cc(70, 0.0)], [('on', 4, 0, 50, 0.6)]), ('drain',), P([], off3), ('drain',), ('patch', 61), P()]
    out.append(('keyhold', 48000.0, st))
    # 5. MIDI learn: armed, CCs before and after, >= 120 refused, re-learn, forget, a learn over a mapped CC
    st = [('learn', P2), P([cc(3, 0.6)]), P([cc(20, 0.5)]), ('drain',),
          ('learn', P1), P([cc(121, 0.5), cc(122, 0.5)]), ('drain',), P([cc(25, 0.4)]), ('drain',),
          ('learn', P1), P([cc(3, 0.2)]), ('drain',),
          ('learn', P4), ('drain',), P([cc(25, 0.9)]), ('drain',),
          ('forget', P2), ('forget', TUNE), P([cc(3, 0.8), cc(25, 0.1)]), ('drain',),
          ('learn', 0x7FFF0000), P([cc(7, 0.5)]), ('drain',), ('state', [(MAP + 7, P2)]),
          ('learn', P3), ('state', [(P1, 9)]), P([cc(7, 0.3)]), ('drain',),
          ('learn', P4), P([cc(123, 0.0), cc(26, 0.5)]), ('drain',),
          ('forget', P4), P([cc(26, 0.9)]), ('drain',),
          ('state', [(MAP + 40, P1), (MAP + 41, P1), (MAP + 3, P2), (MAP + 3, P4)]),
          ('learn', P1), P([cc(42, 0.5)]), ('drain',), P([cc(40, 0.1), cc(41, 0.2), cc(42, 0.3)]), ('drain',)]
    out.append(('learn', 48000.0, st))
    # 6. THE EDITOR (JX-18): the model's set of a panel control -- the host's round trip (performEdit, then the value
    #    back through process(): 'roundtrip') or one engine record (the name, the floats, the host settings,
    #    writePatch) --, values past the ranges, a bipolar range, KEY HOLD 0 with drained keys, commits
    RT = ('roundtrip',)
    st = [('model', P1, 77), ('commit',), RT, ('model', 0x00600000, 300), RT, ('model', P3, 200), ('model', P2, 5), RT,
          ('model', VOICES, 5), ('commit',), P(), ('model', NAME0, 0x4142), ('model', F1, fb(0.3)), P(),
          ('model', 0x00600130, -2), RT, ('model', 0x00600130, 5), RT,
          ('model', SRATE, 2), P(), ('model', SRATE, 5), P(),
          P([], on3), ('drain',), ('model', KH, 0), ('commit',), P(), ('model', KH, 1), RT,
          ('model', 0x0FFFC01D, 1), P(), ('model', P1, -1), RT, ('model', 0x00600108, 1), RT, P(), P([], off3), P()]
    out.append(('editor', 48000.0, st))
    return out


def payload(entries, w=4):
    f = '>II' if w == 4 else '>QQ'
    pl = b''.join(struct.pack(f, a & (2 ** (8 * w) - 1), b & (2 ** (8 * w) - 1)) for a, b in entries)
    return struct.pack('>I', len(pl)) + pl


def stream_of(stp):
    return stp[1] if stp[0] == 'stream' else payload(stp[1], 4 if stp[0] == 'state' else 8)


def oracle(ci):
    sys.path.insert(0, HERE)
    import jx_host_emu as X
    import jx_bank as B
    bank = open(os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin'), 'rb').read()
    name, rate, steps = chains()[ci]
    h = X.JXHost()
    h.start(rate, 512)
    h.process(256)                             # the first block: initialize's queue applied (the port's: jx3p_product_init)
    q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]
    vb, ve = q(h.core + 24), q(h.core + 32)    # the CC map's records: their index by id (rva 0x319B30)
    index = {h.call(X.IB + CC_INDEX, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF: i for i in range((ve - vb) // 24)}
    obj = {pid: q(vb + 24 * i) for pid, i in index.items()}     # each record's model object (its first word)
    model = q(q(h.core + 8))
    q0, e_step, e_rt = len(h.queue()), len(h.edits), len(h.edits)
    ids = sorted(index, key=index.get)          # the records' ids in the CC map's order
    sg = lambda v: v - (1 << 32) if v >= 1 << 31 else v
    ccof = lambda: [sg(h.call(X.IB + CC_OF, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF) for i in range(len(ids))]
    res = [dict(save=h.get_state().hex(), queue=[], edits=[], ccof=ccof(), ids=ids)]
    for stp in steps:
        k = stp[0]
        if k in ('state', 'state8', 'stream'):
            r = h.set_state(stream_of(stp))
            if r not in (0, 1):
                raise SystemExit('setState -> 0x%x' % r)
        elif k == 'patch':
            p = stp[1]
            h.load_patch(bank[B.BANK_HEADER + p * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (p + 1) * B.BANK_STRIDE])
        elif k == 'proc':
            h.process(256, events=stp[2], params=stp[1])
        elif k == 'drain':
            h.call(X.IB + UI_DRAIN, rcx=h.core, count=2_000_000_000)
        elif k == 'learn':
            h.call(X.IB + LEARN, rcx=h.core + 24, rdx=index.get(stp[1], 0xFFFFFFFF))
        elif k == 'forget':
            if stp[1] in index:
                h.call(X.IB + FORGET, rcx=h.core + 24, rdx=index[stp[1]])
        elif k == 'model':                        # a panel control's set (rva 0x283C90, JX-18)
            h.call(X.IB + MODEL_SET, rcx=model, rdx=obj[stp[1]], r8=stp[2] & 0xFFFFFFFF, r9=1, count=500_000_000)
        elif k == 'commit':                       # its notifies and commit
            for rva in MODEL_COMMIT:
                h.call(X.IB + rva, rcx=model, count=500_000_000)
        elif k == 'roundtrip':                    # the host sends the performEdit values back through process()
            back = [(e[1], 0, e[2]) for e in h.edits[e_rt:] if e[0] == 'performEdit']
            e_rt = len(h.edits)
            h.process(256, params=back)
        qq = h.queue()
        new = [] if k in ('proc', 'roundtrip') else [(0, off, rec[8], rec[9], rec[10]) if kind == 0 else
                                      (kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0])
                                      for kind, off, rec in qq[q0:]]
        q0 = len(qq)
        res.append(dict(save=h.get_state().hex(), queue=new,
                        edits=[list(e) for e in h.edits[e_step:]] if k != 'roundtrip' else [], ccof=ccof()))
        e_step = len(h.edits)
    return res


def port(so, ci, tooth, idfile):
    lib = ctypes.CDLL(so)
    ids = json.load(open(idfile))
    lib.jx3p_cc_of.argtypes = [ctypes.c_uint32]
    lib.jx3p_cc_entry.argtypes = [ctypes.c_uint32]
    ccof = lambda: [lib.jx3p_cc_of(i) for i in ids]
    lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
    lib.jx3p_product_param.argtypes = [ctypes.c_uint, ctypes.c_int, ctypes.c_double]
    lib.jx3p_product_note.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float]
    lib.jx3p_lift_error.restype = ctypes.c_char_p
    sys.path.insert(0, HERE)
    import jx_guest
    name, rate, steps = chains()[ci]
    lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
    if lib.jx3p_product_init(jx_guest.path(96).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             int(rate)) < 0:
        raise SystemExit('jx3p_product_init failed')
    L = (ctypes.c_float * 256)(); R = (ctypes.c_float * 256)()
    lib.jx3p_product_block(L, R, 256, (ctypes.c_int * 1)(), 0)     # the first block: initialize's queue applied
    buf = (ctypes.c_ubyte * 4096)()
    pend = (ctypes.c_int * (5 * 512))()

    def save():
        n = lib.jx3p_state_save(buf, 4096)
        b = bytearray(bytes(buf)[:n])
        if tooth:
            b[-1] ^= 1
        return bytes(b).hex()
    res = [dict(save=save(), queue=[], edits=[], ccof=ccof(),
                entry=[lib.jx3p_cc_entry(i) for i in ids] + [lib.jx3p_cc_entry(i) for i in (0, 0x7777, 0x0FFFC002)])]
    eid, ev_, ekind = (ctypes.c_uint32 * 512)(), (ctypes.c_double * 512)(), (ctypes.c_int * 512)()
    rt = []                                    # the host edits not yet sent back
    for stp in steps:
        k = stp[0]
        n0 = lib.jx3p_product_pending(pend, 5 * 512)
        if k in ('state', 'state8', 'stream'):
            data = stream_of(stp)
            lib.jx3p_state_load((ctypes.c_ubyte * max(1, len(data))).from_buffer_copy(data or b'\0'), len(data))
        elif k == 'patch':
            lib.jx3p_product_load_patch(stp[1])
        elif k == 'proc':
            for e in stp[2]:
                lib.jx3p_product_note(0 if e[0] == 'on' else 1, e[1], e[2], e[3], e[4])
            last = {}
            for pid, off, v in stp[1]:              # process(): one record per queue, its last point
                last[pid] = (off, v)
            for pid, (off, v) in last.items():
                lib.jx3p_product_param(pid, off, v)
            lib.jx3p_product_block(L, R, 256, (ctypes.c_int * 1)(), 0)
        elif k == 'drain':
            lib.jx3p_ui_tick()
        elif k == 'learn':
            lib.jx3p_cc_learn(ctypes.c_uint32(stp[1]))
        elif k == 'forget':
            lib.jx3p_cc_forget(ctypes.c_uint32(stp[1]))
        elif k == 'model':
            lib.jx3p_model_set(ctypes.c_uint32(stp[1]), ctypes.c_int32(stp[2]))
        elif k == 'commit':
            lib.jx3p_model_commit()
        elif k == 'roundtrip':
            for pid, v in rt:
                lib.jx3p_product_param(pid, 0, v)
            rt = []
            lib.jx3p_product_block(L, R, 256, (ctypes.c_int * 1)(), 0)
        ne = lib.jx3p_host_edits(eid, ev_, ekind, 512)
        edits = []
        for i in range(ne):
            if ekind[i] == 1:                        # a load's: performEdit alone
                edits.append(['performEdit', eid[i], ev_[i]])
            else:
                edits += [['beginEdit', eid[i], None], ['performEdit', eid[i], ev_[i]], ['endEdit', eid[i], None]]
            rt.append((eid[i], ev_[i]))              # the round trip sends every performEdit back, as the oracle's
        n1 = lib.jx3p_product_pending(pend, 5 * 512)
        flat = list(pend)
        new = [] if k in ('proc', 'roundtrip') else [(0, r[1], r[2] & 0xFF, r[3] & 0xFF, r[4] & 0xFF) if r[0] == 0 else
                                                     (r[0], r[1], r[3] & 0xFFFFFFFF, r[4]) for r in
                                                     (flat[5 * i:5 * i + 5] for i in range(n0, n1))]
        res.append(dict(save=save(), queue=new, edits=edits, ccof=ccof()))
    if lib.jx3p_lift_error():
        raise SystemExit('the lifted code trapped: %s' % lib.jx3p_lift_error().decode())
    return res


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(int(a[1])), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], int(a[2]), a[3] == '1', a[4]), sys.stdout)
        return 0
    tooth = '--tooth' in a
    sel = [int(x) for x in a[a.index('--chains') + 1].split(',')] if '--chains' in a else list(range(len(chains())))
    tmp = tempfile.mkdtemp()
    atexit.register(shutil.rmtree, tmp, True)     # its builds and inflated images: never left behind
    if '--mutants' in a:                     # each mutant must make at least one chain RED
        # ... on chains that are GREEN without it: a RED a mutant finds on a chain already RED proves nothing
        # (playbook 210: at JX-18 the clean chains 0 and 1 were RED and 'BITES' hid the loads' host edits)
        r = subprocess.run([sys.executable, __file__, '--chains', '0,1,4,5,6'], capture_output=True, text=True)
        if r.returncode:
            print('jx_state_gate --mutants: REFUSE -- the clean chains are RED:\n' + r.stdout[-1500:])
            return 1
        bitten = 0
        for m in (1, 2, 3, 'ks', 'edit', 'ccof'):
            r = subprocess.run([sys.executable, __file__, '--chains', {'ks': '4', 'edit': '6', 'ccof': '5'}.get(m, '0,1'),
                                '--mutant', str(m)], capture_output=True, text=True)
            print('  mutant %s: %s' % (m, 'RED (bites)' if r.returncode else 'GREEN -- DID NOT BITE'), flush=True)
            bitten += r.returncode != 0
        print('jx_state_gate --mutants: %s' % ('BITES (6 of 6)' if bitten == 6 else 'DID NOT BITE on %d of 6' % (6 - bitten)))
        return 0 if bitten == 6 else 1
    so = os.path.join(tmp, 'libjx3p.so')
    mv = a[a.index('--mutant') + 1] if '--mutant' in a else None
    mut = [] if mv is None else ['-DJX_KS_TOOTH=1'] if mv == 'ks' else ['-DJX_EDIT_TOOTH=1'] if mv == 'edit' else \
        ['-DJX_CCOF_TOOTH=1'] if mv == 'ccof' else ['-DJX_STATE_TOOTH=%s' % mv]
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   mut + [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    bad, nsteps = 0, 0
    for ci in sel:
        name = chains()[ci][0]
        o = subprocess.run([sys.executable, __file__, '--oracle', str(ci)], capture_output=True, text=True)
        if o.returncode:
            raise SystemExit('oracle failed (%s): %s' % (name, o.stderr[-1500:]))
        idfile = os.path.join(tmp, 'ids_%d.json' % ci)
        json.dump(json.loads(o.stdout)[0]['ids'], open(idfile, 'w'))
        p = subprocess.run([sys.executable, __file__, '--port', so, str(ci), '1' if tooth else '0', idfile],
                           capture_output=True, text=True)
        if p.returncode:
            raise SystemExit('port failed (%s): %s' % (name, p.stderr[-1500:]))
        ro, rp = json.loads(o.stdout), json.loads(p.stdout)
        steps = chains()[ci][2]
        if rp[0]['entry'] != list(range(len(ro[0]['ids']))) + [-1, -1, -1]:
            raise SystemExit('chain %s: the port\'s CC map records are not the plugin\'s order: %s' % (name, rp[0]['entry']))
        first = None
        for i, (x, y) in enumerate(zip(ro, rp)):
            if x['save'] != y['save'] or [list(q) for q in x['queue']] != [list(q) for q in y['queue']] or \
                    x.get('edits') != y.get('edits') or x['ccof'] != y['ccof']:
                first = i
                break
        nsteps += len(ro)
        if first is None and len(ro) == len(rp):
            print('  chain %d %s: %d steps -- every save, queued record, host edit and menu CC equal (%d records, %d host '
                  'edits)' % (ci, name, len(steps), sum(len(x['queue']) for x in ro),
                              sum(1 for x in ro for e in x.get('edits', []) if e[0] == 'performEdit')), flush=True)
            continue
        bad += 1
        x, y = ro[first], rp[first]
        what = 'boot' if first == 0 else repr(steps[first - 1])[:90]
        if x['save'] != y['save']:
            bx, by = bytes.fromhex(x['save']), bytes.fromhex(y['save'])
            d = [o for o in range(0, max(len(bx), len(by)), 4) if bx[o:o + 4] != by[o:o + 4]]
            print('  chain %d %s: the save differs after step %d (%s): %d words, first at byte %s (plugin %s port %s)' % (
                ci, name, first, what, len(d), d[0] if d else '-', bx[d[0]:d[0] + 4].hex() if d else '',
                by[d[0]:d[0] + 4].hex() if d else ''), flush=True)
        elif [list(q) for q in x['queue']] != [list(q) for q in y['queue']]:
            print('  chain %d %s: the queued records differ after step %d (%s): plugin %s port %s' % (
                ci, name, first, what, x['queue'][:6], y['queue'][:6]), flush=True)
        elif x.get('edits') != y.get('edits'):
            print('  chain %d %s: the host edits differ after step %d (%s): plugin %s port %s' % (
                ci, name, first, what, x.get('edits'), y.get('edits')), flush=True)
        else:
            d = [(i, a, b) for i, (a, b) in enumerate(zip(x['ccof'], y['ccof'])) if a != b]
            print('  chain %d %s: the CC a record\'s menu shows differs after step %d (%s): (record, plugin, port) %s' % (
                ci, name, first, what, d[:6]), flush=True)
    if tooth:
        print('jx_state_gate --tooth: %s' % ('BITES (%d of %d chains)' % (bad, len(sel)) if bad == len(sel) else
                                             'DID NOT BITE on %d of %d' % (len(sel) - bad, len(sel))))
        return 0 if bad == len(sel) else 1
    print('jx_state_gate: %d of %d chains equal (%d saves): %s' % (len(sel) - bad, len(sel), nsteps,
                                                                   'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
