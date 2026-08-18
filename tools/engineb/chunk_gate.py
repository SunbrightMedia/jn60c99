#!/usr/bin/env python3
"""chunk_gate.py -- build and run O2's gate: the chunked build IS the monolith.

Compiles tools/engineb/devboot/chunk_gate.c at the FIRMWARE's engine flag set
and runs it over all 64 patches. See that file for what it compares.

It reuses make_boot.py's flag list and source list rather than restating them,
because that list is already documented as "the one place the two builds could
drift" -- a second copy of it here would be a second place.

  usage: chunk_gate.py [--nv 8] [--chord 2]
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DEVBOOT = os.path.join(HERE, 'devboot')
BUILD = os.path.join(REPO, 'build', 'devboot')
sys.path.insert(0, DEVBOOT)
import make_boot                                   # noqa: E402  (path first)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--nv', type=int, default=8)
    ap.add_argument('--chord', type=int, default=2)
    a = ap.parse_args()

    for f in ('ebdev_boot.bin', 'eb_bank64.bin', 'eb_template.bin'):
        if not os.path.exists(os.path.join(BUILD, f)):
            sys.exit('missing %s -- run tools/engineb/devboot/make_boot.py '
                     'first; this gate compares against the SAME boot image '
                     'and bank the board is flashed with.' % f)

    defs = ['-DEB_DEVCELLS', '-DEBDEV_NV=%d' % a.nv,
            '-DDEVCHORD_N=%d' % a.chord] + make_boot.M1_DEFS
    exe = os.path.join(BUILD, 'chunk_gate')
    # eb_recall.c is NOT in make_boot.sources(): devcrc does not need it. The
    # chunk cursor lives there, and driving the REAL cursor rather than a
    # hand-rolled loop is the whole point of this gate.
    cmd = ([make_boot.CC] + make_boot.CFLAGS + defs +
           ['-o', exe, os.path.join(DEVBOOT, 'chunk_gate.c')] +
           make_boot.sources(True) +
           [os.path.join(REPO, 'engine_b', 'dev', 'eb_recall.c'), '-lm'])
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr[-6000:])
        sys.exit('BUILD FAILED: chunk_gate')

    r = subprocess.run([exe,
                        os.path.join(BUILD, 'ebdev_boot.bin'),
                        os.path.join(BUILD, 'eb_bank64.bin'),
                        os.path.join(BUILD, 'eb_template.bin')],
                       env=dict(os.environ, DEVCRC_NV=str(a.nv)),
                       capture_output=True, text=True)
    print(r.stdout.strip())
    if r.stderr.strip():
        print(r.stderr[-3000:])
    return r.returncode


if __name__ == '__main__':
    raise SystemExit(main())
