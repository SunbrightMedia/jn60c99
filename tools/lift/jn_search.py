#!/usr/bin/env python3
"""jn_search.py -- L6 of the JUNO lift (docs/JUNO_LIFT.md): the MACHINE SEARCH. Seeded random plans over every host
entry (jn_search_seq), each run on the oracle (jn_search_ref.py, its own process) and on the lifted host
(jn_search_c.py, its own process) and compared after EVERY op. W seeds run in parallel. Each result goes to the ledger
(scratchpad/lift/search/ledger.jsonl: seed, ops, result, seconds, time); a clean seed's directory is removed, a
diverging seed's is KEPT and the search STOPS (the defect is fixed first, then the clock restarts). L6 is done when the
ledger shows 24 hours of wall clock with no divergence since the last fix (--report prints it).
usage: python3 tools/lift/jn_search.py [--seed0 1000] [--workers 3] [--nops 120] [--hours 24] [--report]
Run it as a long job: sh tools/run_job.sh <name> python3 tools/lift/jn_search.py ..."""
import os
import sys
import json
import time
import shutil
import argparse
import threading
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jn_search_seq as S                                          # noqa: E402

DIR = os.path.join(REPO, 'scratchpad', 'lift', 'search')
LEDGER = os.path.join(DIR, 'ledger.jsonl')
SO = os.path.join(REPO, 'build', 'jn_host', 'libjunohost.so')
TMPL = os.path.join(REPO, 'build', 'jn_host', 'jn_host_template.bin')


def report():
    if not os.path.exists(LEDGER):
        print('no ledger yet'); return
    rows = [json.loads(ln) for ln in open(LEDGER) if ln.strip()]
    last_bad = max((r['t_end'] for r in rows if r['result'] == 'DIVERGE'), default=None)
    since = [r for r in rows if last_bad is None or r['t_end'] > last_bad]
    clean = [r for r in since if r['result'] == 'CLEAN']
    if since:
        t0 = min(r['t_end'] - r['secs'] for r in since); t1 = max(r['t_end'] for r in since)
        hours = (t1 - t0) / 3600.0
    else:
        hours = 0.0
    lim = [r for r in since if r['result'] == 'ORACLE_LIMIT']
    print('L6 ledger: %d seeds in all; since the last divergence: %d seeds, %d CLEAN, %d oracle-limited, %d ops '
          'compared, %.2f hours of wall clock with no divergence' %
          (len(rows), len(since), len(clean), len(lim), sum(r['ops'] for r in since), hours))


def one(seed, nops, stop):
    if stop.is_set():
        return
    d = os.path.join(DIR, 'seed_%d' % seed)
    t0 = time.time()
    r = subprocess.run([sys.executable, os.path.join(HERE, 'jn_search_ref.py'), d, str(seed), str(nops)],
                       capture_output=True, text=True)
    if r.returncode != 0:
        res, msg, nop = 'REF_FAIL', (r.stdout + r.stderr)[-400:], 0
    else:
        c = subprocess.run([sys.executable, os.path.join(HERE, 'jn_search_c.py'), SO, TMPL, d],
                           capture_output=True, text=True)
        msg = (c.stdout + c.stderr).strip()[-600:]
        meta = json.load(open(os.path.join(d, 'meta.json')))
        nop = len(meta['rows'])
        res = {0: 'CLEAN', 1: 'DIVERGE', 3: 'ORACLE_LIMIT'}.get(c.returncode, 'C_CRASH(%d)' % c.returncode)
    row = dict(seed=seed, ops=nop, result=res, secs=round(time.time() - t0, 1), t_end=time.time(), msg=msg[-300:])
    with LOCK:
        with open(LEDGER, 'a') as f:
            f.write(json.dumps(row) + '\n')
        print('[%s] seed %d: %s (%d ops, %.0fs) %s' % (time.strftime('%H:%M:%S'), seed, res, nop, row['secs'],
                                                       '' if res == 'CLEAN' else msg[-200:]), flush=True)
    if res == 'CLEAN':
        shutil.rmtree(d, ignore_errors=True)
    elif res in ('DIVERGE', 'REF_FAIL') or res.startswith('C_CRASH'):
        stop.set()                                                 # keep the directory; fix first


LOCK = threading.Lock()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--seed0', type=int, default=S.SEARCH_SEED0)
    ap.add_argument('--workers', type=int, default=3)
    ap.add_argument('--nops', type=int, default=120)
    ap.add_argument('--hours', type=float, default=24.0)
    ap.add_argument('--report', action='store_true')
    a = ap.parse_args()
    if a.report:
        report(); return 0
    for p in (SO, TMPL):
        if not os.path.exists(p):
            print('missing %s -- run sh tools/lift/jn_build.sh' % p); return 2
    os.makedirs(DIR, exist_ok=True)
    done = {json.loads(ln)['seed'] for ln in open(LEDGER)} if os.path.exists(LEDGER) else set()
    stop, t_end = threading.Event(), time.time() + a.hours * 3600
    nxt = [a.seed0]

    def worker():
        while not stop.is_set() and time.time() < t_end:
            with LOCK:
                while nxt[0] in done:
                    nxt[0] += 1
                s = nxt[0]; nxt[0] += 1
            one(s, a.nops, stop)
    ts = [threading.Thread(target=worker) for _ in range(a.workers)]
    [t.start() for t in ts]
    [t.join() for t in ts]
    report()
    return 1 if stop.is_set() else 0


if __name__ == '__main__':
    sys.exit(main())
