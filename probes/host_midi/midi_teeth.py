"""The MIDI controller intake's teeth (CLAIMS B16): midi_ctl_gate.py --port against mutated builds
of the port, each a defect the gate must see (the controllers, CLAIMS A26; the sustain and
all notes off, CLAIMS B16b). Builds each mutant in a temporary directory (the tree
is not touched), loads it in this process only (libjuno only: two-process rule), runs the gate's
port check, prints how many chains each mutant breaks.

    python3 probes/host_midi/midi_teeth.py [mutant ...]     (needs cc and scratchpad/midi_ctl_ref.pkl)"""
import ctypes
import glob
import os
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))

MUTANTS = [
    ('bend_div', 'the bend as v / 8191 (the immediate-set census\'s law, unclamped: -8192 gives -1.0001)',
     'src/juno_midi.c', 'voices_arm(st, 4112u, 7456u, juno_curve(26, v + 8192));',
     'voices_arm(st, 4112u, 7456u, (float)v / 8191.0f);'),
    ('bend_unclamped16', 'the bend taken as an int, not its low 16 bits',
     'src/juno_midi.c', 'int v = (int16_t)(uint16_t)v16;', 'int v = v16;'),
    ('expr_t0', 'the expression ramped at time index 0, not 1',
     'src/juno_midi.c', 'juno_rr_arm(st, 101136u, juno_curve(18, v), 1);',
     'juno_rr_arm(st, 101136u, juno_curve(18, v), 0);'),
    ('mod_no_limit', 'the mod wheel taking CC bytes over 127 (clamped to 127)',
     'src/juno_midi.c', 'if ((unsigned)v > 127u) return;\n    voices_arm(st, 4000u',
     'if ((unsigned)v > 127u) v = 127;\n    voices_arm(st, 4000u'),
    ('no_ccmap', 'no default CC assignments',
     'src/juno_midi.c', 'return (cc >= 0 && cc < 128) ? JUNO_CC_MAP[cc] : -1;', 'return -1;'),
    ('trunc_ignored', 'the CC conversion always rounding (the entry\'s truncate flag ignored)',
     'src/juno_midi.c', 'if (p->trunc) {', 'if (0) {'),
    ('srate_listener', 'a parameter record of the engine-rate setting switching the rate (the listener)',
     'gui/juno_bridge.c',
     'if (e >= 0) engine_host_entry(c, juno_midi_entry_host(e), juno_midi_record_value(e, r->f));',
     'if (e >= 0) { if (juno_midi_entry_host(e) == JUNO_SE_SRATE) juno_gui_set_engine_rate_setting(c, '
     'juno_midi_record_value(e, r->f)); else engine_host_entry(c, juno_midi_entry_host(e), '
     'juno_midi_record_value(e, r->f)); }'),
    ('damper', 'the sustain as a damper: a new key with no key down does not free the held notes',
     'gui/juno_bridge.c', '    if (c->kb_sus_note && !kbm_any(c, KB_DOWN)) {\n        int i;\n        for (i = 127; i >= 0; --i) {\n            int o = c->kb_order[i];',
     '    if (0) {\n        int i;\n        for (i = 127; i >= 0; --i) {\n            int o = c->kb_order[i];'),
    ('no_alias_127', 'the press-order walk skipping an empty slot (no index -1, key 127 kept down)',
     'gui/juno_bridge.c', '            if (kbm_has(c, KB_LATCH, k)) { synth_note_off(c, k & 0xFF); kbm_clear(c, KB_LATCH, k); }',
     '            if (k >= 0 && kbm_has(c, KB_LATCH, k)) { synth_note_off(c, k & 0xFF); kbm_clear(c, KB_LATCH, k); }'),
    ('arp_no_hold', 'the arp sustain ignored: a key released under the pedal leaves the arp',
     'gui/juno_bridge.c', '    if (c->kb_sus_arp) kbl_add(&c->kb_arp_latch, k);\n    else arp_dispatch',
     '    if (0) kbl_add(&c->kb_arp_latch, k);\n    else arp_dispatch'),
    ('release_keeps', 'the pedal\'s release not freeing the held notes',
     'gui/juno_bridge.c', '    if (!on) kb_free_note_latch(c, (signed char)c->kb_flag8);', '    (void)0;'),
    ('cc123_no_flag', 'CC 123 without the held flag the last gate-off leaves (1856 stays)',
     'gui/juno_bridge.c', '    if (any) juno_note_broadcast_held(c->st, 0);\n}', '    (void)any;\n}'),
    ('cc123_keeps_mask', 'CC 123 keeping the assigner\'s held-note mask',
     'gui/juno_bridge.c', '    c->held_notes[0] = c->held_notes[1] = c->held_notes[2] = c->held_notes[3] = 0;\n    c->legato_mask = 0;\n    if (any)',
     '    c->legato_mask = 0;\n    if (any)'),
    ('switch_no_hold_transfer', 'the arp switch-on leaving the held notes out of the arp',
     'gui/juno_bridge.c', '            if (kbm_has(c, KB_LATCH, k)) kb_arp_key_on(c, k, c->kb_vel[k]);',
     '            if (0) kb_arp_key_on(c, k, c->kb_vel[k]);'),
    ('params_first', 'the parameter queues pushed before the note events',
     'gui/juno_bridge.c', '    for (i = 0; i < npar; ++i) proc_param(c, &par[i]);\n', ''),
]


def build(tmp, name, path, old, new):
    d = os.path.join(tmp, name)
    shutil.copytree(os.path.join(REPO, 'src'), os.path.join(d, 'src'))
    os.makedirs(os.path.join(d, 'gui'))
    shutil.copy(os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(d, 'gui', 'juno_bridge.c'))
    f = os.path.join(d, path)
    s = open(f).read()
    if s.count(old) != 1:
        raise SystemExit('%s: the mutation site is not unique in %s' % (name, path))
    s = s.replace(old, new)
    if name == 'params_first':       # the queues before the events
        site = '    for (i = 0; i < nev; ++i) {\n        unsigned char m[3];\n        float v = ev[i].velocity;'
        if s.count(site) != 1:
            raise SystemExit('params_first: the event loop is not unique')
        s = s.replace(site, '    for (i = 0; i < npar; ++i) proc_param(c, &par[i]);\n' + site)
    open(f, 'w').write(s)
    so = os.path.join(d, 'libjuno.so')
    cmd = ['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so,
           os.path.join(d, 'gui', 'juno_bridge.c')] + sorted(glob.glob(os.path.join(d, 'src', '*.c'))) + ['-lm']
    subprocess.check_call(cmd)
    return so


def main():
    import freshlib
    import midi_ctl_gate as G
    tmp = tempfile.mkdtemp(prefix='midi_teeth_')
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
            res[name] = G.check_port(tooth=name)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-18s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
