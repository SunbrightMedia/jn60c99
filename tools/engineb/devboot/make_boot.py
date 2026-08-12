#!/usr/bin/env python3
"""make_boot.py -- build and run the two device-image generators.

    python3 tools/engineb/devboot/make_boot.py            # 44,100 only, NV=6
    python3 tools/engineb/devboot/make_boot.py --rates 44100,48000,96000 --nv 8
    python3 tools/engineb/devboot/make_boot.py --randt 64 # deeper format sweep

Produces, under build/devboot/:
    ebdev_boot.bin/.h   the post-init+prepare device cell array, per rate
    eb_bank64.bin/.h    the 64 factory patches in the compact format
    eb_template.bin/.h  the record template the compact bytes are installed into

NOTHING HERE IS JUNO-SPECIFIC EXCEPT THE SOURCE LIST AND THE THREE ENTRY
POINTS (chorus_init / engine_init / engine_prepare). END_GOAL item 7: point it
at another port's boot triple and its own eb_patch and it does the same job.

Exit code is the patch generator's: non-zero means the round trip FAILED, and
that is the result that matters.
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
BUILD = os.path.join(REPO, 'build', 'devboot')
CC = os.environ.get('CC', 'cc')
CFLAGS = ['-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-w',
          '-I' + os.path.join(REPO, 'src'),
          '-I' + os.path.join(REPO, 'engine_b'),
          '-I' + os.path.join(REPO, 'engine_b', 'dev')]


def sources():
    out = []
    for d in ('src', 'engine_b'):
        for fn in sorted(os.listdir(os.path.join(REPO, d))):
            if not fn.endswith('.c'):
                continue
            if fn.startswith('test_') or fn == 'engineb_stub.c':
                continue          # standalone probe mains, not engine sources
            out.append(os.path.join(REPO, d, fn))
    return out


def build(name):
    exe = os.path.join(BUILD, name)
    cmd = [CC] + CFLAGS + ['-o', exe, os.path.join(HERE, name + '.c')] \
        + sources() + ['-lm']
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr[-4000:])
        sys.exit('BUILD FAILED: ' + name)
    return exe


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rates', default='44100')
    ap.add_argument('--nv', type=int, default=6)
    ap.add_argument('--randt', type=int, default=8,
                    help='random templates per patch in the format sweep')
    a = ap.parse_args()
    os.makedirs(BUILD, exist_ok=True)
    bank = os.path.join(REPO, 'truth', 'presetbankog1.bin')
    if not os.path.exists(bank):
        sys.exit('no bank at ' + bank)

    env = dict(os.environ, BOOTGEN_RATES=a.rates, BOOTGEN_NV=str(a.nv))
    exe = build('bootgen')
    r = subprocess.run([exe, os.path.join(BUILD, 'ebdev_boot.bin'),
                        os.path.join(BUILD, 'ebdev_boot.h'), 'ebdev_boot'],
                       env=env, capture_output=True, text=True)
    print(r.stdout.strip())
    if r.returncode:
        print(r.stderr[-2000:]); sys.exit('bootgen failed')

    exe = build('patchbank')
    r = subprocess.run([exe, bank, BUILD],
                       env=dict(os.environ, PB_RANDT=str(a.randt)),
                       capture_output=True, text=True)
    print(r.stdout.strip())
    if r.stderr.strip():
        print(r.stderr[-2000:])
    return r.returncode


if __name__ == '__main__':
    sys.exit(main())
