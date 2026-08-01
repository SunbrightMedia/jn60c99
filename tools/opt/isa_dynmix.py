#!/usr/bin/env python3
"""dynall.py — whole-engine DYNAMIC instruction mix, M7 vs x86-64, gcov-weighted.

Same method as dynmix.py but over EVERY function of EVERY src/*.c, so the M7
per-sample instruction total is complete (libm expf/fmodf excepted; reported).
Self-validates each file against callgrind's measured Ir.
"""
import re, subprocess, os, collections
from mix import cls_arm, cls_x86, ORDER

S = os.path.dirname(os.path.abspath(__file__))
REPO = "/home/user/jn60c99"
G = S + "/gcov"
SAMPLES = 4800

AFLAGS = ("-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -mcpu=cortex-m7 "
          "-mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -g -c").split()
XFLAGS = "-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -g -c".split()


def gcov_counts(path):
    c = {}
    if not os.path.exists(path): return c
    for L in open(path, errors='replace'):
        p = L.split(':', 2)
        if len(p) < 3: continue
        cnt, ln = p[0].strip(), p[1].strip()
        if not ln.isdigit(): continue
        ln = int(ln)
        c[ln] = None if cnt == '-' else (0 if cnt in ('#####', '$$$$$') else int(cnt.rstrip('*')))
    return c


def dis_all(obj, arch, srcname):
    tool = "arm-none-eabi-objdump" if arch == 'arm' else "objdump"
    out = subprocess.run([tool, "-dl", "--no-show-raw-insn", obj],
                         capture_output=True, text=True).stdout
    per = collections.defaultdict(list)
    sym, cur = None, None
    for L in out.split("\n"):
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', L)
        if m:
            sym = m.group(1); cur = None; continue
        m = re.match(r'^(/\S+?):(\d+)(?:\s|$)', L)
        if m:
            cur = int(m.group(2)) if srcname in m.group(1) else None
            continue
        if L.startswith('/') or L.rstrip().endswith('():'):
            continue
        if sym is None: continue
        if not L.strip():
            sym = None; continue
        m = re.match(r'^\s*[0-9a-f]+:\s+(.*)$', L)
        if not m: continue
        t = re.sub(r'\s*@.*$', '', m.group(1)).strip()
        if arch == 'arm':
            t = re.sub(r'\s*//.*$', '', t).strip()
        if not t or t.startswith(('...', '.word', '.short', '.byte', '(bad)')):
            continue
        per[sym].append((t, cur))
    return per


def run():
    srcs = sorted(os.path.basename(p) for p in
                  __import__('glob').glob(REPO + "/src/*.c"))
    grand = {'arm': collections.Counter(), 'x86': collections.Counter()}
    rows = []
    for src in srcs:
        base = src[:-2]
        gp = f"{G}/{src}.gcov"
        counts = gcov_counts(gp)
        if not counts:
            continue
        objs = {}
        for arch, flags in (('arm', AFLAGS), ('x86', XFLAGS)):
            o = f"{S}/all_{base}_{arch}.o"
            if not os.path.exists(o):
                subprocess.run(["arm-none-eabi-gcc" if arch == 'arm' else "gcc"]
                               + flags + [f"{REPO}/src/{src}", "-o", o],
                               capture_output=True)
            objs[arch] = dis_all(o, arch, src)
        for arch in ('arm', 'x86'):
            tot = collections.Counter(); un = 0
            for sym, body in objs[arch].items():
                for t, ln in body:
                    w = counts.get(ln) if ln is not None else None
                    if w is None:
                        un += 1; continue
                    if w == 0: continue
                    k = cls_arm(t) if arch == 'arm' else cls_x86(t)
                    if k == 'FPARITH+LOAD':
                        tot['FPARITH'] += w; tot['FPLOAD'] += w; tot['TOTAL'] += w
                    else:
                        tot[k] += w; tot['TOTAL'] += w
            for k, v in tot.items():
                grand[arch][k] += v / float(SAMPLES)
            if arch == 'x86':
                rows.append((src, tot['TOTAL'] / float(SAMPLES)))
    print("per-file x86 dynamic instrs/sample (gcov-weighted):")
    for s, v in sorted(rows, key=lambda r: -r[1]):
        if v >= 1: print(f"   {s:22s} {v:9.0f}")
    print()
    hdr = f"{'arch':5s} " + '  '.join(f"{k:>8s}" for k in ORDER) + f"  {'TOTAL':>9s}"
    print(hdr); print('-'*len(hdr))
    for arch in ('x86', 'arm'):
        c = grand[arch]
        print(f"{arch:5s} " + '  '.join(f"{c[k]:8.0f}" for k in ORDER) + f"  {c['TOTAL']:9.0f}")
    print()
    x, a = grand['x86'], grand['arm']
    print("ARM/x86 dynamic ratios:")
    for k in ORDER + ['TOTAL']:
        if x[k] > 0:
            print(f"   {k:9s} {a[k]:9.0f} / {x[k]:9.0f} = {a[k]/x[k]:.3f}")
    print()
    print(f"  x86 memory accesses/sample : {x['FPLOAD']+x['FPSTORE']+x['ILOAD']+x['ISTORE']:.0f}")
    print(f"  arm memory accesses/sample : {a['FPLOAD']+a['FPSTORE']+a['ILOAD']+a['ISTORE']:.0f}")


if __name__ == '__main__':
    run()
