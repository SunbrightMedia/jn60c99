#!/usr/bin/env python3
"""m7ops.py — DYNAMIC counts of the Cortex-M7's individually expensive opcodes,
gcov-weighted over the real 8-voice steady state. Also the x86 counterpart of
each, so the cost asymmetry is visible.
"""
import re, subprocess, os, glob, collections
from dynall import gcov_counts, dis_all, SAMPLES, S, REPO, AFLAGS, XFLAGS

BUCKETS_ARM = [
    ("VDIV.F32",      r'^vdiv\.f32'),
    ("VDIV.F64",      r'^vdiv\.f64'),
    ("f64 arith",     r'^v(add|sub|mul|mla|mls|nmla|nmls|abs|neg|minnm|maxnm)\.f64'),
    ("f64<->f32 cvt", r'^vcvt\.(f64\.f32|f32\.f64)'),
    ("int<->fp cvt",  r'^vcvt(r)?\.(s32|u32)\.(f32|f64)|^vcvt\.(f32|f64)\.(s32|u32)'),
    ("VCMP(E)",       r'^vcmpe?\.'),
    ("VMRS  (FPSCR->APSR)", r'^vmrs'),
    ("VMOV core<->FP", r'^vmov\s+(r|s\d+,\s*r|\w+,\s*s)'),
    ("VMOV fp<->fp/imm", r'^vmov\.(f32|f64)'),
    ("VLDR",          r'^vldr'),
    ("VSTR",          r'^vstr'),
    ("BL (call)",     r'^bl\b'),
    ("f32 add/sub",   r'^v(add|sub)\.f32'),
    ("f32 mul",       r'^vmul\.f32'),
    ("f32 minnm/maxnm", r'^v(min|max)nm\.f32'),
]
BUCKETS_X86 = [
    ("divss/divsd",   r'^divs[sd]'),
    ("sd (double) arith", r'^(add|sub|mul)sd'),
    ("cvt f64<->f32", r'^cvt(ss2sd|sd2ss)'),
    ("int<->fp cvt",  r'^cvt(t?s[sd]2si|si2s[sd])'),
    ("ucomiss/comiss", r'^u?comis[sd]'),
    ("-",             r'^\$never\$'),
    ("-",             r'^\$never\$'),
    ("movd/movq gpr<->xmm", r'^mov[dq]\s+%(r|e)'),
    ("movaps/movapd reg", r'^mov(aps|apd)\s+%xmm\S+,\s*%xmm'),
    ("mem->xmm loads", r'^movs[sd]\s+[^%]'),
    ("xmm->mem stores", r'^movs[sd]\s+%xmm\S+,\s*[^%]'),
    ("call",          r'^call'),
    ("addss/subss",   r'^(add|sub)ss'),
    ("mulss",         r'^mulss'),
    ("minss/maxss",   r'^(min|max)ss'),
]


def run(arch, buckets):
    pats = [(n, re.compile(p)) for n, p in buckets]
    tot = collections.Counter()
    allops = collections.Counter()
    for path in sorted(glob.glob(REPO + "/src/*.c")):
        src = os.path.basename(path); base = src[:-2]
        counts = gcov_counts(f"{S}/gcov/{src}.gcov")
        if not counts: continue
        o = f"{S}/all_{base}_{arch}.o"
        if not os.path.exists(o):
            subprocess.run(["arm-none-eabi-gcc" if arch == 'arm' else "gcc"]
                           + (AFLAGS if arch == 'arm' else XFLAGS) + [path, "-o", o],
                           capture_output=True)
        for sym, body in dis_all(o, arch, src).items():
            for t, ln in body:
                w = counts.get(ln) if ln is not None else None
                if not w: continue
                mn = t.split()[0]
                allops[re.sub(r'\.(w|n)$', '', mn)] += w
                for n, p in pats:
                    if p.match(t):
                        tot[n] += w
    return tot, allops


if __name__ == '__main__':
    ta, aa = run('arm', BUCKETS_ARM)
    tx, ax = run('x86', BUCKETS_X86)
    print(f"{'Cortex-M7 op class':24s} {'per sample':>11s}   |  {'x86-64 counterpart':24s} {'per sample':>11s}")
    print('-'*84)
    for (na, _), (nx, _) in zip(BUCKETS_ARM, BUCKETS_X86):
        if na == '-': continue
        print(f"{na:24s} {ta[na]/SAMPLES:11.0f}   |  {nx:24s} {tx[nx]/SAMPLES:11.0f}")
    print()
    print("Top 25 M7 dynamic opcodes (per sample):")
    for m, c in aa.most_common(25):
        print(f"   {m:16s} {c/SAMPLES:9.0f}")
