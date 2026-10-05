#!/usr/bin/env python3
"""tooth_tree.py -- the one scaffold every gate's --tooth uses.

A tooth is a deliberate, named defect: copy the tree into scratchpad/,
apply exact text edits to the PORT, rebuild libjuno.so there, run the gate's
--port check against the SAME oracle pickles (scratchpad/ is symlinked), and
require the gate to FAIL (exit 1). Every gate must be SEEN TO FAIL before it
is believed (CLAUDE.md); this makes that one call instead of a copied block.

    from tooth_tree import run_tooth
    rc = run_tooth('effect_depth',
                   [('src/effect_modes.c', 'if (etype <= 1)', 'if (0)')],
                   ['tools/verify/effect_param_gate.py', '--port'])

Returns 0 when the tooth BITES, 1 when it does not (the gate is then NOT
believed), 2 when the mutant does not build or an anchor is stale. Each
anchor must occur exactly once: a moved anchor is a stale gate, never a pass.
"""
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')


def run_tooth(name, edits, gate_cmd, tail=3000):
    d = os.path.join(SCRATCH, 'tooth_' + name)
    if os.path.exists(d):
        shutil.rmtree(d)
    os.makedirs(d)
    try:
        for sub in ('src', 'gui', 'tools', 'truth', 'tests'):
            if os.path.isdir(os.path.join(REPO, sub)):
                shutil.copytree(os.path.join(REPO, sub), os.path.join(d, sub), symlinks=True)
        shutil.copy(os.path.join(REPO, 'Makefile'), d)
        os.symlink(SCRATCH, os.path.join(d, 'scratchpad'))
        for rel, old, new in edits:
            p = os.path.join(d, rel)
            s = open(p).read()
            if s.count(old) != 1:
                print('TOOTH %s: anchor occurs %d times in %s -- the tooth is stale'
                      % (name, s.count(old), rel))
                return 2
            open(p, 'w').write(s.replace(old, new))
        r = subprocess.run(['make', '-s', 'libjuno.so'], cwd=d, capture_output=True, text=True)
        if r.returncode:
            print(r.stdout + r.stderr)
            print('TOOTH %s: BUILD FAILED -- no verdict' % name)
            return 2
        r = subprocess.run([sys.executable] + list(gate_cmd), cwd=d,
                           capture_output=True, text=True)
        print(r.stdout[-tail:])
        if r.returncode == 1:
            print('TOOTH %s: BITES' % name)
            return 0
        print('TOOTH %s: DID NOT BITE (exit %d) -- the gate is NOT believed'
              % (name, r.returncode))
        return 1
    finally:
        shutil.rmtree(d, ignore_errors=True)
