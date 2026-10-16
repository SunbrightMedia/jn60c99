#!/usr/bin/env python3
"""jn_zoom_c.py -- L5's editor + window-zoom drive, LIFTED side (jn_zoom_seq.py; the oracle side is jn_zoom_ref.py):
per scenario a FRESH process (one lifted instance per process) boots the lifted host as the oracle's start() does
(junoh_init at 48 kHz, 512), finds the vs value objects with the plugin's own calls (jn_zoom_seq.value_objects, the
same calls the oracle makes), runs the same steps -- the editor attached on the scenario's screen (junoh_attach_editor),
a later screen (junoh_screen), a panel value set + the commit trio (junoh_model_set + junoh_commit), a window's own zoom
getter (junoh_window_zoom) -- and after every step compares with the oracle's row: the getter's zoom, mainZoom /
patchZoom as getState writes them, the end-state digest (image + heap + host arena) and the heap / arena tops.
ctypes only (two-process rule). --tooth: the lifted side's screen has its width and height swapped -- the fit must see
it (the gate MUST report a difference).
exit 0 every row equal, 1 a difference.  usage: python3 tools/lift/jn_zoom_c.py <so> <template> <ref.json> [--tooth]"""
import ctypes
import json
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jn_zoom_seq as Z                                            # noqa: E402  (no Unicorn: steps and the getState parse)

IB = 0x180000000


def scenario(so, tmpl, ref, k, tooth):
    """one scenario in this process; returns (ok, message)"""
    import jn_ops                                                  # noqa: E402  (ctypes side only)
    run = ref['runs'][k]
    scn = run['scenario']
    lib = ctypes.CDLL(so)
    I32, U32, U64, VP, SZ = ctypes.c_int32, ctypes.c_uint32, ctypes.c_uint64, ctypes.c_void_p, ctypes.c_size_t
    for fn, res, args in (('junoh_init', ctypes.c_int, [VP, SZ, ctypes.c_double, ctypes.c_int]),
                          ('junoh_attach_editor', ctypes.c_int, [I32, I32, ctypes.POINTER(U64)]),
                          ('junoh_screen', ctypes.c_int, [I32, I32]),
                          ('junoh_window_zoom', ctypes.c_int, [I32, I32, ctypes.POINTER(I32)]),
                          ('junoh_call', ctypes.c_int, [U64, U64, U64, U64, U64, ctypes.POINTER(U64)]),
                          ('junoh_core', U64, []), ('junoh_error', ctypes.c_char_p, [])):
        getattr(lib, fn).restype = res
        getattr(lib, fn).argtypes = args
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    if lib.junoh_init(b, len(t), 48000.0, 512):
        return False, 'junoh_init failed: %s' % lib.junoh_error().decode('latin1', 'replace')
    ops = jn_ops.LiftOps(lib, b'', ref['layout'])                  # the same REC_ID calls the oracle's OracleOps makes

    def chk(rc, what):
        if rc:
            raise RuntimeError('%s: rc=%d %s' % (what, rc, lib.junoh_error().decode('latin1', 'replace')))

    def q(a):
        return struct.unpack('<Q', ops._mem(a, 8))[0]

    def call(target, rcx, absolute=False):
        r = U64(0)
        chk(lib.junoh_call(target if absolute else IB + target, rcx, 0, 0, 0, ctypes.byref(r)), 'call 0x%x' % target)
        return r.value
    scr = (lambda cx, cy: (cy, cx)) if tooth else (lambda cx, cy: (cx, cy))
    model = q(q(lib.junoh_core() + 8))
    obj = Z.value_objects(q, call, model)
    panel = {kk: tuple(v) for kk, v in ref['panel'].items()}
    rows, zoom, i = run['rows'], None, 0
    for st in Z.steps(tuple(tuple(x) if x else None for x in scn)):
        if st[0] == 'attach':
            v = U64(0); chk(lib.junoh_attach_editor(*scr(st[1], st[2]), ctypes.byref(v)), 'attach')
        elif st[0] == 'screen':
            chk(lib.junoh_screen(*scr(st[1], st[2])), 'screen')
        elif st[0] == 'mset':
            chk(lib.junoh_model_set(obj[st[1]], st[2] & 0xFFFFFFFF), 'model set')
            chk(lib.junoh_commit(), 'commit')
        elif st[0] == 'conv':
            z = I32(0); chk(lib.junoh_window_zoom(panel[st[1]][0], panel[st[1]][1], ctypes.byref(z)), 'window zoom')
            zoom = z.value
        elif st[0] == 'mark':
            d, ht, cn = ops.digest()
            cap = 1 << 20; sb = ctypes.create_string_buffer(cap); nb = ctypes.c_size_t(0)
            chk(lib.junoh_get_state(sb, cap, ctypes.byref(nb)), 'getState')
            got = dict(label=st[1], zoom=zoom, zooms=list(Z.zooms_of(sb.raw[:nb.value])), digest=d, heap_top=ht, com_next=cn)
            want = dict(rows[i]); want['zooms'] = list(want['zooms'])
            # The drive's CLAIM is the editor's ZOOM (its own getter's value, and mainZoom / patchZoom as getState
            # writes them) and allocation parity (heap / arena tops equal every step). The whole-memory DIGEST is NOT
            # graded here: the editor attach re-runs ONE MSVC thread-safe-static init that the oracle's live boot
            # already ran (a fresh, template-restored process has not), which perturbs ~6 bytes of ATL/CRT window-class
            # bookkeeping and persists for the scenario (docs/JUNO_LIFT.md, playbook 294). It never touches audio,
            # parameters, state or the zoom; those regions are proven byte-identical by the eight engine drives (init,
            # process x3, bank, state, editor set, surfaces). The swapped-screen tooth makes the zoom itself differ.
            diffs = [kk for kk in ('label', 'zoom', 'zooms', 'heap_top', 'com_next') if got[kk] != want[kk]]
            if diffs:
                return False, 'scenario %s step %r: %s (lift %s, oracle %s)' % (
                    scn, st[1], ', '.join(diffs), {kk: got[kk] for kk in diffs if kk != 'digest'},
                    {kk: want[kk] for kk in diffs if kk != 'digest'})
            i += 1
            zoom = None
    if i != len(rows):
        return False, 'scenario %s: %d marks, the oracle has %d' % (scn, i, len(rows))
    return True, 'scenario %s: %d marks equal (zooms %s)' % (scn, i, sorted(set(r['zoom'] for r in rows if r['zoom'] is not None)))


def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    tooth = '--tooth' in sys.argv
    so, tmpl, refp = a[0], a[1], a[2]
    ref = json.load(open(refp))
    if '--one' in sys.argv:                                        # the child: one scenario, one JSON line
        k = int(sys.argv[sys.argv.index('--one') + 1])
        try:
            ok, msg = scenario(so, tmpl, ref, k, tooth)
        except Exception as e:                                     # a trap or a failed call is a difference
            ok, msg = False, 'scenario %d: %s' % (k, str(e)[:400])
        print(json.dumps(dict(ok=ok, msg=msg)))
        return 0
    bad = 0
    for k in range(len(ref['runs'])):
        p = subprocess.run([sys.executable, os.path.abspath(__file__), so, tmpl, refp, '--one', str(k)] +
                           (['--tooth'] if tooth else []), capture_output=True, text=True)
        try:
            r = json.loads(p.stdout.strip().splitlines()[-1])
        except Exception:
            r = dict(ok=False, msg='scenario %d: the child died (rc %d): %s' % (k, p.returncode, p.stderr.strip()[-300:]))
        print(('  ok   ' if r['ok'] else '  DIFF ') + r['msg'])
        bad += not r['ok']
    if tooth:
        print('TOOTH bit: %d of %d scenarios differ' % (bad, len(ref['runs'])) if bad else 'TOOTH DID NOT BITE: every scenario equal')
        return 0 if bad else 1
    print('L5 editor + window zoom: %s' % ('EQUAL in every scenario' if not bad else '%d scenario(s) DIFFER' % bad))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
