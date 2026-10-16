#!/usr/bin/env python3
"""jn_surf_c.py -- L5 (surfaces) C side: the lifted JUNO host (libjunohost.so) replays the shared plan
(jn_surf_seq.plan) through its junoh_* entries; after EVERY op it digests its end-state memory (image + heap + host
arena) exactly as jn_surf_ref.py does and compares with the oracle's row, so the first divergence names its op. Then
the output words, the final memory byte for byte, and the imports answered by the oracle's default (the lift's
junoh_unhandled vs the oracle's .unhandled delta since the cut). ctypes only (two-process rule). EXACTLY 0 is the bar.
A tooth (--tooth) sets the first voice-count value one lower (6 -> 5): the digests MUST diverge at that op.
usage: python3 tools/lift/jn_surf_c.py <so> <template> <refdir> [--tooth]"""
import ctypes
import sys
import os
import json
import struct
import hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jn_surf_seq as S                                            # noqa: E402


class EV(ctypes.Structure):
    _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int),
                ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]


class PAR(ctypes.Structure):
    _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]


class CTX(ctypes.Structure):
    _fields_ = [('state', ctypes.c_uint32), ('ppq', ctypes.c_double), ('cs', ctypes.c_double),
                ('ce', ctypes.c_double), ('tempo', ctypes.c_double)]


def main():
    so, tmpl, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
    tooth = '--tooth' in sys.argv
    lib = ctypes.CDLL(so)
    I, U32, U64, D, VP, SZ = ctypes.c_int, ctypes.c_uint32, ctypes.c_uint64, ctypes.c_double, ctypes.c_void_p, ctypes.c_size_t
    sig = dict(junoh_init=(I, [VP, SZ, D, I]), junoh_set_rate=(I, [D]), junoh_ui_tick=(I, []),
               junoh_cc_learn=(I, [U32]), junoh_cc_forget=(I, [U32]), junoh_commit=(I, []),
               junoh_rec_id=(I, [I, ctypes.POINTER(U32), ctypes.POINTER(U64)]),
               junoh_get_state=(I, [VP, SZ, ctypes.POINTER(SZ)]), junoh_set_state=(I, [VP, SZ, ctypes.POINTER(U32)]),
               junoh_process=(I, [I, ctypes.POINTER(EV), I, ctypes.POINTER(PAR), I, ctypes.POINTER(CTX),
                                  ctypes.POINTER(U32), ctypes.POINTER(U32)]),
               junoh_heap_top=(U64, []), junoh_com_next=(U64, []), junoh_guest=(VP, [U64, SZ]),
               junoh_unhandled=(I, [ctypes.c_char_p, SZ]), junoh_error=(ctypes.c_char_p, []))
    for fn, (res, args) in sig.items():
        getattr(lib, fn).restype = res
        getattr(lib, fn).argtypes = args
    meta = json.load(open(os.path.join(refdir, 'meta.json')))
    ref_words = open(os.path.join(refdir, 'words.bin'), 'rb').read()
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    stage = ['init']

    def chk(rc):
        if rc:
            msg = lib.junoh_error().decode('latin1', 'replace')
            if tooth:
                print('TOOTH bit: the perturbed plan failed at %s (%s)' % (stage[0], msg)); sys.exit(0)
            print('L5 surfaces RED: %s rc=%d: %s' % (stage[0], rc, msg)); sys.exit(1)
    chk(lib.junoh_init(b, len(t), 48000.0, 512))
    IB, IMGSZ, HB, COM = meta['IB'], meta['IMGSZ'], meta['HEAP_BASE'], meta['COM']

    def mem(base, size):
        p = lib.junoh_guest(base, size) if size else None
        if size and not p:
            raise RuntimeError('junoh_guest(0x%x, %d) -> NULL' % (base, size))
        return ctypes.string_at(p, size) if size else b''

    def digest():
        m = hashlib.sha256()
        m.update(mem(IB, IMGSZ)); m.update(mem(HB, lib.junoh_heap_top() - HB)); m.update(mem(COM, lib.junoh_com_next() - COM))
        return m.hexdigest()

    cx = CTX(S.T['state'], S.T['ppq'], S.T['cs'], S.T['ce'], S.T['tempo'])
    ops = S.plan(rates=meta['rates'])
    perturbed = False
    for k, op in enumerate(ops):
        stage[0] = 'op %d (%s)' % (k, op[0])
        w = b''
        if op[0] == 'proc':
            n = op[1]
            evs = [EV(1 if e[0] == 'on' else 0, e[1], e[2], e[3], e[4]) for e in op[2]]
            pars = []
            for (pid, off, val) in op[3]:
                if tooth and not perturbed and pid == S.VOICES:
                    val -= 1; perturbed = True                     # the tooth: 6 voices -> 5
                pars.append(PAR(pid, off, float(val)))
            eva = (EV * len(evs))(*evs) if evs else None
            para = (PAR * len(pars))(*pars) if pars else None
            L = (U32 * n)(); R = (U32 * n)()
            chk(lib.junoh_process(n, eva, len(evs), para, len(pars), ctypes.byref(cx), L, R))
            w = struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R)
        elif op[0] == 'rate':
            chk(lib.junoh_set_rate(op[1]))
        elif op[0] == 'uitick':
            chk(lib.junoh_ui_tick())
        elif op[0] in ('learn', 'forget'):
            pid = U32(0); obj = U64(0)
            chk(lib.junoh_rec_id(op[1], ctypes.byref(pid), ctypes.byref(obj)))
            chk((lib.junoh_cc_learn if op[0] == 'learn' else lib.junoh_cc_forget)(pid.value))
        elif op[0] == 'commit':
            chk(lib.junoh_commit())
        elif op[0] == 'getset':
            cap = 1 << 20; buf = ctypes.create_string_buffer(cap); nb = SZ(0); r = U32(0)
            chk(lib.junoh_get_state(buf, cap, ctypes.byref(nb)))
            chk(lib.junoh_set_state(buf, nb.value, ctypes.byref(r)))
            if r.value:
                print('L5 surfaces RED: setState -> 0x%x' % r.value); return 1
        row = meta['rows'][k]
        same = (digest() == row['digest'] and lib.junoh_heap_top() == row['heap_top']
                and lib.junoh_com_next() == row['com_next'] and w == ref_words[row['woff']:row['woff'] + row['wlen']])
        if not same:
            if tooth:
                print('TOOTH bit: the end state diverges at op %d (%s)' % (k, op[0])); return 0
            print('L5 surfaces RED: op %d (%s) differs from the oracle: heap_top 0x%x/0x%x com_next 0x%x/0x%x words %s'
                  % (k, op[0], lib.junoh_heap_top(), row['heap_top'], lib.junoh_com_next(), row['com_next'],
                     'equal' if w == ref_words[row['woff']:row['woff'] + row['wlen']] else 'DIFFER'))
            return 1
    if tooth:
        print('TOOTH DID NOT BITE: every op matched the oracle'); return 1
    # the final memory byte for byte, and the imports the oracle answered by default
    for name, base, size in (('image.bin', IB, IMGSZ), ('heap.bin', HB, meta['heap_top'] - HB),
                             ('com.bin', COM, meta['com_next'] - COM)):
        if mem(base, size) != open(os.path.join(refdir, name), 'rb').read():
            print('L5 surfaces RED: final %s differs' % name); return 1
    ub = ctypes.create_string_buffer(8192); lib.junoh_unhandled(ub, 8192)
    unh = dict((ln.split('=')[0], int(ln.split('=')[1])) for ln in ub.value.decode().split('\n') if ln)
    if unh != meta['unhandled']:
        print('L5 surfaces RED: imports answered by the default differ: lift %s, oracle %s' % (unh, meta['unhandled']))
        return 1
    print('L5 surfaces GREEN: %d ops (%s) -- every op\'s end-state digest, heap/arena tops and output words equal the '
          'oracle; final memory byte-identical; default-answered imports equal (%s)'
          % (len(ops), ', '.join(sorted(set(o[0] for o in ops))), unh or 'none'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
