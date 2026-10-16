#!/usr/bin/env python3
"""split_lift.py -- the lift compiled in parts (docs/JUNO_LIFT.md, playbook 292). lift/jn_lift.c is ONE C99 file (the
address-taken lift: 24,291 functions, 2.3 M statements); one cc1 over it reached 14 GB and was killed (2026-10-16). The
split is mechanical text: the SAME function definitions, in N parts of about equal size, each made external (the word
"static" dropped from its prototype and its definition line -- nothing else changes). Every part holds the lift's
include and declarations and all the prototypes; part 0 also holds the lift's tail (the dispatch table, jp8_icall,
jp8_run, the import names). The tools that read the lift (l3_cases.py, check_reached.py, l3_flags.py) keep reading the
one file. Self-check: the parts' definitions, joined in order, equal the file's (with "static " dropped), every
prototype has one definition, and the head, prototypes and tail are the file's own lines.
usage: python3 tools/lift/split_lift.py <lift.c> <outdir> <nparts>     -> <outdir>/lift_<k>.c, k = 0 .. nparts-1"""
import os
import re
import sys

PROTO = re.compile(r'^static void (f_[0-9a-f]+)\(CPU \*c\);$')
DEF = re.compile(r'^static void (f_[0-9a-f]+)\(CPU \*c\) \{')
TAIL = 'typedef struct { uint64_t rva; void (*fn)(CPU *); } jp8_fn_t;'


def split(lines):
    i = 0
    while i < len(lines) and not PROTO.match(lines[i]):
        i += 1
    head = lines[1:i]                                   # the include and the declarations (line 0: the roots comment)
    j = i
    while j < len(lines) and PROTO.match(lines[j]):
        j += 1
    protos = lines[i:j]
    k = lines.index(TAIL, j)
    body, tail = lines[j:k], lines[k:]
    if not body or not DEF.match(body[0]):
        raise SystemExit('split_lift: the first line after the prototypes is not a function definition')
    funcs = []
    for ln in body:
        if DEF.match(ln):
            funcs.append([ln])
        else:
            funcs[-1].append(ln)
    return lines[0], head, protos, funcs, tail


def main():
    src, out, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
    lines = open(src).read().split('\n')
    top, head, protos, funcs, tail = split(lines)
    names_p = [PROTO.match(p).group(1) for p in protos]
    names_d = [DEF.match(f[0]).group(1) for f in funcs]
    if sorted(names_p) != sorted(names_d) or len(set(names_d)) != len(names_d):
        raise SystemExit('split_lift: the prototypes and the definitions are not the same functions')
    ext = lambda ln: ln[len('static '):]
    size = [sum(len(x) + 1 for x in f) for f in funcs]
    total, parts, acc, cur = sum(size), [[] for _ in range(n)], 0, 0
    for f, s in zip(funcs, size):                       # in order, a new part each time the running size passes k/n
        while cur < n - 1 and acc >= total * (cur + 1) / n:
            cur += 1
        parts[cur].append(f)
        acc += s
    os.makedirs(out, exist_ok=True)
    pro = [ext(p) for p in protos]
    for p, fs in enumerate(parts):
        txt = ['/* part %d of %d of %s (tools/lift/split_lift.py): the same definitions, external */' % (p, n, os.path.basename(src))]
        txt += head + pro
        for f in fs:
            txt += [ext(f[0])] + f[1:]
        if p == 0:
            txt += tail
        open(os.path.join(out, 'lift_%d.c.partial' % p), 'w').write('\n'.join(txt) + ('' if p == 0 else '\n'))
    # self-check: re-read the parts; their definitions in order are the file's, made external; the tail is the file's
    got, gtail = [], None
    for p in range(n):
        pl = open(os.path.join(out, 'lift_%d.c.partial' % p)).read().split('\n')
        if pl[1:1 + len(head)] != head or pl[1 + len(head):1 + len(head) + len(pro)] != pro:
            raise SystemExit('split_lift: part %d head / prototypes differ' % p)
        rest = pl[1 + len(head) + len(pro):]
        if p == 0:
            ti = rest.index(TAIL)
            rest, gtail = rest[:ti], rest[ti:]
        elif rest and rest[-1] == '':
            rest = rest[:-1]
        got += rest
    want = [ext(ln) if DEF.match(ln) else ln for f in funcs for ln in f]
    if got != want or gtail != tail:
        raise SystemExit('split_lift: SELF-CHECK FAILED (the parts do not hold the file\'s definitions / tail)')
    for p in range(n):
        os.replace(os.path.join(out, 'lift_%d.c.partial' % p), os.path.join(out, 'lift_%d.c' % p))
    print('split_lift: %d functions in %d parts (%s statements lines each ~%d MB); self-check: the definitions and the '
          'tail are the file\'s' % (len(funcs), n, '/'.join(str(len(fs)) for fs in parts), total // n >> 20))


if __name__ == '__main__':
    main()
