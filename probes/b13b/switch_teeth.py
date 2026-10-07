"""The engine-rate switch's teeth (CLAIMS B13b): rate_switch_gate.py --port against mutated builds of
the port, each a defect in the in-place switch (gui/juno_bridge.c setsr_inplace, src/recall_ramp.c
juno_rr_setsr_*) the gate must see. Builds each mutant in a temporary directory (the tree is not
touched; the builder is midi_teeth.py's), loads it in this process only (libjuno only: two-process
rule), runs the gate's port check, prints how many chains each mutant breaks.

    [ONLY=chain,...] python3 probes/b13b/switch_teeth.py [mutant ...]   (needs cc and scratchpad/rate_switch_ref.pkl)"""
import ctypes
import os
import shutil
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'host_midi'))

B = 'gui/juno_bridge.c'
R = 'src/recall_ramp.c'
MUTANTS = [
    ('refused', 'the switch on a running engine refused (the port before CLAIMS B13b: the rate kept)',
     B, '            setsr_inplace(c, (float)c->eng_req, 1);', '            return 0;'),
    ('no_suspend', 'no processor suspend (the mute ramps down)',
     B, '    juno_rr_setsr_suspend(c->st);', '    (void)0;'),
    ('no_resume', 'no processor resume (the mute ramps up)',
     B, '    juno_rr_setsr_resume(c->st);', '    (void)0;'),
    ('no_reapply', 'no re-apply of the rate-dependent cells',
     B, '    juno_rr_setsr_reapply(c->st, ref);', '    (void)0;'),
    ('no_reverb_taps', 'the reverb taps and wipe countdown not re-applied',
     R, '    for (i = 0; i < 34; ++i) JI(st, 11022208u + 4u * (uint32_t)i) = JI(r, 11022208u + 4u * (uint32_t)i);',
     '    (void)0;'),
    ('no_runtime_reset', 'no runtime reset (sub_1803A1300): memories and buffers kept',
     B, '    juno_chorus_init(c->st);                          /* sub_1803A1300 */', '    (void)0;'),
    ('no_constants', 'no constructor constants (sub_1803990C0)',
     B, '    juno_engine_init_core(c->st);                     /* sub_1803990C0 */', '    (void)0;'),
    ('build_extras', 'the BUILD wrapper\'s state written too (the DCO latches re-armed)',
     B, '    juno_engine_init_core(c->st);                     /* sub_1803990C0 */',
     '    juno_engine_init(c->st);'),
    ('ref_old_rate', 'the re-applied values from a recall at the old rate',
     B, '    st_build(ref, rate, &rshim, c->chorus_mode);     /* the build\'s rate laws at the new rate */',
     '    st_build(ref, old, &rshim, c->chorus_mode);'),
    ('resume_old_rate', 'the resume armed before the rate changes',
     B, '    JF(c->st, 16) = rate;                             /* rva 0x3C2770: the records\' rate */\n'
        '    juno_engine_init_core(c->st);                     /* sub_1803990C0 */\n'
        '    juno_chorus_init(c->st);                          /* sub_1803A1300 */\n'
        '    juno_driver_unit_noise_reinit(c->st);             /* ... in every unit\'s noise copy */\n'
        '    juno_rr_setsr_resume(c->st);                      /* vt5, at the new rate */',
     '    juno_rr_setsr_resume(c->st);\n    JF(c->st, 16) = rate;\n    juno_engine_init_core(c->st);\n'
     '    juno_chorus_init(c->st);\n    juno_driver_unit_noise_reinit(c->st);'),
    ('no_noise_reinit', 'the units\' noise copies not re-initialized (the shared block only)',
     B, '    juno_driver_unit_noise_reinit(c->st);             /* ... in every unit\'s noise copy */',
     '    (void)0;'),
    ('nan_tank', 'the reverb tank\'s level test as the decompiler wrote it (a NaN level runs the tank)',
     'src/master_render.c', '  if ( !(v475 > 0.0) || (v476 = *(float *)(a1 + 10759376), !(v476 > 0.0)) )',
     '  if ( v475 <= 0.0 || (v476 = *(float *)(a1 + 10759376), v476 <= 0.0) )'),
    ('predelay_clamp', 'the reverb pre-delay clamped at 0 (the old integer law)',
     'src/reverb_recall.c', '    return (int)(long long)x - 2;                        /* cvttss2si rdi; sub edi, 2 */',
     '    return (int)(long long)x - 2 < 0 ? 0 : (int)(long long)x - 2;'),
    ('reverb_once', 'the reverb\'s re-arm sequence run once, not twice',
     R, '    for (k = 0; k < 2; ++k) {                             /* the reverb (+0x1ff0), twice */',
     '    for (k = 0; k < 1; ++k) {'),
]


def main():
    import freshlib
    import rate_switch_gate as S
    import midi_ctl_gate as G
    from midi_teeth import build
    tmp = tempfile.mkdtemp(prefix='switch_teeth_')
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
            only = os.environ.get('ONLY')        # e.g. ONLY=run48,fx: these chains only
            res[name] = G.check_port(tooth=name, only=only.split(',') if only else None,
                                     ref_pkl=S.REF_PKL, title=S.TITLE)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print()
    for name, b in res.items():
        print('%-17s %s (%d chains differ)' % (name, 'BITES' if b else 'DID NOT BITE', b))
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
