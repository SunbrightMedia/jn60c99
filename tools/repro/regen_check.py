#!/usr/bin/env python3
"""regen_check.py -- every generated file of the JUNO-60 port rebuilt from the plugin and compared,
byte for byte, with the commit (task #62: "PROVEN repeatable" for the derivations, not only the gates).

Each entry runs its probes (Unicorn only: the oracle's census pickles, written into THIS tree's
scratchpad/) and its generator, which writes the file in place or to standard output; then the file
must equal the committed one (`git diff --quiet`). It rewrites tracked files, so it refuses to run in
a tree with uncommitted changes to them -- run it in a fresh clone (tools/repro/reproduce.sh does) or a
snapshot whose scratchpad is its own.

usage: python3 tools/repro/regen_check.py [--list] [--only NAME,...] [--force]
exit 1 when a file differs or a step fails.
"""
import os
import subprocess
import sys
import time

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PY = sys.executable

# name: (the files it writes, the commands; a command ending in "> FILE" writes FILE from stdout)
ENTRIES = [
    ('carp_patterns', ['src/carp_patterns.h'], ['tools/gen_carp_patterns.py > src/carp_patterns.h']),
    ('midi_tables', ['src/midi_tables.h'], ['tools/verify/gen_midi_tables.py > src/midi_tables.h']),
    ('conv_tables', ['src/conv_tables.h'], ['tools/verify/gen_conv_tables.py > src/conv_tables.h']),
    ('boot_ramps', ['src/boot_ramps.h'], ['tools/verify/gen_boot_ramps.py > src/boot_ramps.h']),
    ('state_tables', ['src/juno_state_tables.h'], [
        'probes/b6/state_load_census.py', 'probes/b6/state_mask_census.py', 'probes/b6/patch_load_census.py',
        'probes/b6/patch_load_census.py --craft', 'probes/b6/pid_host_map.py', 'tools/verify/gen_state_tables.py']),
    ('host_ramps', ['src/ramp_cells.h', 'src/host_ramp_table.h'], [
        'probes/host/ramp_records_units.py', 'probes/host/host_census_v2.py', 'probes/host/host_census_v3.py',
        'probes/host/host_census_flags.py', 'probes/host/host_census_h.py', 'probes/host/host_census_mt.py',
        'probes/host/host_census_dtype.py', 'tools/verify/gen_host_ramps.py']),
    # the committed order: delay, reverb, chorus; the reverb tables from the pillar-3 gate's own reference
    # (its four table rates, into a file of their own so the gate's 18-rate reference is never replaced)
    ('finefx_tables', ['src/finefx_tables.h'], [
        'tools/verify/finefx_delay_rates.py', 'tools/verify/chorus_finefx_derive.py',
        'JUNO_FINEFX_REF_PKL=scratchpad/finefx_reverb_ref.pkl tools/verify/finefx_cellsweep.py 44100 48000 88200 96000',
        'tools/verify/gen_finefx_c.py',
        'JUNO_FINEFX_REF_PKL=scratchpad/finefx_reverb_ref.pkl tools/verify/gen_reverb_finefx_c.py',
        'tools/verify/gen_chorus_finefx_c.py']),
    ('teensy_golden', ['tests/teensy_golden.h', 'tools/verify/teensy_golden.json'], ['tools/verify/gen_teensy_golden.py']),
    ('arp_golden', ['tests/arp_pattern_golden.h'], [
        'tools/verify/arp_sched_ab.py --ref-goldens', 'tools/verify/arp_sched_ab.py --emit-goldens']),
    # engine B (the S3 fork) and the firmware's generated headers
    ('eb_devcells', [], ['tools/engineb/gen_devcells.py --check']),
    ('eb_fork_tab', ['engine_b/eb_pitch_fork_tab.h'], [
        'tools/engineb/fork_tab_input.py > scratchpad/fork_tab_input.txt',
        'tools/engineb/gen_fork_tab.py scratchpad/fork_tab_input.txt']),
    ('eb_halfos_fir', ['engine_b/eb_halfos_fir.h'], ['tools/engineb/gen_halfos_fir.py']),
    ('eb_reverb_halfband', ['engine_b/eb_reverb_halfband.h'], ['tools/engineb/gen_reverb_halfband.py']),
    ('s3_vectors', ['esp32s3/main/s3_pitch_vectors.h', 'esp32s3/main/s3_exp_vectors.h'], ['tools/engineb/gen_s3_vectors.py']),
    ('note_table', [], ['tools/verify/notevel_exhaust.py --ref', 'tools/verify/notevel_exhaust.py --check-table']),
    ('rdata_tables', [], ['tools/repro/rdata_check.py']),
]


def run(cmd, log):
    out = None
    if ' > ' in cmd:
        cmd, out = cmd.split(' > ')
    words = cmd.split()
    env = dict(os.environ)
    while words and '=' in words[0] and not words[0].endswith('.py'):   # VAR=value before the script
        k, v = words.pop(0).split('=', 1)
        env[k] = v
    argv = [PY] + words
    t0 = time.time()
    with open(log, 'a') as lg:
        lg.write('$ %s%s\n' % (' '.join(argv), (' > ' + out) if out else ''))
        lg.flush()
        if out:
            with open(os.path.join(REPO, out), 'w') as f:
                r = subprocess.run(argv, cwd=REPO, stdout=f, stderr=lg, env=env)
        else:
            r = subprocess.run(argv, cwd=REPO, stdout=lg, stderr=subprocess.STDOUT, env=env)
    return r.returncode, time.time() - t0


def main():
    if '--list' in sys.argv:
        for name, files, cmds in ENTRIES:
            print('%-14s %s\n    %s' % (name, ' '.join(files) or '(a check)', '\n    '.join(cmds)))
        return 0
    only = sys.argv[sys.argv.index('--only') + 1].split(',') if '--only' in sys.argv else None
    tracked = [f for _, files, _ in ENTRIES for f in files]
    dirty = subprocess.run(['git', 'status', '--porcelain', '--'] + tracked, cwd=REPO, capture_output=True, text=True).stdout
    if dirty.strip() and '--force' not in sys.argv:
        raise SystemExit('regen_check: the generated files have uncommitted changes here -- run it in a fresh clone:\n' + dirty)
    os.makedirs(os.path.join(REPO, 'scratchpad', 'b6'), exist_ok=True)
    log = os.path.join(REPO, 'scratchpad', 'regen_check.log')
    bad = 0
    for name, files, cmds in ENTRIES:
        if only and name not in only:
            continue
        # the port library before EVERY entry: some generators load it (teensy_golden), a fresh
        # clone has none, and the entries before rewrite src/ headers (identical bytes, new times),
        # so a library built once at the start is older than its sources and the generators'
        # stale-guard refuses it (proof run repro3, 2026-10-10). make rebuilds only when needed.
        if subprocess.run(['make', '-s', 'libjuno.so'], cwd=REPO).returncode:
            raise SystemExit('regen_check: make libjuno.so failed before ' + name)
        t, fail = 0.0, None
        for c in cmds:
            rc, dt = run(c, log)
            t += dt
            if rc:
                fail = 'step failed: %s (exit %d)' % (c, rc)
                break
        if not fail and files:
            diff = subprocess.run(['git', 'diff', '--stat', '--'] + files, cwd=REPO, capture_output=True, text=True).stdout.strip()
            if diff:
                fail = 'DIFFERS from the commit: ' + diff.replace('\n', '; ')
        print('%-4s %-14s %s (%d s)' % ('ok' if not fail else 'FAIL', name,
                                        fail or ('IDENTICAL: ' + ' '.join(files) if files else 'check passed'), t), flush=True)
        bad += fail is not None
    print('regen_check: %s (log: %s)' % ('GREEN' if not bad else 'RED -- %d entries' % bad, os.path.relpath(log, REPO)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
