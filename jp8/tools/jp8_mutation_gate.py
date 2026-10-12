#!/usr/bin/env python3
"""jp8_mutation_gate.py -- MEASURE THE REACH OF THE JUPITER-8 HOST GATE (docs/PORT_COMPLETENESS_CHARTER.md section 4).

The port is the plugin's machine code, lifted; a slip in it would be a slip of the lifter or of the runtime at ONE
instruction. Each mutation below changes ONE instruction of the lift, at every place the lift holds it, in code the
gate's drive RUNS (its rva is in the lift's reach, build/jp8_host/hostreach_lift.json): a float add made a subtract,
a subtract an add, a multiply an add, or the value a guest store writes with its low bit flipped. All mutations live in
ONE build, each behind its own number (`if (JP8_MUT == k) { the slip } else { the instruction }`, JP8_MUT read once
from the environment), so one compile serves them all; the product pipeline as the gate's (jp8_fast.py, jp8_xlane.py,
-O2). Then the gate's own C side (jp8_host_c.py) runs once per mutation against the gate's references:
  KILLED      it fails (a word, a state byte, an edit, the memory after, a trap) -- that slip is seen;
  UNREACHED   it passes and the slip never ran (each slip counts its runs, reported at exit): the drive does not reach
              that instruction (its rva came from the lift's reach, which holds more drives) -- a reach statement;
  EQUIVALENT  it passes, the slip ran and never changed a value (both values are computed and compared at each run);
  SURVIVED    it passes and the slip changed a value -- a slip the gate cannot see: a gate to write (or ACCEPTED,
              named with its reason).
CONTROL: JP8_MUT=0 must pass EXACTLY 0 (the guards change nothing) and the known slip -- the host gate's own tooth T1,
the FINE TUNE setter's addss at 0x38633e -- must be KILLED, or the harness is broken.
The sites are drawn with a fixed seed from the reached instructions of each kind, spread over the lift's functions.

    python3 jp8/tools/jp8_mutation_gate.py <refdir> [--n 40] [--seed 1] [--out build/jp8_mut]
Run it after jp8_host_gate.sh (it reads the gate's lift, reach, references and runtime objects) and in a snapshot.
exit 0 = the controls hold and every mutation is KILLED or named in ACCEPTED below."""
import argparse
import collections
import json
import os
import random
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRC = os.path.join(REPO, 'jp8', 'src', 'jp8_host_lift.c')
GATE = os.path.join(REPO, 'build', 'jp8_host')
STMT = re.compile(r'^(  /\*([0-9a-f]+) (.*?)\*/ )(.*)$')
HDR = re.compile(r'^static void f_([0-9a-f]+)\(CPU \*c\) \{$')
TOOTH_RVA = '38633e'                       # the host gate's T1 site (the FINE TUNE setter's addss)
ACCEPTED = {}                              # rva/kind -> the reason a survivor is equivalent (filled when one is proven)
# kind: (the mnemonic the line carries, the pattern, its replacement)
KINDS = {
    'add2sub': ('addss', 'JP8_ADDSS(', 'JP8_SUBSS('),
    'sub2add': ('subss', 'JP8_SUBSS(', 'JP8_ADDSS('),
    'mul2add': ('mulss', 'JP8_MULSS(', 'JP8_ADDSS('),
    'store^1': ('mov', None, None),         # M32(addr)=(value); -> M32(addr)=(value)^1ULL;
}
STORE = re.compile(r'^(M32\(.*\))=(\(.*\));$')

ap = argparse.ArgumentParser()
ap.add_argument('refdir')
ap.add_argument('--n', type=int, default=40)
ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--out', default=os.path.join(REPO, 'build', 'jp8_mut'))
ap.add_argument('--timeout', type=int, default=900)
a = ap.parse_args()
os.makedirs(a.out, exist_ok=True)
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)

reach = json.load(open(os.path.join(GATE, 'hostreach_lift.json')))
executed = set(reach['executed'])          # rvas as hex strings (no 0x)
lines = open(SRC).read().split('\n')
fn_of, cur = {}, None
by_kind = collections.defaultdict(lambda: collections.defaultdict(list))   # kind -> rva -> [line numbers]
for i, ln in enumerate(lines):
    m = HDR.match(ln)
    if m:
        cur = m.group(1); continue
    m = STMT.match(ln)
    if not m or m.group(2) not in executed:
        continue
    rva, mnem, text = m.group(2), m.group(3).split(' ')[0], m.group(4)
    for k, (mn, pat, _) in KINDS.items():
        if mnem != mn:
            continue
        if pat is not None and text.count(pat) == 1:
            by_kind[k][rva].append(i); fn_of.setdefault(rva, cur)
        elif pat is None and mnem == 'mov' and STORE.match(text):
            by_kind[k][rva].append(i); fn_of.setdefault(rva, cur)
log('reached candidates: %s' % ', '.join('%s %d' % (k, len(v)) for k, v in by_kind.items()))
rnd = random.Random(a.seed)
sites = []                                  # (k, kind, rva)
per = max(1, a.n // len(KINDS))
for kind in KINDS:
    rv = sorted(by_kind[kind])
    rnd.shuffle(rv)
    seen_fn, pick = set(), []
    for r in rv:                            # one site per function first, then the rest
        if fn_of[r] not in seen_fn:
            pick.append(r); seen_fn.add(fn_of[r])
        if len(pick) == per:
            break
    for r in rv:
        if len(pick) == per:
            break
        if r not in pick:
            pick.append(r)
    sites += [(kind, r) for r in pick]
assert TOOTH_RVA in by_kind['add2sub'], 'the control site 0x%s is not a reached addss' % TOOTH_RVA
sites = [('add2sub', TOOTH_RVA)] + [s for s in sites if s != ('add2sub', TOOTH_RVA)]   # k = 1: the known slip
plan = {}
for k, (kind, rva) in enumerate(sites, start=1):
    for i in by_kind[kind][rva]:
        plan[i] = (k, kind)
out = list(lines)
FOP = re.compile(r'^(XF\(\d+,0\))=(JP8_(?:ADDSS|SUBSS|MULSS))\((.*)\);$')
def measured(k, kind, text):
    """the statement with slip k MEASURED: both values computed, the slip's taken when JP8_MUT == k, and the run
    counts how often it ran and how often the two values differed (jp8_mut_f / jp8_mut_u, reported at exit)"""
    if kind == 'store^1':
        s_ = STORE.match(text)
        return '%s=jp8_mut_u(%d, %s, (%s)^1ULL);' % (s_.group(1), k, s_.group(2), s_.group(2))
    f_ = FOP.match(text)
    if not f_:
        return None
    _, pat, rep = KINDS[kind]
    op = f_.group(2) + '('
    assert op == pat
    return '%s=jp8_mut_f(%d, %s(%s), %s(%s));' % (f_.group(1), k, f_.group(2), f_.group(3), rep[:-1], f_.group(3))
for i, (k, kind) in list(plan.items()):
    m = STMT.match(lines[i])
    if measured(k, kind, m.group(4)) is None:          # a float op in another form: not a site
        del plan[i]
for i, (k, kind) in plan.items():
    m = STMT.match(lines[i])
    head, text = m.group(1), m.group(4)
    out[i] = head + measured(k, kind, text)
inc = next(i for i, ln in enumerate(out) if ln.startswith('#include "jp8_cpu.h"'))
out[inc + 1:inc + 1] = ['#include <stdlib.h>',
                        '#include <stdio.h>',
                        '/* jp8_mutation_gate.py: the mutation in force (JP8_MUT from the environment; 0: none); at exit the',
                        ' * run reports how often slip k ran and how often its value differed from the instruction\'s */',
                        'static int jp8_mut_v = -1; static unsigned long jp8_mut_n, jp8_mut_d;',
                        'static void jp8_mut_report(void) { fprintf(stderr, "JP8_MUT %d: ran %lu, changed %lu\\n", '
                        'jp8_mut_v, jp8_mut_n, jp8_mut_d); }',
                        'static int jp8_mut_get(void) { if (jp8_mut_v < 0) { const char *e = getenv("JP8_MUT"); '
                        'jp8_mut_v = e ? atoi(e) : 0; if (jp8_mut_v > 0) atexit(jp8_mut_report); } return jp8_mut_v; }',
                        'static float jp8_mut_f(int k, float o, float m) { uint32_t a, b; if (jp8_mut_get() != k) return o; '
                        'jp8_mut_n++; memcpy(&a, &o, 4); memcpy(&b, &m, 4); if (a != b) jp8_mut_d++; return m; }',
                        'static uint64_t jp8_mut_u(int k, uint64_t o, uint64_t m) { if (jp8_mut_get() != k) return o; '
                        'jp8_mut_n++; if ((uint32_t)o != (uint32_t)m) jp8_mut_d++; return m; }']
mutsrc = os.path.join(a.out, 'jp8_host_lift_mut.c')
open(mutsrc, 'w').write('\n'.join(out))
log('%d mutations at %d lines -> %s' % (len(sites), len(plan), mutsrc))
BASE = ['-std=c99', '-pedantic-errors', '-ffp-contract=off', '-fno-strict-aliasing', '-fwrapv', '-fPIC', '-DJP8_RELOC',
        '-DJP8_FLAT', '-DJP8_GS_BASE=0x580000000ULL', '-I' + os.path.join(REPO, 'jp8', 'src')]
PRD = BASE + ['-O2', '-DJP8_RELOC_CHECK=0', '-DJP8_MQ=']
def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        sys.exit('FAILED: %s\n%s%s' % (' '.join(cmd), r.stdout[-2000:], r.stderr[-2000:]))
    return r.stdout
fast = os.path.join(a.out, 'jp8_host_lift_mut_fast.c'); xl = os.path.join(a.out, 'jp8_host_lift_mut_xl.c')
log(run([sys.executable, os.path.join(HERE, 'jp8_fast.py'), mutsrc, fast]).strip())
log(run([sys.executable, os.path.join(HERE, 'jp8_xlane.py'), fast, xl]).strip()[:200])
obj = os.path.join(a.out, 'hlift_mut.o'); lib = os.path.join(a.out, 'libjp8host_mut.so')
run(['cc'] + PRD + ['-w', '-c', '-o', obj, xl])
run(['cc', '-shared', '-o', lib, obj, os.path.join(GATE, 'hrt_prd.o'), os.path.join(GATE, 'hhost_prd.o'), '-lm'])
log('built %s' % lib)

def grade(k):
    """(exit code, the first line that says why, (ran, changed) or None)"""
    env = dict(os.environ, JP8_MUT=str(k))
    try:
        r = subprocess.run([sys.executable, os.path.join(HERE, 'jp8_host_c.py'), a.refdir, lib], env=env,
                           capture_output=True, text=True, timeout=a.timeout)
        why = (r.stdout + r.stderr).strip().split('\n')
        first = next((x for x in why if 'differ' in x or 'TRAP' in x or 'Error' in x), why[-1] if why else '')
        cnt = re.search(r'JP8_MUT %d: ran (\d+), changed (\d+)' % k, r.stderr)
        return r.returncode, first[:170], (int(cnt.group(1)), int(cnt.group(2))) if cnt else None
    except subprocess.TimeoutExpired:
        return 'timeout', 'no end in %d s' % a.timeout, None
rc, why, _ = grade(0)
log('CONTROL 0 (no mutation): rc %s %s' % (rc, why))
if rc != 0:
    sys.exit('CONTROL 0 FAILED: the guarded build is not EXACTLY 0 without a mutation -- the harness is broken')
res = []
sited = {k for k, _ in plan.values()}
for k, (kind, rva) in enumerate(sites, start=1):
    if k not in sited:
        continue
    rc, why, cnt = grade(k)
    ran, changed = cnt if cnt else (None, None)
    if rc != 0:
        verdict = 'KILLED'
    elif cnt is None:
        verdict = 'NO COUNT'                # the run did not report (a broken harness): never a pass
    elif ran == 0:
        verdict = 'UNREACHED'               # this drive never runs it: a reach statement, not a graded slip
    elif changed == 0:
        verdict = 'EQUIVALENT'              # it ran and never changed a value on this drive
    else:
        verdict = 'ACCEPTED' if '%s/%s' % (rva, kind) in ACCEPTED else 'SURVIVED'
    res.append(dict(k=k, kind=kind, rva=rva, fn=fn_of.get(rva), lines=len(by_kind[kind][rva]), verdict=verdict, why=why,
                    ran=ran, changed=changed))
    log('%2d %-8s 0x%-7s f_%-7s %-10s ran %s changed %s  %s' % (k, kind, rva, fn_of.get(rva), verdict, ran, changed,
                                                              why if rc != 0 else ''))
    if k == 1 and verdict != 'KILLED':
        sys.exit('CONTROL 1 FAILED: the known slip (the host gate\'s T1 site) was not killed -- the harness is broken')
json.dump(dict(refdir=a.refdir, seed=a.seed, results=res), open(os.path.join(a.out, 'mutations.json'), 'w'), indent=1)
c = collections.Counter(r['verdict'] for r in res)
log('MUTATION REACH: %d mutations -- %s' % (len(res), ', '.join('%s %d' % kv for kv in sorted(c.items()))))
surv = [r for r in res if r['verdict'] in ('SURVIVED', 'NO COUNT')]
for r in surv:
    log('SURVIVOR: %s at 0x%s (f_%s)' % (r['kind'], r['rva'], r['fn']))
sys.exit(1 if surv else 0)
