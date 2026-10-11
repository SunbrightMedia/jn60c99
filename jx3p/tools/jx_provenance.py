#!/usr/bin/env python3
"""jx_provenance.py -- every file of the JX-3P port has a known origin and a running proof (JX-26e; the JUNO-60's
tools/verify/provenance_check.py; docs/GATE_PARITY.tsv class provenance).

Reads jx3p/docs/PROVENANCE.tsv (file, role, made_by, proof) and is RED on:
  1. a file of jx3p/src, jx3p/gen or jx3p/gui (git-tracked; jx3p/gui/web's included) with no row;
  2. a row whose file does not exist;
  3. a row that is not RETIRED with no proof, or a proof file that does not exist or that jx3p/tools/jx_verify.sh
     does not run (a check nobody runs proves nothing: playbook 212);
  4. a RETIRED file the product builds -- or a file the product builds with no row, or a RETIRED one: the product's
     units are jx3p/tools/jx_product_gate.py's SRCS and every local file they include ("...", recursively; the
     bridge's lifted source and runtime among them).
On 2026-10-11 its first reading found jx3p/src/jx_recall.c (the pool-model recall, 197 KB of table) built into
every product and called by nothing.

    python3 jx3p/tools/jx_provenance.py [--self-test]
  --self-test: rules 1, 3 and 4 must each turn a planted case RED.
exit 0 = every file accounted for.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LEDGER = os.path.join(REPO, 'jx3p', 'docs', 'PROVENANCE.tsv')
SUITE = os.path.join(HERE, 'jx_verify.sh')
ROLES = ('PORTED', 'TRANSCRIBED', 'LIFTED', 'GENERATED', 'SHARED', 'RUNTIME', 'WEB', 'DATA', 'RETIRED')


def load(path=LEDGER):
    rows = {}
    for ln in open(path):
        if not ln.strip() or ln.startswith('#'):
            continue
        f = ln.rstrip('\n').split('\t')
        if len(f) != 4:
            raise SystemExit('MALFORMED row (4 tab fields): %r' % ln)
        rows[f[0]] = dict(role=f[1], made=f[2], proof=[] if f[3].strip() == '-' else [p.strip() for p in f[3].split(' + ')])
    return rows


def tracked():
    out = subprocess.run(['git', 'ls-files', 'jx3p/src', 'jx3p/gen', 'jx3p/gui'], cwd=REPO, capture_output=True,
                         text=True, check=True).stdout.split()
    return sorted(out)


def suite_runs():
    toks = set()
    for ln in open(SUITE):
        if ln.lstrip().startswith('#'):
            continue
        for t in ln.split('#', 1)[0].replace('"', ' ').replace("'", ' ').split():
            toks.add(os.path.basename(t))
    return toks


def product_units():
    """the product's translation units (jx_product_gate.py SRCS) and the local files they include, repo-relative"""
    src = open(os.path.join(HERE, 'jx_product_gate.py')).read()
    m = re.search(r'^SRCS = \[(.*?)\]', src, re.S | re.M)
    units = re.findall(r"'([^']+)'", m.group(1))
    seen = []

    def walk(rel):
        rel = os.path.normpath(rel)
        if rel in seen or not os.path.exists(os.path.join(REPO, rel)):
            return
        seen.append(rel)
        for inc in re.findall(r'^\s*#\s*include\s*"([^"]+)"', open(os.path.join(REPO, rel), errors='replace').read(), re.M):
            for base in (os.path.dirname(rel), 'jx3p/src', 'src'):
                if os.path.exists(os.path.join(REPO, base, inc)):
                    walk(os.path.join(base, inc))
                    break
    for u in units:
        walk(u)
    return seen


def check(rows, files, runs, built):
    bad = []
    for f in files:
        if f not in rows:
            bad.append('no row: %s' % f)
    for f, r in rows.items():
        if not os.path.exists(os.path.join(REPO, f)):
            bad.append('the row names %s, which does not exist' % f)
        if r['role'] not in ROLES:
            bad.append('%s: unknown role %s' % (f, r['role']))
        if r['role'] != 'RETIRED':
            if not r['proof']:
                bad.append('%s: no proof' % f)
            for p in r['proof']:
                if not os.path.exists(os.path.join(REPO, p)):
                    bad.append('%s: its proof %s does not exist' % (f, p))
                elif os.path.basename(p) not in runs:
                    bad.append('%s: its proof %s is not run by jx_verify.sh' % (f, p))
    for f in built:
        if f not in rows:
            bad.append('the product builds %s, which has no row' % f)
        elif rows[f]['role'] == 'RETIRED':
            bad.append('the product builds %s, which is RETIRED' % f)
    return bad


def main():
    rows, files, runs, built = load(), tracked(), suite_runs(), product_units()
    if '--self-test' in sys.argv:
        ok = True
        plants = [('a file with no row', dict(rows), files + ['jx3p/src/planted.c'], runs, built),
                  ('a proof nobody runs', dict(rows, **{'jx3p/src/jx_ftz.c': dict(role='RUNTIME', made='-',
                                                                                    proof=['jx3p/tools/fw_map.py'])}),
                   files, runs, built),
                  ('a RETIRED file built', dict(rows), files, runs, built + ['jx3p/src/jx_seq.c'])]
        for what, r, f, ru, b in plants:
            hit = bool(check(r, f, ru, b))
            print('  self-test %-22s %s' % (what, 'RED (seen)' if hit else 'NOT SEEN'))
            ok = ok and hit
        print('jx_provenance --self-test: %s' % ('BITES' if ok else 'DID NOT BITE'))
        return 0 if ok else 1
    bad = check(rows, files, runs, built)
    for b in bad:
        print('  ' + b)
    by = {}
    for r in rows.values():
        by[r['role']] = by.get(r['role'], 0) + 1
    print('jx_provenance: %d files (%s); the product builds %d of them: %s' % (
        len(rows), ', '.join('%d %s' % (n, k) for k, n in sorted(by.items())), len(built),
        'EVERY FILE ACCOUNTED FOR' if not bad else '%d PROBLEMS' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
