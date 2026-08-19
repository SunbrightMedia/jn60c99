#!/usr/bin/env python3
"""paramclass_gate.py -- O3's map gate. Runnable standalone.

    python3 tools/engineb/paramclass_gate.py            # gate + 3 teeth
    python3 tools/engineb/paramclass_gate.py --no-teeth

WHAT IT PROVES.

  1. THE NARROWED REFRESH IS THE FULL REBUILD. For every parameter, over 13
     base patches and 6 probe values: pre-edit coefficients + only the class's
     sub-builders re-run == a full rebuild, BYTE FOR BYTE. This is the claim
     C9 asked for a tooth on, and O3's entire saving rests on it.

  2. THE CHECKED-IN TABLE IS NOT STALE. engine_b/dev/eb_param_class.h is
     GENERATED, and this gate regenerates it and diffs. A table that has
     drifted from the engine is a knob that rebuilds the wrong thing --
     wrong sound, no error, which is the failure this project has paid for
     most. So the table is never trusted; it is re-derived every run.

TEETH. A gate never seen to fail is not a gate.
  --tooth-tail   every parameter forced voices-only  -> tail/master params must differ
  --tooth-voice  every parameter forced tail+master  -> per-voice params must differ
  --tooth-one    voice 3 dropped from every mask     -> C9's tooth verbatim
Each tooth RUN MUST FAIL. A tooth that passes is printed NOT CAUGHT and fails
this script.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
BUILD = os.path.join(REPO, 'build', 'paramclass')
CC = os.environ.get('CC', 'cc')
BANK = os.path.join(REPO, 'truth', 'presetbankog1.bin')
POS = os.path.join(REPO, 'build', 'devrecall', 'recall_positions.txt')
TABLE = os.path.join(REPO, 'engine_b', 'dev', 'eb_param_class.h')


def sh(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def main():
    teeth = '--no-teeth' not in sys.argv
    os.makedirs(BUILD, exist_ok=True)

    if not os.path.exists(POS):
        sys.exit('no %s -- run devrecall_gate.py --patch-scan first '
                 '(the discovery scan owns WHICH parameters exist)' % POS)

    src = [os.path.join(HERE, 'devboot', 'paramclass_gate.c')]
    src += sorted(os.path.join(REPO, 'src', f)
                  for f in os.listdir(os.path.join(REPO, 'src'))
                  if f.endswith('.c'))
    src += sorted(os.path.join(REPO, 'engine_b', f)
                  for f in os.listdir(os.path.join(REPO, 'engine_b'))
                  if f.endswith('.c') and not f.startswith('test_'))
    exe = os.path.join(BUILD, 'paramclass')
    r = sh([CC, '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing',
            '-w', '-I' + os.path.join(REPO, 'src'),
            '-I' + os.path.join(REPO, 'engine_b'), '-o', exe] + src + ['-lm'])
    if r.returncode:
        print(r.stderr[-4000:])
        sys.exit('BUILD FAILED')

    print('=' * 66)
    print('PARAMETER CLASS GATE')
    print('=' * 66)
    out = os.path.join(BUILD, 'eb_param_class.h')
    r = sh([exe, BANK, POS, out])
    tail = r.stdout.strip().splitlines()
    print('\n'.join(tail[-4:]) if len(tail) > 4 else r.stdout.strip())
    bad = r.returncode

    # ---- the table is regenerated, never trusted --------------------------
    want = open(TABLE).read() if os.path.exists(TABLE) else ''
    got = open(out).read()
    # ⚠ MATCH A TABLE ROW, NOT ANY LINE STARTING WITH '{'. The first version
    # counted the accessor function's opening brace as a 60th row and reported
    # a stale table that was not stale. A staleness check that cries wolf gets
    # switched off, which is worse than not having one.
    ROW = re.compile(r'^\{\s*-?\d+\s*,')
    wrows = [l.strip() for l in want.splitlines() if ROW.match(l.strip())]
    grows = [l.strip() for l in got.splitlines() if ROW.match(l.strip())]
    if wrows == grows and wrows:
        print('checked-in eb_param_class.h matches the re-derived table '
              '(%d rows)' % len(wrows))
    else:
        print('*** eb_param_class.h IS STALE: checked-in %d rows, '
              're-derived %d rows ***' % (len(wrows), len(grows)))
        for a, b in zip(wrows, grows):
            if a != b:
                print('    checked-in %s' % a)
                print('    measured   %s' % b)
                break
        bad = 1

    if teeth:
        print('-' * 66)
        for t in ('--tooth-tail', '--tooth-voice', '--tooth-one'):
            rr = sh([exe, BANK, POS, os.path.join(BUILD, 'tooth.h'), t])
            # the C returns 0 when a tooth run correctly FAILED to match
            if rr.returncode == 0:
                print('%-16s CAUGHT' % t)
            else:
                print('%-16s NOT CAUGHT -- the gate cannot see a short map'
                      % t)
                bad = 1

    print('-' * 66)
    print('PARAMCLASS GATE: %s' % ('PASS' if not bad else 'FAIL'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
