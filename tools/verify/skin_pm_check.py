#!/usr/bin/env python3
"""skin_pm_check.py -- the web page's patch window against the PLUGIN (CLAIMS A39).

The patch manager gate's references (tools/verify/patch_manager_gate.py: the plugin's own run of a seeded
command script) are played into the web page (gui/skin: the patch manager compiled into the WASM, the
page's own dialogs, files and handlers) in headless Chromium by tools/verify/skin_pm_run.mjs, which writes
the page's log in JUNO-60.exe's --pm-script form; the exe check's parser and the gate's own grade() then
compare each command with the plugin's run: the dialogs asked, the files changed, the model calls, the
manager's whole state (banks, histories, clipboard, selection, the view's record), every file.

The gate's folders are the page's own (files.js keeps Windows paths): its setup files are served to the
page (?pmsetup=), nothing is translated.

usage: skin_pm_check.py [--seeds 9:40,1:200,...] [--keep] [--tooth keys|capture|button]
  --tooth: a defect put into the page's own code (the list's up / down keys exchanged; a drag's moves lost;
           the bank name's button unknown): the check must FAIL
"""
import json
import os
import pickle
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'dist'))
import patch_manager_gate as G  # noqa: E402
import exe_pm_check as X  # noqa: E402

RATE = 48000                                     # the gate's plugin runs at 48000 (patch_manager_emu.PlugPM)


def answers(op):
    """a command's scripted answers as the page takes them: text (bytes -> a Latin-1 string or null), menu,
    box, file (a list of paths or null)"""
    out = []
    for kind, v in op[-1]:
        if kind == 'text':
            out.append(['text', None if v is None else v.decode('latin1')])
        elif kind in ('menu', 'box'):
            out.append([kind, v])
        elif kind == 'file':
            out.append(['file', None if v is None else (v if isinstance(v, list) else [v])])
    return out


def command(op, pids):
    k = op[0]
    if k == 'key':
        return ['key', op[1], op[2]]
    if k == 'func':
        return ['func', op[1], op[2]]
    if k in ('mouse', 'bank'):
        return [k, [[t, x, y] for t, (x, y) in op[2]]]
    if k == 'set':
        return ['set', pids[op[1] % len(pids)], op[2]]
    if k == 'save':
        return ['save']
    if k == 'tick':
        return ['tick', op[1]]
    raise SystemExit('unknown command %r' % (op,))


def run_seed(seed, steps, keep, tooth=None):
    pkl = os.path.join(REPO, 'scratchpad', 'patch_manager_ref%d_%d_%d.pkl' % (G.REF_FORMAT, seed, steps))
    ref = pickle.load(open(pkl, 'rb'))
    if ref.get('fmt') != G.REF_FORMAT:
        raise SystemExit('%s: an old reference form' % pkl)
    rel = 'scratchpad/skin_pm/s%d_%d' % (seed, steps)          # served by the runner (the repository's root)
    work = os.path.join(REPO, rel)
    shutil.rmtree(work, ignore_errors=True)
    os.makedirs(work)
    files = []
    for i, (p, d) in enumerate(G.setup(seed)):                # the gate's files, under their own paths
        open(os.path.join(work, 'f%d.bin' % i), 'wb').write(d)
        files.append({'path': p, 'url': '/%s/f%d.bin' % (rel, i)})
    json.dump({'dirs': {'data': G.DATA, 'patch': G.PATCH, 'old': G.OLD, 'script': G.SCRIPT}, 'files': files},
              open(os.path.join(work, 'setup.json'), 'w'))
    pids, ops = ref['pids'], ref['ops']
    n = len(ref['res']) - 1
    watch = [G.DATA, G.PATCH, G.OLD, G.DESK]
    run = {'setup': '/%s/setup.json' % rel, 'rate': RATE, 'watch': watch, 'tooth': tooth,
           'ops': [{'full': 1 if G.full_step(i, n) else 0, 'answers': answers(op), 'cmd': command(op, pids)}
                   for i, op in enumerate(ops, 1)]}
    rp, lp = os.path.join(work, 'run.json'), os.path.join(work, 'out.log')
    json.dump(run, open(rp, 'w'))
    r = subprocess.run(['node', os.path.join(HERE, 'skin_pm_run.mjs'), rp, lp], cwd=REPO, timeout=7200,
                       capture_output=True, text=True)
    if r.returncode != 0:
        print('  the page: ' + (r.stderr or r.stdout).strip()[-600:])
    out = open(lp, encoding='latin1').read().split('\n') if os.path.exists(lp) else []
    if 'boot' not in out:                                    # the page wrote no log: a failure, not a crash
        return 1, ['the page wrote no log (%s)' % ((r.stderr or r.stdout).strip()[-300:])], len(ops)
    nfail, fails, nops = G.grade(ref, X.parse_log(out, ops, lambda p: p, watch))
    if r.returncode != 0:
        nfail += 1
    if keep:
        print('  kept %s' % work)
    else:
        shutil.rmtree(work)
    return nfail, fails, nops


def main():
    spec = sys.argv[sys.argv.index('--seeds') + 1] if '--seeds' in sys.argv else '9:40,1:200,2:200,3:200'
    keep = '--keep' in sys.argv
    tooth = sys.argv[sys.argv.index('--tooth') + 1] if '--tooth' in sys.argv else None
    bad = 0
    for item in spec.split(','):
        seed, steps = (int(x) for x in item.split(':'))
        nfail, fails, n = run_seed(seed, steps, keep, tooth)
        for f in fails[:3 if tooth else None]:
            print('  FAIL ' + f)
        print('%s seed %d: %d of %d commands differ from the plugin' % ('ok  ' if not nfail else 'FAIL', seed, nfail, n))
        bad += nfail > 0
    if tooth:
        print('skin_pm_check --tooth %s: %s' % (tooth, 'BITES' if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('skin_pm_check: %s (%s)' % ('GREEN' if not bad else 'RED', spec))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
