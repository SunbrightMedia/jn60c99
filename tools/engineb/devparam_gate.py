#!/usr/bin/env python3
"""devparam_gate.py -- THE WARM PARAMETER EDIT MATCHES THE PLUGIN.

    python3 tools/engineb/devparam_gate.py            # main + all teeth
    python3 tools/engineb/devparam_gate.py --no-teeth

A knob move is not a patch recall. The plugin's live edit (juno_apply_param_leaf)
writes the edited leaf's cells and never touches per-voice NOTE state; the device
used to answer every edit with a full recall whose seed_voices broadcasts voice
0's note cells onto every voice (the storm's stuck note, b45). This gate puts
real notes down and proves the warm edit leaves the five note cells untouched --
through juno_apply_param_leaf for a value-tree leaf, and through a note-state
preserve for a non-leaf FX/switch byte.

Like devrecall_gate this is a HOST build: it proves the METHOD, which is
address-map independent. devrecall_gate proves the device cell MAP carries the
offsets. Neither runs an Xtensa instruction; together they cover the chip.

TEETH. Each check has a compile flag that must make the run FAIL. A tooth that
does not fire is printed NOT CAUGHT and the gate is red.
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import devrecall_gate as G     # reuse the flat-tree assembly + constants

BANK = os.path.join(G.REPO, 'truth', 'presetbankog1.bin')
DEV_HDRS = ('eb_param_class.h', 'eb_devparam.h')

TEETH = [
    ('GATE_TOOTH_LEAF_IS_RECALL',
     'a leaf edit applied as a full recall must corrupt note state'),
    ('GATE_TOOTH_NO_PRESERVE',
     'a non-leaf edit with no note preserve must corrupt note state'),
    ('GATE_TOOTH_MAP_OFFBY',
     'an off-by-one leaf map must leave the target coefficient unmoved'),
]


def build(tag, extra=()):
    root, files = G.make_tree(False, 'devparam_' + tag)
    for h in DEV_HDRS:
        shutil.copy(os.path.join(G.REPO_DEV, h), os.path.join(root, h))
    out = os.path.join(G.BUILD, 'devparam_' + tag)
    cmd = [G.CC] + G.BASE_CFLAGS + list(extra) + ['-I' + root, '-o', out,
           os.path.join(HERE, 'devparam', 'gate.c')] + \
          [os.path.join(root, f) for f in files] + ['-lm']
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stdout[-3000:]); print(r.stderr[-6000:])
        sys.exit('BUILD FAILED (%s)' % tag)
    return out


def run(binpath):
    r = subprocess.run([binpath, BANK], capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--no-teeth', action='store_true')
    a = ap.parse_args()

    print('=' * 70)
    print('DEVPARAM GATE -- the warm edit leaves note state as the plugin does')
    print('=' * 70)
    rc, out = run(build('main'))
    print(out)
    if rc != 0:
        sys.exit('*** DEVPARAM GATE RED (main run failed) ***')

    if a.no_teeth:
        print('teeth skipped')
        return
    print('-' * 70)
    print('TEETH (each must FAIL)')
    print('-' * 70)
    bad = 0
    for flag, why in TEETH:
        rc, out = run(build(flag.lower(), extra=['-D' + flag]))
        caught = rc != 0
        print('  %-32s %s  (%s)' % (flag, 'CAUGHT' if caught else 'NOT CAUGHT', why))
        if not caught:
            bad += 1
            print(out)
    if bad:
        sys.exit('*** %d TOOTH/TEETH DID NOT FIRE ***' % bad)
    print('\nDEVPARAM GATE GREEN: plugin-exact warm edit proven, all teeth fired.')


if __name__ == '__main__':
    main()
