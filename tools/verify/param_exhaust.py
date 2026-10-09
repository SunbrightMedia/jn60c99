#!/usr/bin/env python3
"""param_exhaust.py -- CLAIMS A1: every exposed panel parameter x all 256 byte values, the plugin's own
dispatch vs the port's setter, at 44100 / 48000 / 96000 -- in two processes (CLAUDE.md two-process
rule: the plugin's side writes a reference, the port's side reads it; the first version ran both in
one process).

For each BINDINGS row of src/juno_apply.c (blob position, engine cell; read as text, so the plugin's
side loads no port code): dispatch index = blob position + 744 with the raw byte into every unit of a
live plugin instance (Unicorn), snap the ramps, read the cell from unit 0; the port's
juno_gui_set_param(row, byte) then juno_gui_peek(cell) must give the same bits. Both sides walk the
same sequence (rows in order, bytes 0..255, the state carried along), one instance per rate.
25 rows x 256 bytes x 3 rates = 19200 comparisons; for a finite domain the exhaustion is the proof.

usage: param_exhaust.py --ref     the plugin's side -> scratchpad/param_exhaust_ref.pkl (Unicorn only)
       param_exhaust.py           the port's side (libjuno only): exit 1 on any difference
"""
import os
import pickle
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
REF = os.path.join(REPO, 'scratchpad', 'param_exhaust_ref.pkl')
RATES = (44100.0, 48000.0, 96000.0)


def bindings():
    """(blob position, engine cell, name) per row of the port's BINDINGS table, as text"""
    src = open(os.path.join(REPO, 'src', 'juno_apply.c')).read()
    m = re.search(r'BINDINGS\[\]\s*=\s*\{(.*?)\n\};', src, re.S)
    rows = re.findall(r'\{\s*(\d+)\s*,\s*\d+\s*,\s*[A-Z_]+\s*,\s*(\d+)\s*,\s*"([^"]*)"', m.group(1))
    return [(int(bp), int(off), nm) for (bp, off, nm) in rows]


def build_ref():
    sys.path.insert(0, HERE)
    import e2e_emu as E
    bind = bindings()
    out = {}
    for sr in RATES:
        e = E.E2E()
        e.build(sr)
        e.snap_all()
        e.clear_latch()
        e.set_ftz()
        for i, (bp, off, nm) in enumerate(bind):
            for byte in range(256):
                for u in range(9):
                    try:
                        e.dispatch(u, bp + 744, byte)
                    except RuntimeError:
                        pass
                e.snap_all()
                out[(sr, i, byte)] = e.rd_u32(e.state[0] + off)
        print('  plugin: rate %d, %d rows' % (int(sr), len(bind)), flush=True)
        del e
    pickle.dump({'fmt': 1, 'bind': bind, 'cells': out}, open(REF + '.partial', 'wb'))
    os.replace(REF + '.partial', REF)
    print('wrote %s: %d values' % (os.path.relpath(REF, REPO), len(out)))
    return 0


def port_side():
    import ctypes
    if not os.path.exists(REF):
        raise SystemExit('no reference: run param_exhaust.py --ref first')
    ref = pickle.load(open(REF, 'rb'))
    bind = bindings()
    if bind != ref['bind']:
        raise SystemExit('src/juno_apply.c BINDINGS changed since the reference: run --ref again')
    lib = ctypes.CDLL(os.path.join(REPO, 'libjuno.so'))
    lib.juno_gui_param_count.restype = ctypes.c_int
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    lib.juno_gui_set_param.restype = ctypes.c_float
    lib.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    if len(bind) != lib.juno_gui_param_count():
        raise SystemExit('BINDINGS has %d rows, juno_gui_param_count %d' % (len(bind), lib.juno_gui_param_count()))
    f = lambda u: struct.unpack('<f', struct.pack('<I', u & 0xffffffff))[0]
    ok = bad = 0
    for sr in RATES:
        c = lib.juno_gui_create(ctypes.c_float(sr), 0)
        print('--- rate %d ---' % int(sr))
        for i, (bp, off, nm) in enumerate(bind):
            miss = []
            for byte in range(256):
                lib.juno_gui_set_param(c, i, byte)
                pv = lib.juno_gui_peek(c, off)
                gv = ref['cells'][(sr, i, byte)]
                if gv != pv:
                    miss.append((byte, gv, pv))
            ok += 256 - len(miss)
            bad += len(miss)
            tag = 'OK 256/256' if not miss else 'BAD %d/256 first: byte %d plugin %08x (%.6g) port %08x (%.6g)' % (
                len(miss), miss[0][0], miss[0][1], f(miss[0][1]), miss[0][2], f(miss[0][2]))
            print('  [%2d] blob%3d off%6d %-18s %s' % (i, bp, off, nm, tag))
        lib.juno_gui_destroy(c)
    print('EXHAUSTION TOTAL: %d identical / %d mismatched of %d' % (ok, bad, ok + bad))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(build_ref() if '--ref' in sys.argv else port_side())
