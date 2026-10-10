#!/usr/bin/env python3
"""jx_wasm_check.py -- the DELIVERED JX-3P web engine (jx3p/gui/web/jx3p.{js,wasm}) against a native
build of the same sources, on the page's own calls (jx3p_init, jx3p_recall, 256-sample jx3p_render
blocks, note on / off; jx3p/tools/jx_wasm_run.mjs runs the WASM in node).

The native side is the engine jx_full_gate.sh grades against the plugin (FTZ/DAZ on, as the plugin
runs). WebAssembly has no FTZ/DAZ: where a denormal reaches the arithmetic the two can differ -- the
caveat the JX status page names. This check measures it instead of naming it: per patch, the first
256-sample block whose L or R bits differ from the native build with FTZ ON (the proven engine), and
from the native build with FTZ OFF (the same arithmetic as the WASM).

  python3 jx3p/tools/jx_wasm_check.py [--patches 0,5,20,49] [--dir D]   exit 0 = WASM == native FTZ-on
                                                                   (D: another build's jx3p.js/.wasm)
  python3 jx3p/tools/jx_wasm_check.py --tooth                      the full gate's tooth build (a note one
                                                                   semitone off) must differ (exit 0 = bites)
Two-process rule: no Unicorn here; node runs the WASM.
"""
import ctypes
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
PLAN = [('idle', 24064), ('on', 60, 100), ('render', 12032), ('off', 60), ('render', 4096)]   # = jx_wasm_run.mjs
# (idle past the 0.5 s start mute + 10 ms fade: a plan inside it compares zeros)
N = 256


def fnv(b):
    h = 0xcbf29ce484222325
    for x in b:
        h = ((h ^ x) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF
    return '%016x' % h


def native(so, patches, ftz):
    lib = ctypes.CDLL(so)
    if ftz:
        lib.jx_enable_hw_ftz()
    out = {}
    L, R = (ctypes.c_float * N)(), (ctypes.c_float * N)()
    for p in patches:
        if not lib.jx3p_init(os.path.join(REPO, 'jx3p', 'gen', 'jx_template.bin').encode(),
                             os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             os.path.join(REPO, 'jx3p', 'gen', 'jx_master_recall.bin').encode()):
            raise SystemExit('native jx3p_init failed')
        lib.jx3p_recall(p)
        hs = []
        for op in PLAN:
            if op[0] == 'on':
                lib.jx3p_note_on(op[1], op[2])
            elif op[0] == 'off':
                lib.jx3p_note_off(op[1])
            else:
                for _ in range(0, op[1], N):
                    lib.jx3p_render(L, R, N)
                    hs.append(fnv(bytes(L)) + fnv(bytes(R)))
        out[str(p)] = hs
    return out


def build(dst, extra=()):
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                    *extra, '-o', dst] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    return dst


def run_side(so, patches, ftz):
    """the native side in its own process (a fresh library state per configuration)"""
    r = subprocess.run([sys.executable, __file__, '--native', so, ','.join(map(str, patches)), '1' if ftz else '0'],
                       capture_output=True, text=True, check=True)
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
        print(json.dumps(native(args[1], [int(x) for x in args[2].split(',')], args[3] == '1')))
        return 0
    patches = [int(x) for x in (args[args.index('--patches') + 1] if '--patches' in args else '0,5,20,49').split(',')]
    tmp = tempfile.mkdtemp()
    so = build(os.path.join(tmp, 'libjx3p.so'))
    if '--tooth' in args:
        bad = build(os.path.join(tmp, 'libjx3p_tooth.so'), ['-DJX_FULL_TOOTH=1'])
        d = first_diff(run_side(so, patches[:1], True), run_side(bad, patches[:1], True))
        print('jx_wasm_check --tooth: %s' % ('BITES (first differing block: patch %s block %d)' % d if d else
                                              'DID NOT BITE'))
        return 0 if d else 1
    wdir = ['--dir', args[args.index('--dir') + 1]] if '--dir' in args else []
    w = subprocess.run(['node', os.path.join(HERE, 'jx_wasm_run.mjs'), '--patches', ','.join(map(str, patches))] + wdir,
                       capture_output=True, text=True)
    if w.returncode:
        raise SystemExit('node failed: ' + w.stderr[-600:])
    wasm = json.loads(w.stdout)
    on, off = run_side(so, patches, True), run_side(so, patches, False)
    nb = sum(len(v) for v in on.values())
    d_on, d_off = first_diff(wasm, on), first_diff(wasm, off)
    print('%d patches, %d blocks of %d samples each' % (len(patches), nb, N))
    print('  WASM vs native FTZ on  (the proven engine): %s' % (
        'every block equal' if not d_on else 'first difference patch %s block %d (sample %d)' % (d_on[0], d_on[1], N * d_on[1])))
    print('  WASM vs native FTZ off (the same arithmetic): %s' % (
        'every block equal' if not d_off else 'first difference patch %s block %d' % d_off))
    print('jx_wasm_check: %s' % ('GREEN' if not d_on else 'RED -- the delivered page does not play the proven engine'))
    return 1 if d_on else 0


if __name__ == '__main__':
    sys.exit(main())
