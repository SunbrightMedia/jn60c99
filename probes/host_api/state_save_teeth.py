"""The state save's teeth (CLAIMS A32): state_save_gate.py --port against mutated builds of the port,
each a defect in the parameter store, the UI timer's drain or MIDI learn (gui/juno_bridge.c,
src/juno_midi.c) the gate must see. Builds each mutant in a temporary directory (the tree is not
touched; the builder is midi_teeth.py's), loads it in this process only (libjuno only: two-process
rule), runs the gate's port check, prints how many chains each mutant breaks.

    python3 probes/host_api/state_save_teeth.py [mutant ...]     (needs cc and scratchpad/state_save_ref.pkl)"""
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
    ('no_link', 'the bytes not setting their host-only float',
     B, '    if (id == 0x00600004u || id == 0x0060003Au) {\n        float h', '    if (0) {\n        float h'),
    ('link_div', 'the host-only float as byte / 255 (not byte x (1 / 255))',
     B, 'float h = (float)v * (1.0f / 255.0f);', 'float h = (float)v / 255.0f;'),
    ('no_mask', 'the store keeping every value unmasked',
     B, '    if (masked && JUNO_STATE_ENT[k].mask) v = (int32_t)((uint32_t)v & JUNO_STATE_ENT[k].mask);',
     '    (void)masked;'),
    ('patch_masked', 'a patch load masking the values it stores (as setState does)',
     B, '        if (sk >= 0) store_put(c, sk, v, 0);', '        if (sk >= 0) store_put(c, sk, v, 1);'),
    ('patch_no_store', 'a patch load leaving the store',
     B, '        if (sk >= 0) store_put(c, sk, v, 0);', '        (void)sk;'),
    ('host_records_store', 'host parameter records written to the store (the store following automation)',
     B, '            r->id = p->id;\n            r->f = (float)p->value;\n        }\n        return;',
     '            r->id = p->id;\n            r->f = (float)p->value;\n        }\n        ui_push(c, p->id, (float)p->value);\n        return;'),
    ('tick_no_store', 'the drain dropping the store records',
     B, '        if (e >= 0 && k >= 0) store_set(c, k, juno_midi_record_value(e, c->ui_q[i].f));',
     '        (void)e; (void)k;'),
    ('push_no_store_record', 'a mapped CC queueing no store record',
     B, '        if (e >= 0) ui_push(c, juno_midi_entry_id(e), juno_midi_cc_value(e, m[2]));', ''),
    ('learn_last_cc', 'the learn taking the last CC since the drain, not the first',
     B, '        if (c->ui_cc < 0 && m[1] < 120) c->ui_cc = m[1];', '        if (m[1] < 120) c->ui_cc = m[1];'),
    ('learn_any_cc', 'the drain offering CC 120..127 to the learn (the plugin passes them over)',
     B, '        if (c->ui_cc < 0 && m[1] < 120) c->ui_cc = m[1];', '        if (c->ui_cc < 0) c->ui_cc = m[1];'),
    ('learn_keeps_old', 'the learning record keeping its old CC in the map',
     M, '    old = m->rec[r];                         /* the map\'s key of the record\'s old CC, erased */\n    if (old >= 0) m->map[old] = -1;',
     '    old = m->rec[r];\n    (void)old;'),
    ('forget_noop', 'forget doing nothing',
     M, '    old = m->rec[entry];\n    if (old >= 0) m->map[old] = -1;\n    m->rec[entry] = -1;', '    (void)old;'),
    ('setting_no_store', 'the setting\'s own switch not stored in the model',
     B, '    store_set(c, state_k(0x0FFFC015u), value);       /* the model\'s value (getState) */\n', ''),
    ('count_always4', 'the count always 4 bytes (the port before this claim)',
     B, '    hw = ((JUNO_STATE_N + 128) << 6) / 5 < len ? 8 : 4;', '    hw = 4;'),
    ('short_rejected', 'a payload the stream does not hold in full rejected (the port before this claim)',
     B, '    if (cnt <= 0) return -1;', '    if (cnt <= 0 || (uint32_t)cnt > (uint32_t)len - 4u) return -1;'),
    ('save_rec_view', 'getState writing each record\'s own CC view, not the map',
     B, '        put_be32(p + 4, (uint32_t)juno_ccmap_state_value(&c->ccmap, k));',
     '        { int e2, f = -1; for (e2 = 0; e2 < JUNO_CCMAP_RECS; ++e2) if (c->ccmap.rec[e2] == k) f = (int)juno_midi_entry_id(e2); put_be32(p + 4, (uint32_t)f); }'),
]


def main():
    import freshlib
    import state_save_gate as S
    from midi_teeth import build
    base = S.check_port(title='baseline (the port as built)')           # a mutant counts only on a green gate (playbook 155)
    if base:
        print('BASELINE RED: %d chains fail on the unmutated port -- teeth not graded' % base)
        return 2
    tmp = tempfile.mkdtemp(prefix='state_save_teeth_')
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
            res[name] = S.check_port(title='mutant ' + name)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-21s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
