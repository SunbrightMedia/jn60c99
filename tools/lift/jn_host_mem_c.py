#!/usr/bin/env python3
"""jn_host_mem_c.py -- L5 (init) C side: load the lifted JUNO host (libjunohost.so), call junoh_init(template, 48000,
512), and compare its memory to the oracle reference (jn_host_mem_ref.py) byte for byte. ctypes only (two-process
rule: no Unicorn here). EXACTLY 0 or the first differing address. A tooth (--tooth) perturbs the rate so the memory
must differ (seen to fail, mantra 5). usage: python3 tools/lift/jn_host_mem_c.py <so> <template> <refdir> [--tooth]"""
import ctypes
import sys
import os
import json


def main():
    so, tmpl_path, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
    tooth = '--tooth' in sys.argv
    lib = ctypes.CDLL(so)
    lib.junoh_init.restype = ctypes.c_int
    lib.junoh_init.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
    lib.junoh_error.restype = ctypes.c_char_p
    for fn in ('junoh_heap_top', 'junoh_com_next', 'junoh_core'):
        getattr(lib, fn).restype = ctypes.c_uint64
    lib.junoh_guest.restype = ctypes.c_void_p
    lib.junoh_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]

    meta = json.load(open(os.path.join(refdir, 'meta.json')))
    t = open(tmpl_path, 'rb').read()
    buf = ctypes.create_string_buffer(t, len(t))
    rate = 44100.0 if tooth else 48000.0                 # the tooth: a different rate -> the memory must differ
    rc = lib.junoh_init(buf, len(t), rate, 512)
    if rc != 0:
        print('junoh_init rc=%d: %s' % (rc, lib.junoh_error().decode('latin1', 'replace')))
        return 2 if not tooth else 0                      # a trap under the tooth still counts as "differs"

    def read(base, size):
        p = lib.junoh_guest(base, size)
        if not p:
            raise RuntimeError('junoh_guest(0x%x, %d) -> NULL' % (base, size))
        return ctypes.string_at(p, size)

    bad = []
    ht, cn = lib.junoh_heap_top(), lib.junoh_com_next()
    if ht != meta['heap_top']:
        bad.append('heap_top 0x%x != oracle 0x%x' % (ht, meta['heap_top']))
    if cn != meta['com_next']:
        bad.append('com_next 0x%x != oracle 0x%x' % (cn, meta['com_next']))
    regions = [('image.bin', meta['IB'], meta['IMGSZ']),
               ('heap.bin', meta['HEAP_BASE'], meta['heap_top'] - meta['HEAP_BASE']),
               ('com.bin', meta['COM'], meta['com_next'] - meta['COM'])]
    for name, base, size in regions:
        ref = open(os.path.join(refdir, name), 'rb').read()
        got = read(base, len(ref)) if size == len(ref) else read(base, size)
        if ref != got:
            first = next((i for i in range(min(len(ref), len(got))) if ref[i] != got[i]), min(len(ref), len(got)))
            bad.append('%s differs at +0x%x (guest 0x%x): ref %02x got %02x (of %d bytes)'
                       % (name, first, base + first, ref[first] if first < len(ref) else -1,
                          got[first] if first < len(got) else -1, len(ref)))
    if tooth:
        if bad:
            print('TOOTH bit: the perturbed init differs (%s)' % bad[0])
            return 0
        print('TOOTH DID NOT BITE: the perturbed init matched the oracle'); return 1
    if bad:
        print('L5 init RED:'); [print('  ' + b) for b in bad]; return 1
    print('L5 init GREEN: image + heap + com byte-identical to the oracle; heap_top 0x%x, com_next 0x%x' % (ht, cn))
    return 0


if __name__ == '__main__':
    sys.exit(main())
