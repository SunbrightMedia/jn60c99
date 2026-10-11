#!/usr/bin/env python3
"""nan_ab.py -- NaN-REACHABILITY GATE (playbook 81; the JX-3P's twin is jx3p/tools/jx_nan_ab.py).

x86 comiss/ucomiss set CF=ZF=PF=1 on unordered, so `ja`/`jae` are NOT taken on
NaN while C's `<=`/`>=` ARE false -- the two agree on every ordered input and
differ only on NaN. unordered_audit.py counts the sites where that matters:
104 in the JX master, 57 in the JUNO master. Hand-rewriting them would trade one
proven defect for an unknown number of new ones.

This gate settles the question by EXPERIMENT instead. It puts a NaN into one DSP
state cell on BOTH sides, renders, and compares bit-exact. If the port and the
plugin disagree, some comparison downstream of that cell handles NaN
differently -- exactly the defect class, found without guessing which site.

A difference here is a REAL defect: both engines start from identical state and
identical input, so nothing else can explain a divergence -- once the CONTROL
(no NaN) is equal, which is checked first.

ORACLE (--oracle, its own process: e2e_emu + the recall model, recall_render_ab.prepare_recall) and PORT (--port, its
own process: libjuno.so, juno_gui_apply_bank -- the same model) meet only through a JSON file (the two-process rule;
until 2026-10-11 this gate loaded both in one process and no target ran it).
CELLS: a first 64-frame render after the note finds the float cells it MOVES (a float after, a float or zero before)
and the float cells it READS without moving (parameters, coefficients: a compare's inputs are often these), in voice
0's window and in the master's whole object; per seed a sample of each; plus FIXED, the inputs of the master's clamp
at rva 0x366417 (src/master_render.c `!(v437 > 2^-13)`: v437 = cell +4297472's result x cell +4297792).
THE ONE OBJECT: the plugin gives each of its nine units its own engine object; the port keeps every unit's cells in
ONE, at the plugin's offsets (src/juno_engine.h). A NaN at offset X is therefore written into all nine of the
plugin's objects -- the unit that owns X reads it, the others never read X (else the port's one object could not be
exact) -- and into the port's one. Per target: a fresh recall, the note, the NaN, FRAMES frames; the output bits and
the live cells' values after the render compared.

    python3 tools/verify/nan_ab.py [--patch 5] [--seeds 1,2] [--cells 16] [--frames 512]
    python3 tools/verify/nan_ab.py --tooth   the port rebuilt with the decompile's `v437 <= 0.00012207031` back at
                                             the clamp (a mutated copy of src/master_render.c): a cell must differ
exit 0 = every injected cell equal (or, --tooth, the defect seen); 2 = the control differs (the harness is wrong).
"""
import atexit
import ctypes
import glob
import hashlib
import json
import os
import random
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
NAN_BITS = 0xffc00000
CHUNK = 24                         # NaN runs per oracle process
VWIN = 84096                       # voice 0's window in its object (the cells the old gate drew from)
FIXED = ((8, 4297792), (8, 4297472), (8, 4297488), (8, 4297584))
TOOTH = ('if ( !(v437 > 0.00012207031f) )', 'if ( v437 <= 0.00012207031 )')


def floatish(u):
    """a 32-bit word holding a float of a DSP's scale (|x| in [1e-20, 1e20]): an index, a counter, a flag or a
    pointer's half is none -- a NaN there would test an out-of-bounds read, not a compare"""
    x = struct.unpack('<f', struct.pack('<I', u))[0]
    return x == x and 1e-20 <= abs(x) <= 1e20


def oracle(patch, seeds, ncell, frames):
    import numpy as np
    import e2e_emu as E, real_recall as R, recall_render_ab as RA
    from unicorn import UC_HOOK_MEM_READ
    bank, leaves, rate = E.bank_bytes(), R.leaf_table(), RA.SR
    size = E.STATE_SZ

    def boot():
        e = RA.prepare_recall(patch, bank, leaves, E, R, rate)
        e.note_on(60, 105)
        return e

    def run(e, cells):
        L, Rr = e.render(frames)
        cv = [struct.unpack('<I', e.uc.mem_read(e.state[u] + o, 4))[0] for u, o in cells]
        return [hashlib.sha256(struct.pack('<%dI' % (2 * len(L)), *(list(L) + list(Rr)))).hexdigest()[:16],
                sum(1 for x in L if x & 0x7FFFFFFF), cv]

    e = boot()
    win = {0: VWIN, 8: size}
    before = {u: np.frombuffer(bytes(e.uc.mem_read(e.state[u], win[u])), '<u4') for u in win}
    reads = {u: set() for u in win}

    def hk(uc, access, addr, sz, value, user):
        for u in win:
            o = addr - e.state[u]
            if 0 <= o < win[u]:
                reads[u].add(o & ~3)
    hs = [e.uc.hook_add(UC_HOOK_MEM_READ, hk, begin=e.state[u], end=e.state[u] + win[u] - 1) for u in win]
    e.render(64)
    for h in hs:
        e.uc.hook_del(h)
    live = {}
    for u in win:
        after = np.frombuffer(bytes(e.uc.mem_read(e.state[u], win[u])), '<u4')
        moved = set(int(i) * 4 for i in np.nonzero(before[u] != after)[0])
        out = []
        for o in sorted(moved | reads[u]):
            ua, ub = int(before[u][o // 4]), int(after[o // 4])
            if o in moved:
                if floatish(ub) and (ua == 0 or floatish(ua)):
                    out.append(o)
            elif floatish(ua):
                out.append(o)
        live[u] = out
    targets = list(FIXED)
    for sd in seeds:
        r = random.Random(7741 * sd + patch)
        for u in (8, 0):
            pool = [o for o in live[u] if (u, o) not in FIXED and (u, o) not in targets]
            targets += [(u, o) for o in sorted(r.sample(pool, min(ncell, len(pool))))]
    cells = list(targets)                          # the live cells read back after each render
    return {'live': {str(u): len(live[u]) for u in live}, 'cells': cells, 'rate': rate,
            'bank': bank.hex(), 'control': run(boot(), cells), 'targets': targets}


def oracle_run(patch, frames, cells, targets):
    """the NaN runs of one chunk of targets (its own process: hundreds of engines in one process exhaust memory)"""
    import e2e_emu as E, real_recall as R, recall_render_ab as RA
    bank, leaves = E.bank_bytes(), R.leaf_table()
    out = []
    for u, o in targets:
        e = RA.prepare_recall(patch, bank, leaves, E, R, RA.SR)
        e.note_on(60, 105)
        for k in range(9):                         # the port's ONE object: the NaN in all nine of the plugin's
            e.uc.mem_write(e.state[k] + o, struct.pack('<I', NAN_BITS))
        L, Rr = e.render(frames)
        cv = [struct.unpack('<I', e.uc.mem_read(e.state[w] + c, 4))[0] for w, c in cells]
        out.append([u, o, [hashlib.sha256(struct.pack('<%dI' % (2 * len(L)), *(list(L) + list(Rr)))).hexdigest()[:16],
                           sum(1 for x in L if x & 0x7FFFFFFF), cv]])
        del e
    return out


def port(so, patch, frames, ref):
    lib = ctypes.CDLL(so)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = bytes.fromhex(ref['bank'])
    cells = ref['cells']

    def run(inject):
        ctx = lib.juno_gui_create(ctypes.c_float(float(ref['rate'])), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
        lib.juno_gui_note_on(ctx, 60, 105)
        if inject is not None:
            lib.juno_gui_poke(ctx, inject, NAN_BITS)
        buf = (ctypes.c_float * (2 * frames))()
        lib.juno_gui_render(ctx, buf, frames)
        w = struct.unpack('<%dI' % (2 * frames), bytes(buf))   # the oracle's render returns bit patterns
        L, Rr = list(w[0::2]), list(w[1::2])
        cv = [lib.juno_gui_peek(ctx, o) for u, o in cells]
        lib.juno_gui_destroy(ctx)
        return [hashlib.sha256(struct.pack('<%dI' % (2 * frames), *(L + Rr))).hexdigest()[:16],
                sum(1 for x in L if x & 0x7FFFFFFF), cv]
    return {'control': run(None), 'targets': [run(o) for u, o, _ in ref['targets']]}


def tooth_lib(tmp):
    """the port with the decompile's ordered compare back at the clamp: a mutated COPY of src/master_render.c"""
    src = open(os.path.join(REPO, 'src', 'master_render.c')).read()
    if src.count(TOOTH[0]) != 1:
        raise SystemExit('REFUSE: the tooth\'s site is not in src/master_render.c once -- the tooth cannot be built')
    mut = os.path.join(tmp, 'master_render.c')
    open(mut, 'w').write(src.replace(TOOTH[0], TOOTH[1]))
    units = [mut] + [f for f in sorted(glob.glob(os.path.join(REPO, 'src', '*.c'))) if not f.endswith('master_render.c')]
    units += [os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(REPO, 'gui', 'juno_pm.c')]
    so = os.path.join(tmp, 'libjuno_tooth.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                    '-I', os.path.join(REPO, 'src'), '-I', os.path.join(REPO, 'gui'), '-o', so] + units + ['-lm'],
                   check=True)
    return so


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(int(a[1]), [int(x) for x in a[2].split(',')], int(a[3]), int(a[4])), sys.stdout)
        return 0
    if a[:1] == ['--oracle-run']:
        q = json.load(open(a[3]))
        json.dump(oracle_run(int(a[1]), int(a[2]), q['cells'], q['targets']), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], int(a[2]), int(a[3]), json.load(open(a[4]))), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    patch, seeds = int(opt('--patch', '5')), opt('--seeds', '1,2')
    ncell, frames = int(opt('--cells', '16')), int(opt('--frames', '512'))
    tooth = '--tooth' in a
    tmp = tempfile.mkdtemp(prefix='junonan_')
    atexit.register(shutil.rmtree, tmp, True)
    if tooth:
        so = tooth_lib(tmp)
    else:
        import freshlib
        so = freshlib.check()
    o = subprocess.run([sys.executable, __file__, '--oracle', str(patch), seeds, str(ncell), str(frames)],
                       capture_output=True, text=True)
    if o.returncode:
        raise SystemExit('oracle failed: rc %d %s' % (o.returncode, o.stderr[-1500:]))
    r = json.loads(o.stdout)
    targets, r['targets'] = r['targets'], []
    for c in range(0, len(targets), CHUNK):
        tf = os.path.join(tmp, 'targets.json')
        json.dump({'cells': r['cells'], 'targets': targets[c:c + CHUNK]}, open(tf, 'w'))
        oc = subprocess.run([sys.executable, __file__, '--oracle-run', str(patch), str(frames), tf], capture_output=True,
                            text=True)
        if oc.returncode:
            raise SystemExit('oracle failed (targets %d..): rc %d %s' % (c, oc.returncode, oc.stderr[-1500:]))
        r['targets'] += json.loads(oc.stdout)
    ref = os.path.join(tmp, 'ref.json')
    json.dump(r, open(ref, 'w'))
    p = subprocess.run([sys.executable, __file__, '--port', so, str(patch), str(frames), ref], capture_output=True,
                       text=True)
    if p.returncode:
        raise SystemExit('port failed: ' + p.stderr[-1500:])
    q = json.loads(p.stdout)
    print('patch %d at %g Hz: live float cells (moved or read) -- voice 0 %s, master %s; %d targets, %d frames each' % (
        patch, r['rate'], r['live']['0'], r['live']['8'], len(r['targets']), frames))
    if r['control'] != q['control']:
        print('CONTROL (no NaN): DIFFERS -- the harness, not the NaN, would be graded: ABORT')
        return 2
    if not r['control'][1]:
        print('CONTROL (no NaN): the plugin\'s output is silent -- this run would grade nothing: ABORT')
        return 2
    print('CONTROL (no NaN): output and live cells equal (%d nonzero L samples)' % r['control'][1])
    bad = []
    for (u, off, ro), po in zip(r['targets'], q['targets']):
        if ro != po:
            bad.append((u, off))
            what = 'output' if ro[0] != po[0] else 'live cells'
            print('  NaN in %s +%d: the %s differs' % ('master' if u == 8 else 'voice 0', off, what))
    if tooth:
        print('nan_ab --tooth: %s' % ('BITES (%d of %d cells differ)' % (len(bad), len(r['targets'])) if bad else
                                      'DID NOT BITE'))
        return 0 if bad else 1
    print('nan_ab: NaN in %d live DSP cells (voice 0 and the master), every output sample and live cell: %s' % (
        len(r['targets']), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
