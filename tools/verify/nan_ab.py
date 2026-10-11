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
0's window and in the master's whole object; per seed a sample of each; plus FIXED, the inputs of the master's delay clamp
at rva 0x366417 (src/master_render.c `!(v437 > 2^-13)`: v437 = cell +4297472's result x cell +4297792).
THE ONE OBJECT: the plugin gives each of its nine units its own engine object; the port keeps every unit's cells in
ONE, at the plugin's offsets (src/juno_engine.h). A NaN at offset X is therefore written into all nine of the
plugin's objects -- the unit that owns X reads it, the others never read X (else the port's one object could not be
exact) -- and into the port's one. Per target: a fresh recall, the note, the NaN, FRAMES frames; the output bits and
the live cells' values after the render compared.

MARKED NaNs (2026-10-11). The value the single runs write, 0xFFC00000, is the x86 default NaN -- the very value an
invalid operation (0 * inf, inf - inf) makes -- so a NaN the port MAKES and one it PASSES ON look the same there.
--bits writes another value (a payload no operation makes; a signalling NaN, which every operation quiets). --multi
writes every target of the seeds AT ONCE, each its own marked NaN, in three scenes (all quiet, all signalling, mixed;
the sign alternating): where two different NaNs meet in an operation, x86 returns the FIRST operand's, so an operand
order the compiler swapped shows here, and a payload lost or a NaN made instead of passed on shows too.

    python3 tools/verify/nan_ab.py [--patch 5] [--seeds 1,2] [--cells 16] [--frames 512] [--bits 0xffc00000]
    python3 tools/verify/nan_ab.py --multi [--patch 5] [--seeds 1,2] [--cells 16]
    python3 tools/verify/nan_ab.py --tooth   the port rebuilt with the decompile's ordered `<= 0.0` back at the
                                             curve clamp, rva 0x3672CD (a mutated copy of src/master_render.c,
                                             TOOTH below): a cell must differ
    python3 tools/verify/nan_ab.py --multi --tooth-flags   the port built without -frounding-math -fsignaling-nans
                                             (GCC's sign folds back, playbook 225): a scene must differ
exit 0 = every injected cell equal (or, a tooth, the defect seen); 2 = the control differs (the harness is wrong).
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
# the tooth: the decompile's ordered form back at a site a NaN in these targets REACHES (rva 0x3672CD, master line
# 2375: 18 of the 68 targets evaluate it with a NaN). The first tooth (the delay clamp at rva 0x366417) is reached by
# none: its one "bite" (job juno_nan_post) was the port's own 4 then-wrong cells, so it never failed on its own
# mutation -- found 2026-10-11 by native_replay.py's sweep tooth, which did not bite either (playbook 227)
TOOTH = ('if ( !((float)(*(float *)(a1 + 101456) - v541) > 0.0) )', 'if ( (float)(*(float *)(a1 + 101456) - v541) <= 0.0 )')


def marked(i, kind):
    """the i-th marked NaN: a nonzero payload no operation makes (the default NaN's payload is 0), the sign by i's
    parity; kind 'q' quiet (bit 22 set), 's' signalling (bit 22 clear)"""
    p = (0x1235 + 0x2C1B * i) & 0x3FFFFF
    return (0x80000000 if i % 2 else 0) | (0x7FC00000 if kind == 'q' else 0x7F800000) | p


SCENES = (('quiet', lambda i: 'q'), ('signalling', lambda i: 's'), ('mixed', lambda i: 's' if i % 3 == 0 else 'q'))


def nanstats(words):
    """a scene's reach: the NaN words among the output samples and the live cells, and how many distinct MARKED ones
    (a payload no operation makes) -- a scene whose marks never reach them graded nothing about payloads"""
    nan = [w for w in words if (w & 0x7F800000) == 0x7F800000 and w & 0x7FFFFF]
    return [len(nan), len(set(w for w in nan if w & 0x3FFFFF))]


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


def oracle_run(patch, frames, cells, targets, bits=NAN_BITS):
    """the NaN runs of one chunk of targets (its own process: hundreds of engines in one process exhaust memory); a
    target is (unit, offset) -- the NaN `bits` -- or a scene: a list of (unit, offset, bits), all written at once"""
    import e2e_emu as E, real_recall as R, recall_render_ab as RA
    bank, leaves = E.bank_bytes(), R.leaf_table()
    out = []
    for t in targets:
        e = RA.prepare_recall(patch, bank, leaves, E, R, RA.SR)
        e.note_on(60, 105)
        u, o = (t[0], t[1]) if not isinstance(t[0], list) else (-1, -1)
        for _, oo, b in ([t[0], t[1], bits],) if u >= 0 else t:
            for k in range(9):                     # the port's ONE object: the NaN in all nine of the plugin's
                e.uc.mem_write(e.state[k] + oo, struct.pack('<I', b))
        L, Rr = e.render(frames)
        cv = [struct.unpack('<I', e.uc.mem_read(e.state[w] + c, 4))[0] for w, c in cells]
        out.append([u, o, [hashlib.sha256(struct.pack('<%dI' % (2 * len(L)), *(list(L) + list(Rr)))).hexdigest()[:16],
                           sum(1 for x in L if x & 0x7FFFFFFF), cv] + ([nanstats(list(L) + list(Rr) + cv)] if u < 0 else [])])
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
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    bank = bytes.fromhex(ref['bank'])
    cells = ref['cells']

    bits = ref.get('bits', NAN_BITS)

    def run(inject):
        ctx = lib.juno_gui_create(ctypes.c_float(float(ref['rate'])), 0)
        lib.juno_set_fp_oracle_mode(1)            # after create, which sets the production FTZ (playbook 120)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
        lib.juno_gui_note_on(ctx, 60, 105)
        for o, b in ([] if inject is None else [(inject, bits)] if not isinstance(inject, list) else inject):
            lib.juno_gui_poke(ctx, o, b)
        buf = (ctypes.c_float * (2 * frames))()
        lib.juno_gui_render(ctx, buf, frames)
        w = struct.unpack('<%dI' % (2 * frames), bytes(buf))   # the oracle's render returns bit patterns
        L, Rr = list(w[0::2]), list(w[1::2])
        cv = [lib.juno_gui_peek(ctx, o) for u, o in cells]
        lib.juno_gui_destroy(ctx)
        return [hashlib.sha256(struct.pack('<%dI' % (2 * frames), *(L + Rr))).hexdigest()[:16],
                sum(1 for x in L if x & 0x7FFFFFFF), cv] + ([nanstats(L + Rr + cv)] if isinstance(inject, list) else [])
    return {'control': run(None), 'targets': [run(o) for u, o, _ in ref['targets']],
            'scenes': [run([(o, b) for u, o, b in sc]) for sc in ref.get('scenes', [])]}


def tooth_lib(tmp, flags=True):
    """the port with the decompile's ordered compare back at the clamp: a mutated COPY of src/master_render.c; or
    (flags=False) the port unmutated, built without -frounding-math -fsignaling-nans"""
    src = open(os.path.join(REPO, 'src', 'master_render.c')).read()
    if flags and src.count(TOOTH[0]) != 1:
        raise SystemExit('REFUSE: the tooth\'s site is not in src/master_render.c once -- the tooth cannot be built')
    mut = os.path.join(tmp, 'master_render.c')
    open(mut, 'w').write(src.replace(TOOTH[0], TOOTH[1]) if flags else src)
    units = [mut] + [f for f in sorted(glob.glob(os.path.join(REPO, 'src', '*.c'))) if not f.endswith('master_render.c')]
    units += [os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(REPO, 'gui', 'juno_pm.c')]
    so = os.path.join(tmp, 'libjuno_tooth.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off'] + (['-frounding-math', '-fsignaling-nans'] if flags
                                                                    else []) + ['-fno-strict-aliasing', '-shared', '-fPIC',
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
        json.dump(oracle_run(int(a[1]), int(a[2]), q['cells'], q['targets'], q.get('bits', NAN_BITS)), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], int(a[2]), int(a[3]), json.load(open(a[4]))), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    patch, seeds = int(opt('--patch', '5')), opt('--seeds', '1,2')
    ncell, frames = int(opt('--cells', '16')), int(opt('--frames', '512'))
    bits, multi, tflags = int(opt('--bits', hex(NAN_BITS)), 0), '--multi' in a, '--tooth-flags' in a
    tooth = '--tooth' in a or tflags
    tmp = tempfile.mkdtemp(prefix='junonan_')
    atexit.register(shutil.rmtree, tmp, True)
    if tooth:
        so = tooth_lib(tmp, flags=not tflags)
    else:
        import freshlib
        so = freshlib.check()
    o = subprocess.run([sys.executable, __file__, '--oracle', str(patch), seeds, str(ncell), str(frames)],
                       capture_output=True, text=True)
    if o.returncode:
        raise SystemExit('oracle failed: rc %d %s' % (o.returncode, o.stderr[-1500:]))
    r = json.loads(o.stdout)
    targets, r['targets'], r['bits'] = r['targets'], [], bits
    # the scenes: every target at once, each its own marked NaN
    r['scenes'] = [[[u, o, marked(i, kf(i))] for i, (u, o) in enumerate(targets)] for _, kf in SCENES] if multi else []
    for c in range(0, len(targets) if not multi else 1, CHUNK):
        tf = os.path.join(tmp, 'targets.json')
        json.dump({'cells': r['cells'], 'bits': bits, 'targets': targets[c:c + CHUNK] if not multi else r['scenes']},
                  open(tf, 'w'))
        oc = subprocess.run([sys.executable, __file__, '--oracle-run', str(patch), str(frames), tf], capture_output=True,
                            text=True)
        if oc.returncode:
            raise SystemExit('oracle failed (targets %d..): rc %d %s' % (c, oc.returncode, oc.stderr[-1500:]))
        if multi:
            r['scene_out'] = [x[2] for x in json.loads(oc.stdout)]
        else:
            r['targets'] += json.loads(oc.stdout)
    ref = os.path.join(tmp, 'ref.json')
    json.dump(r, open(ref, 'w'))
    p = subprocess.run([sys.executable, __file__, '--port', so, str(patch), str(frames), ref], capture_output=True,
                       text=True)
    if p.returncode:
        raise SystemExit('port failed: ' + p.stderr[-1500:])
    q = json.loads(p.stdout)
    print('patch %d at %g Hz: live float cells (moved or read) -- voice 0 %s, master %s; %d targets, %d frames each' % (
        patch, r['rate'], r['live']['0'], r['live']['8'], len(targets), frames))
    if r['control'] != q['control']:
        print('CONTROL (no NaN): DIFFERS -- the harness, not the NaN, would be graded: ABORT')
        return 2
    if not r['control'][1]:
        print('CONTROL (no NaN): the plugin\'s output is silent -- this run would grade nothing: ABORT')
        return 2
    print('CONTROL (no NaN): output and live cells equal (%d nonzero L samples)' % r['control'][1])
    if multi:
        bad = [nm for (nm, _), ro, po in zip(SCENES, r['scene_out'], q['scenes']) if ro != po]
        for (nm, _), ro, po in zip(SCENES, r['scene_out'], q['scenes']):
            print('  scene %-10s %d marked NaNs at once -- the plugin: %d NaN words in the output and live cells, %d '
                  'marked: %s' % (nm, len(targets), ro[3][0], ro[3][1], 'EQUAL' if ro == po else 'the %s differs' % (
                      'output' if ro[0] != po[0] else 'live cells')))
            if ro != po and ro[0] == po[0]:
                for (cu, co), x, y in [(c, x, y) for c, x, y in zip(r['cells'], ro[2], po[2]) if x != y][:12]:
                    print('    %s +%d: plugin 0x%08X, port 0x%08X' % ('master' if cu == 8 else 'voice 0', co, x, y))
        if not tooth and min(ro[3][1] for ro in r['scene_out']) == 0:
            print('nan_ab --multi: a scene\'s marks reach neither the output nor a live cell -- it grades no payload: '
                  'REFUSE')
            return 2
        if tooth:
            print('nan_ab --multi --tooth-flags: %s' % ('BITES (%d of %d scenes differ)' % (len(bad), len(SCENES)) if bad
                                                        else 'DID NOT BITE'))
            return 0 if bad else 1
        print('nan_ab --multi: %d live DSP cells, each its own marked NaN, in %d scenes: %s' % (
            len(targets), len(SCENES), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
        return 1 if bad else 0
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
    print('nan_ab: NaN 0x%08X in %d live DSP cells (voice 0 and the master), every output sample and live cell: %s' % (
        bits, len(r['targets']), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
