#!/usr/bin/env python3
"""make_boot.py -- build and run the THREE device-image generators.

    python3 tools/engineb/devboot/make_boot.py                 # the C3 defaults
    python3 tools/engineb/devboot/make_boot.py --nv 8 --chord 2
    python3 tools/engineb/devboot/make_boot.py --randt 64      # deeper format sweep

Produces, under build/devboot/ AND (copied) esp32s3/main/gen/:
    ebdev_boot.h    the post-init+prepare device cell array, one rate
    eb_bank64.h     the 64 factory patches in the compact format
    eb_template.h   the record template the compact bytes are installed into
    devcrc.h        what the BOARD's own recall must produce, per patch

THE THIRD ONE IS THE POINT OF THIS SESSION. The first two are data the chip
needs; devcrc.h is the answer key, computed by the SAME sequence
(engine_b/dev/eb_devseq.c) through the SAME rebased addressing, so the board
can check its own arithmetic instead of being trusted.

NOTHING HERE IS JUNO-SPECIFIC EXCEPT THE SOURCE LIST AND THE PORT ENTRY POINTS
THE THREE .c FILES CALL. END_GOAL item 7: point it at another port's boot
triple and its own eb_patch and it does the same job.

Exit code: non-zero if ANY of the three fails -- the patch round trip, an
unmapped cell on the device sequence, or a near-constant CRC table.
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
BUILD = os.path.join(REPO, 'build', 'devboot')
GEN = os.path.join(REPO, 'esp32s3', 'main', 'gen')
CC = os.environ.get('CC', 'cc')
# THE FIRMWARE'S ENGINE FLAG SET (M1, esp32s3/main/CMakeLists.txt + the
# S3_EXTRA_DEFS the shipping build passes). Only the EB_* ones can reach a
# coefficient; the S3L_* ones are firmware-only and are excluded here so the
# host build does not have to know about them. -DEB_IDF is excluded because it
# selects IDF headers.
#
# THIS LIST IS THE ONE PLACE THE TWO BUILDS COULD DRIFT, and the drift is not
# silent: the generated devcrc.h carries DEVCRC_RC_SZ / DEVCRC_MC_SZ and the
# firmware fails to COMPILE if either disagrees with its own sizeof.
M1_DEFS = [
    '-DEB_FORK_S3', '-DEB_LFO_SHARED=1', '-DEB_VCF_RES_LUT=256',
    '-DEB_DCO_WT=1', '-DEB_VCF_DEADCOEF=1', '-DEB_ATREST_BLOCK=1',
    '-DEB_ATREST_O1=1', '-DEB_ZEROCOEF=1', '-DEB_EXP_MEMO=1',
    '-DEB_HALF_OS_VCF=1', '-DEB_NOLIBM=1', '-DEB_VCF_MAPFAST=1',
    '-DEB_FPDIV=1', '-DEB_CR_PITCH=1', '-DEB_CR_MODCV=1', '-DEB_CR_VCFCV=1',
    '-DEB_CR_ENV=1', '-DEB_CR_N=4', '-DEB_CR_NP=4', '-DEB_CR_NC=2',
    '-DEB_CR_NE=2', '-DEB_ENV_CR=2',
]

CFLAGS = ['-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-w',
          '-I' + HERE,
          '-I' + os.path.join(REPO, 'src'),
          '-I' + os.path.join(REPO, 'engine_b'),
          '-I' + os.path.join(REPO, 'engine_b', 'dev')]


def sources(dev):
    out = []
    for d in ('src', 'engine_b'):
        for fn in sorted(os.listdir(os.path.join(REPO, d))):
            if not fn.endswith('.c'):
                continue
            if fn.startswith('test_') or fn == 'engineb_stub.c':
                continue          # standalone probe mains, not engine sources
            out.append(os.path.join(REPO, d, fn))
    if dev:
        out += [os.path.join(REPO, 'engine_b', 'dev', f)
                for f in ('ebdev.c', 'eb_devseq.c')]
    return out


def build(name, defs=()):
    exe = os.path.join(BUILD, name)
    cmd = [CC] + CFLAGS + list(defs) + ['-o', exe,
                                        os.path.join(HERE, name + '.c')] \
        + sources('-DEB_DEVCELLS' in defs) + ['-lm']
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr[-6000:])
        sys.exit('BUILD FAILED: ' + name)
    return exe


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rate', default='44100',
                    help='ONE rate. 516 of 30,156 bytes move between 44.1k and '
                         '48k (bootgen measures it), and a wrong-rate image is '
                         'a quiet detune rather than a crash -- so the firmware '
                         'prints the image rate, not the rate it configured.')
    ap.add_argument('--nv', type=int, default=8,
                    help='scatter rows. 8 = what the 1,152-case gate runs at; '
                         'the 96 bytes 6 would save are not worth configuring '
                         'the device differently from its gate (playbook 28).')
    ap.add_argument('--chord', type=int, default=2,
                    help='DEVCHORD_N -- must match the firmware build')
    ap.add_argument('--randt', type=int, default=8,
                    help='random templates per patch in the format sweep')
    ap.add_argument('--defs', default=' '.join(M1_DEFS),
                    help='the ENGINE flag set the FIRMWARE is built at. It is '
                         'not optional: -DEB_DCO_WT=1 and -DEB_VCF_RES_LUT '
                         'change sizeof(eb_render_coefs) from 10,564 to '
                         '18,788, so a CRC table generated at trunk defaults '
                         'predicts a different struct than the chip builds. '
                         'The firmware carries a compile-time assert on '
                         'DEVCRC_RC_SZ that catches exactly this.')
    ap.add_argument('--no-copy', action='store_true')
    a = ap.parse_args()
    os.makedirs(BUILD, exist_ok=True)
    bank = os.path.join(REPO, 'truth', 'presetbankog1.bin')
    if not os.path.exists(bank):
        sys.exit('no bank at ' + bank)
    bad = 0

    # ---------------------------------------------------------- 1. boot image
    env = dict(os.environ, BOOTGEN_RATES=a.rate, BOOTGEN_NV=str(a.nv))
    exe = build('bootgen')
    r = subprocess.run([exe, os.path.join(BUILD, 'ebdev_boot.bin'),
                        os.path.join(BUILD, 'ebdev_boot.h'), 'ebdev_boot'],
                       env=env, capture_output=True, text=True)
    print(r.stdout.strip())
    if r.returncode:
        print(r.stderr[-2000:])
        sys.exit('bootgen failed')

    # ------------------------------------------------- 2. bank + template
    exe = build('patchbank')
    r = subprocess.run([exe, bank, BUILD],
                       env=dict(os.environ, PB_RANDT=str(a.randt)),
                       capture_output=True, text=True)
    print(r.stdout.strip())
    if r.stderr.strip():
        print(r.stderr[-2000:])
    bad |= r.returncode

    # ------------------------------------------- 3. the board's answer key
    print('\n=== THE ANSWER KEY, at the FIRMWARE\'s engine flags ===')
    print('    ' + a.defs)
    exe = build('devcrc', ['-DEB_DEVCELLS', '-DEBDEV_NV=%d' % a.nv,
                           '-DDEVCHORD_N=%d' % a.chord] + a.defs.split())
    r = subprocess.run([exe, os.path.join(BUILD, 'ebdev_boot.bin'),
                        os.path.join(BUILD, 'eb_bank64.bin'),
                        os.path.join(BUILD, 'eb_template.bin'),
                        os.path.join(BUILD, 'devcrc.h')],
                       env=dict(os.environ, DEVCRC_NV=str(a.nv)),
                       capture_output=True, text=True)
    print(r.stdout.strip())
    if r.stderr.strip():
        print(r.stderr[-2000:])
    bad |= r.returncode

    if not a.no_copy:
        os.makedirs(GEN, exist_ok=True)
        for h in ('ebdev_boot.h', 'eb_bank64.h', 'eb_template.h', 'devcrc.h'):
            src = os.path.join(BUILD, h)
            if os.path.exists(src):
                shutil.copy(src, os.path.join(GEN, h))
        print('copied 4 headers into %s' % GEN)
        print('  (the firmware includes THESE; regenerate after any change to '
              'the map,\n   the patch format, the chord or the boot triple)')
    return bad


if __name__ == '__main__':
    sys.exit(main())
