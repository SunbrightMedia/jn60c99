#!/usr/bin/env python3
"""jn_editor_c.py -- L5 (editor) C side: the editor's SET through the lifted JUNO's OWN model (junoh_model_set -> rva
0x283DB0, flag 1). For every parameter record it sets the same values as the oracle, captures the performEdit sequence
the plugin's controller makes (junoh_edits), then renders one warm block. The performEdit sequence, the output words
and the end-state memory are graded byte-for-byte against jn_editor_ref.py. ctypes only (two-process rule). EXACTLY 0
is the bar. A tooth (--tooth value) sets each value one higher, so the performEdits + audio + end-state MUST differ.
usage: python3 tools/lift/jn_editor_c.py <so> <template> <refdir> [--tooth value]"""
import ctypes
import sys
import os
import struct
import json

VALS_DEFAULT = (0, 64, 127)


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
    lib.junoh_rec_id.restype = ctypes.c_int
    lib.junoh_rec_id.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_uint64)]
    lib.junoh_model_set.restype = ctypes.c_int
    lib.junoh_model_set.argtypes = [ctypes.c_uint64, ctypes.c_uint32]
    lib.junoh_edits.restype = ctypes.c_int
    lib.junoh_edits.argtypes = [ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_double), ctypes.c_int]
    for fn in ('junoh_heap_top', 'junoh_com_next'):
        getattr(lib, fn).restype = ctypes.c_uint64
    lib.junoh_guest.restype = ctypes.c_void_p
    lib.junoh_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]

    def chk(rc, what):
        if rc:
            print('%s rc=%d: %s' % (what, rc, lib.junoh_error().decode('latin1', 'replace')))
            sys.exit(0 if tooth else 2)

    meta = json.load(open(os.path.join(refdir, 'meta.json')))
    ref_edits = json.load(open(os.path.join(refdir, 'edits.json')))
    ref_w = open(os.path.join(refdir, 'words.bin'), 'rb').read()
    vals = tuple(meta['vals'])
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    chk(lib.junoh_init(b, len(t), 48000.0, 512), 'junoh_init')

    def proc(n):
        cx = CTX(0x402, 0.0, 0.0, 0.0, 120.0)
        L = (ctypes.c_uint32 * n)(); R = (ctypes.c_uint32 * n)()
        chk(lib.junoh_process(n, None, 0, None, 0, ctypes.byref(cx), L, R), 'process')
        return struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R)

    def edit_count():
        return lib.junoh_edits(None, None, 0)

    proc(512); proc(512)                         # warm past the 960-sample start mute (max block is 512)
    n0 = edit_count()                            # performEdits so far (none expected) -- the oracle slices from here
    nrec = meta['nrec']
    for i in range(nrec):
        rid = ctypes.c_uint32(0); obj = ctypes.c_uint64(0)
        chk(lib.junoh_rec_id(i, ctypes.byref(rid), ctypes.byref(obj)), 'rec_id')
        for v in vals:
            chk(lib.junoh_model_set(obj.value, (v + 1 if tooth else v) & 0xFFFFFFFF), 'model_set')
    ntot = edit_count()
    ids = (ctypes.c_uint32 * ntot)(); vls = (ctypes.c_double * ntot)()
    lib.junoh_edits(ids, vls, ntot)
    got_edits = [[int(ids[k]), struct.unpack('<Q', struct.pack('<d', vls[k]))[0]] for k in range(n0, ntot)]
    got_w = proc(256)

    diffs = []
    diffs.append(('performEdits', got_edits == ref_edits))
    diffs.append(('output words', got_w == ref_w))

    def read(base, size):
        p = lib.junoh_guest(base, size)
        if not p:
            raise RuntimeError('junoh_guest(0x%x,%d)->NULL' % (base, size))
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
            print('TOOTH bit: %s differ from the oracle' % ', '.join(differ)); return 0
        print('TOOTH DID NOT BITE: every quantity matched'); return 1
    bad = [n for n, eq in diffs if not eq]
    if bad:
        if not diffs[0][1]:
            d = next((k for k in range(min(len(got_edits), len(ref_edits))) if got_edits[k] != ref_edits[k]), None)
            print('  performEdits: got %d, ref %d; first diff at %s' % (len(got_edits), len(ref_edits), d))
        print('L5 editor RED: %s differ (end-state: %s)' % (', '.join(bad), ', '.join(endbad) or 'ok')); return 1
    print('L5 editor GREEN: %d records set, %d performEdits, %d words AND end-state byte-identical to the oracle'
          % (meta['nrec'], len(ref_edits), len(ref_w) // 4))
    return 0


if __name__ == '__main__':
    sys.exit(main())
