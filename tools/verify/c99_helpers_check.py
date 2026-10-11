#!/usr/bin/env python3
"""c99_helpers_check.py -- the ISO C99 twins of the x86 arithmetic graded against the machine's own (2026-10-11,
playbook 218; docs/GATE_PARITY.tsv c99).

c99_gate.py proves the ports are ISO C99. This proves the C99 code that replaced the compiler extensions computes
what they computed -- on every input class, not only where a gate's renders happen to pass:
  jp8/src/jp8_cpu.h (the lifted code of the JX-3P and the JUPITER-8): jp8_mulu64, jp8_muls64 (mul / imul's
      128-bit product), jp8_divu128, jp8_divs128 (div / idiv's 128 / 64 quotient and remainder), jp8_clz64,
      jp8_ctz64, jp8_popcount64 (bsr / bsf / lzcnt / tzcnt / popcnt), op_imul2 at 8, 16, 32, 64 bits (CF = OF);
  jx3p/src/jx_voice_helpers.c: jxm_mulu64, jxm_clz64 (the tanf Payne-Hanek path), and the two conversions --
      cvtsd2si in the expf kernel (rint + the integer indefinite) and cvttsd2si in the tanf reduction.
REFERENCE: GCC's unsigned / signed __int128 and __builtin_clzll / ctzll / popcountll, and the SSE2 instructions
themselves (_mm_cvtsd_si32 / _mm_cvttsd_si32 under the default MXCSR) -- the test may use what the port may not.
The helpers are compiled from their OWN source text (the header included; the voice helpers' functions and
conversion blocks cut out of the file by brace matching, so an edit there is what is graded).
INPUTS: every pair of 64 edge words (0, 1, 2^k - 1, 2^k, 2^k + 1 at the 8 / 16 / 31 / 32 / 63-bit edges, the sign
words) and 2,000,000 seeded random words of random width; for the conversions the int32 edges +- 0.5 / 0.25 /
one ulp, the ties, the infinities, NaN, the denormals and 2,000,000 random doubles of random exponent.

    python3 tools/verify/c99_helpers_check.py [--self-test]
  --self-test: five planted mutations (one per family: the product's carry, the signed quotient's negation, the
               scan's last step, the rounding bound, the truncation bound) must each turn the check RED.
exit 0 = every helper equal to the reference on every input (or, --self-test, every mutation seen).
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
CPU_H = os.path.join(REPO, 'jp8', 'src', 'jp8_cpu.h')
VH_C = os.path.join(REPO, 'jx3p', 'src', 'jx_voice_helpers.c')


def cut_function(src, name):
    """the text of `static inline ... name(...) { ... }` (brace matched)"""
    m = re.search(r'static inline [^\n;{]*\b%s\s*\(' % re.escape(name), src)
    if not m:
        raise SystemExit('REFUSE: %s not found in the voice helpers -- the check cannot grade it' % name)
    return src[m.start():close(src, src.index('{', m.end()))]


def cut_block(src, start):
    """the `{ ... }` block that opens at the first '{' of the marker `start` (brace matched)"""
    i = src.find(start)
    if i < 0:
        raise SystemExit('REFUSE: the block %r not found in the voice helpers -- the check cannot grade it' % start)
    j = src.index('{', i)
    return src[j:close(src, j)]


def close(src, j):
    depth = 0
    for k in range(j, len(src)):
        if src[k] == '{':
            depth += 1
        elif src[k] == '}':
            depth -= 1
            if depth == 0:
                return k + 1
    raise SystemExit('REFUSE: unbalanced braces')


TEST = r'''
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <emmintrin.h>
#include "jp8_cpu.h"
/* ---- cut from jx3p/src/jx_voice_helpers.c ---- */
@VH_FUNCS@
static int32_t vh_cvtsd2si(double z) { int32_t n; @VH_CVT@ return n; }
static int32_t vh_cvttsd2si(double zn) { int32_t n; @VH_CVTT@ return n; }
/* ---- the reference: the compiler's 128-bit arithmetic and builtins, the SSE2 instructions ---- */
typedef unsigned __int128 u128; typedef __int128 s128;
static uint64_t S = 0x9E3779B97F4A7C15ULL;
static uint64_t rnd(void) { S ^= S << 13; S ^= S >> 7; S ^= S << 17; return S; }
static uint64_t word(void) { unsigned w = (unsigned)(rnd() % 65); return w == 64 ? rnd() : (rnd() & ((1ULL << w) - 1)); }
static long nbad = 0, ncase = 0;
#define BAD(...) do { if (nbad++ < 8) { printf("  MISMATCH "); printf(__VA_ARGS__); printf("\n"); } } while (0)
static void mul(uint64_t a, uint64_t b)
{
    uint64_t h, l; u128 p = (u128)a * b; s128 q = (s128)(int64_t)a * (int64_t)b;
    ncase++;
    l = jp8_mulu64(a, b, &h);
    if (l != (uint64_t)p || h != (uint64_t)(p >> 64)) BAD("jp8_mulu64 %016llx %016llx", (unsigned long long)a, (unsigned long long)b);
    l = jxm_mulu64(a, b, &h);
    if (l != (uint64_t)p || h != (uint64_t)(p >> 64)) BAD("jxm_mulu64 %016llx %016llx", (unsigned long long)a, (unsigned long long)b);
    l = jp8_muls64(a, b, &h);
    if (l != (uint64_t)q || h != (uint64_t)((u128)q >> 64)) BAD("jp8_muls64 %016llx %016llx", (unsigned long long)a, (unsigned long long)b);
}
static void imul(uint64_t a, uint64_t b)
{
    static const int SZ[4] = { 8, 16, 32, 64 }; int k;
    for (k = 0; k < 4; ++k) {
        int sz = SZ[k]; CPU c; uint64_t m = sz == 64 ? ~0ULL : (1ULL << sz) - 1, r, want; s128 p, s; int flag;
        s128 sa = sz == 64 ? (s128)(int64_t)a : sz == 32 ? (s128)(int32_t)a : sz == 16 ? (s128)(int16_t)a : (s128)(int8_t)a;
        s128 sb = sz == 64 ? (s128)(int64_t)b : sz == 32 ? (s128)(int32_t)b : sz == 16 ? (s128)(int16_t)b : (s128)(int8_t)b;
        p = sa * sb; want = (uint64_t)p & m;
        s = sz == 64 ? (s128)(int64_t)want : sz == 32 ? (s128)(int32_t)want : sz == 16 ? (s128)(int16_t)want : (s128)(int8_t)want;
        flag = p != s;
        memset(&c, 0, sizeof c); c.cf = c.of = !flag;
        r = op_imul2(&c, sz, a, b);
        ncase++;
        if (r != want || c.cf != flag || c.of != flag) BAD("op_imul2/%d %016llx %016llx", sz, (unsigned long long)a, (unsigned long long)b);
    }
}
static void dv(uint64_t nh, uint64_t nl, uint64_t d)
{
    uint64_t q, r; u128 n = ((u128)nh << 64) | nl; s128 sn = (s128)n; int64_t sd = (int64_t)d;
    if (!d) return;
    ncase++;
    q = jp8_divu128(nh, nl, d, &r);                      /* the quotient's low 64 bits (x86 faults past them) */
    if (q != (uint64_t)(n / d) || r != (uint64_t)(n % d)) BAD("jp8_divu128 %016llx:%016llx / %016llx", (unsigned long long)nh, (unsigned long long)nl, (unsigned long long)d);
    if (sd == -1 && nh == 0x8000000000000000ULL && nl == 0) return;   /* -2^127 / -1: undefined in C, #DE on x86 */
    q = jp8_divs128(nh, nl, d, &r);
    if (q != (uint64_t)(u128)(sn / sd) || r != (uint64_t)(u128)(sn % sd)) BAD("jp8_divs128 %016llx:%016llx / %016llx", (unsigned long long)nh, (unsigned long long)nl, (unsigned long long)d);
}
static void scan(uint64_t x)
{
    ncase++;
    if (jp8_popcount64(x) != (unsigned)__builtin_popcountll(x)) BAD("jp8_popcount64 %016llx", (unsigned long long)x);
    if (!x) return;
    if (jp8_clz64(x) != (unsigned)__builtin_clzll(x)) BAD("jp8_clz64 %016llx", (unsigned long long)x);
    if (jxm_clz64(x) != (unsigned)__builtin_clzll(x)) BAD("jxm_clz64 %016llx", (unsigned long long)x);
    if (jp8_ctz64(x) != (unsigned)__builtin_ctzll(x)) BAD("jp8_ctz64 %016llx", (unsigned long long)x);
}
static void cvt(double x)
{
    int32_t a = vh_cvtsd2si(x), b = _mm_cvtsd_si32(_mm_set_sd(x));
    int32_t c = vh_cvttsd2si(x), d = _mm_cvttsd_si32(_mm_set_sd(x));
    ncase++;
    if (a != b) BAD("cvtsd2si %.17g: twin %d, the instruction %d", x, a, b);
    if (c != d) BAD("cvttsd2si %.17g: twin %d, the instruction %d", x, c, d);
}
static double asd(uint64_t u) { double d; memcpy(&d, &u, 8); return d; }
int main(void)
{
    uint64_t E[64]; int ne = 0, i, j, k; long t;
    static const int B[5] = { 8, 16, 31, 32, 63 };
    E[ne++] = 0; E[ne++] = 1; E[ne++] = 2; E[ne++] = 3;
    for (i = 0; i < 5; ++i) { uint64_t p = 1ULL << B[i]; E[ne++] = p - 1; E[ne++] = p; E[ne++] = p + 1; E[ne++] = 0 - p; E[ne++] = 0 - p - 1; E[ne++] = p - 2; }
    E[ne++] = ~0ULL; E[ne++] = ~0ULL - 1; E[ne++] = 0x7FFFFFFFFFFFFFFFULL; E[ne++] = 0x8000000000000001ULL;
    E[ne++] = 0xFFFFFFFF00000000ULL; E[ne++] = 0x00000000FFFFFFFFULL; E[ne++] = 0xAAAAAAAAAAAAAAAAULL; E[ne++] = 0x5555555555555555ULL;
    E[ne++] = 0x0123456789ABCDEFULL; E[ne++] = 0xFEDCBA9876543210ULL;
    for (i = 0; i < ne; ++i) {
        scan(E[i]);
        for (j = 0; j < ne; ++j) {
            mul(E[i], E[j]); imul(E[i], E[j]);
            for (k = 0; k < ne; ++k) dv(E[i], E[j], E[k]);
        }
    }
    for (t = 0; t < 2000000; ++t) {
        uint64_t a = word(), b = word(), d = word();
        mul(a, b); imul(a, b); scan(a);
        dv(a % (d ? d : 1), b, d);      /* no overflow: the x86 domain */
        dv(a, b, d);                     /* past it: the quotient's low 64 bits */
    }
    {
        static const double C[] = { 0.0, -0.0, 0.5, -0.5, 1.5, -1.5, 2.5, -2.5, 0.49999999999999994, -0.49999999999999994,
            2147483647.0, 2147483647.25, 2147483647.5, 2147483647.75, 2147483648.0, 2147483648.5,
            -2147483648.0, -2147483648.25, -2147483648.5, -2147483648.75, -2147483649.0, -2147483649.5,
            1e10, -1e10, 1e300, -1e300, 4503599627370496.5, -9600.0, 8191.5, -9599.5 };
        for (i = 0; i < (int)(sizeof C / sizeof C[0]); ++i) { cvt(C[i]); cvt(nextafter(C[i], 1e308)); cvt(nextafter(C[i], -1e308)); }
        cvt(asd(0x7FF0000000000000ULL)); cvt(asd(0xFFF0000000000000ULL)); cvt(asd(0x7FF8000000000000ULL));
        cvt(asd(0xFFF8000000000001ULL)); cvt(asd(0x0000000000000001ULL)); cvt(asd(0x8000000000000001ULL));
        for (t = 0; t < 2000000; ++t) {
            uint64_t u = rnd(); unsigned e = 1023u - 8u + (unsigned)(rnd() % 48u);   /* |x| from 2^-8 to 2^39 */
            cvt(asd((u & 0x800FFFFFFFFFFFFFULL) | ((uint64_t)e << 52)));
            cvt((double)(int32_t)rnd() + (double)(rnd() % 4u) * 0.25);              /* integers and quarter ties */
        }
    }
    printf("%ld cases, %ld mismatches\n", ncase, nbad);
    return nbad != 0;
}
'''

MUTATIONS = [   # (what, file key, exact text, mutated text): each must be SEEN to turn the check RED
    ('the product carry (jp8_mulu64)', 'cpu', '*hi = hh + (lh >> 32) + (hl >> 32) + (mid >> 32);',
     '*hi = hh + (lh >> 32) + (hl >> 32);'),
    ('the signed negation (jp8_divs128)', 'cpu', 'nh = ~nh + (nl == 0);', 'nh = ~nh;'),
    ('the scan step (jxm_clz64)', 'vh', 'if (!(x >> 63)) { n += 1; }\n  return n;',
     'return n;'),
    ('the rounding bound (cvtsd2si)', 'vh', 'r <= 2147483647.0', 'r < 2147483647.0'),
    # (not 't > -2147483649.0' -> 't >= -2147483648.0': an EQUIVALENT mutant -- truncation there gives INT_MIN, the
    # integer indefinite's own value -- seen NOT to bite, 2026-10-11)
    ('the truncation bound (cvttsd2si)', 'vh', 't < 2147483648.0', 't < 2147483647.0'),
]


def run(cpu_text, vh_text, label):
    vh_funcs = cut_function(vh_text, 'jxm_mulu64') + '\n' + cut_function(vh_text, 'jxm_clz64')
    cvt = cut_block(vh_text, 'int32_t n; { double t = z, r = rint(t);')
    cvtt = cut_block(vh_text, 'int32_t n; { double t = zn;')
    with tempfile.TemporaryDirectory(prefix='c99h_') as tmp:
        open(os.path.join(tmp, 'jp8_cpu.h'), 'w').write(cpu_text)
        src = TEST.replace('@VH_FUNCS@', vh_funcs).replace('@VH_CVT@', cvt).replace('@VH_CVTT@', cvtt)
        open(os.path.join(tmp, 't.c'), 'w').write(src)
        exe = os.path.join(tmp, 't')
        c = subprocess.run(['cc', '-O2', '-ffp-contract=off', '-I', tmp, '-o', exe, os.path.join(tmp, 't.c'), '-lm'],
                           capture_output=True, text=True)
        if c.returncode:
            raise SystemExit('REFUSE: the check did not build (%s):\n%s' % (label, c.stderr[-2000:]))
        r = subprocess.run([exe], capture_output=True, text=True)
        return r.returncode, r.stdout


def main():
    cpu, vh = open(CPU_H).read(), open(VH_C).read()
    if '--self-test' in sys.argv:
        ok = True
        for what, key, old, new in MUTATIONS:
            text = cpu if key == 'cpu' else vh
            if text.count(old) != 1:
                print('  self-test %-38s REFUSE: its text is not in the source once' % what)
                ok = False
                continue
            text = text.replace(old, new)
            rc, out = run(text if key == 'cpu' else cpu, text if key == 'vh' else vh, what)
            seen = rc != 0
            print('  self-test %-38s %s' % (what, 'RED (seen: %s)' % out.strip().splitlines()[-1] if seen else 'NOT SEEN'))
            ok = ok and seen
        print('c99_helpers_check --self-test: %s' % ('BITES' if ok else 'DID NOT BITE'))
        return 0 if ok else 1
    rc, out = run(cpu, vh, 'the tree')
    print(out.rstrip())
    print('c99_helpers_check: the C99 multiply, divide, bit scans and conversions == the machine\'s: %s' % (
        'GREEN' if rc == 0 else 'RED'))
    return rc


if __name__ == '__main__':
    sys.exit(main())
