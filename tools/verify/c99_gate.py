#!/usr/bin/env python3
"""c99_gate.py -- BOTH PORTS ARE ISO C99, AND IT IS CHECKED (docs/GATE_PARITY.tsv class c99, 2026-10-11).

The goal, in the user's words: "THE FULL PLUGIN, RECREATED PERFECTLY IN C99". On 2026-10-11 the JX-3P port used
unsigned __int128 (the lifted 64-bit mul / imul / div, the voice helpers' Payne-Hanek path), __builtin_clzll and
x86 inline asm (cvtsd2si) on the path every gate ran -- compiler extensions, not C99 -- and nothing said so: a
build with -std=c99 accepts them. Two checks, every product translation unit:

  1. gcc -std=c99 -pedantic-errors -fsyntax-only: no __int128, no GNU syntax ISO C rejects.
  2. the unit's LIVE code -- what a preprocessor keeps, the unit and every local file it includes ("...",
     recursively), each #if evaluated -- scanned for compiler extensions (__int128, __builtin_*, __attribute__,
     asm / __asm__, __declspec, __typeof__, __extension__, statement expressions, _mm_* / _MM_* intrinsics) and for
     #include <...> of a header that is not one of C99's 24, in two configurations:
       GENERIC  a C99 compiler on a platform the code knows nothing about (no __x86_64__, __SSE__, __GNUC__,
                __linux__ ...): NOTHING may be found -- the port must stand on ISO C alone (it picks its own portable
                paths: JP8_SOFTFP, no hardware FTZ, no image guard);
       NATIVE   this host's gcc on x86-64 Linux, the configuration every gate builds: only the floating-point mode
                glue C99 has no words for (<fenv.h> cannot set FTZ / DAZ) -- _mm_getcsr / _mm_setcsr and the
                _MM_SET_*_MODE macros from <xmmintrin.h> / <pmmintrin.h> -- and the gates' image guard (mprotect from
                <sys/mman.h>) may appear. A __builtin, an __int128 or an asm on the path that runs is RED even when
                a portable twin sits in the #else (2026-10-11: the voice helpers' cvtsd2si asm was such a case).

The product units are what ships and what every gate builds: JUNO -- libjuno.so's (Makefile: gui/juno_bridge.c,
gui/juno_pm.c, src/*.c); JX-3P -- jx3p/gui/jx_bridge.c (with the lifted code, the JP8 runtime, the render object it
includes), jx3p/gui/jx_pm_glue.c with gui/juno_pm.c (-DJPM_PRODUCT), jx3p/src/jx_recall.c, jx_voice_render.c,
jx_voice_helpers.c, jx_master_render.c, jx_ftz.c.

    python3 tools/verify/c99_gate.py [--self-test]
  --self-test: a planted __int128, an unguarded builtin, a guarded builtin with no alternative, an unguarded POSIX
  header and a builtin on the native path with a portable #else must each be RED; the FTZ glue GREEN (a tooth seen
  to fail).
exit 0 = every unit ISO C99 (or, --self-test, every plant judged right).
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

JUNO = ['gui/juno_bridge.c', 'gui/juno_pm.c'] + sorted('src/' + f for f in os.listdir(os.path.join(REPO, 'src'))
                                                      if f.endswith('.c'))
JX = ['jx3p/gui/jx_bridge.c', 'jx3p/gui/jx_pm_glue.c', 'gui/juno_pm.c', 'jx3p/src/jx_recall.c',
      'jx3p/src/jx_voice_render.c', 'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c',
      'jx3p/src/jx_ftz.c']
UNITS = [('JUNO-60', u, ['-Isrc', '-Igui']) for u in JUNO] + \
        [('JX-3P', u, ['-Ijx3p/src', '-Isrc', '-Igui', '-DJPM_PRODUCT="PG-JX3P"']) for u in JX]

ISO_HEADERS = set('assert complex ctype errno fenv float inttypes iso646 limits locale math setjmp signal stdarg '
                  'stdbool stddef stdint stdio stdlib string tgmath time wchar wctype'.split())
EXT = re.compile(r'\b(__int128|__builtin_\w+|__attribute__|__asm__|__asm|asm|__declspec|__typeof__|typeof|'
                 r'__extension__|_mm_\w+|_MM_\w+|mprotect)\b|\(\s*\{')
NATIVE_OK_TOKENS = {'_mm_getcsr', '_mm_setcsr', '_MM_SET_FLUSH_ZERO_MODE', '_MM_SET_DENORMALS_ZERO_MODE',
                    '_MM_FLUSH_ZERO_ON', '_MM_FLUSH_ZERO_OFF', '_MM_DENORMALS_ZERO_ON', '_MM_DENORMALS_ZERO_OFF',
                    'mprotect'}
NATIVE_OK_HEADERS = {'xmmintrin.h', 'pmmintrin.h', 'sys/mman.h'}
CONFIGS = {
    'generic': {'__STDC__': '1', '__STDC_VERSION__': '199901L', '__STDC_HOSTED__': '1'},
    'native': {'__STDC__': '1', '__STDC_VERSION__': '199901L', '__STDC_HOSTED__': '1', '__x86_64__': '1',
               '__SSE__': '1', '__SSE2__': '1', '__GNUC__': '13', '__linux__': '1', '__LP64__': '1'},
}


def strip(text):
    """comments and string / char literals blanked, line structure kept"""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if text.startswith('/*', i):
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', text[i:j])); i = j
        elif text.startswith('//', i):
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif c in '"\'':
            j = i + 1
            while j < n and text[j] != c and text[j] != '\n':
                j += 2 if text[j] == '\\' else 1
            k = j + 1 if j < n and text[j] == c else j
            out.append(c + ' ' * max(0, k - i - 2) + (c if k > j else '')); i = k
        else:
            out.append(c); i += 1
    return ''.join(out)


def cond_value(expr, macros):
    """an #if expression's value: defined() from the macro table, other names their integer value or 0"""
    e = re.sub(r'\bdefined\s*\(\s*(\w+)\s*\)|\bdefined\s+(\w+)',
               lambda m: '1' if (m.group(1) or m.group(2)) in macros else '0', expr)
    for _ in range(8):                                  # object-like macros, expanded a few levels
        e2 = re.sub(r'\b([A-Za-z_]\w*)\b', lambda m: macros.get(m.group(1)) or '0'
                    if m.group(1) not in ('and', 'or', 'not') else m.group(1), e)
        if e2 == e:
            break
        e = e2
    e = re.sub(r'\b(0[xX][0-9a-fA-F]+|\d+)[uUlL]*\b', r'\1', e)
    e = e.replace('&&', ' and ').replace('||', ' or ')
    e = re.sub(r'!(?!=)', ' not ', e)
    try:
        return bool(eval(e, {'__builtins__': {}}, {}))
    except Exception:
        raise SystemExit('c99_gate: cannot evaluate #if %r (as %r)' % (expr.strip(), e))


def preprocess(path, macros, found, cfg, seen_stack=()):
    """walk the file as a preprocessor would in configuration cfg: the live lines' extensions and system headers
    into found (path, line, what)"""
    path = os.path.normpath(path)
    if path in seen_stack:
        return
    raw = open(path, encoding='utf-8', errors='replace').read()
    raw = re.sub(r'\\\n', '  ', raw)                   # continued lines joined (line numbers drift by the joins)
    lines = strip(raw).split('\n')
    rawl = raw.split('\n')
    stack = []                                          # [live, taken, parent_live]
    live = True
    for k, ln in enumerate(lines):
        m = re.match(r'\s*#\s*(\w+)\s*(.*)', ln)
        if m:
            d, rest = m.group(1), m.group(2)
            if d in ('if', 'ifdef', 'ifndef'):
                v = (cond_value(rest, macros) if d == 'if' else
                     (rest.split()[0] in macros) == (d == 'ifdef')) if live else False
                stack.append([live, v]); live = live and v
            elif d == 'elif':
                plive, taken = stack[-1]
                v = plive and not taken and cond_value(rest, macros)
                stack[-1][1] = taken or v; live = v
            elif d == 'else':
                plive, taken = stack[-1]
                live = plive and not taken; stack[-1][1] = True
            elif d == 'endif':
                live = stack.pop()[0]
            elif not live:
                pass
            elif d == 'define':
                mm = re.match(r'([A-Za-z_]\w*)(\()?\s*(.*)', rest)
                macros[mm.group(1)] = None if mm.group(2) else (mm.group(3).strip() or '1')
                if mm.group(2):
                    macros[mm.group(1)] = '1'
            elif d == 'undef':
                macros.pop(rest.split()[0], None)
            elif d == 'error':
                found.append((path, k + 1, '#error (%s)' % rest.strip()[:60]))
            elif d == 'include':
                inc = re.match(r'\s*#\s*include\s*([<"])([^>"]+)[>"]', rawl[k])
                if not inc:                             # a computed include: its macro's value
                    name = rest.strip()
                    val = macros.get(name, '')
                    inc = re.match(r'([<"])([^>"]+)[>"]', val or '')
                if not inc:
                    continue
                if inc.group(1) == '"':
                    for base in (os.path.dirname(path), os.path.join(REPO, 'jx3p', 'src'), os.path.join(REPO, 'src'),
                                 os.path.join(REPO, 'gui')):
                        if os.path.exists(os.path.join(base, inc.group(2))):
                            preprocess(os.path.join(base, inc.group(2)), macros, found, cfg, seen_stack + (path,))
                            break
                else:
                    h = inc.group(2)
                    if not (h.endswith('.h') and h[:-2] in ISO_HEADERS) and \
                            not (cfg == 'native' and h in NATIVE_OK_HEADERS):
                        found.append((path, k + 1, '#include <%s>' % h))
            continue
        if not live:
            continue
        for t in EXT.finditer(ln):
            w = t.group(0).strip()
            if cfg == 'native' and w in NATIVE_OK_TOKENS:
                continue
            found.append((path, k + 1, w))


def scan(path, flags, cfg):
    macros = dict(CONFIGS[cfg])
    for f in flags:
        if f.startswith('-D'):
            nm, _, v = f[2:].partition('=')
            macros[nm] = v or '1'
    found = []
    preprocess(path, macros, found, cfg)
    return found


def check(units, quiet=False):
    bad = 0
    for port, u, flags in units:
        r = subprocess.run(['gcc', '-std=c99', '-pedantic-errors', '-fsyntax-only'] + flags + [u],
                           cwd=REPO, capture_output=True, text=True)
        errs = [l for l in (r.stdout + r.stderr).splitlines() if 'error' in l]
        found = [(cfg,) + f for cfg in ('generic', 'native') for f in scan(os.path.join(REPO, u), flags, cfg)]
        if r.returncode or found:
            bad += 1
            if not quiet:
                print('  %-8s %-34s NOT ISO C99' % (port, u))
                for l in errs[:3]:
                    print('      ' + l[:160])
                for cfg, p, k, t in found[:6]:
                    print('      %-7s %s:%d  %s' % (cfg, os.path.relpath(p, REPO), k, t))
    return bad


PLANTS = [
    ('int128', 'unsigned __int128 x;\nint main(void) { return (int)x; }\n', True),
    ('builtin', 'int f(unsigned long long x) { return __builtin_clzll(x); }\n', True),
    ('noalt', '#if defined(__GNUC__)\nint f(unsigned long long x) { return __builtin_clzll(x); }\n#endif\n', True),
    ('posix', '#include <unistd.h>\nint f(void) { return 0; }\n', True),
    ('native', '#if defined(__x86_64__)\nint f(unsigned long long x) { return __builtin_clzll(x); }\n#else\n'
               'int f(unsigned long long x) { return (int)x; }\n#endif\n', True),
    ('glue', '#if defined(__SSE__)\n#include <xmmintrin.h>\nvoid g(void) { _mm_setcsr(_mm_getcsr() | 0x8040); }\n'
             '#else\nvoid g(void) { }\n#endif\n', False),
]


def main():
    if '--self-test' in sys.argv:
        ok = True
        with tempfile.TemporaryDirectory() as d:
            for name, src, red in PLANTS:
                p = os.path.join(d, name + '.c')
                open(p, 'w').write(src)
                got = check([('plant', p, [])], quiet=True) > 0
                print('  plant %-8s %s (%s)' % (name, 'RED' if got else 'GREEN', 'right' if got == red else 'WRONG'))
                ok = ok and got == red
        print('c99_gate --self-test: %s' % ('BITES' if ok else 'DID NOT BITE'))
        return 0 if ok else 1
    bad = check(UNITS)
    print('c99_gate: %d product units (JUNO-60 %d, JX-3P %d), gcc -std=c99 -pedantic-errors + the extension scan: %s'
          % (len(UNITS), len(JUNO), len(JX), 'ISO C99' if not bad else '%d NOT ISO C99' % bad))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
