#!/usr/bin/env python3
"""jp8_mutation_prescreen.py -- does a candidate drive segment SEE a mutation? The C side alone, no oracle (playbook 246).

The mutation build (jp8_mutation_gate.py: build/jp8_mut/libjp8host_mut.so, every slip behind JP8_MUT == k) runs the
segment once with JP8_MUT=0 and once per k, each in its own process (JP8_MUT is read once). A slip the segment cannot
show in C cannot be shown by a gate on it either; one it shows is worth the oracle's references. Per k it prints the
blocks whose words differ, the 'memhash' steps that differ (image + heap: what the gate grades at that step), the
memory after, and how often the slip ran and changed a value. Steps: patch, block, getstate, setstate, compstate,
memhash (jp8_host_seq's forms).
    python3 jp8/tools/jp8_mutation_prescreen.py <lib> <refdir> reach|<segment.py> k[,k..]
<segment.py>: one Python expression, the step list (Q = jp8_host_seq, BY = its BYNAME); 'reach' = Q.reach_steps().
<refdir>: any reference directory of the rate in JP8_HOST_RATE (its template; the same at every first rate)."""
import ctypes
import hashlib
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jp8_bank as B          # noqa: E402
import jp8_host_seq as Q      # noqa: E402


def child(lib_path, refdir, seg):
    steps = Q.reach_steps() if seg == 'reach' else eval(open(seg).read(), dict(Q=Q, BY=Q.BYNAME))
    tm = open(os.path.join(refdir, 'jp8_host_template.bin'), 'rb').read()
    lib = ctypes.CDLL(os.path.abspath(lib_path))

    class EV(ctypes.Structure):
        _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int), ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]

    class PAR(ctypes.Structure):
        _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]
    U32P, SZP = ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_size_t)
    lib.jp8h_init.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
    lib.jp8h_load_patch.argtypes = [ctypes.c_char_p, ctypes.c_size_t]
    lib.jp8h_process.argtypes = [ctypes.c_int, ctypes.POINTER(EV), ctypes.c_int, ctypes.POINTER(PAR), ctypes.c_int, ctypes.c_void_p,
                                 ctypes.c_void_p, ctypes.c_void_p]
    lib.jp8h_get_state.argtypes = [ctypes.c_void_p, ctypes.c_size_t, SZP]
    lib.jp8h_set_state.argtypes = lib.jp8h_component_state.argtypes = [ctypes.c_char_p, ctypes.c_size_t, U32P]
    lib.jp8h_error.restype = ctypes.c_char_p
    lib.jp8h_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]; lib.jp8h_guest.restype = ctypes.c_void_p
    lib.jp8h_heap_top.restype = ctypes.c_uint64

    def mem():
        m = hashlib.sha256()
        for a, n in ((Q.IMG_BASE, 0xDE7000), (Q.HEAP_BASE, lib.jp8h_heap_top() - Q.HEAP_BASE)):
            m.update(ctypes.string_at(lib.jp8h_guest(a, n), n))
        return m.hexdigest()[:16]
    if lib.jp8h_init(tm, len(tm), Q.RATE, Q.MAXBLOCK):
        return dict(err='jp8h_init: %s' % lib.jp8h_error().decode())
    bank = B.bank_bytes(); out = []; states = {}
    for st in steps:
        k = st[0]; r = 0
        if k == 'patch':
            blob = B.patch_blob(bank, st[1]); r = lib.jp8h_load_patch(blob, len(blob))
        elif k == 'memhash':
            out.append('M' + mem())
        elif k == 'getstate':
            nb = ctypes.c_size_t(0); buf = ctypes.create_string_buffer(1 << 20)
            r = lib.jp8h_get_state(buf, 1 << 20, ctypes.byref(nb)); states[st[1]] = buf.raw[:nb.value]
        elif k in ('setstate', 'compstate'):
            o = ctypes.c_uint32(0); s = Q.state_variant(states[st[1]], st[2])
            r = (lib.jp8h_set_state if k == 'setstate' else lib.jp8h_component_state)(s, len(s), ctypes.byref(o))
        elif k == 'block':
            _, n, evs, pars = st[:4]
            ev = (EV * max(1, len(evs)))(*[EV(1 if kk == 'on' else 0, off, ch, p, v) for kk, off, ch, p, v in evs])
            pa = (PAR * max(1, len(pars)))(*[PAR(pid, off, v) for pid, off, v in pars])
            L = (ctypes.c_uint32 * n)(); R = (ctypes.c_uint32 * n)()
            r = lib.jp8h_process(n, ev, len(evs), pa, len(pars), None, L, R)
            out.append('W' + hashlib.sha1(bytes(L) + bytes(R)).hexdigest()[:12])
        else:
            return dict(err='a step this tool does not run: %r' % (st[:2],))
        if r:
            return dict(err='step %r: rc %d %s' % (st[:2], r, lib.jp8h_error().decode()))
    return dict(seq=out, mem=mem())


if os.environ.get('JP8_PRESCREEN_CHILD'):
    print(json.dumps(child(*sys.argv[1:4])))
    sys.exit(0)
if len(sys.argv) != 5:
    sys.exit(__doc__)
lib_path, refdir, seg, ks = sys.argv[1:5]
res = {}
for k in [0] + [int(x) for x in ks.split(',')]:
    r = subprocess.run([sys.executable, __file__, lib_path, refdir, seg], env=dict(os.environ, JP8_MUT=str(k), JP8_PRESCREEN_CHILD='1'),
                       capture_output=True, text=True)
    try:
        res[k] = json.loads(r.stdout.strip().split('\n')[-1])
    except (ValueError, IndexError):
        res[k] = dict(err=(r.stdout + r.stderr)[-300:])
    res[k]['mut'] = next((x for x in r.stderr.split('\n') if x.startswith('JP8_MUT')), '')
base = res[0]
if 'err' in base:
    sys.exit('JP8_MUT=0: %s' % base['err'])
seen = 0
for k in sorted(res):
    if k == 0:
        continue
    m = res[k]
    if 'err' in m:
        print('k=%-3d %s' % (k, m['err'])); continue
    dw = [i for i, (a, b) in enumerate(zip(base['seq'], m['seq'])) if a != b and a[0] == 'W']
    dm = [i for i, (a, b) in enumerate(zip(base['seq'], m['seq'])) if a != b and a[0] == 'M']
    end = m['mem'] != base['mem']; seen += bool(dw or dm or end)
    print('k=%-3d %s: words differ in %d blocks (first at step %s), %d memhash steps differ, memory after %s; %s' % (
        k, 'SEEN' if dw or dm or end else 'NOT SEEN', len(dw), dw[0] if dw else '-', len(dm), 'differs' if end else 'equal', m['mut']))
print('prescreen: %d of %d mutations seen by this segment at %g Hz' % (seen, len(res) - 1, Q.RATE))
