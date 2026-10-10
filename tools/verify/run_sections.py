#!/usr/bin/env python3
"""run_sections.py -- make verify, JOBS sections at a time (the user, 2026-10-10: "do all four gates at once").

The gate list stays ONE shell recipe in the Makefile, target verify-recipe (tools/repro/claims_census.py
reads it there). This runner takes it as make expands it (`make -n -s verify-recipe`), runs its prelude --
pathcheck and the shared references: the index cell map, the plugin's recall, the render reference, the
exhaustive recall at 18 rates, the port's state -- first and alone, then its sections (each `echo "=== ... ==="`
block) JOBS at a time, each in its own bash with the prelude's `newest` and `fresh()` and its own FAIL. A
section's output is kept whole and printed when it ends, under a line with its index, exit and time; exit 1
when the prelude or any section failed. --jobs 1 runs the sections one by one in the recipe's order: the
old make verify (also: make verify-seq).

Why overlapping is safe, and the check that keeps it so (--audit, run before every parallel run): a section
builds its own references (X_ref.pkl, then its port side and its teeth read them, in order, inside the
section); the shared ones come from the prelude; every tooth builds in its own directory. --audit lists each
scratch file name that scripts of two different sections name; a parallel run refuses to start while the
list is not empty (seen to fail: --audit-tooth plants one).
"""
import concurrent.futures
import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
# A section whose script has a child KILLED by the kernel (bash prints "line N: PID Killed  cmd") did not
# fail a gate: it lost a race for memory. Paid 2026-10-10 (playbook 195): proof run repro4, four sections
# in parallel plus other jobs on a 15 GB machine, ARP SCATTER GRID's --ref-grid killed after 1902 s.
KILLED_RE = re.compile(r'^(?:bash: )?line \d+: +\d+ Killed\b', re.M)
MIN_FREE_GIB = float(os.environ.get('VERIFY_MIN_FREE_GIB', '4'))
REPO = os.path.dirname(os.path.dirname(HERE))
HEAD_RE = re.compile(r'^\s*echo "=== ')
SCRIPT_RE = re.compile(r'(?:tools|probes)/[A-Za-z0-9_/]+\.(?:py|sh)')
NAME_RE = re.compile(r"""(?:scratch\(|SCRATCH\s*,\s*|SCRATCH\s*\+\s*|scratchpad/|SP\s*\+\s*|WORK\s*,\s*)\s*['"/]*"""
                     r"""([A-Za-z0-9_.%{}\-]+\.(?:pkl|so|log|txt|json|bin|npy|c|exe))""")


# Names that scripts of several sections name but that one section alone writes, read in the code
# (2026-10-10) -- allowed ONLY among the sections whose titles start as listed; a new section naming
# one of them is still reported.
ALLOW = {
    'arp_sched_ref.pkl': ('arp_sched_ab.py --ref alone writes it (section LIVE GATE 4/7)',
                          ('LIVE GATE 4/7', 'ARP SCATTER GRID', 'ARP GOLDENS')),
    'arp_grid_ref.pkl': ('arp_sched_ab.py --ref-grid alone writes it, --port-grid reads it',
                         ('LIVE GATE 4/7', 'ARP SCATTER GRID', 'ARP GOLDENS')),
    'arp_golden_ref.pkl': ('arp_sched_ab.py --ref-goldens alone writes it, --check/--port-goldens read it',
                           ('LIVE GATE 4/7', 'ARP SCATTER GRID', 'ARP GOLDENS')),
    'warm_render_%s.pkl': ('warm_render_gate.py: one file per model, settled / live',
                           ('WARM RENDER (', 'WARM RENDER LIVE')),
}


def recursive(block):
    """True when make -n would RUN this recipe instead of printing it: a $(MAKE) / ${MAKE} or a '+'
    line makes GNU make execute the line even under -n, and the verify recipe is ONE logical line --
    so `make -n verify-recipe` once ran the whole verify (2026-10-10, playbook 193)"""
    return bool(re.search(r'\$[({]MAKE[)}]|^\t\+', block, re.M))


def recipe():
    """the verify recipe as make expands it: (prelude lines, [(title, lines)])"""
    mk = open(os.path.join(REPO, 'Makefile')).read()
    m = re.search(r'^verify-recipe:.*?(?=^\S|\Z)', mk, re.M | re.S)
    if not m or recursive(m.group(0)):
        raise SystemExit('run_sections: REFUSED -- the verify-recipe target is missing or calls $(MAKE); '
                         'make -n would run it, not print it. Call plain `make` inside the recipe.')
    r = subprocess.run(['make', '-n', '-s', '--no-print-directory', 'verify-recipe'], cwd=REPO,
                       capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('run_sections: make -n verify-recipe failed:\n' + r.stderr)
    lines = r.stdout.rstrip('\n').split('\n')
    heads = [i for i, l in enumerate(lines) if HEAD_RE.match(l)]
    if not heads:
        raise SystemExit('run_sections: no "=== ... ===" section in the verify recipe')
    secs = []
    for k, i in enumerate(heads):
        j = heads[k + 1] if k + 1 < len(heads) else len(lines)
        title = lines[i].split('"=== ', 1)[1].split(' ===', 1)[0]
        secs.append((title, lines[i:j]))
    return lines[:heads[0]], secs


def defs(prelude):
    """the prelude lines every section needs: `newest` and `fresh()` (FAIL is each section's own)"""
    keep = [l for l in prelude if re.match(r'^\s*(newest=|fresh\(\))', l)]
    if len(keep) != 2:
        raise SystemExit('run_sections: the prelude lost its newest= / fresh() lines: %r' % keep)
    return keep


def script(lines, head):
    """one bash script: FAIL=0, the shared definitions, the lines (backslash-newline joined), exit $FAIL"""
    return 'FAIL=0; \\\n' + '\n'.join(head + lines) + '\nexit $FAIL\n'


def run(title, text):
    t0 = time.time()
    r = subprocess.run(['bash', '-c', text], cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return title, r.returncode, time.time() - t0, r.stdout.decode(errors='replace')


def names(lines):
    """the scratch file names the scripts of these lines name (and the lines themselves)"""
    out = set(NAME_RE.findall('\n'.join(lines)))
    for s in set(SCRIPT_RE.findall('\n'.join(lines))):
        p = os.path.join(REPO, s)
        if os.path.exists(p):
            out |= set(NAME_RE.findall(open(p, errors='replace').read()))
    return out


def audit(prelude, secs):
    """[(name, [section indices])] for every scratch name that scripts of two sections name,
    the prelude's own references excepted (built before any section starts)"""
    # not the `newest=$(ls -t ...)` line: it names EVERY tools/verify script (the oracle's dependency
    # list), which once made every name a prelude name and the audit blind (its tooth caught it)
    shared = names([l for l in prelude if not re.match(r'^\s*newest=', l)])
    seen = {}
    for k, (title, lines) in enumerate(secs):
        for n in names(lines) - shared:
            seen.setdefault(n, []).append(k)
    def allowed(n, ks):
        return n in ALLOW and all(secs[k][0].startswith(ALLOW[n][1]) for k in ks)
    return sorted((n, ks) for n, ks in seen.items() if len(ks) > 1 and not allowed(n, ks))


def mem_free_gib():
    """MemAvailable from /proc/meminfo (GiB); inf where there is none"""
    try:
        for line in open('/proc/meminfo'):
            if line.startswith('MemAvailable:'):
                return int(line.split()[1]) / 1048576.0
    except OSError:
        pass
    return float('inf')


def schedule(secs, head, jobs, report, free=mem_free_gib):
    """run the sections, `jobs` at a time in the recipe's order; a new one starts only while
    MemAvailable >= MIN_FREE_GIB (or when nothing else runs). report(k, title, rc, dt, out) per
    section; returns the indices whose output shows a child killed by the kernel."""
    pending, running, killed = list(range(len(secs))), {}, []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, jobs)) as ex:
        while pending or running:
            while pending and len(running) < max(1, jobs) and (not running or free() >= MIN_FREE_GIB):
                k = pending.pop(0)
                title, lines = secs[k]
                running[ex.submit(run, title, script(lines, head))] = k
            done, _ = concurrent.futures.wait(list(running), timeout=15,
                                              return_when=concurrent.futures.FIRST_COMPLETED)
            for f in done:
                k = running.pop(f)
                title, rc, dt, out = f.result()
                if KILLED_RE.search(out):
                    killed.append(k)
                report(k, title, rc, dt, out)
    return killed


def retry(killed, secs, head, report):
    """run each killed section again, ALONE, after the others: a kill is the machine's verdict, not the
    gate's. A second kill fails the section."""
    for k in killed:
        title, lines = secs[k]
        print('--- section %d: a child was KILLED by the kernel (memory) -- running it again, alone' % (k + 1))
        _, rc, dt, out = run(title, script(lines, head))
        if KILLED_RE.search(out):
            rc = rc or 1
            print('--- section %d: KILLED AGAIN while running alone' % (k + 1))
        report(k, title, rc, dt, out, tag=' (retried alone)')


def main():
    args = sys.argv[1:]
    jobs = int(args[args.index('--jobs') + 1]) if '--jobs' in args else 4
    prelude, secs = recipe()
    if '--guard-tooth' in args:              # the guard must see a recursive recipe
        ok = recursive('verify-recipe:\n\t@FAIL=0; \\\n\t$(MAKE) -s x && y; \\\n') and \
             recursive('verify-recipe:\n+\tfoo\n'.replace('+\t', '\t+')) and \
             not recursive('verify-recipe:\n\tmake -s x && y\n')
        print('run_sections --guard-tooth: %s' % ('BITES' if ok else 'DID NOT BITE'))
        return 0 if ok else 1
    if '--kill-tooth' in args:               # a section whose child the kernel kills must be retried alone
        import tempfile
        mark = os.path.join(tempfile.mkdtemp(), 'killed_once')
        secs_t = [('tooth killed once', ['if [ ! -e %s ]; then touch %s; bash -c "kill -9 \\$\\$" || FAIL=1; fi'
                                         % (mark, mark)]), ('tooth ok', ['true'])]
        seen = []
        rep = lambda k, t, rc, dt, out, tag='': seen.append((k, rc, tag))
        killed = schedule(secs_t, [], 2, rep)
        retry(killed, secs_t, [], rep)
        ok = killed == [0] and sorted(seen) == [(0, 0, ' (retried alone)'), (0, 1, ''), (1, 0, '')]
        print('run_sections --kill-tooth: %s (killed %s, results %s)' % ('BITES' if ok else 'DID NOT BITE',
                                                                        killed, sorted(seen)))
        return 0 if ok else 1
    if '--list' in args:
        for k, (title, lines) in enumerate(secs):
            print('%2d  %s' % (k + 1, title[:110]))
        return 0
    if '--audit' in args or '--audit-tooth' in args or jobs > 1:
        if '--audit-tooth' in args:          # plant: two sections naming one scratch file
            secs = secs + [('tooth A', ['python3 x.py > scratchpad/audit_tooth_shared.log']),
                           ('tooth B', ['python3 y.py > scratchpad/audit_tooth_shared.log'])]
        clash = audit(prelude, secs)
        for n, ks in clash:
            print('SHARED  %-34s sections %s' % (n, ', '.join('%d (%s)' % (k + 1, secs[k][0][:40]) for k in ks)))
        if '--audit' in args or '--audit-tooth' in args:
            print('run_sections --audit: %d scratch name(s) shared by two sections' % len(clash))
            return 1 if clash else 0
        if clash:
            print('run_sections: REFUSED -- two sections name one scratch file, so they cannot overlap; '
                  'run --jobs 1 (make verify-seq) or give one of them its own name')
            return 1
    head = defs(prelude)
    t0 = time.time()
    title, rc0, dt, out = run('prelude', script(prelude, []))
    sys.stdout.write(out)
    print('--- prelude (the shared references): exit %d, %.0f s' % (rc0, dt))
    sys.stdout.flush()
    fails = {}
    count = [0]

    def report(k, title, rc, dt, out, tag=''):
        count[0] += 1
        sys.stdout.write(out)
        print('--- [%d/%d] section %d%s: exit %d, %.0f s  (%s)' % (min(count[0], len(secs)), len(secs), k + 1, tag,
                                                                rc, dt, title[:70]))
        sys.stdout.flush()
        if rc:
            fails[k] = title
        else:
            fails.pop(k, None)
    killed = schedule(secs, head, jobs, report)
    retry(killed, secs, head, report)
    if rc0:
        fails[-1] = 'prelude'
    print('=== run_sections: %d sections, %d at a time (MemAvailable floor %.0f GiB), %d retried alone, %.0f s: %s' % (
        len(secs), jobs, MIN_FREE_GIB, len(killed), time.time() - t0,
        'every section exit 0' if not fails else
        'FAILED: ' + '; '.join('prelude' if k < 0 else '%d (%s)' % (k + 1, t[:60]) for k, t in sorted(fails.items()))))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
