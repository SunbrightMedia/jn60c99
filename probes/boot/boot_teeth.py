"""The start-up transient's teeth (CLAIMS B15): boot_gate.py --port against mutated builds of the
port, each a defect in the boot ramps (src/recall_ramp.c juno_rr_boot, src/boot_ramps.h) the gate
must see. Builds each mutant in a temporary directory (the tree is not touched; the builder is
midi_teeth.py's), loads it in this process only (libjuno only: two-process rule), runs the gate's
port check, prints how many chains each mutant breaks.

    python3 probes/boot/boot_teeth.py [mutant ...]     (needs cc and scratchpad/boot_ref.pkl)"""
import ctypes
import os
import shutil
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'host_midi'))

MUTANTS = [
    ('all_t0', 'every boot ramp at time index 0 (the census\'s indices 1, 5 and 8 ignored)',
     'src/recall_ramp.c', 'arm_rec(st, i, target, JUNO_BOOT_RAMP[k].t);', 'arm_rec(st, i, target, 0);'),
    ('start0', 'every boot ramp from 0 (the 22 other starts ignored; INERT: must NOT bite, see start0_inert)',
     'src/recall_ramp.c', 'memcpy(&start, &JUNO_BOOT_RAMP[k].start, 4);', 'start = 0.0f;'),
    ('no_toggle', 'the record\'s stored target left as the build left it before the arm',
     'src/recall_ramp.c', '        rec_at(st, i)->target = (target == 0.0f) ? 1.0f : 0.0f;\n', ''),
    ('stopped_pump', 'the ramp pump stepping the units the voice count stops (their boot ramps run on)',
     'src/recall_ramp.c', 'if (u < 8 && u >= nv) { ++k; continue; }', '(void)nv;'),
]


def start0_inert():
    """why the start0 mutant cannot bite, COMPUTED (playbook 172), not assumed: every boot ramp whose
    start is not 0 runs at time index 0 (4 ms), so it ends inside the unit's start-up mute (960
    samples) before the unit's DSP reads the cell -- the start is unobservable on the output. True
    while src/boot_ramps.h holds that; a non-zero start at a later index makes start0 a live tooth."""
    import re
    src = open(os.path.join(REPO, 'src', 'boot_ramps.h')).read()
    rows = re.findall(r'\{ (\d+)u, (\d+), 0x([0-9a-f]{8})u \}', src)
    late = [(c, t) for c, t, b in rows if b != '00000000' and t != '0']
    nz = sum(1 for _, _, b in rows if b != '00000000')
    print('start0: %d boot ramps start other than 0, %d of them after time index 0 -> %s' % (
        nz, len(late), 'inert' if not late else 'LIVE (it must bite)'))
    return not late


def main():
    import freshlib
    import boot_gate as B
    import midi_ctl_gate as G
    from midi_teeth import build
    tmp = tempfile.mkdtemp(prefix='boot_teeth_')
    res = {}
    try:
        names = [a for a in sys.argv[1:] if not a.startswith('-')]   # optional: these mutants only
        for name, what, path, old, new in MUTANTS:
            if names and name not in names:
                continue
            so = build(tmp, name, path, old, new)
            lib = ctypes.CDLL(so)
            freshlib.load = lambda lib=lib: lib
            print('--- mutant %s: %s' % (name, what))
            sys.stdout.flush()
            res[name] = G.check_port(tooth=name, ref_pkl=B.REF_PKL, title=B.TITLE)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-14s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    inert = start0_inert()
    ok = all(b for n, b in res.items() if n != 'start0' or not inert) and not (inert and res.get('start0'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
