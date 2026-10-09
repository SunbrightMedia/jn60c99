#!/usr/bin/env python3
"""claims_census.py -- which proof of docs/CLAIMS.md does the routine pipeline re-run? (task #62)

A claim is repeatable only if the command that proves it runs again. This census reads every
ledger row (sections A-E), takes the scripts its proof column names, and finds whether a make
target runs each one: named in a recipe of the Makefile (or tools/engineb/foundation.sh), or
named in the source of a script that is itself run (a subprocess command, an import, a path) --
the closure over those mentions. Comments and docstrings are removed first (a docstring that names a
teeth script runs nothing); a name in code still counts, so the census can only over-report reach.

usage: python3 tools/repro/claims_census.py [--all] [--tooth missing|unrun]
  --all: every row, not only the gaps; --tooth: a defect the census must see (a row whose script does
  not exist; A3's proof dropped from the make targets) -- it must then exit 1
exit 1 when a row's proof is not run and tools/repro/claims_routes.tsv gives no route (or the route is not run);
a struck row closed '-> Axx' is as good as the rows it names.
"""
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOOTH = sys.argv[sys.argv.index('--tooth') + 1] if '--tooth' in sys.argv else None
EXT = r'(?:py|mjs|c|sh)'
PATH_RE = re.compile(r'(?<![\w/.-])((?:tools|tests|probes|engine_b|gui|esp32s3|pi)/[\w/.-]+?\.' + EXT + r')\b')


def src(path):
    """a script's CODE: comments and docstrings removed (a mention there runs nothing)"""
    try:
        t = open(os.path.join(REPO, path), encoding='utf-8', errors='replace').read()
    except OSError:
        return ''
    if path.endswith('.py'):
        t = re.sub(r'(?s)("""|\'\'\').*?\1', '', t)
        t = re.sub(r'(?m)#.*$', '', t)
    elif path.endswith(('.mjs', '.c')):
        t = re.sub(r'(?s)/\*.*?\*/', '', t)
        t = re.sub(r'(?m)(^|[^:])//.*$', r'\1', t)
    elif path.endswith(('.sh', 'Makefile')) or path == 'Makefile':
        t = re.sub(r'(?m)^\s*#.*$', '', t)
    if TOOTH == 'unrun':                    # TOOTH: A3's proof called nowhere (every recipe and script)
        t = t.replace('notevel_exhaust', 'notevel_exhaust_dropped')
    return t


def index_scripts():
    """basename -> repo paths, for every script in the tree (a bare name in a recipe or an import)"""
    by = {}
    for top in ('tools', 'tests', 'probes', 'engine_b', 'gui'):
        for d, _, fs in os.walk(os.path.join(REPO, top)):
            for f in fs:
                if re.search(r'\.' + EXT + '$', f):
                    p = os.path.relpath(os.path.join(d, f), REPO)
                    by.setdefault(f, []).append(p)
                    by.setdefault(f.rsplit('.', 1)[0], []).append(p)
    return by


def mentions(text, by, here):
    out = set(PATH_RE.findall(text))
    for m in re.findall(r'^\s*(?:import|from)\s+([\w.]+)', text, re.M):     # python imports: same folder
        name = m.split('.')[0]
        for p in by.get(name, []):
            if p.endswith('.py') and os.path.dirname(p) in (here, 'tools/verify', 'probes/b6'):
                out.add(p)
    for m in re.findall(r'["\'/ ]([\w-]+\.(?:py|mjs|c|sh))\b', text):        # a script named by file name
        for p in by.get(m, []):
            out.add(p)
    return {p for p in out if os.path.exists(os.path.join(REPO, p))}


def closure(by):
    roots = src('Makefile') + src('tools/engineb/foundation.sh')
    run = mentions(roots, by, '')
    todo = list(run)
    while todo:
        p = todo.pop()
        for q in mentions(src(p), by, os.path.dirname(p)):
            if q not in run:
                run.add(q)
                todo.append(q)
    return run


def rows():
    """(row id, claim, proof column, line); columns split on ' | ' (a claim may hold a bare '|')"""
    out = []
    for ln in open(os.path.join(REPO, 'docs', 'CLAIMS.md'), encoding='utf-8'):
        m = re.match(r'^\| ([A-E]\d+[a-z]?) \|', ln)
        if m:
            cols = ln.rstrip().rstrip('|').split(' | ')
            out.append((m.group(1), cols[1].strip(), cols[2] if len(cols) > 2 else '', ln))
    if TOOTH == 'missing':                  # TOOTH: a row whose proof script does not exist
        out.append(('Z1', 'a tooth row', 'tools/verify/zz_no_such_gate.py', '| Z1 | a tooth row | tools/verify/zz_no_such_gate.py | - |'))
    return out


def routes():
    out = {}
    for ln in open(os.path.join(REPO, 'tools', 'repro', 'claims_routes.tsv'), encoding='utf-8'):
        if ln.strip() and not ln.startswith('#'):
            rid, kind, scripts, why = ln.rstrip('\n').split('\t')
            out[rid] = (kind, [] if scripts == '-' else scripts.split(), why)
    return out


def main():
    by = index_scripts()
    run = closure(by)
    rt = routes()
    allrows = rows()
    state = {}
    lines = []

    def scripts_of(proof):
        sc = set(PATH_RE.findall(proof))
        if not sc:
            for m in re.findall(r'\b([\w-]+\.(?:py|mjs|c))\b', proof):
                sc.update(by.get(m, [m]))
        return sorted(sc)

    for rid, claim, proof, ln in allrows:
        scripts = scripts_of(proof)
        missing = [s for s in scripts if not os.path.exists(os.path.join(REPO, s))]
        notrun = [s for s in scripts if s not in run and s not in missing]
        redirect = re.findall(r'->\s*(A\d+)', claim) if claim.startswith('~~') else []
        if scripts and not notrun and not missing:
            st, note = 'ok', ''
        elif rid in rt:
            kind, rs, why = rt[rid]
            # a diagnostic is not a proof: the row's OTHER scripts must run; a route's scripts must run
            bad = [s for s in notrun + missing if s not in rs] if kind == 'diagnostic' else [s for s in rs if s not in run]
            st = 'GAP' if bad else kind
            note = (' route not run: %s' % ', '.join(bad)) if bad else (' -- ' + why)
        elif redirect:
            st, note = 'closed', ' -> ' + ', '.join(redirect)
        else:
            st, note = 'GAP', ''
        if st == 'GAP' and not note:
            note = ('; not run: ' + ', '.join(notrun) if notrun else '') + ('; missing: ' + ', '.join(missing) if missing else '') + \
                   ('' if scripts else '; no script named')
        state[rid] = (st, redirect)
        lines.append((st, rid, re.sub(r'\*', '', claim)[:58], note))
    for i, (st, rid, claim, note) in enumerate(lines):           # a closed row is as good as the rows it names
        if st == 'closed':
            dead = [r for r in state[rid][1] if state.get(r, ('GAP',))[0] == 'GAP']
            if dead:
                lines[i] = ('GAP', rid, claim, note + ' (GAP there: %s)' % ', '.join(dead))
    gaps = 0
    for st, rid, claim, note in lines:
        gaps += st == 'GAP'
        if st != 'ok' and (st == 'GAP' or '--all' in sys.argv):
            print('%-10s %-5s %s%s' % (st, rid, claim, note))
    counts = {}
    for st, *_ in lines:
        counts[st] = counts.get(st, 0) + 1
    print('claims_census: %d rows (%s), %d scripts run by the make targets, %d GAP' % (
        len(lines), ', '.join('%d %s' % (v, k) for k, v in sorted(counts.items())), len(run), gaps))
    return 1 if gaps else 0


if __name__ == '__main__':
    sys.exit(main())
