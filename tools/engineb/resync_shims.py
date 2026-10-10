#!/usr/bin/env python3
"""resync_shims.py -- keep the engine_b/shim forks on the port's current src/ (task #62, 2026-10-10).

A fork is a verbatim copy of one src/ file (voice_render.c, master_render.c, juno_driver.c,
chorus_init.c) with engine B's block(s) in place of the port's. engine_b/shim/BASES.tsv records, per
fork, the git blob of the src/ file it is synced to. When src/ moves on, the fork must follow: this
tool three-way merges each stale fork (base = the recorded blob, ours = the fork, theirs = the current
src/ file) and records the new base.

  python3 tools/engineb/resync_shims.py --check      list the stale or unrecorded forks (exit 1 if
                                                      any); shim_drift_tooth.py runs it (make engineb 1b)
  python3 tools/engineb/resync_shims.py              merge every stale fork: a clean merge is written
                                                      and recorded; a conflicted one is left in
                                                      build/shim_resync/ (diff3 markers) and reported --
                                                      resolve it there, copy it in, then record it:
  python3 tools/engineb/resync_shims.py --record D/F  record fork D/F as synced to src/F as it is now

Why: until 2026-10-10 nothing recorded a fork's base, so 15 forks silently predated the October src/
changes and four of them no longer linked: make engineb was RED from 2026-10-07 until the proof run
found it (docs/engineb/METHOD_PLAYBOOK.md 191). The tool only moves text; every merged fork is graded
by its own null against src/ (null_b --module M, make engineb), never by this tool.
"""
import hashlib
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SHIM = os.path.join(REPO, 'engine_b', 'shim')
BASES = os.path.join(SHIM, 'BASES.tsv')
OUT = os.path.join(REPO, 'build', 'shim_resync')
HEADER = ('# engine_b/shim/BASES.tsv -- the git blob of the src/ file each fork is synced to.\n'
          '# Written by tools/engineb/resync_shims.py (--record / a clean merge); checked by\n'
          '# tools/engineb/shim_drift_tooth.py (make engineb step 1b). fork<TAB>src blob\n')


def blob(data):
    """git's blob id of `data` (= git hash-object)."""
    return hashlib.sha1(b'blob %d\0' % len(data) + data).hexdigest()


def forks():
    """every fork, as 'dir/file': a .c file under engine_b/shim/<dir>/ whose name is a src/ file"""
    out = []
    for d in sorted(os.listdir(SHIM)):
        dp = os.path.join(SHIM, d)
        if not os.path.isdir(dp):
            continue
        for f in sorted(os.listdir(dp)):
            if f.endswith('.c') and os.path.exists(os.path.join(REPO, 'src', f)):
                out.append(d + '/' + f)
    return out


def src_blob(fork):
    return blob(open(os.path.join(REPO, 'src', fork.split('/')[1]), 'rb').read())


def read_bases(path=BASES):
    b = {}
    if os.path.exists(path):
        for line in open(path):
            if line.strip() and not line.startswith('#'):
                k, v = line.split()[:2]
                b[k] = v
    return b


def write_bases(b):
    with open(BASES, 'w') as f:
        f.write(HEADER)
        for k in sorted(b):
            f.write('%s\t%s\n' % (k, b[k]))


def stale(bases=None):
    """[(fork, recorded blob or None, current src blob)] for every fork not synced to src/ now"""
    bases = read_bases() if bases is None else bases
    return [(k, bases.get(k), src_blob(k)) for k in forks() if bases.get(k) != src_blob(k)]


def merge(fork, base_sha):
    """three-way merge of one fork onto the current src/ file; (conflicts, merged bytes)"""
    os.makedirs(OUT, exist_ok=True)
    d, f = fork.split('/')
    base = subprocess.run(['git', '-C', REPO, 'cat-file', '-p', base_sha], capture_output=True)
    if base.returncode:
        return -1, b'git cannot read blob %s: %s' % (base_sha.encode(), base.stderr)
    bp = os.path.join(OUT, '%s.%s.base' % (d, f))
    open(bp, 'wb').write(base.stdout)
    r = subprocess.run(['git', 'merge-file', '-p', '--diff3', '-L', 'fork', '-L', 'base', '-L', 'src',
                        os.path.join(SHIM, d, f), bp, os.path.join(REPO, 'src', f)], capture_output=True)
    return r.returncode, r.stdout


def main():
    args = sys.argv[1:]
    if args[:1] == ['--check']:
        s = stale()
        for k, rec, cur in s:
            print('  %-32s %s' % (k, 'NOT RECORDED in engine_b/shim/BASES.tsv' if rec is None else
                                  'synced to src blob %s, src/%s is now %s' % (rec[:10], k.split('/')[1], cur[:10])))
        print('resync_shims --check: %d of %d forks %s' % (len(s), len(forks()),
              'stale -- run tools/engineb/resync_shims.py' if s else 'stale: every fork is synced to src/'))
        return 1 if s else 0
    if args[:1] == ['--record']:
        b = read_bases()
        for k in args[1:]:
            if k not in forks():
                print('no fork %s' % k)
                return 2
            b[k] = src_blob(k)
            print('recorded %s at src blob %s' % (k, b[k][:10]))
        write_bases(b)
        return 0
    b = read_bases()
    bad = 0
    for k, rec, cur in stale(b):
        if rec is None:
            print('  %-32s NOT RECORDED: check it against src/ by hand, then --record it' % k)
            bad = 1
            continue
        n, text = merge(k, rec)
        if n == 0:
            open(os.path.join(SHIM, k), 'wb').write(text)
            b[k] = cur
            print('  %-32s merged clean onto src blob %s' % (k, cur[:10]))
        else:
            d, f = k.split('/')
            p = os.path.join(OUT, '%s.%s.merge' % (d, f))
            open(p, 'wb').write(text)
            print('  %-32s %s -> %s' % (k, '%d conflict(s)' % n if n > 0 else text.decode(errors='replace'),
                                        os.path.relpath(p, REPO)))
            bad = 1
    write_bases(b)
    print('resync_shims: %s' % ('every stale fork merged; grade them: make engineb' if not bad else
                                'resolve the reported forks, copy them in, --record them, then make engineb'))
    return bad


if __name__ == '__main__':
    sys.exit(main())
