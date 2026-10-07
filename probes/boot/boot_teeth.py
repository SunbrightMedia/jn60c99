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
    ('start0', 'every boot ramp from 0 (the 22 other starts ignored)',
     'src/recall_ramp.c', 'memcpy(&start, &JUNO_BOOT_RAMP[k].start, 4);', 'start = 0.0f;'),
    ('no_toggle', 'the record\'s stored target left as the build left it before the arm',
     'src/recall_ramp.c', '        rec_at(st, i)->target = (target == 0.0f) ? 1.0f : 0.0f;\n', ''),
    ('stopped_pump', 'the ramp pump stepping the units the voice count stops (their boot ramps run on)',
     'src/recall_ramp.c', 'if (u < 8 && u >= nv) { ++k; continue; }', '(void)nv;'),
]


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
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
