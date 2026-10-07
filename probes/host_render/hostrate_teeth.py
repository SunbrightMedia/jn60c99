"""The host-rate change's teeth (CLAIMS B13c): host_rate_gate.py --port against mutated builds of
the port (probes/host_midi/midi_teeth.py's builder: each mutant in a temporary directory, the tree
untouched, loaded in this process only -- libjuno only, two-process rule).

    python3 probes/host_render/hostrate_teeth.py      (needs cc and scratchpad/host_rate_ref.pkl)"""
import ctypes
import os
import shutil
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'host_midi'))

MUTANTS = [
    ('no_reset', 'the tick phase and the note count kept at a found object',
     'gui/juno_bridge.c', '    if (juno_ro_lookup(&c->ro) > 0) { c->drv_phase = 0; c->drv_notes = 0; }\n    if (c->drv_nq < DRV_QMAX) {',
     '    juno_ro_lookup(&c->ro);\n    if (c->drv_nq < DRV_QMAX) {'),
    ('old_tick_rate', 'the tick period still timed at the old host rate',
     'gui/juno_bridge.c', '    c->drv_rate = c->setup_rate;\n    c->ro.host = c->setup_rate;',
     '    c->ro.host = c->setup_rate;'),
    ('cold_restart', 'the engine restarted cold at the new rate (the port before B13c: juno_gui_reinit + plugin_init)',
     'gui/juno_bridge.c', '    (void)on;\n    if (!c || c->ro_model) return;',
     '    (void)on;\n    if (!c || c->ro_model) return;\n    if (on) { int r = c->setup_rate; juno_gui_reinit(c, (float)r, c->chorus_mode); juno_gui_plugin_init(c); return; }'),
    ('no_cc120', 'the all-sound-off record dropped (inert: CC 120 reaches no engine entry -- must NOT bite)',
     'gui/juno_bridge.c', '        r->m[0] = 0xB0; r->m[1] = 120; r->m[2] = 0;', '        r->m[0] = 0; r->m[1] = 0; r->m[2] = 0; --c->drv_nq;'),
]


def main():
    import freshlib
    import host_rate_gate as HG
    import midi_teeth as MT
    tmp = tempfile.mkdtemp(prefix='hostrate_teeth_')
    res = {}
    HG.G.PRELUDE = 256
    try:
        for name, what, path, old, new in MUTANTS:
            so = MT.build(tmp, name, path, old, new)
            lib = ctypes.CDLL(so)
            freshlib.load = lambda lib=lib: lib
            print('--- mutant %s: %s' % (name, what))
            sys.stdout.flush()
            res[name] = HG.G.check_port(tooth=name, ref_pkl=HG.REF_PKL, title=HG.TITLE)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-14s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    ok = all(b for n, b in res.items() if n != 'no_cc120') and not res.get('no_cc120')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
