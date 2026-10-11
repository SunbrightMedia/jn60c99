#!/usr/bin/env python3
"""jx_nan_ab.py -- the JX-3P's NaN reachability (JX-26e; the JUNO-60's tools/verify/nan_ab.py, playbook 81).

x86 comiss / ucomiss set CF = ZF = PF = 1 on unordered: ja / jae are NOT taken on NaN, while C's <= / >= are
false -- the two agree on every ordered input and differ only on NaN, so no gate whose states stay NaN-free can
see a mistranscribed compare (the JX master emitted NaN where the plugin clamps: SCOPE_AUDIT, 2026-08-25). This
settles it by EXPERIMENT: a NaN put into one live DSP cell on BOTH sides, the render run, every output sample and
every unit's state compared.

ORACLE  (Unicorn: --oracle) tools/verify/jx_emu.py boot(44100, product=True, patch=K) -- the plugin's own boot and
        patch load --, a note-on 60 / 105, one 256-sample chunk; the cells that render MOVED (a float before and
        after: exponent field nonzero -- an index or a counter would make the injection an out-of-bounds read, not
        a NaN test) in the master's block and in voice 0's; per seed a sample of them; per target a fresh boot,
        the note, the NaN (0x7FC00000) written into the cell, 1024 samples in 256-sample chunks: L / R bits and
        every unit's window hashed (the full-chain gate's DSP mode: every unit, no gain stage). The cells: the
        ones the first chunk MOVED and the ones it READ without moving (parameters, coefficients: a compare's
        inputs are often these), each holding a float of a DSP's scale; plus the chorus clamp's inputs (FIXED).
PORT    (ctypes: --port) jx3p_init + jx3p_recall + jx3p_host_stage(0) on the 44.1 kHz guest image, the same note,
        the same NaN into the same cell (jx3p_vstate / jx3p_mstate), the same renders.
CONTROL first: no injection, everything equal -- else the harness, not the NaN, is being graded.

MARKED NaNs (2026-10-11; the JUNO's nan_ab.py): --bits writes another value than 0x7FC00000 (a payload no operation
makes; a signalling NaN, which every operation quiets). --multi writes every target AT ONCE, each its own marked NaN,
in three scenes (all quiet, all signalling, mixed; the sign alternating): where two different NaNs meet in an
operation, x86 returns the FIRST operand's -- so a scene shows whether the port's operand order is the plugin's.

    python3 jx3p/tools/jx_nan_ab.py [--patch 5] [--seeds 1,2] [--cells 16] [--bits 0x7fc00000]
    python3 jx3p/tools/jx_nan_ab.py --multi [--patch 5] [--seeds 1,2] [--cells 16]
    python3 jx3p/tools/jx_nan_ab.py --tooth   the master built with JX_NAN_TOOTH (the decompile's `<= 0` back at the
                                              chorus clamp, rva 0x39E341): at least one cell must differ
exit 0 = every injected cell equal (or, --tooth, the defect seen).
"""
import atexit
import ctypes
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
import jx_master_bisect as B  # noqa: E402  (SNAP_V, SNAP_M, CH, clean: the bisect's windows)

NAN = 0x7FC00000
CHUNK = 24                     # NaN runs per oracle process
SRCS = B.SRCS
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
from nan_ab import marked, SCENES, nanstats  # noqa: E402  (the JUNO gate's marked NaNs: one rule for both ports)


def floatish(u):
    """a 32-bit word that holds a float of a DSP's scale (|x| in [1e-20, 1e20]): an index, a counter, a flag or a
    pointer's half is none -- a NaN there would test an out-of-bounds read, not a compare"""
    x = struct.unpack('<f', struct.pack('<I', u))[0]
    return x == x and 1e-20 <= abs(x) <= 1e20


def live(before, after, reads):
    """float-aligned offsets the render MOVED (a float after it, a float or zero before) or READ without moving (a
    float: the parameters and coefficients -- a compare's inputs are often these: the chorus clamp's +270160)"""
    out = []
    for o in range(0, min(len(before), len(after)) - 3, 4):
        a, b = before[o:o + 4], after[o:o + 4]
        ua, ub = struct.unpack('<I', a)[0], struct.unpack('<I', b)[0]
        if a != b:
            if floatish(ub) and (ua == 0 or floatish(ua)):
                out.append(o)
        elif o in reads and floatish(ua):
            out.append(o)
    return out


# the chorus clamp's inputs (jx_master_render.c, asm 0x39E341: comiss; ja -- NaN takes the clamp): always targets,
# so the tooth (JX_NAN_TOOTH) has a cell that reaches it whatever the sample draws
FIXED = ((8, 270160), (8, 269872), (8, 269904), (8, 270000))


def oracle(patch, seeds, ncell):
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    import jx_emu as J

    def boot():
        jx = J.JX().boot(44100.0, snap=False, product=True, patch=patch)
        jx.note_on(60, 105)
        return jx

    def run(jx):
        res = []
        for _ in range(1024 // B.CH):
            L, R = jx.render(B.CH, B.CH)
            res.append(hashlib.sha256(struct.pack('<%dI' % (2 * B.CH), *(L + R))).hexdigest()[:16])
        res.append([hashlib.sha256(B.clean(bytes(jx.uc.mem_read(jx.state[u], B.SNAP_V if u < 8 else B.SNAP_M))))
                    .hexdigest()[:16] for u in range(9)])
        return res
    from unicorn import UC_HOOK_MEM_READ
    jx = boot()
    win = {8: B.STATE_END, 0: B.SNAP_V}
    before = {u: bytes(jx.uc.mem_read(jx.state[u], win[u])) for u in win}
    reads = {u: set() for u in win}

    def hk(uc, access, addr, size, value, user):
        for u in win:
            o = addr - jx.state[u]
            if 0 <= o < win[u]:
                reads[u].add(o & ~3)
    h = jx.uc.hook_add(UC_HOOK_MEM_READ, hk, begin=min(jx.state[u] for u in win),
                       end=max(jx.state[u] + win[u] for u in win))
    jx.render(B.CH, B.CH)
    jx.uc.hook_del(h)
    moved = {u: live(before[u], bytes(jx.uc.mem_read(jx.state[u], win[u])), reads[u]) for u in win}
    targets = list(FIXED)
    for sd in seeds:
        r = random.Random(7741 * sd + patch)
        for u in (8, 0):
            pool = [o for o in moved[u] if (u, o) not in FIXED]
            targets += [(u, o) for o in sorted(r.sample(pool, min(ncell, len(pool))))]
    return {'moved': {str(u): len(moved[u]) for u in moved}, 'control': run(boot()), 'targets': targets}


def oracle_run(patch, targets, bits=NAN):
    """the NaN runs of one chunk of targets (its own process: hundreds of boots in one process exhaust memory); a
    target is (unit, offset) -- the NaN `bits` -- or a scene: a list of (unit, offset, bits), all written at once"""
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    import jx_emu as J
    out = []
    for t in targets:
        jx = J.JX().boot(44100.0, snap=False, product=True, patch=patch)
        jx.note_on(60, 105)
        scene = isinstance(t[0], list)
        for u, o, b in t if scene else [(t[0], t[1], bits)]:
            jx.uc.mem_write(jx.state[u] + o, struct.pack('<I', b))
        res, words = [], []
        for _ in range(1024 // B.CH):
            L, R = jx.render(B.CH, B.CH)
            res.append(hashlib.sha256(struct.pack('<%dI' % (2 * B.CH), *(L + R))).hexdigest()[:16])
            words += list(L) + list(R)
        res.append([hashlib.sha256(B.clean(bytes(jx.uc.mem_read(jx.state[w], B.SNAP_V if w < 8 else B.SNAP_M))))
                    .hexdigest()[:16] for w in range(9)])
        if scene:                  # the reach: the NaN words in the output and the targets' cells after the render
            res.append(nanstats(words + [struct.unpack('<I', jx.uc.mem_read(jx.state[u] + o, 4))[0] for u, o, _ in t]))
        out.append([-1, -1, res] if scene else [t[0], t[1], res])
        del jx
    return out


def port(so, patch, ref):
    lib = ctypes.CDLL(so)
    lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
    for f in ('jx3p_vstate', 'jx3p_mstate'):
        getattr(lib, f).restype = ctypes.c_void_p
    sys.path.insert(0, HERE)
    import jx_guest

    def boot():
        if not lib.jx3p_init(jx_guest.path(44).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             None):
            raise SystemExit('jx3p_init failed')
        lib.jx3p_recall(patch)
        lib.jx3p_host_stage(0)
        lib.jx3p_note_on(60, 105)

    def base(u):
        return lib.jx3p_vstate(u) if u < 8 else lib.jx3p_mstate()

    def run(scene=None):
        res, words = [], []
        Lb = (ctypes.c_float * B.CH)(); Rb = (ctypes.c_float * B.CH)()
        for _ in range(1024 // B.CH):
            lib.jx3p_render(Lb, Rb, B.CH)
            res.append(hashlib.sha256(bytes(Lb) + bytes(Rb)).hexdigest()[:16])
            words += list(struct.unpack('<%dI' % B.CH, bytes(Lb))) + list(struct.unpack('<%dI' % B.CH, bytes(Rb)))
        res.append([hashlib.sha256(B.clean(ctypes.string_at(base(u), B.SNAP_V if u < 8 else B.SNAP_M))).hexdigest()[:16]
                    for u in range(9)])
        if scene is not None:
            res.append(nanstats(words + [struct.unpack('<I', ctypes.string_at(base(u) + o, 4))[0] for u, o, _ in scene]))
        return res
    boot()
    out = {'control': run(), 'targets': [], 'scenes': []}
    bits = ref.get('bits', NAN)
    for u, o, _ in ref['targets']:
        boot()
        ctypes.memmove(base(u) + o, struct.pack('<I', bits), 4)
        out['targets'].append(run())
    for sc in ref.get('scenes', []):
        boot()
        for u, o, b in sc:
            ctypes.memmove(base(u) + o, struct.pack('<I', b), 4)
        out['scenes'].append(run(sc))
    return out


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(int(a[1]), [int(x) for x in a[2].split(',')], int(a[3])), sys.stdout)
        return 0
    if a[:1] == ['--oracle-run']:
        q = json.load(open(a[2]))
        json.dump(oracle_run(int(a[1]), q['targets'], q.get('bits', NAN)), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], int(a[2]), json.load(open(a[3]))), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    patch, seeds, ncell = int(opt('--patch', '5')), opt('--seeds', '1,2'), int(opt('--cells', '16'))
    bits, multi = int(opt('--bits', hex(NAN)), 0), '--multi' in a
    tooth = '--tooth' in a
    tmp = tempfile.mkdtemp(prefix='jxnan_')
    atexit.register(shutil.rmtree, tmp, True)
    so = os.path.join(tmp, 'libjx.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   (['-DJX_NAN_TOOTH=1'] if tooth else []) + [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    o = subprocess.run([sys.executable, __file__, '--oracle', str(patch), seeds, str(ncell)], capture_output=True,
                       text=True)
    if o.returncode:
        raise SystemExit('oracle failed: rc %d %s' % (o.returncode, o.stderr[-1500:]))
    r = json.loads(o.stdout)
    targets, r['targets'], r['bits'] = r['targets'], [], bits
    r['scenes'] = [[[u, o, marked(i, kf(i))] for i, (u, o) in enumerate(targets)] for _, kf in SCENES] if multi else []
    for c in range(0, len(targets) if not multi else 1, CHUNK):
        tf = os.path.join(tmp, 'targets.json')
        json.dump({'bits': bits, 'targets': targets[c:c + CHUNK] if not multi else r['scenes']}, open(tf, 'w'))
        oc = subprocess.run([sys.executable, __file__, '--oracle-run', str(patch), tf], capture_output=True, text=True)
        if oc.returncode:
            raise SystemExit('oracle failed (targets %d..): rc %d %s' % (c, oc.returncode, oc.stderr[-1500:]))
        if multi:
            r['scene_out'] = [x[2] for x in json.loads(oc.stdout)]
        else:
            r['targets'] += json.loads(oc.stdout)
    ref = os.path.join(tmp, 'ref.json')
    json.dump(r, open(ref, 'w'))
    p = subprocess.run([sys.executable, __file__, '--port', so, str(patch), ref], capture_output=True, text=True)
    if p.returncode:
        raise SystemExit('port failed: ' + p.stderr[-1500:])
    q = json.loads(p.stdout)
    print('patch %d: live float cells (moved or read) -- master %s, voice 0 %s; %d targets' % (
        patch, r['moved']['8'], r['moved']['0'], len(targets)))
    if r['control'] != q['control']:
        print('CONTROL (no NaN): DIFFERS -- the harness, not the NaN, would be graded: ABORT')
        return 2
    print('CONTROL (no NaN): every chunk and every unit equal')
    if multi:
        bad = [nm for (nm, _), ro, po in zip(SCENES, r['scene_out'], q['scenes']) if ro != po]
        for (nm, _), ro, po in zip(SCENES, r['scene_out'], q['scenes']):
            print('  scene %-10s %d marked NaNs at once -- the plugin: %d NaN words in the output and the cells, %d '
                  'marked: %s' % (nm, len(targets), ro[-1][0], ro[-1][1], 'EQUAL' if ro == po else 'the %s differs' % (
                      'output' if ro[:-2] != po[:-2] else 'state')))
        if min(ro[-1][1] for ro in r['scene_out']) == 0:
            print('jx_nan_ab --multi: a scene\'s marks reach neither the output nor a target cell -- it grades no '
                  'payload: REFUSE')
            return 2
        print('jx_nan_ab --multi: %d live DSP cells, each its own marked NaN, in %d scenes: %s' % (
            len(targets), len(SCENES), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
        return 1 if bad else 0
    bad = []
    for (u, off, ro), po in zip(r['targets'], q['targets']):
        if ro != po:
            bad.append((u, off))
            what = 'output' if ro[:-1] != po[:-1] else 'state'
            print('  NaN in %s +0x%x: the %s differs' % ('master' if u == 8 else 'voice %d' % u, off, what))
    if tooth:
        print('jx_nan_ab --tooth: %s' % ('BITES (%d of %d cells differ)' % (len(bad), len(r['targets'])) if bad else
                                         'DID NOT BITE'))
        return 0 if bad else 1
    print('jx_nan_ab: NaN 0x%08X in %d live DSP cells (master and voice 0), every output sample and unit state: %s' % (
        bits, len(r['targets']), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
