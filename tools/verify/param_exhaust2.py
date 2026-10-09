#!/usr/bin/env python3
"""param_exhaust2.py -- CLAIMS A1 / A4: the exhaustion of param_exhaust.py (25 rows x 256 bytes x 3 rates)
into a WARM engine (12000 samples idle-rendered) and a MID-NOTE engine (note_on(60, 105) + 3000
samples), state-level, the plugin's dispatch vs the port's setter in the same configuration -- in two
processes (CLAUDE.md two-process rule; the first version ran both in one process).

usage: param_exhaust2.py --ref    the plugin's side -> scratchpad/param_exhaust2_ref.pkl (Unicorn only)
       param_exhaust2.py          the port's side (libjuno only): exit 1 on any difference
"""
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
from param_exhaust import bindings, RATES          # noqa: E402  (text only: no port code is loaded)
REF = os.path.join(REPO, 'scratchpad', 'param_exhaust2_ref.pkl')
CONFIGS = ('warm', 'midnote')


def build_ref():
    import e2e_emu as E
    bind = bindings()
    out = {}
    for config in CONFIGS:
        for sr in RATES:
            e = E.E2E()
            e.build(sr)
            e.snap_all()
            e.clear_latch()
            e.set_ftz()
            if config == 'warm':
                e.render(12000)
            else:
                e.note_on(60, 105)
                e.render(3000)
            for i, (bp, off, nm) in enumerate(bind):
                for byte in range(256):
                    for u in range(9):
                        try:
                            e.dispatch(u, bp + 744, byte)
                        except RuntimeError:
                            pass
                    e.snap_all()
                    out[(config, sr, i, byte)] = e.rd_u32(e.state[0] + off)
            print('  plugin: %s, rate %d' % (config, int(sr)), flush=True)
            del e
    pickle.dump({'fmt': 1, 'bind': bind, 'cells': out}, open(REF + '.partial', 'wb'))
    os.replace(REF + '.partial', REF)
    print('wrote %s: %d values' % (os.path.relpath(REF, REPO), len(out)))
    return 0


def port_side():
    import ctypes
    if not os.path.exists(REF):
        raise SystemExit('no reference: run param_exhaust2.py --ref first')
    ref = pickle.load(open(REF, 'rb'))
    bind = bindings()
    if bind != ref['bind']:
        raise SystemExit('src/juno_apply.c BINDINGS changed since the reference: run --ref again')
    lib = ctypes.CDLL(os.path.join(REPO, 'libjuno.so'))
    for fn, rt, at in [
            ('juno_gui_create', ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
            ('juno_gui_destroy', None, [ctypes.c_void_p]),
            ('juno_gui_warmup', None, [ctypes.c_void_p, ctypes.c_int]),
            ('juno_gui_note_on', None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
            ('juno_gui_render', ctypes.c_int, [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]),
            ('juno_gui_set_param', ctypes.c_float, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
            ('juno_gui_peek', ctypes.c_uint, [ctypes.c_void_p, ctypes.c_int]),
            ('juno_gui_param_count', ctypes.c_int, [])]:
        getattr(lib, fn).restype = rt
        getattr(lib, fn).argtypes = at
    if len(bind) != lib.juno_gui_param_count():
        raise SystemExit('BINDINGS has %d rows, juno_gui_param_count %d' % (len(bind), lib.juno_gui_param_count()))
    bad_all = 0
    for config in CONFIGS:
        ok = bad = 0
        for sr in RATES:
            c = lib.juno_gui_create(ctypes.c_float(sr), 0)
            if config == 'warm':
                lib.juno_gui_warmup(c, 12000)
            else:
                lib.juno_gui_note_on(c, 60, 105)
                buf = (ctypes.c_float * 6000)()
                lib.juno_gui_render(c, buf, 3000)
            print('--- [%s] rate %d ---' % (config, int(sr)))
            for i, (bp, off, nm) in enumerate(bind):
                miss = []
                for byte in range(256):
                    lib.juno_gui_set_param(c, i, byte)
                    pv = lib.juno_gui_peek(c, off)
                    gv = ref['cells'][(config, sr, i, byte)]
                    if gv != pv:
                        miss.append((byte, gv, pv))
                ok += 256 - len(miss)
                bad += len(miss)
                tag = 'OK 256/256' if not miss else 'BAD %d/256 first: byte %d plugin %08x port %08x' % (
                    len(miss), miss[0][0], miss[0][1], miss[0][2])
                print('  [%2d] blob%3d off%6d %-18s %s' % (i, bp, off, nm, tag))
            lib.juno_gui_destroy(c)
        print('[%s] TOTAL: %d identical / %d mismatched of %d' % (config, ok, bad, ok + bad))
        bad_all += bad
    return 1 if bad_all else 0


if __name__ == '__main__':
    sys.exit(build_ref() if '--ref' in sys.argv else port_side())
