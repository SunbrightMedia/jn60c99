#!/usr/bin/env python3
"""nan_codegen.py -- the compiler flips a NaN's sign only where the transcription writes a negation.

A NaN keeps its sign through mulss / addss / subss / a conversion; a negation (xorps with the sign mask) flips it. GCC
folds operations that are exact for every NUMBER and so flips a NaN where the plugin does not: x * 16384 computed as
-(x * -16384) (the delay read heads: 13 sites in the JUNO master, 12 in the JX master), v * x with v = -1.0 as -x
(JUNO voice, the sign selectors at lines 1753, 1857, 1961, 2065) -- measured by the tooth, 2026-10-11.
-frounding-math (no fold that holds only in round-to-nearest) and -fsignaling-nans (no fold that would skip an
operation a signalling NaN goes through) keep every one; the port runs in round to nearest, so no number changes --
only a NaN's sign (playbook 225).

A flip is placed by its .loc line, and the scheduler and tail duplication move or copy instructions: without the
flags the tooth lists JUNO master lines 1195 and 2749 for the folds of lines 1200 and 2721, and voice line 763's one
negation is two flips on two paths. So this gate pins the compiler; it can not see a fold whose flip carries a line
that also negates. The live A/B (nan_ab.py, jx_nan_ab.py) grades the result against the plugin.

Two checks per render file, on GCC's own output for the port's flags (-g: each instruction's C line):
  A. every sign flip GCC emits (xorps / xorpd / pxor with a register or constant other than itself) lies on a C line
     that writes a unary minus;
  B. every unary minus in the C compiles to a flip on its line -- or on another line that negates the same operand
     (one negation the compiler shares between two lines).
    python3 tools/verify/nan_codegen.py --port-of juno|jx
    python3 tools/verify/nan_codegen.py --port-of juno|jx --tooth   without the two flags: check A must fail
exit 0 = both checks hold for every file (or, --tooth, the defect seen); 1 = a line fails (listed).
"""
import re
import subprocess
import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
FILES = {'juno': ['src/voice_render.c', 'src/master_render.c'],
         'jx': ['jx3p/src/jx_voice_render.c', 'jx3p/src/jx_master_render.c']}
BASE = ['-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing']
NANFLAGS = ['-frounding-math', '-fsignaling-nans']
# a unary minus: after an operator, '(' , ',' , '=' , 'return' or a cast's ')' -- a '-' that opens a continued line
# is the binary minus of the line before
UNARY = re.compile(r'(?:[=(,?:+*/]|\breturn|\((?:float|double)\))\s*-\s*(?=[A-Za-z_(*])')


def flips_by_line(path, flags):
    """the C lines GCC gives a sign flip"""
    r = subprocess.run(['cc'] + BASE + flags + ['-g', '-S', '-o', '-', path, '-I', os.path.dirname(path)],
                       capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('REFUSE: %s did not compile:\n%s' % (path, r.stderr[-1500:]))
    files = {m.group(1): m.group(2) for m in re.finditer(r'\.file\s+(\d+)\s+"([^"]+)"', r.stdout)}
    base, cur, out = os.path.basename(path), None, {}
    for ln in r.stdout.split('\n'):
        m = re.match(r'\s*\.loc\s+(\d+)\s+(\d+)', ln)
        if m:
            cur = (files.get(m.group(1), '?'), int(m.group(2)))
            continue
        m = re.match(r'\s*(xorps|xorpd|pxor)\s+(\S+),\s*(%xmm\d+)\s*$', ln)
        if m and m.group(2) != m.group(3):
            if cur is None or os.path.basename(cur[0]) != base:
                out.setdefault(-1, 0)
                out[-1] += 1                          # a flip outside this file's lines (a header's inline helper)
            else:
                out[cur[1]] = out.get(cur[1], 0) + 1
    return out


def code_lines(text):
    """the file's lines with comments blanked (newlines kept, so line numbers hold) and preprocessor lines dropped"""
    text = re.sub(r'/\*.*?\*/', lambda m: re.sub(r'[^\n]', ' ', m.group(0)), text, flags=re.S)
    return ['' if re.match(r'\s*#', ln) else ln.split('//')[0] for ln in text.split('\n')]


def negations(lines):
    """the C lines that write a unary minus, and each one's negated operand (its first identifier)"""
    out = {}
    for i, s in enumerate(lines, 1):
        ops = []
        for m in UNARY.finditer(s.replace('->', '..')):
            w = re.match(r'[\s(*]*(?:float|double|int)?\s*\)?[\s(*]*([A-Za-z_]\w*)', s[m.end():])
            ops.append(w.group(1) if w else '?')
        if ops:
            out[i] = ops
    return out


def check(port, flags):
    bad = []
    for f in FILES[port]:
        path = os.path.join(REPO, f)
        raw = open(path).read().split('\n')
        lines = code_lines('\n'.join(raw))
        fl, neg = flips_by_line(path, flags), negations(lines)
        a = sorted(l for l in fl if l not in neg)          # A: a flip with no negation on its line
        # B's one exception: the same operand negated on a line that has the flip (the compiler negates once)
        shared = lambda l: any(any(re.search(r'-\s*(?:\(\s*(?:float|double)\s*\)\s*)?' + re.escape(op) + r'\b',
                                             lines[k - 1]) for op in neg[l]) for k in fl if k in neg and k != l)
        b = sorted(l for l in neg if l not in fl and not shared(l))
        print('  %-30s %3d flips on %3d lines, %3d negations in the C: %s' % (
            f, sum(fl.values()), len(fl), len(neg), 'every flip a negation, every negation a flip' if not (a or b)
            else '%d flips the C does not write, %d negations without a flip' % (len(a), len(b))))
        for l in a:
            print('    FLIP NOT IN THE C  %s' % ('a header\'s inline code' if l < 0 else
                                               'line %d: %s' % (l, raw[l - 1].strip()[:100])))
        for l in b:
            print('    NEGATION FOLDED    line %d: %s' % (l, raw[l - 1].strip()[:100]))
        bad += [(f, 'A', l) for l in a] + [(f, 'B', l) for l in b]
    return bad


def main():
    a = sys.argv[1:]
    port = a[a.index('--port-of') + 1] if '--port-of' in a else 'juno'
    mk = open(os.path.join(REPO, 'Makefile')).read()
    m = re.search(r'^CFLAGS\s*\?=(.*)$', mk, re.M)
    if not m or not all(x in m.group(1).split() for x in NANFLAGS):
        print('nan_codegen: the Makefile\'s CFLAGS lack %s -- the product is not built as graded' % ' '.join(NANFLAGS))
        return 1
    if '--tooth' in a:
        bad = check(port, [])
        hit = [x for x in bad if x[1] == 'A']
        print('nan_codegen --tooth (%s, without %s): %s' % (port, ' '.join(NANFLAGS), 'BITES (%d flips the C does '
                                                            'not write)' % len(hit) if hit else 'DID NOT BITE'))
        return 0 if hit else 1
    bad = check(port, NANFLAGS)
    print('nan_codegen %s: %s' % (port, 'the compiled render code negates exactly where the C does' if not bad else
                                  'FAIL (%d lines)' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
