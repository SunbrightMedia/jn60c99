#!/usr/bin/env python3
"""jx_mutation_gate.py -- MEASURE THE REACH OF THE JX GATES (docs/PORT_COMPLETENESS_CHARTER.md section 4).

Reading a gate tells what it checks; only breaking the port tells what it MISSES. Each mutation below puts ONE
plausible slip into one part of the JX port -- a constant a hair off, an operand dropped, a table entry moved --
in a line that RUNS (the DSP sites were chosen from a gcov run of the product path: patches 5 and 34 played,
every chosen line executed 225,000 to 4,700,000 times), the port's library is rebuilt (its hash must change, else
the mutation is a no-op: SKIP), and ONE fast gate runs on the mutated tree: KILLED when it fails, SURVIVED (a blind
spot: a gate to write) when it passes. Each file is restored after its mutation. The lift's own mutation (one
addss of the lifted parameter system made a subss) is jx_lift_gate.py --tooth, in GATE 3e.

    python3 jx3p/tools/jx_mutation_gate.py [--only NAME,...] [--list]
Run it in a snapshot (tools/snap_tree.sh): it edits the tree it runs in, one file at a time.
exit 0 = every mutation KILLED (or SKIP with its reason).
"""
import hashlib
import os
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
PY = sys.executable
PG = [PY, 'jx3p/tools/jx_product_gate.py']
PLAY = PG + ['--rates', '48000', '--patches', '5', '--on', '0.55', '--off', '1.0', '--secs', '1.2']

# (name, the part of the port it probes, file, the text (once in the file), its replacement, the gate)
MUTATIONS = [
    # this filter's output reaches the audio one sample later only through a mix coefficient that is 0 on patch 5
    # -- MEASURED: with the slip 6 voice words differ (+0xD30, +0xD40, +0x2430, +0x2440, +0x2650, +0x3210), the audio
    # is bit-identical at 48 / 96 kHz. No audio gate sees it, and the unit-state gate at 44.1 kHz never runs this
    # branch (both SURVIVED, 2026-10-10); the unit-state gate at the product's 96 kHz engine compares every voice word
    ('voice_filter', 'voice DSP (a filter accumulation, 1.3 M runs; its state only)', 'jx3p/src/jx_voice_render.c',
     'v1121 = (float)((float)(v1118 * *(float *)(st + 10432 + 16128*(v)))',
     'v1121 = (float)((float)(v1118 * 1.0000001f * *(float *)(st + 10432 + 16128*(v)))',
     [PY, 'jx3p/tools/jx_master_bisect.py', '--rate', '96000', '5', '4000']),
    ('master_gain', 'master chain (an effect gain, 225 k runs)', 'jx3p/src/jx_master_render.c',
     'v488 = v487 * *(float *)(st + 270016);', 'v488 = v487 * 1.0000001f * *(float *)(st + 270016);', PLAY),
    ('helper_poly', 'voice helper (a polynomial term, 4.2 M runs)', 'jx3p/src/jx_voice_helpers.c',
     'v4 = v2 * v1 * v1;', 'v4 = v2 * v1 * v1 * 1.0000001;', PLAY),
    ('converter_tap', 'the render object\'s rate converter (a filter tap, 4.7 M runs)', 'src/juno_conv.c',
     'sum = sum + x[xi] * hk;', 'sum = sum + x[xi] * hk * 1.0000001f;', PLAY),
    # (60e9 + 1 in place of 60e9, the first form of this mutation, moves a tick by 1e-8 sample per tick: no run of
    # seconds can see it -- SURVIVED, an equivalent slip in practice; 23 ticks a beat is a real one)
    ('driver_clock', 'the render driver\'s clock period (23 ticks a beat)', 'jx3p/gui/jx_bridge.c',
     'P = T > 0 ? (60000000000LL * (long long)g_drv_rate / T) / 24',
     'P = T > 0 ? (60000000000LL * (long long)g_drv_rate / T) / 23',
     PG + ['--rates', '48000', '--patches', '34', '--on', '0.55', '--off', '1.6', '--secs', '1.8']),
    ('record_law', 'the driver\'s value law for host automation (half no longer rounded up)', 'jx3p/gui/jx_bridge.c',
     '    r = (0.0 > r) ? ceil(r - 0.5) : floor(r + 0.5);\n#else',
     '    r = (0.0 > r) ? ceil(r - 0.5) : floor(r + 0.499);\n#else',     # VCF CUTOFF at 0.5: 127.5 -> 128, the slip 127
     PG + ['--rates', '48000', '--patches', '0', '--on', '0.6', '--off', '1.0', '--secs', '1.2', '--set', '60003A=0.5']),
    ('state_mask', 'the DAW state\'s storage law (VCF CUTOFF & 0xFF made & 0x7F)', 'jx3p/src/jx_state_tables.h',
     '{ 0x0060003Au, 0xFFu,', '{ 0x0060003Au, 0x7Fu,', [PY, 'jx3p/tools/jx_state_gate.py', '--chains', '3']),
    ('patch_offset', 'the patch browser\'s decode (MASTER TUNE read one byte late)', 'jx3p/src/jx_patch_tables.h',
     '{ 0x00000002u, 18u,', '{ 0x00000002u, 19u,', [PY, 'jx3p/tools/jx_patch_gate.py', '--chains', '1']),
    ('srate_table', 'the engine-rate setting table (48000 made 48001)', 'jx3p/src/jx_srate.h',
     '96000, 88200, 48000, 44100,', '96000, 88200, 48001, 44100,',
     PG + ['--rates', '48000', '--patches', '0', '--on', '0.55', '--secs', '1.2', '--state', 'r2@0']),
    ('midi_range', 'the host automation id map\'s range (VCF CUTOFF 0..255 made 0..254)', 'jx3p/src/jx_midi_tables.h',
     '{ 0x0060003Au, 0, 255, 0 },', '{ 0x0060003Au, 0, 254, 0 },',
     PG + ['--rates', '48000', '--patches', '0', '--on', '0.6', '--off', '1.0', '--secs', '1.2', '--set', '60003A=0.7']),
    ('boot_record', 'initialize\'s records (the all-sound-off message made CC 121)', 'jx3p/src/jx_state_tables.h',
     '#define JX_STATE_BOOT_MIDI1 0x78u', '#define JX_STATE_BOOT_MIDI1 0x79u',
     [PY, 'jx3p/tools/jx_state_gate.py', '--chains', '0']),
]


def lib_hash(root, tmp):
    so = os.path.join(tmp, 'm.so')
    r = subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o',
                        so] + [os.path.join(root, s) for s in SRCS] + ['-lm'], capture_output=True, text=True)
    if r.returncode:
        return None
    return hashlib.sha256(open(so, 'rb').read()).hexdigest()


def main():
    a = sys.argv[1:]
    if '--list' in a:
        for m in MUTATIONS:
            print('%-14s %s  (%s)' % (m[0], m[1], m[2]))
        return 0
    only = set(a[a.index('--only') + 1].split(',')) if '--only' in a else None
    root = REPO
    tmp = tempfile.mkdtemp()
    base = lib_hash(root, tmp)
    if base is None:
        raise SystemExit('the unmutated port does not build')
    killed, survived, skipped = [], [], []
    for name, what, rel, old, new, gate in MUTATIONS:
        if only and name not in only:
            continue
        path = os.path.join(root, rel)
        src = open(path).read()
        if src.count(old) != 1:
            raise SystemExit('%s: the text is in %s %d times (want 1) -- the table is stale' % (name, rel, src.count(old)))
        t0 = time.time()
        try:
            open(path, 'w').write(src.replace(old, new))
            h = lib_hash(root, tmp)
            if h is None or h == base:
                skipped.append(name)
                print('  SKIP     %-14s %s: %s' % (name, what, 'does not build' if h is None else 'the library is unchanged'),
                      flush=True)
                continue
            r = subprocess.run(gate, cwd=root, capture_output=True, text=True)
            tail = (r.stdout.strip().split('\n') or [''])[-1][:110]
            (killed if r.returncode else survived).append(name)
            print('  %-8s %-14s %s (%.0fs): %s' % ('KILLED' if r.returncode else 'SURVIVED', name, what, time.time() - t0,
                                                   tail), flush=True)
        finally:
            open(path, 'w').write(src)
    if lib_hash(root, tmp) != base:
        raise SystemExit('the tree was not restored: the library differs from the unmutated one')
    print('jx_mutation_gate: %d killed, %d survived %s, %d skipped -- %s' % (
        len(killed), len(survived), survived, len(skipped), 'GREEN' if not survived and killed else 'RED'))
    return 0 if not survived and killed else 1


if __name__ == '__main__':
    sys.exit(main())
