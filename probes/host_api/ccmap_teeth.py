"""The CC map's teeth (CLAIMS A31): ccmap_state_gate.py --port against mutated builds of the port,
each a defect in the core's CC map (src/juno_midi.c juno_ccmap_*, gui/juno_bridge.c) the gate must
see. Builds each mutant in a temporary directory (the tree is not touched; the builder is
midi_teeth.py's), loads it in this process only (libjuno only: two-process rule), runs the gate's
port check, prints how many chains each mutant breaks.

    python3 probes/host_api/ccmap_teeth.py [mutant ...]     (needs cc and scratchpad/ccmap_state_ref.pkl)"""
import ctypes
import os
import shutil
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'host_midi'))

B = 'gui/juno_bridge.c'
M = 'src/juno_midi.c'
MUTANTS = [
    ('const_map', 'the push reading the boot\'s map, not the core\'s (the port before CLAIMS A31)',
     B, '        int e = juno_ccmap_lookup(&c->ccmap, m[1]);', '        int e = juno_midi_cc_entry(m[1]);'),
    ('no_clear', 'a state load that keeps the old map (no rva 0x31A4F0)',
     B, '    juno_ccmap_clear(&c->ccmap);              /* rva 0x31A4F0 (-1): the CC map emptied */\n', ''),
    ('entries_ignored', 'the map entries skipped (the map emptied, never refilled)',
     B, '        if (juno_ccmap_state_entry(&c->ccmap, id, v)) continue;   /* rva 0x31A6A0 */',
     '        if (id - 0x10000000u <= 0x7Fu) continue;'),
    ('no_boot_map', 'no default assignments at the boot',
     M, 'return (cc >= 0 && cc < 128) ? JUNO_CC_MAP[cc] : -1;', 'return -1;'),
    ('first_wins', 'a CC given twice keeps its first entry',
     M, '    m->map[cc] = (int8_t)e;\n    m->rec[e] = (int8_t)cc;\n    return 1;',
     '    if (m->map[cc] < 0) m->map[cc] = (int8_t)e;\n    m->rec[e] = (int8_t)cc;\n    return 1;'),
    ('one_cc_per_param', 'a parameter keeping one CC (a new CC for it frees the old one)',
     M, '    m->map[cc] = (int8_t)e;\n    m->rec[e] = (int8_t)cc;\n    return 1;',
     '    if (m->rec[e] >= 0) m->map[m->rec[e]] = -1;\n    m->map[cc] = (int8_t)e;\n    m->rec[e] = (int8_t)cc;\n    return 1;'),
]


def main():
    import freshlib
    import ccmap_state_gate as S
    import midi_ctl_gate as G
    from midi_teeth import build
    base = G.check_port(ref_pkl=S.REF_PKL, title=S.TITLE + ' -- baseline')           # a mutant counts only on a green gate (playbook 155)
    if base:
        print('BASELINE RED: %d chains fail on the unmutated port -- teeth not graded' % base)
        return 2
    tmp = tempfile.mkdtemp(prefix='ccmap_teeth_')
    res = {}
    try:
        names = [a for a in sys.argv[1:] if not a.startswith('-')]
        for name, what, path, old, new in MUTANTS:
            if names and name not in names:
                continue
            so = build(tmp, name, path, old, new)
            lib = ctypes.CDLL(so)
            freshlib.load = lambda lib=lib: lib
            print('--- mutant %s: %s' % (name, what))
            sys.stdout.flush()
            res[name] = G.check_port(tooth=name, ref_pkl=S.REF_PKL, title=S.TITLE)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-17s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
