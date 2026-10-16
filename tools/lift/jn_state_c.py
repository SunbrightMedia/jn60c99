#!/usr/bin/env python3
"""jn_state_c.py -- L5 (state) C side: the DAW state round trip through the lifted JUNO's OWN getState / setState.
The drive mirrors jn_state_ref.py: load P -> getState S_P (graded bit-exact vs the oracle) -> load Q -> setState(S_P)
-> getState S2 (graded) -> play (words + end-state graded). ctypes only (two-process rule). EXACTLY 0 is the bar.
Three teeth, each proving one compared quantity is live (seen to fail, mantra 5):
  --tooth getstate : load P+1 instead of P   -> S_P differs from the oracle
  --tooth skip     : skip the setState(S_P)   -> S2 + play + end-state differ (setState is load-bearing)
  --tooth note     : a semitone up in the play -> the output words differ
usage: python3 tools/lift/jn_state_c.py <so> <template> <refdir> [--tooth getstate|skip|note]"""
import ctypes
import sys
import os
import struct
import json

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jn_bank_seq as S                                            # noqa: E402


class EV(ctypes.Structure):
    _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int),
                ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]


class CTX(ctypes.Structure):
    _fields_ = [('state', ctypes.c_uint32), ('ppq', ctypes.c_double), ('cs', ctypes.c_double),
                ('ce', ctypes.c_double), ('tempo', ctypes.c_double)]


def main():
    so, tmpl, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
    tooth = sys.argv[sys.argv.index('--tooth') + 1] if '--tooth' in sys.argv else None
    lib = ctypes.CDLL(so)
    lib.junoh_init.restype = ctypes.c_int
    lib.junoh_init.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
    lib.junoh_error.restype = ctypes.c_char_p
    lib.junoh_load_patch.restype = ctypes.c_int
    lib.junoh_load_patch.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
    lib.junoh_get_state.restype = ctypes.c_int
    lib.junoh_get_state.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_size_t)]
    lib.junoh_set_state.restype = ctypes.c_int
    lib.junoh_set_state.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_uint32)]
    lib.junoh_process.restype = ctypes.c_int
    lib.junoh_process.argtypes = [ctypes.c_int, ctypes.POINTER(EV), ctypes.c_int, ctypes.c_void_p, ctypes.c_int,
                                  ctypes.POINTER(CTX), ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_uint32)]
    for fn in ('junoh_heap_top', 'junoh_com_next'):
        getattr(lib, fn).restype = ctypes.c_uint64
    lib.junoh_guest.restype = ctypes.c_void_p
    lib.junoh_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]

    def chk(rc, what):
        if rc:
            print('%s rc=%d: %s' % (what, rc, lib.junoh_error().decode('latin1', 'replace')))
            sys.exit(0 if tooth else 2)

    def load(rec):
        b = ctypes.create_string_buffer(rec, len(rec)); chk(lib.junoh_load_patch(b, len(rec)), 'load_patch')

    def get_state():
        # ONE call, like the oracle: junoh_get_state always runs the plugin's getState and makes a stream, so a
        # size-probe call would run it twice and allocate twice (the heap / COM end-state would then diverge).
        cap = 1 << 20
        buf = ctypes.create_string_buffer(cap); n = ctypes.c_size_t(0)
        chk(lib.junoh_get_state(buf, cap, ctypes.byref(n)), 'get_state')
        if n.value > cap:
            raise RuntimeError('state %d bytes exceeds the %d-byte buffer' % (n.value, cap))
        return buf.raw[:n.value]

    def set_state(data):
        r = ctypes.c_uint32(0); chk(lib.junoh_set_state(data, len(data), ctypes.byref(r)), 'set_state'); return r.value

    def play():
        got = bytearray()
        for st in S.patch_steps():
            n = st['n']; evs = []
            for (k, off, ch, p, v) in st['events']:
                if tooth == 'note' and k == 'on':
                    p += 1
                evs.append(EV(1 if k == 'on' else 0, off, ch, p, v))
            eva = (EV * len(evs))(*evs) if evs else None
            cx = CTX(st['ctx']['state'], st['ctx']['ppq'], st['ctx']['cs'], st['ctx']['ce'], st['ctx']['tempo'])
            L = (ctypes.c_uint32 * n)() if n else (ctypes.c_uint32 * 1)()
            R = (ctypes.c_uint32 * n)() if n else (ctypes.c_uint32 * 1)()
            chk(lib.junoh_process(n, eva, len(evs), None, 0, ctypes.byref(cx), L, R), 'process')
            if n:
                got += struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R)
        return bytes(got)

    meta = json.load(open(os.path.join(refdir, 'meta.json')))
    rec_p = open(os.path.join(refdir, 'patch_p.bin'), 'rb').read()
    rec_q = open(os.path.join(refdir, 'patch_q.bin'), 'rb').read()
    ref_sp = open(os.path.join(refdir, 'state_p.bin'), 'rb').read()
    ref_s2 = open(os.path.join(refdir, 'state_2.bin'), 'rb').read()
    ref_w = open(os.path.join(refdir, 'words.bin'), 'rb').read()
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    chk(lib.junoh_init(b, len(t), 48000.0, 512), 'junoh_init')

    diffs = []       # (name, equal?) for every graded quantity
    load(rec_p)
    if tooth == 'getstate':
        load(rec_q)  # load a DIFFERENT patch so the saved state differs from the oracle's (the getState compare is live)
    s_p = get_state()
    diffs.append(('getState(S_P)', s_p == ref_sp))
    load(rec_q)
    if tooth != 'skip':
        r_set = set_state(s_p)
        diffs.append(('setState result', r_set == meta['r_set']))
    s_2 = get_state()
    diffs.append(('getState(S2)', s_2 == ref_s2))
    got = play()
    diffs.append(('output words', got == ref_w))

    def read(base, size):
        p = lib.junoh_guest(base, size)
        if not p:
            raise RuntimeError('junoh_guest(0x%x, %d) -> NULL' % (base, size))
        return ctypes.string_at(p, size)
    endbad = []
    if lib.junoh_heap_top() != meta['heap_top']:
        endbad.append('heap_top')
    if lib.junoh_com_next() != meta['com_next']:
        endbad.append('com_next')
    for name, base, size in (('image.bin', meta['IB'], meta['IMGSZ']),
                             ('heap.bin', meta['HEAP_BASE'], meta['heap_top'] - meta['HEAP_BASE']),
                             ('com.bin', meta['COM'], meta['com_next'] - meta['COM'])):
        try:
            r = open(os.path.join(refdir, name), 'rb').read(); g = read(base, len(r))
        except RuntimeError as e:
            endbad.append('%s unreadable (%s)' % (name, e)); continue
        if g != r:
            endbad.append(name)
    diffs.append(('end-state', not endbad))

    if tooth:
        differ = [n for n, eq in diffs if not eq]
        if differ:
            print('TOOTH %s bit: %s differ from the oracle' % (tooth, ', '.join(differ))); return 0
        print('TOOTH %s DID NOT BITE: every quantity matched the oracle' % tooth); return 1
    bad = [n for n, eq in diffs if not eq]
    if bad:
        print('L5 state RED: %s differ (end-state: %s)' % (', '.join(bad), ', '.join(endbad) or 'ok')); return 1
    print('L5 state GREEN: getState %d bytes bit-exact, setState->0x%x, idempotent %s, %d words AND end-state '
          'byte-identical to the oracle' % (len(ref_sp), meta['r_set'], meta['idempotent'], len(ref_w) // 4))
    return 0


if __name__ == '__main__':
    sys.exit(main())
