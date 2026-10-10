#!/usr/bin/env python3
"""jx_wasm_check.py -- the DELIVERED JX-3P web engine (jx3p/gui/web/jx3p.{js,wasm}) against a native
build of the same sources, on the page's own calls (JX-10: jx3p_init on the 96 kHz guest image, jx3p_recall,
jx3p_product_open(host rate), jx3p_product_block per 256-sample block with that block's events at their
offsets; jx3p/tools/jx_wasm_run.mjs runs the WASM in node). The native product path is the one
jx_product_gate.py grades against the plugin's own process().

The plan, per host rate (44100, 48000: the page's rates; 96000): idle past the 0.5 s start mute, a chord
at offset 37 of its block (three keys, velocities 100 / 90 / 80), a key released at offset 200, a key
struck again where another is released, all keys up -- on clock patches the arpeggiator plays between.

WebAssembly has no FTZ/DAZ: where a denormal reaches the arithmetic the two can differ -- the caveat the
JX status page names. This check measures it instead of naming it: per patch, the first 256-sample block
whose L or R bits differ from the native build with FTZ ON (the proven engine), and from the native build
with FTZ OFF (the same arithmetic as the WASM).

  python3 jx3p/tools/jx_wasm_check.py [--patches 0,5,20,34,49,61] [--rates 44100,48000,96000] [--dir D]
                                      exit 0 = WASM == native FTZ-on (D: another build's jx3p.js/.wasm)
  python3 jx3p/tools/jx_wasm_check.py --tooth     the full gate's tooth build (a note one semitone off)
                                                  must differ (exit 0 = bites)
Two-process rule: no Unicorn here; node runs the WASM.
"""
import ctypes
import gzip
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
N = 256


def plan(rate):
    """the page's calls as blocks of events [offset, type (0 on / 1 off), key, velocity]"""
    blk = lambda t: int(t * rate) // N
    nb = blk(1.6)
    out = [[] for _ in range(nb)]
    a, b, c, d = blk(0.55), blk(0.9), blk(1.1), blk(1.3)
    out[a] = [[37, 0, 60, 100], [37, 0, 64, 90], [37, 0, 67, 80]]
    out[b] = [[200, 1, 64, 0]]
    out[c] = [[3, 1, 67, 0], [3, 0, 67, 70], [255, 0, 72, 127]]
    out[d] = [[0, 1, 60, 0], [0, 1, 67, 0], [17, 1, 72, 0]]
    return {'rate': rate, 'blocks': out}


def fnv(b):
    h = 0xcbf29ce484222325
    for x in b:
        h = ((h ^ x) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF
    return '%016x' % h


def guest96(tmp):
    """the page's data: the 96 kHz guest image (jx3p/gen/jx_guest_96k.bin.gz, the plugin's heap after its boot),
    inflated"""
    dst = os.path.join(tmp, 'jx_guest_96k.bin')
    if not os.path.exists(dst):
        with gzip.open(os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_96k.bin.gz'), 'rb') as f:
            open(dst, 'wb').write(f.read())
    return dst


def native(so, patches, ftz, planfile):
    lib = ctypes.CDLL(so)
    if ftz:
        lib.jx_enable_hw_ftz()
    pl = json.load(open(planfile))
    img = guest96(os.path.dirname(planfile))
    lib.jx3p_lift_error.restype = ctypes.c_char_p
    out = {}
    L, R = (ctypes.c_float * N)(), (ctypes.c_float * N)()
    for p in patches:
        if not lib.jx3p_init(img.encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(), None):
            raise SystemExit('native jx3p_init failed')
        lib.jx3p_recall(p)
        if lib.jx3p_lift_error():
            raise SystemExit('the lifted parameter system trapped: %s' % lib.jx3p_lift_error().decode())
        if lib.jx3p_product_open(pl['rate']) < 0:
            raise SystemExit('native jx3p_product_open failed')
        hs = []
        for evs in pl['blocks']:
            arr = (ctypes.c_int * max(1, 4 * len(evs)))(*[x for e in evs for x in e])
            lib.jx3p_product_block(L, R, N, arr, len(evs))
            hs.append(fnv(bytes(L)) + fnv(bytes(R)))
        out[str(p)] = hs
    return out


def build(dst, extra=()):
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                    *extra, '-o', dst] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    return dst


def run_side(so, patches, ftz, planfile):
    """the native side in its own process (a fresh library state per configuration)"""
    r = subprocess.run([sys.executable, __file__, '--native', so, ','.join(map(str, patches)), '1' if ftz else '0',
                        planfile], capture_output=True, text=True, check=True)
    return json.loads(r.stdout)


def first_diff(a, b):
    for p in a:
        for k, (x, y) in enumerate(zip(a[p], b[p])):
            if x != y:
                return p, k
        if len(a[p]) != len(b[p]):
            return p, min(len(a[p]), len(b[p]))
    return None


def main():
    args = sys.argv[1:]
    if args[:1] == ['--native']:
        print(json.dumps(native(args[1], [int(x) for x in args[2].split(',')], args[3] == '1', args[4])))
        return 0
    opt = lambda k, d: args[args.index(k) + 1] if k in args else d
    patches = [int(x) for x in opt('--patches', '0,5,20,34,49,61').split(',')]
    rates = [int(x) for x in opt('--rates', '44100,48000,96000').split(',')]
    tmp = tempfile.mkdtemp()
    so = build(os.path.join(tmp, 'libjx3p.so'))
    if '--tooth' in args:
        pf = os.path.join(tmp, 'plan.json')
        json.dump(plan(rates[0]), open(pf, 'w'))
        bad = build(os.path.join(tmp, 'libjx3p_tooth.so'), ['-DJX_FULL_TOOTH=1'])
        d = first_diff(run_side(so, patches[:1], True, pf), run_side(bad, patches[:1], True, pf))
        print('jx_wasm_check --tooth: %s' % ('BITES (first differing block: patch %s block %d)' % d if d else
                                              'DID NOT BITE'))
        return 0 if d else 1
    wdir = ['--dir', opt('--dir', '')] if '--dir' in args else []
    red = 0
    for rate in rates:
        pf = os.path.join(tmp, 'plan%d.json' % rate)
        json.dump(plan(rate), open(pf, 'w'))
        w = subprocess.run(['node', os.path.join(HERE, 'jx_wasm_run.mjs'), '--plan', pf, '--patches',
                            ','.join(map(str, patches))] + wdir, capture_output=True, text=True)
        if w.returncode:
            raise SystemExit('node failed: ' + w.stderr[-600:])
        wasm = json.loads(w.stdout)
        on, off = run_side(so, patches, True, pf), run_side(so, patches, False, pf)
        nb = sum(len(v) for v in on.values())
        d_on, d_off = first_diff(wasm, on), first_diff(wasm, off)
        print('host rate %d: %d patches, %d blocks of %d samples each' % (rate, len(patches), nb, N))
        print('  WASM vs native FTZ on  (the proven engine): %s' % (
            'every block equal' if not d_on else 'first difference patch %s block %d (sample %d)' % (
                d_on[0], d_on[1], N * d_on[1])))
        print('  WASM vs native FTZ off (the same arithmetic): %s' % (
            'every block equal' if not d_off else 'first difference patch %s block %d' % d_off), flush=True)
        red += bool(d_on)
    print('jx_wasm_check: %s' % ('GREEN' if not red else 'RED -- the delivered page does not play the proven engine'))
    return 1 if red else 0


if __name__ == '__main__':
    sys.exit(main())
