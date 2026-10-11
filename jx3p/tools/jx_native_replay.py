#!/usr/bin/env python3
"""jx_native_replay.py -- the JX-3P's oracle graded by the real CPU (the JUNO-60's tools/verify/native_replay.py).

The JX plugin's own voice and master render, run NATIVELY on this CPU (tools/verify/native_replay.c, asg = 0: the
loop of tools/verify/jx_emu.py JX.render) from the state the Unicorn oracle prepared (the plugin's product boot at
44.1 kHz, its own patch load, a note-on 60 / 105, optional NaNs), against Unicorn itself and against the port
(jx_bridge: jx3p_init + jx3p_recall + jx3p_host_stage(0), the same note and NaNs -- jx_nan_ab.py's scene):
  UNICORN vs CPU-DAZ (MXCSR 0x1FC0)  the model against the machine in the model's own mode: every output sample and
                                      every unit's window (jx_master_bisect.clean, the bisect's rule)
  PORT oracle mode vs CPU-DAZ         jx_set_fp_oracle_mode(1): DAZ on, FTZ off -- the gates' mode
  PORT product mode vs CPU-FTZ        jx_enable_hw_ftz(): FTZ + DAZ -- the plugin in a host (MXCSR 0x9FC0)
    python3 jx3p/tools/jx_native_replay.py [--patch 5] [--frames 4096]         one scene, no NaN
    python3 jx3p/tools/jx_native_replay.py --sweep [--seeds 1,2] [--cells 16] [--all] [--tooth]
        every jx_nan_ab.py target alone (--all: every live float cell), three NaNs each (0x7FC00000, a marked quiet
        one, a marked signalling one); the scenes that change nothing are counted (the reach) -- most JX cells are
        rewritten before they are read, so few scenes reach; fewer than 4 refuses. --tooth: the port built with
        JX_NAN_TOOTH (jx_nan_ab.py's tooth) -- a scene must differ
exit 0 = every comparison holds (or, --tooth, the defect seen); 1 = one fails; 2 = the harness failed.
"""
import ctypes
import hashlib
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_master_bisect as B  # noqa: E402  (SNAP_V, SNAP_M, CH, clean, SRCS)

LOWPAGE = 0x10000
NATIVE_C = os.path.join(REPO, 'tools', 'verify', 'native_replay.c')


def win(u):
    return B.SNAP_V if u < 8 else B.SNAP_M


def oracle_snap(d, patch, frames, inject):
    import jx_emu as J
    jx = J.JX().boot(44100.0, snap=False, product=True, patch=patch)
    jx.note_on(60, 105)
    for u, o, b in inject:
        jx.uc.mem_write(jx.state[u] + o, struct.pack('<I', b))
    regions = [(LOWPAGE, 0x100000 - LOWPAGE), (J.IB, J.IMGSZ), (J.HEAP_BASE, (jx.heap - J.HEAP_BASE + 0xFFF) & ~0xFFF),
               (J.STUB_BASE, 0x100000), (J.BUF_BASE, J.BUF_SIZE)]
    for a, n in regions:
        open(os.path.join(d, 'region_%x.bin' % a), 'wb').write(bytes(jx.uc.mem_read(a, n)))
    meta = dict(asg=0, block=B.CH, BUF_BASE=J.BUF_BASE, PB_VOICE=J.PB_VOICE, PB_MASTER=J.PB_MASTER, SVOICE=jx.SVOICE,
                SMASTER=jx.SMASTER)
    for i in range(9):
        meta['state%d' % i] = jx.state[i]
        meta['win%d' % i] = jx.state[i]
        meta['wsz%d' % i] = win(i)
    open(os.path.join(d, 'meta.txt'), 'w').write(''.join('%s = %x\n' % kv for kv in meta.items()))
    if getattr(jx, '_mxcsr', None) != 0x9FC0:
        raise SystemExit('REFUSE: the oracle is not in its mode (MXCSR 0x9FC0)')
    with open(os.path.join(d, 'unicorn.bin'), 'wb') as f:
        L, R = [], []
        for _ in range(frames // B.CH):
            l, r = jx.render(B.CH, B.CH)
            L += l
            R += r
        for x, y in zip(L, R):
            f.write(struct.pack('<II', x, y))
        for i in range(9):
            f.write(bytes(jx.uc.mem_read(jx.state[i], win(i))))


def port_runs(d, patch, frames, scenes, mode, so):
    """the port in its own process: per scene a fresh instance, its NaNs, the render; the output words and the
    cleaned windows' hashes"""
    lib = ctypes.CDLL(so)
    for f in ('jx3p_vstate', 'jx3p_mstate'):
        getattr(lib, f).restype = ctypes.c_void_p
    import jx_guest
    out = []
    for sc in scenes:
        if mode == 'oracle':
            lib.jx_set_fp_oracle_mode(1)
        else:
            lib.jx_enable_hw_ftz()
        if not lib.jx3p_init(jx_guest.path(44).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             None):
            raise SystemExit('jx3p_init failed')
        lib.jx3p_recall(patch)
        lib.jx3p_host_stage(0)
        lib.jx3p_note_on(60, 105)
        base = lambda u: lib.jx3p_vstate(u) if u < 8 else lib.jx3p_mstate()
        for u, o, b in sc:
            ctypes.memmove(base(u) + o, struct.pack('<I', b), 4)
        Lb = (ctypes.c_float * B.CH)()
        Rb = (ctypes.c_float * B.CH)()
        words = []
        for _ in range(frames // B.CH):
            lib.jx3p_render(Lb, Rb, B.CH)
            lw = struct.unpack('<%dI' % B.CH, bytes(Lb))
            rw = struct.unpack('<%dI' % B.CH, bytes(Rb))
            for x, y in zip(lw, rw):
                words += [x, y]
        hs = [hashlib.sha256(B.clean(ctypes.string_at(base(u), win(u)))).hexdigest()[:16] for u in range(9)]
        out.append([words, hs])
    json.dump(out, open(os.path.join(d, 'port_%s.json' % mode), 'w'))


def native(exe, d, frames, mx, scenes):
    """every scene in ONE native process (--batch: each from the snapshot as written), streamed: per scene the
    output words and the nine cleaned windows' hashes"""
    bf = os.path.join(d, 'batch.txt')
    open(bf, 'w').write(''.join(' '.join('%d@%d:%d' % (u, o, b) for u, o, b in sc) + '\n' for sc in scenes))
    p = subprocess.Popen(['bash', '-c', 'ulimit -s unlimited; exec "$@"', '_', exe, d, str(frames), mx, '/dev/stdout',
                          '-', '--batch', bf], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    res = []

    def take(n):
        b = p.stdout.read(n)
        if len(b) != n:
            raise SystemExit('native run ended early: %s' % p.stderr.read()[-600:].decode(errors='replace'))
        return b
    for _ in scenes:
        no = 8 * frames
        words = list(struct.unpack('<%dI' % (no // 4), take(no)))
        hs = [hashlib.sha256(B.clean(take(win(u)))).hexdigest()[:16] for u in range(9)]
        res.append((words, hs))
    if p.wait():
        raise SystemExit('native run failed (rc %d): %s' % (p.returncode, p.stderr.read()[-600:]))
    return res


def build_port(d, tooth):
    so = os.path.join(d, 'libjx.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans',
                    '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] + (['-DJX_NAN_TOOTH=1'] if tooth else [])
                   + [os.path.join(REPO, s) for s in B.SRCS] + ['-lm'], check=True)
    return so


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle-snap']:
        oracle_snap(a[1], int(a[2]), int(a[3]), json.loads(a[4]))
        return 0
    if a[:1] == ['--port']:
        port_runs(a[1], int(a[2]), int(a[3]), json.load(open(a[4])), a[5], a[6])
        return 0
    opt = lambda k, dflt: a[a.index(k) + 1] if k in a else dflt
    patch, sweep, tooth = int(opt('--patch', '5')), '--sweep' in a, '--tooth' in a
    frames = int(opt('--frames', '1024' if sweep else '4096'))
    frames -= frames % B.CH
    d = opt('--keep', None) or tempfile.mkdtemp(prefix='jxnat_')
    os.makedirs(d, exist_ok=True)
    rr = subprocess.run([sys.executable, __file__, '--oracle-snap', d, str(patch), str(frames), '[]'],
                        capture_output=True, text=True)
    if rr.returncode:
        print('oracle failed: %s' % rr.stderr[-1500:])
        return 2
    exe = os.path.join(d, 'native_replay')
    subprocess.run(['cc', '-O2', '-o', exe, NATIVE_C], check=True)
    so = build_port(d, tooth)
    if sweep and '--targets' in a:     # chosen cells, unit:offset[,unit:offset..] -- a site's own inputs
        import jx_nan_ab as NA
        scenes = []
        for i, t in enumerate(opt('--targets', '').split(',')):
            u, o = (int(x, 0) for x in t.split(':'))
            for b in (NA.NAN, NA.marked(i, 'q'), NA.marked(i, 's')):
                scenes.append([[u, o, b]])
    elif sweep:
        seeds, ncell = (opt('--seeds', '1,2'), opt('--cells', '16')) if '--all' not in a else ('1', '1000000')
        r = json.loads(subprocess.run([sys.executable, os.path.join(HERE, 'jx_nan_ab.py'), '--oracle', str(patch),
                                       seeds, ncell], capture_output=True, text=True, check=True).stdout)
        import jx_nan_ab as NA
        scenes = []
        for i, (u, o) in enumerate(r['targets']):
            for b in (NA.NAN, NA.marked(i, 'q'), NA.marked(i, 's')):
                scenes.append([[u, o, b]])
    else:
        scenes = [[]]
    sf = os.path.join(d, 'scenes.json')
    json.dump(scenes, open(sf, 'w'))
    bad = 0
    if not sweep:                       # the model against the machine, the scene with no NaN
        U = open(os.path.join(d, 'unicorn.bin'), 'rb').read()
        no = 8 * frames
        uw = list(struct.unpack('<%dI' % (no // 4), U[:no]))
        uh, p = [], no
        for u in range(9):
            uh.append(hashlib.sha256(B.clean(U[p:p + win(u)])).hexdigest()[:16])
            p += win(u)
        for name, mx in (('CPU-DAZ', '0x1FC0'), ('CPU-FTZ', '0x9FC0')):
            cw, ch = native(exe, d, frames, mx, [[]])[0]
            units = [u for u in range(9) if ch[u] != uh[u]]
            nd = sum(1 for x, y in zip(cw, uw) if x != y)
            print('  UNICORN vs %s: output %s, unit windows differing: %s' % (
                name, 'EQUAL' if not nd else '%d words differ' % nd, units or 'none'))
            if name == 'CPU-DAZ' and (nd or units):
                bad = 1
    reach = {}
    for mode, mx in (('oracle', '0x1FC0'), ('product', '0x9FC0')):
        pr = subprocess.run([sys.executable, __file__, '--port', d, str(patch), str(frames), sf, mode, so],
                            capture_output=True, text=True)
        if pr.returncode:
            print('port failed: %s' % pr.stderr[-800:])
            return 2
        P = json.load(open(os.path.join(d, 'port_%s.json' % mode)))
        C = native(exe, d, frames, mx, [[]] + scenes)          # scene 0: no NaN (the reach control)
        ctl = C[0]
        diff = []
        reach[mode] = 0
        for k, sc in enumerate(scenes):
            cw, ch = C[k + 1]
            reach[mode] += (cw, ch) != ctl
            if cw != P[k][0] or ch != P[k][1]:
                diff.append((sc, 'output' if cw != P[k][0] else 'units %s' % [u for u in range(9)
                                                                             if ch[u] != P[k][1][u]]))
        print('  PORT (%s mode) vs the CPU (MXCSR %s): %d scene%s, %d frames%s: %s' % (
            mode, mx, len(scenes), 's' if len(scenes) > 1 else '', frames,
            ' (%d change the output or a window)' % reach[mode] if sweep else '',
            'EQUAL' if not diff else '%d DIFFER' % len(diff)))
        for sc, what in diff[:10]:
            print('    %s: the %s differs' % (', '.join('unit %d +0x%x NaN %08X' % (u, o, b) for u, o, b in sc) or
                                            'no NaN', what))
        bad |= bool(diff)
    if '--keep' not in a:
        shutil.rmtree(d, ignore_errors=True)
    if tooth:
        print('jx_native_replay --tooth: %s' % ('BITES' if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    if sweep and min(reach.values()) < 4:
        print('jx_native_replay --sweep: fewer than 4 scenes reach the output or a window -- REFUSE')
        return 2
    print('jx_native_replay%s: %s' % (' --sweep' if sweep else '', 'every comparison holds' if not bad else
                                      'A COMPARISON FAILS'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
