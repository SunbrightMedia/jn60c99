#!/usr/bin/env python3
"""jx_pm_teeth_sweep.py -- which seed each patch-window tooth bites on (gui/juno_pm.c PM_TOOTH 1-19 on the JX).

Every tooth of jx_patch_manager_gate.py is seen to fail on a seed whose script reaches its mutation. A change to the
command script (a new command kind, one more random draw) re-seeds EVERY tooth, not only the new ones: 2026-10-14,
jxverify_144e went RED after 15.7 h on tooth 5 (seed 1 no longer renamed a bank to another bank's name in other
letter cases) because the bank name presses of row 20 shifted the JX script and only teeth 18 / 19 were re-run
(playbook 256). This tool re-runs them all: the plugin's reference per candidate seed (made from the plugin when it
is missing), the unchanged port GREEN on each (else every tooth would seem to bite there), every tooth's library
once, then each tooth on each seed -- the port side only, the references shared.

usage: jx_pm_teeth_sweep.py [--seeds 9:40,1:200,5:200,100:150] [--teeth 1-19] [--jobs 3]
prints each tooth's biting seeds and the list for jx_verify.sh (the first candidate that bites, in the order given);
exits 1 when a seed is RED or a tooth bites on none of the candidates.
"""
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
GATE = os.path.join(HERE, 'jx_patch_manager_gate.py')
sys.path.insert(0, HERE)


def opt(k, d):
    return sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d


def ref_path(seed, steps):
    return os.path.join(REPO, 'scratchpad', 'jx_art_patch_manager_ref2_%d_%d.pkl' % (seed, steps))


def port(pkl, tooth=None):
    r = subprocess.run([sys.executable, GATE, '--port', pkl] + (['--tooth', str(tooth)] if tooth else []),
                       capture_output=True, text=True)
    m = re.search(r'PORT (\d+) (\d+)', r.stdout)
    if not m:
        raise SystemExit('%s tooth %s: no verdict\n%s' % (pkl, tooth, r.stderr[-1500:]))
    return int(m.group(1))


def main():
    seeds = [tuple(int(v) for v in x.split(':')) for x in opt('--seeds', '9:40,1:200,5:200,100:150').split(',')]
    lo, _, hi = opt('--teeth', '1-19').partition('-')
    teeth = list(range(int(lo), int(hi or lo) + 1))
    jobs = int(opt('--jobs', '3'))
    import jx_patch_manager_gate as J

    def make_ref(sn):                          # the plugin's reference (its own process, as the gate makes it)
        s, n = sn
        p = ref_path(s, n)
        if not os.path.exists(p):
            r = subprocess.run([sys.executable, GATE, '--plugin', p + '.partial', '--seed', str(s), '--steps', str(n)],
                               capture_output=True, text=True)
            if r.returncode:
                raise SystemExit('the plugin side failed on seed %d\n%s' % (s, r.stderr[-1500:]))
            os.replace(p + '.partial', p)
    with ThreadPoolExecutor(jobs) as ex:       # the references and every library (each its own file)
        list(ex.map(make_ref, seeds))
        list(ex.map(lambda t: J.build(t), [None] + [str(t) for t in teeth]))
    with ThreadPoolExecutor(jobs) as ex:
        base = list(ex.map(lambda sn: port(ref_path(*sn)), seeds))
    red = [sn for sn, f in zip(seeds, base) if f]
    for s, n in seeds:
        print('seed %d (%d steps): %s' % (s, n, 'RED' if (s, n) in red else 'GREEN'), flush=True)
    if red:
        return 1
    with ThreadPoolExecutor(jobs) as ex:
        res = list(ex.map(lambda ts: (ts[0], ts[1], port(ref_path(*ts[1]), ts[0])),
                          [(t, sn) for t in teeth for sn in seeds]))
    out, bad = [], []
    for t in teeth:
        bites = [sn for tt, sn, f in res if tt == t and f]
        print('tooth %2d bites on %s' % (t, ', '.join('%d:%d' % b for b in bites) or 'NONE'))
        if bites:
            out.append('%d:%d:%d' % (t, bites[0][0], bites[0][1]))
        else:
            bad.append(t)
    print('jx_verify.sh list: ' + ' '.join(out))
    if bad:
        print('teeth that bite on no candidate: %s' % ' '.join(map(str, bad)))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
