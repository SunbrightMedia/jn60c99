#!/usr/bin/env python3
"""jx_master_bisect.py -- where does the C master first leave the plugin's? (two processes: Unicorn, ctypes)

Both sides boot patch k on the plugin's own records (jx_emu.boot(product=True) / jx3p_init + jx3p_recall),
render the DSP mode of the full-chain gate (the per-unit renders: every unit, no gain stage; idle 4,096,
a note-on 60/100, then N samples) in 256-sample chunks, and record after every chunk the sha256 of each
unit's compared window (voices [0, 0x60000), the master [0, 0xAAD000); the object pointer at +136 and
the ramp id list's end pointer at +0x78 excluded; the master's window ends at its block's end,
0xAAC310: past it lie the plugin's next heap objects -- its parameter object among them --, which the
port keeps apart), the 36 control objects (note managers, note stores, assigners, parameter objects:
compared directly, as jx_recall_data_gate.py does) and the chunk's L/R bits. The first chunk that differs
is then rendered again sample by sample on both sides, and the master words that differ after its first
differing sample are listed with their values.

    python3 jx3p/tools/jx_master_bisect.py [patch=0] [N=12000]
    python3 jx3p/tools/jx_master_bisect.py [--tooth] --variants '34:67=3;0:65=5' [N=12000]
    python3 jx3p/tools/jx_master_bisect.py --gate [N=12000]     (64 patches + VARIANTS + the tooth; ~30 min)
  --variants: patches the factory bank does not hold -- a factory patch's own patch-load records with
  values changed (jx_master_recall_export.variant_records), loaded by the plugin through its host
  entry; the port gets their aux from the same exporter (--variants --out). The master's two mode
  cells (records 67 and 65) select paths no factory patch reaches.
  --tooth: the port built with JX_MASTER_TOOTH (the four effect-LFO sites' argument 0.0, the defect
  fixed 2026-10-10) -- every variant that reaches a site must differ.
"""
import ctypes
import hashlib
import json
import os
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SNAP_V, SNAP_M, CH, IDLE = 0x60000, 0xAAD000, 256, 4096
# each voice's high window: its ramp targets (SCOPE_AUDIT row 2) -- [0xA60000, 0xAAC320): the unit's
# parameter object starts at state + 0xAAC320 (EXECUTED: proc - state = 0xAAC320 for all nine units), and
# the port keeps it as its own blob (compared as proc0..8); the window's tail over it is a copy the port
# never updates (the note-on's dispatch writes proc +0x460 / +0x480 / +0x660: seen as the only differing
# words of the first run with the full [0xA60000, 0xAAD000))
HI_LO, HI_SZ = 0xA60000, 0xAAC320 - 0xA60000
# the mode values no factory patch holds (record 67 -> the master's +0xAAC1E8: the factory bank has 0, 1, 2,
# 5; record 65 -> +0xAAC1E4: 0, 2), and two crossed; the plugin's host entry accepts 0..5
VARIANTS = '34:67=3;34:67=4;0:67=4;0:65=1;0:65=3;0:65=4;0:65=5;34:67=4,65=5;40:65=3'
TOOTH_VARIANTS = '34:67=3;34:67=4;0:65=5'          # one per effect-LFO site group the tooth reverts
STATE_END = 0xAAC310       # a unit's state block; the master's parameter object follows it in the plugin's heap
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']


def clean(b):
    """the words the port keeps elsewhere: the object pointer (+136) and the ramp id list's end pointer
    (+0x78). (The start-mute count +0xAAC308 was masked here until 2026-10-10: the port now writes its
    count back to the word -- jx_bridge.c JX_LATCH_STORE -- and it is compared like every other word.)"""
    b = bytearray(b)
    b[136:144] = bytes(8)
    b[0x78:0x80] = bytes(8)
    if len(b) > STATE_END:          # past the master's own block: the plugin's next heap objects
        b[STATE_END:] = bytes(len(b) - STATE_END)
    return bytes(b)


def schedule(n):
    """(note_before, samples) per render call: the idle in chunks, then the note, then n"""
    out = [(False, min(CH, IDLE - o)) for o in range(0, IDLE, CH)]
    first = True
    for o in range(0, n, CH):
        out.append((first, min(CH, n - o)))
        first = False
    return out


def oracle(k, n, fine=None, stop=None):
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    sys.path.insert(0, HERE)
    import jx_emu as J
    import jx_template_export as T
    if os.environ.get('JX_BISECT_VARIANT'):              # a variant patch (--variants)
        import jx_master_recall_export as X
        jx = J.JX().boot(44100.0, snap=False, product=True)
        jx.host_records(X.variant_records(os.environ['JX_BISECT_VARIANT']))
    else:
        jx = J.JX().boot(44100.0, snap=False, product=True, patch=k)
    uc = jx.uc
    res = []
    for i, (note, m) in enumerate(schedule(n)):
        if note:
            jx.note_on(60, 100)
        if fine == i:                                    # sample by sample, the master after each
            out = []
            for s in range(m if stop is None else stop + 1):
                if s == stop:
                    open(os.environ['JX_BISECT_DUMP'] + '.oracle.pre', 'wb').write(clean(bytes(uc.mem_read(jx.state[8], SNAP_M))))
                L, R = jx.render(1, 1)
                out.append((L[0], R[0], hashlib.sha256(clean(bytes(uc.mem_read(jx.state[8], SNAP_M)))).hexdigest()))
            json.dump({'fine': out, 'master': clean(bytes(uc.mem_read(jx.state[8], SNAP_M))).hex()[:0]}, sys.stdout)
            open(os.environ['JX_BISECT_DUMP'] + '.oracle', 'wb').write(clean(bytes(uc.mem_read(jx.state[8], SNAP_M))))
            return None
        L, R = jx.render(m, CH)
        res.append([hashlib.sha256(clean(bytes(uc.mem_read(jx.state[u], SNAP_V if u < 8 else SNAP_M)))).hexdigest()[:16]
                    for u in range(9)] + [hashlib.sha256(struct.pack('<%dI' % (2 * m), *(L + R))).hexdigest()[:16]] +
                   [hashlib.sha256(b).hexdigest()[:16] for b in T.control_blobs(jx)] +
                   [hashlib.sha256(bytes(uc.mem_read(jx.state[u] + HI_LO, HI_SZ))).hexdigest()[:16] for u in range(8)])
    return res


def port(so, k, n, fine=None, stop=None):
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    for f in ('jx3p_vstate', 'jx3p_mstate', 'jx3p_ctl', 'jx3p_vhigh'):
        getattr(lib, f).restype = ctypes.c_void_p
    g = lambda p: os.path.join(REPO, 'jx3p', p).encode()
    aux = os.environ.get('JX_BISECT_AUX', '').encode() or g('gen/jx_master_recall.bin')
    if not lib.jx3p_init(g('gen/jx_template.bin'), g('truth/preset_bank_1.bin'), aux):
        raise SystemExit('jx3p_init failed')
    lib.jx3p_recall(k)
    lib.jx3p_host_stage(0)
    res = []
    for i, (note, m) in enumerate(schedule(n)):
        if note:
            lib.jx3p_note_on(60, 100)
        Lb = (ctypes.c_float * m)(); Rb = (ctypes.c_float * m)()
        if fine == i:
            out = []
            for s in range(m if stop is None else stop + 1):
                if s == stop:
                    open(os.environ['JX_BISECT_DUMP'] + '.port.pre', 'wb').write(clean(ctypes.string_at(lib.jx3p_mstate(), SNAP_M)))
                lib.jx3p_render(ctypes.byref(Lb, 4 * s), ctypes.byref(Rb, 4 * s), 1)
                L = struct.unpack('<I', struct.pack('<f', Lb[s]))[0]; R = struct.unpack('<I', struct.pack('<f', Rb[s]))[0]
                out.append((L, R, hashlib.sha256(clean(ctypes.string_at(lib.jx3p_mstate(), SNAP_M))).hexdigest()))
            json.dump({'fine': out}, sys.stdout)
            open(os.environ['JX_BISECT_DUMP'] + '.port', 'wb').write(clean(ctypes.string_at(lib.jx3p_mstate(), SNAP_M)))
            return None
        lib.jx3p_render(Lb, Rb, m)
        bits = list(struct.unpack('<%dI' % m, bytes(Lb))) + list(struct.unpack('<%dI' % m, bytes(Rb)))
        sizes = (0x7A8, 0xFF0, 0xB0)
        ctl = [ctypes.string_at(lib.jx3p_ctl(w, i), sizes[w]) for i in range(9) for w in range(3)]
        ctl += [ctypes.string_at(lib.jx3p_ctl(3, i), 0x700) for i in range(9)]
        res.append([hashlib.sha256(clean(ctypes.string_at(lib.jx3p_vstate(u), SNAP_V) if u < 8 else
                                         ctypes.string_at(lib.jx3p_mstate(), SNAP_M))).hexdigest()[:16]
                    for u in range(9)] + [hashlib.sha256(struct.pack('<%dI' % (2 * m), *bits)).hexdigest()[:16]] +
                   [hashlib.sha256(b).hexdigest()[:16] for b in ctl] +
                   [hashlib.sha256(ctypes.string_at(lib.jx3p_vhigh(u), HI_SZ)).hexdigest()[:16] for u in range(8)])
    return res


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        r = oracle(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else None, int(a[4]) if len(a) > 4 else None)
        if r is not None:
            json.dump(r, sys.stdout)
        return 0
    if a[:1] == ['--port']:
        r = port(a[1], int(a[2]), int(a[3]), int(a[4]) if len(a) > 4 else None, int(a[5]) if len(a) > 5 else None)
        if r is not None:
            json.dump(r, sys.stdout)
        return 0
    if a[:1] == ['--gate']:                              # the gate jx_verify.sh runs
        n = a[1] if len(a) > 1 else '12000'
        run = lambda *x: subprocess.run([sys.executable, __file__] + list(x), capture_output=True, text=True)
        bad = []
        for k in range(64):
            r = run(str(k), n)
            print(r.stdout.strip().splitlines()[0] if r.stdout.strip() else 'patch %d: NO OUTPUT %s' % (k, r.stderr[-300:]),
                  flush=True)
            if r.returncode:
                bad.append(str(k))
        r = run('--variants', VARIANTS, n)
        print('\n'.join(l for l in r.stdout.splitlines() if l.startswith('variant')), flush=True)
        if r.returncode:
            bad.append('variants')
        t = run('--tooth', '--variants', TOOTH_VARIANTS, '3000')
        bites = t.stdout.count('first differing chunk') == len(TOOTH_VARIANTS.split(';'))
        print('tooth (the effect-LFO argument lost again, on %s): %s' % (TOOTH_VARIANTS, 'BITES' if bites else
                                                                          'DID NOT BITE\n' + t.stdout[-800:]))
        print('jx_master_bisect --gate: 64 factory patches + %d variants, every chunk of every unit, the control '
              'objects and L/R equal to the plugin\'s: %s' % (len(VARIANTS.split(';')),
                                                            'GREEN' if not bad and bites else 'RED (%s)' % ' '.join(bad)))
        return 0 if not bad and bites else 1
    if a[:1] == ['--tooth']:                             # the effect-LFO argument lost again: must be seen
        os.environ['JX_BISECT_TOOTH'] = '1'
        a = a[1:]
        print('TOOTH BUILD: the four effect-LFO sites get the decompile\'s lost argument (0.0) back')
    if a[:1] == ['--variants']:
        specs = a[1].split(';')
        n = a[2] if len(a) > 2 else '12000'
        tmp = tempfile.mkdtemp()
        aux = os.path.join(tmp, 'variants.bin')
        subprocess.run([sys.executable, os.path.join(HERE, 'jx_master_recall_export.py'), '--variants', a[1],
                        '--out', aux], check=True)
        bad = 0
        for i, sp in enumerate(specs):
            env = dict(os.environ, JX_BISECT_VARIANT=sp, JX_BISECT_AUX=aux)
            r = subprocess.run([sys.executable, __file__, str(i), n], env=env, capture_output=True, text=True)
            print(('variant %s: ' % sp) + r.stdout.strip().replace('patch %d: ' % i, '', 1), flush=True)
            if r.returncode:
                bad += 1
                if r.stderr.strip():
                    print(r.stderr[-1500:])
        print('variants: %d of %d differ' % (bad, len(specs)))
        return 1 if bad else 0
    k = int(a[0]) if a else 0
    n = int(a[1]) if len(a) > 1 else 12000
    tmp = tempfile.mkdtemp()
    so = os.path.join(tmp, 'libjx3p.so')
    tooth = ['-DJX_MASTER_TOOTH=1'] if os.environ.get('JX_BISECT_TOOTH') == '1' else []
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] + tooth +
                   [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    run = lambda *x: json.loads(subprocess.run([sys.executable, __file__] + [str(y) for y in x],
                                               capture_output=True, text=True, check=True).stdout)
    o, p = run('--oracle', k, n), run('--port', so, k, n)
    sched = schedule(n)
    first = next((i for i in range(len(o)) if o[i] != p[i]), None)
    if first is None:
        print('patch %d: every chunk equal (%d chunks)' % (k, len(o)))
        return 0
    start = sum(m for _, m in sched[:first])
    names = ['v%d' % u for u in range(8)] + ['master', 'L/R'] + \
        ['%s%d' % (w, i) for i in range(9) for w in ('mgr', 'ns', 'asg')] + ['proc%d' % i for i in range(9)] + \
        ['vhigh%d' % u for u in range(8)]
    print('patch %d: first differing chunk %d (samples %d..%d, %s after the note): %s' % (
        k, first, start, start + sched[first][1] - 1, start - IDLE,
        ' '.join(nm for nm, x, y in zip(names, o[first], p[first]) if x != y)))
    env = dict(os.environ, JX_BISECT_DUMP=os.path.join(tmp, 'm'))
    fo = json.loads(subprocess.run([sys.executable, __file__, '--oracle', str(k), str(n), str(first)], env=env,
                                   capture_output=True, text=True, check=True).stdout)['fine']
    fp = json.loads(subprocess.run([sys.executable, __file__, '--port', so, str(k), str(n), str(first)], env=env,
                                   capture_output=True, text=True, check=True).stdout)['fine']
    s1 = next((s for s in range(len(fo)) if fo[s] != fp[s]), None)
    print('  sample by sample: first difference at sample %s of the chunk (%s): output %s, master state %s' % (
        s1, start + s1 if s1 is not None else '-', 'differs' if s1 is not None and fo[s1][:2] != fp[s1][:2] else 'equal',
        'differs' if s1 is not None and fo[s1][2] != fp[s1][2] else 'equal'))
    # the master words that differ at the end of the chunk
    mo = open(os.path.join(tmp, 'm.oracle'), 'rb').read()
    mp = open(os.path.join(tmp, 'm.port'), 'rb').read()
    diff = [i for i in range(0, len(mo), 4) if mo[i:i + 4] != mp[i:i + 4]]
    print('  master words different at the chunk\'s end: %d; first: %s' % (len(diff), ' '.join(
        '+0x%x(o %08x p %08x)' % (i, struct.unpack_from('<I', mo, i)[0], struct.unpack_from('<I', mp, i)[0]) for i in diff[:8])))
    if s1 is not None:                                   # the words that first sample wrote differently
        for side, args in (('oracle', ['--oracle', str(k), str(n), str(first), str(s1)]),
                           ('port', ['--port', so, str(k), str(n), str(first), str(s1)])):
            subprocess.run([sys.executable, __file__] + args, env=env, capture_output=True, text=True, check=True)
        b = {x: open(os.path.join(tmp, 'm.' + x), 'rb').read() for x in ('oracle', 'port', 'oracle.pre', 'port.pre')}
        w = lambda x, i: struct.unpack_from('<I', b[x], i)[0]
        pre = [i for i in range(0, SNAP_M, 4) if w('oracle.pre', i) != w('port.pre', i)]
        d1 = [i for i in range(0, SNAP_M, 4) if w('oracle', i) != w('port', i)]
        print('  at sample %d: %d words differ before it, %d after it:' % (start + s1, len(pre), len(d1)))
        for i in d1[:24]:
            print('    +0x%05x (%7d): before %08x (%r)  oracle %08x (%r)  port %08x (%r)' % (
                i, i, w('oracle.pre', i), struct.unpack_from('<f', b['oracle.pre'], i)[0], w('oracle', i),
                struct.unpack_from('<f', b['oracle'], i)[0], w('port', i), struct.unpack_from('<f', b['port'], i)[0]))
    return 1


if __name__ == '__main__':
    sys.exit(main())
