#!/usr/bin/env python3
"""edit_cover_gate.py -- CLAIMS A35: the host edit's scratch copies only the
recall's cells (gui/juno_bridge.c JUNO_EDIT_COVER), and no byte outside them
ever reaches a result.

A host edit (host_edit_live) runs the recall on a scratch copy of the state and
takes the setter's cells from it. The port proved that path against the plugin
with a FULL copy (host_edit_gate.py, state_load_gate.py, bank_product_gate.py);
the product now refreshes only the cover. This gate builds the same sources four
ways and drives them through the same corpus (tools/verify/edit_cover_drv.c: the
product boot, a patch load, three keys held, then every host parameter at min,
max, mid, two seeded values and max + 1, one block after each edit):

  full     -DJUNO_EDIT_FULLCOPY  the whole array per edit (the proven path)
  poison   -DJUNO_EDIT_POISON    the cover, and EVERY byte outside it random,
                                 freshly, before every edit
  product  (no flag)             the cover, the scratch kept
  tooth k  poison + -DJUNO_EDIT_TOOTH=k: the cover without range k

and requires poison == full and product == full on every block's audio and on
the whole state after every parameter. The corpus: the factory bank (64
patches) and every 9th patch of each user bank at the plugin's boot (engine
96 kHz, host 48000), plus host 44100 and the engine settings 48 / 88.2 kHz.
Reach: every config's poison run must count >= 400 edits per patch reaching
the scratch. Teeth (must FAIL): the voice block (k = 0), the global segment
[90368, 96960) (k = 2), the port-owned tail (k = 31) -- the three ranges the
corpus needs (--census, 2026-10-08: the recall writes the other 29 census
ranges before it reads them; they stay in the cover, it costs 15 KB a copy).

usage: python3 tools/verify/edit_cover_gate.py [--quick] [--census]
  --quick    the factory configs only, 16 patches
  --census   also report, for each of the 32 ranges, whether the corpus needs
             it (its tooth differs) -- information, not a pass condition
"""
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth  # noqa: E402

WORK = os.path.join(REPO, 'scratchpad', 'edit_cover')
CFLAGS = ['-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing']
TEETH = [(0, 'the voice block'), (2, 'the global segment [90368, 96960)'), (31, 'the port-owned tail')]
NCOVER = 32


def sources():
    src = os.path.join(REPO, 'src')
    return ([os.path.join(HERE, 'edit_cover_drv.c'), os.path.join(REPO, 'gui', 'juno_bridge.c')] +
            sorted(os.path.join(src, f) for f in os.listdir(src) if f.endswith('.c')))


def build(name, flags):
    exe = os.path.join(WORK, 'drv_' + name)
    subprocess.check_call(['gcc'] + CFLAGS + flags + ['-o', exe] + sources() + ['-lm'])
    return exe


def run(exe, out, bank, rate, eng, patches):
    subprocess.check_call([exe, out, bank, str(rate), str(eng)] + [str(p) for p in patches])
    return open(out).read().splitlines()


def compare(a, b):
    """first differing line of two corpus outputs (None: equal); the probe line
    of a poison run is not part of the result"""
    a = [x for x in a if not x.startswith('probe')]
    b = [x for x in b if not x.startswith('probe')]
    ctx = ''
    for i in range(max(len(a), len(b))):
        x = a[i] if i < len(a) else '<end>'
        y = b[i] if i < len(b) else '<end>'
        if x.startswith(('patch', 'edit')):
            ctx = x
        if x != y:
            return 'line %d (%s): %s vs %s' % (i + 1, ctx, x, y)
    return None


def configs(quick):
    fac = truth.BANK
    cfg = [('factory, boot (96 kHz engine), host 48000', fac, 48000, -1,
            list(range(0, 64, 4)) if quick else list(range(64))),
           ('factory, host 44100', fac, 44100, -1, list(range(1, 64, 8))),
           ('factory, engine setting 48 kHz', fac, 48000, 2, list(range(2, 64, 8))),
           ('factory, engine setting 88.2 kHz', fac, 48000, 1, list(range(3, 64, 16)))]
    udir = os.path.join(REPO, 'scratchpad', 'userbanks')
    if not quick and os.path.isdir(udir):
        for f in sorted(os.listdir(udir)):
            if f.lower().endswith('.bin'):
                cfg.append(('user bank %s' % os.path.splitext(f)[0].lstrip('~'), os.path.join(udir, f), 48000, -1,
                            list(range(0, 64, 9))))
    return cfg


def main():
    quick = '--quick' in sys.argv
    truth.verify()
    os.makedirs(WORK, exist_ok=True)
    print('building: full, poison, product, %d teeth' % len(TEETH))
    exes = {'full': build('full', ['-DJUNO_EDIT_FULLCOPY']),
            'poison': build('poison', ['-DJUNO_EDIT_POISON']),
            'product': build('product', [])}
    for k, _ in TEETH:
        exes['tooth%d' % k] = build('tooth%d' % k, ['-DJUNO_EDIT_POISON', '-DJUNO_EDIT_TOOTH=%d' % k])
    fails = 0
    with ThreadPoolExecutor(max_workers=3) as pool:
        for n, (name, bank, rate, eng, patches) in enumerate(configs(quick)):
            futs = {v: pool.submit(run, exes[v], os.path.join(WORK, 'c%d_%s.txt' % (n, v)), bank, rate, eng, patches)
                    for v in ('full', 'poison', 'product')}
            out = {v: f.result() for v, f in futs.items()}
            d1, d2 = compare(out['poison'], out['full']), compare(out['product'], out['full'])
            probe = [int(x.split()[1]) for x in out['poison'] if x.startswith('probe')]
            reach = probe[0] if probe else 0
            nb = sum(1 for x in out['full'] if x.startswith('b '))
            ok = d1 is None and d2 is None and reach >= 400 * len(patches)
            fails += not ok
            print('%s %-44s %3d patches, %6d blocks, %6d edits reached: poison %s, product %s' % (
                'ok  ' if ok else 'FAIL', name, len(patches), nb, reach,
                'EQUAL' if d1 is None else 'DIFFERS ' + d1, 'EQUAL' if d2 is None else 'DIFFERS ' + d2))
        # the teeth: the cover without a range the recall needs must differ
        fac, short = truth.BANK, [0, 21, 42, 63]
        ref = run(exes['full'], os.path.join(WORK, 'teeth_full.txt'), fac, 48000, -1, short)
        futs = {k: pool.submit(run, exes['tooth%d' % k], os.path.join(WORK, 'tooth%d.txt' % k), fac, 48000, -1, short)
                for k, _ in TEETH}
        for k, what in TEETH:
            d = compare(futs[k].result(), ref)
            fails += d is None
            print('%s tooth %2d (%s): %s' % ('ok  ' if d else 'FAIL', k, what,
                                             'bites, ' + d if d else 'BLIND: the poisoned build equals the full copy'))
        if '--census' in sys.argv:
            need = []
            for k in range(NCOVER):
                exe = exes.get('tooth%d' % k) or build('tooth%d' % k, ['-DJUNO_EDIT_POISON', '-DJUNO_EDIT_TOOTH=%d' % k])
                d = compare(run(exe, os.path.join(WORK, 'census%d.txt' % k), fac, 48000, -1, short), ref)
                need.append(d is not None)
            print('census: ranges the corpus needs: %s; not needed: %s' % (
                [k for k in range(NCOVER) if need[k]], [k for k in range(NCOVER) if not need[k]]))
    print('edit_cover_gate: %s' % ('GREEN' if not fails else 'RED (%d)' % fails))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
