#!/usr/bin/env python3
"""jn_proc_c.py -- L5 (process) C side: the lifted JUNO host (libjunohost.so) booted with junoh_init, then the shared
process drive (jn_proc_seq.steps) through junoh_process, every output word compared to the oracle reference
(jn_proc_ref.py) byte for byte. ctypes only (two-process rule). EXACTLY 0 is the bar. A tooth (--tooth) shifts the
first note up one semitone, so the audio -- and the compare -- MUST differ (seen to fail, mantra 5).
usage: python3 tools/lift/jn_proc_c.py <so> <template> <refdir> [--tooth]"""
import ctypes
import sys
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jn_proc_seq                                                 # noqa: E402


class EV(ctypes.Structure):
    _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int),
                ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]


class CTX(ctypes.Structure):
    _fields_ = [('state', ctypes.c_uint32), ('ppq', ctypes.c_double), ('cs', ctypes.c_double),
                ('ce', ctypes.c_double), ('tempo', ctypes.c_double)]


def main():
    so, tmpl, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
    tooth = '--tooth' in sys.argv
    lib = ctypes.CDLL(so)
    lib.junoh_init.restype = ctypes.c_int
    lib.junoh_init.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
    lib.junoh_error.restype = ctypes.c_char_p
    lib.junoh_process.restype = ctypes.c_int
    lib.junoh_process.argtypes = [ctypes.c_int, ctypes.POINTER(EV), ctypes.c_int, ctypes.c_void_p, ctypes.c_int,
                                  ctypes.POINTER(CTX), ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_uint32)]
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    rc = lib.junoh_init(b, len(t), 48000.0, 512)
    if rc:
        print('junoh_init rc=%d: %s' % (rc, lib.junoh_error().decode('latin1', 'replace'))); return 2
    ref = open(os.path.join(refdir, 'words.bin'), 'rb').read()
    got = bytearray()
    shifted = False
    for st in jn_proc_seq.steps():
        n = st['n']
        evs = []
        for (k, off, ch, p, v) in st['events']:
            if tooth and not shifted and k == 'on':
                p += 1; shifted = True                              # the tooth: one semitone up -> the audio differs
            evs.append(EV(1 if k == 'on' else 0, off, ch, p, v))
        eva = (EV * len(evs))(*evs) if evs else None
        ctxp = None
        if st['ctx'] is not None:
            cx = CTX(st['ctx']['state'], st['ctx']['ppq'], st['ctx']['cs'], st['ctx']['ce'], st['ctx']['tempo'])
            ctxp = ctypes.byref(cx)
        L = (ctypes.c_uint32 * n)() if n else (ctypes.c_uint32 * 1)()
        R = (ctypes.c_uint32 * n)() if n else (ctypes.c_uint32 * 1)()
        rc = lib.junoh_process(n, eva, len(evs), None, 0, ctxp, L, R)
        if rc:
            print('junoh_process rc=%d: %s' % (rc, lib.junoh_error().decode('latin1', 'replace')))
            return 0 if tooth else 2
        if n:
            got += struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R)
    if tooth:
        if bytes(got) != ref:
            d = next((i for i in range(min(len(got), len(ref))) if got[i] != ref[i]), -1)
            print('TOOTH bit: the shifted note differs from the oracle (first at byte %d)' % d); return 0
        print('TOOTH DID NOT BITE: the shifted note matched the oracle'); return 1
    if bytes(got) != ref:
        nmin = min(len(got), len(ref))
        d = next((i for i in range(nmin) if got[i] != ref[i]), nmin)
        print('L5 process RED: output differs at word %d of %d (byte %d); got %d bytes, ref %d'
              % (d // 4, len(ref) // 4, d, len(got), len(ref)))
        return 1
    print('L5 process GREEN: %d output words byte-identical to the oracle' % (len(ref) // 4))
    return 0


if __name__ == '__main__':
    sys.exit(main())
