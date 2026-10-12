#!/usr/bin/env python3
"""dup_method_gate.py -- no class in the repository's Python defines a method twice.

A second `def name` in one class body silently REPLACES the first: Python raises nothing. Paid 2026-10-12 (playbook 244):
the JUPITER-8 host oracle (jp8/tools/jp8_host_emu.py) gained a second `_imp` for its window model and lost its first --
the heap's block reuse -- so its references were made on a heap that never reused a block; the C side, which reuses
blocks as the oracle had, disagreed at the first address the drive grades (the editor's view). Property setters /
deleters, typing.overload and singledispatch registrations are the legitimate repeats and are skipped.
    python3 tools/verify/dup_method_gate.py              every tracked .py file; exit 0 = none
    python3 tools/verify/dup_method_gate.py --self-test  the tooth: a class with a repeated method must be found"""
import ast
import os
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEGIT = ('.setter', '.deleter', '.register')


def dups(src, name):
    out = []
    for c in ast.walk(ast.parse(src, name)):
        if not isinstance(c, ast.ClassDef):
            continue
        seen = {}
        for fn in c.body:
            if not isinstance(fn, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            decos = [ast.unparse(d) for d in fn.decorator_list]
            if any(d.endswith(LEGIT) or d.split('.')[-1] == 'overload' for d in decos):
                continue
            if fn.name in seen:
                out.append('%s: class %s defines %s at line %d and again at line %d' % (name, c.name, fn.name, seen[fn.name], fn.lineno))
            seen[fn.name] = fn.lineno
    return out


if '--self-test' in sys.argv:
    bad = dups('class A:\n    def f(self): return 1\n    def g(self): return 2\n    def f(self): return 3\n', '<tooth>')
    ok = dups('class A:\n    @property\n    def f(self): return 1\n    @f.setter\n    def f(self, v): pass\n', '<legit>')
    print('tooth: %s; legit repeat: %s' % (bad or 'NOT FOUND', ok or 'none'))
    sys.exit(0 if len(bad) == 1 and not ok else 1)
files = subprocess.run(['git', 'ls-files', '*.py'], cwd=REPO, capture_output=True, text=True, check=True).stdout.split()
found, nread = [], 0
for f in files:
    p = os.path.join(REPO, f)
    if not os.path.exists(p):
        continue
    try:
        src = open(p, encoding='utf-8').read()
    except UnicodeDecodeError:
        continue
    try:
        found += dups(src, f); nread += 1
    except SyntaxError as e:
        found.append('%s: does not parse (%s)' % (f, e))
for x in found:
    print(x)
print('dup_method_gate: %d Python files, %d repeated methods: %s' % (nread, len(found), 'GREEN' if not found else 'RED'))
sys.exit(0 if not found else 1)
