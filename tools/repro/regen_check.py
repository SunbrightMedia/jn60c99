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
    ('finefx_tables', ['src/finefx_tables.h'], [
        'tools/verify/finefx_delay_rates.py', 'tools/verify/chorus_finefx_derive.py', 'tools/verify/reverb_finefx_derive.py',
        'tools/verify/gen_finefx_c.py', 'tools/verify/gen_chorus_finefx_c.py', 'tools/verify/gen_reverb_finefx_c.py']),
    ('teensy_golden', ['tests/teensy_golden.h', 'tools/verify/teensy_golden.json'], ['tools/verify/gen_teensy_golden.py']),
    ('note_table', [], ['tools/verify/notevel_exhaust.py --ref', 'tools/verify/notevel_exhaust.py --check-table']),
    ('rdata_tables', [], ['tools/repro/rdata_check.py']),
]


def run(cmd, log):
    out = None
    if ' > ' in cmd:
        cmd, out = cmd.split(' > ')
    argv = [PY] + cmd.split()
    t0 = time.time()
    with open(log, 'a') as lg:
        lg.write('$ %s%s\n' % (' '.join(argv), (' > ' + out) if out else ''))
        lg.flush()
        if out:
            with open(os.path.join(REPO, out), 'w') as f:
                r = subprocess.run(argv, cwd=REPO, stdout=f, stderr=lg)
        else:
            r = subprocess.run(argv, cwd=REPO, stdout=lg, stderr=subprocess.STDOUT)
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
