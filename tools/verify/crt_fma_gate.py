#!/usr/bin/env python3
"""crt_fma_gate.py -- the plugins' CRT math on the user's CPU: its FMA3 code, run natively, against its SSE2 code.

THE GAP (playbook 226). Each plugin links the MSVC CRT statically. Its init (an _initterm entry: JUNO rva 0x713C70,
JX 0x74A920) runs cpuid and xgetbv at load; on a CPU with FMA + AVX + OSXSAVE whose OS saves the YMM state (every
x86-64 PC since about 2013) it sets a flag, and 13 math functions then take FMA3 code. Unicorn reports no FMA and
cannot decode VEX: every oracle in this repository runs the SSE2 code. The port was transcribed from it.

THE PROOF. For each port: (1) the census -- the init (`mov eax, 0x18001000` .. xgetbv), its flags, the functions
that test the flag, and of those the ones the port's code reaches (direct calls and jumps from every function its
sources name by rva): the reached set must be EXPECT (a function newly reached fails the gate until it is graded
here); (2) each reached function run NATIVELY (tools/verify/crt_fma_native.c: the image mapped at its base, called
through ms_abi), flag clear and flag set, over the inputs below, and the differences compared with RESULT; (3) the
inputs the port can give each one (READ, cited) lie outside its differences:
  expf    (both, 0x6EF740 / 0x722EA0)  every float: the two paths differ at ONE input, -68.5303421 (0xC2890F89,
          0x0E0C39FC / 0x0E0C39FD). The port's calls: src/voice_render.c:799 and jx_voice_render.c:1289 pass
          v * 5.2834215 with v clamped to [0, 1] (cell 1200, written once, by the voice init: 0x40A911CA);
          src/voice_render.c:1258 passes an integer value -- never -68.53.
  tanf    (JX 0x725150)                every float: no difference.
  sin/cos (JX 0x7247F0)                every |x| < 2^23, every infinity and NaN: no difference (the paths differ
          only in the large-argument reduction). Its one caller (0x359600) passes 3522 / n for an int n:
          |x| <= 3522, or an infinity.
  log10   (both, 0x6D2660 / 0x708A70)  every float peak the meter passes ([0.001f, 1.0f], as a double) and the two
          clamps (0.001, 1.0): the largest difference must stay under 1e-12 -- the meter's dB step is the same for
          any log10 within 1e-12 (tools/verify/led_meter_gate.py, part 1).
So the port, built from the SSE2 code, equals the plugin on an FMA3 CPU too: no number the port computes changes.

    python3 tools/verify/crt_fma_gate.py [--port-of juno|jx|both] [--quick]
    python3 tools/verify/crt_fma_gate.py --tooth     the native run with a flag address 4 bytes off (the harness
                                                     defect of a wrong flag): the expf difference must be missed
--quick grades expf / tanf on a 2^24-input window around the known difference instead of all 2^32.
exit 0 = every check holds (or, --tooth, the defect seen); 1 = a check fails; 2 = this CPU cannot run FMA3 code.
"""
import bisect
import collections
import os
import re
import subprocess
import struct
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)

PORTS = {
    'juno': dict(pe=None, srcs=('src', 'gui'), expect={0x6D2660: 'log10', 0x6EF740: 'expf'}),
    'jx': dict(pe=os.path.join(REPO, 'jx3p', 'truth', 'JX3P.vst3'), srcs=('jx3p/src', 'jx3p/gui'),
               expect={0x708A70: 'log10', 0x722EA0: 'expf', 0x7247F0: 'sin/cos', 0x725150: 'tanf'}),
}
EXPF_DIFF = {0xC2890F89: (0x0E0C39FC, 0x0E0C39FD)}
FULL = [(0, 0xFFFFFFFF)]
SMALL = [(0, 0x4AFFFFFF), (0x80000000, 0xCAFFFFFF), (0x7F800000, 0x7FFFFFFF), (0xFF800000, 0xFFFFFFFF)]
METER = [(0x3A83126F, 0x3F800000)]                 # every float peak in [0.001f, 1.0f]
CLAMPS = ['%016x' % struct.unpack('<Q', struct.pack('<d', v))[0] for v in (0.001, 1.0)]
QUICK = [(0xC2000000, 0xC2FFFFFF)]                 # 2^24 inputs, -68.53 among them


def cpu_ok():
    try:
        flags = set(re.search(r'^flags\s*:(.*)$', open('/proc/cpuinfo').read(), re.M).group(1).split())
    except Exception:
        return False
    return {'fma', 'avx', 'osxsave'} <= flags or {'fma', 'avx'} <= flags and 'xsave' in flags


def census(port):
    import pefile
    import capstone
    p = PORTS[port]
    path = p['pe']
    if path is None:
        import truth
        path = truth.VST3
    pe = pefile.PE(path)
    base = pe.OPTIONAL_HEADER.ImageBase
    rf = sorted((e.struct.BeginAddress, e.struct.EndAddress) for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    starts = [b for b, _ in rf]

    def fn_of(a):
        i = bisect.bisect_right(starts, a) - 1
        return rf[i] if i >= 0 and rf[i][0] <= a < rf[i][1] else None
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.skipdata = True
    ins = []
    for s in pe.sections:
        if s.Name.startswith(b'.text'):
            ins += list(md.disasm(s.get_data(), base + s.VirtualAddress))

    def rip(x):
        m = re.search(r'rip ([+-]) (0x[0-9a-f]+)', x.op_str)
        return None if not m else x.address - base + x.size + int(m.group(2), 16) * (1 if m.group(1) == '+' else -1)
    init = [x for x in ins if x.mnemonic == 'mov' and x.op_str == 'eax, 0x18001000']
    if len(init) != 1:
        raise SystemExit('REFUSE: %d CRT FMA3 inits found in %s (expected 1)' % (len(init), path))
    f0 = fn_of(init[0].address - base)
    body = [x for x in ins if fn_of(x.address - base) == f0]
    if not any(x.mnemonic == 'xgetbv' for x in body):
        raise SystemExit('REFUSE: the init at %x has no xgetbv' % f0[0])
    flags = sorted(set(rip(x) for x in body if x.mnemonic == 'mov' and x.op_str.startswith('dword ptr [rip')))
    readers = collections.defaultdict(set)
    edges = collections.defaultdict(set)
    for x in ins:
        if x.mnemonic == 'cmp' and x.op_str.startswith('dword ptr [rip') and x.op_str.endswith(', 0'):
            a = rip(x)
            if a in flags and fn_of(x.address - base):
                readers[a].add(fn_of(x.address - base))
        if (x.mnemonic == 'call' or x.mnemonic.startswith('j')) and x.op_str.startswith('0x'):
            f, g = fn_of(x.address - base), fn_of(int(x.op_str, 16) - base)
            if f and g and f != g:
                edges[f].add(g)
    flag = max(readers, key=lambda k: len(readers[k]))
    fma = {f[0]: f for f in readers[flag]}
    text = ''
    for d in p['srcs']:
        for root, _, files in os.walk(os.path.join(REPO, d)):
            for n in files:
                if n.endswith(('.c', '.h')):
                    text += open(os.path.join(root, n), errors='replace').read()
    roots = set()
    for m in re.finditer(r'(?:rva|sub_18|f_|0x)\s*(?:0x)?([0-9a-fA-F]{5,6})\b', text):
        f = fn_of(int(m.group(1), 16))
        if f:
            roots.add(f)
    seen, q = set(roots), list(roots)
    while q:
        for g in edges[q.pop()]:
            if g not in seen:
                seen.add(g)
                q.append(g)
    reached = {a: f for a, f in fma.items() if f in seen}
    # the error handlers each reached function calls: stubbed with ret in the native run
    hand = {}
    for a, (b, e) in reached.items():
        hand[a] = sorted(set(int(x.op_str, 16) - base for x in ins
                             if b <= x.address - base < e and x.mnemonic == 'call' and x.op_str.startswith('0x')))
    print('  %s: the CRT init %x sets %s; %d math functions test %x; the port reaches %s (from %d named functions)' % (
        port, f0[0], ' '.join('%x' % f for f in flags), len(fma), flag,
        ', '.join('%x' % a for a in sorted(reached)), len(roots)))
    return path, flag, reached, hand


def native(exe, path, mode, fn, flag, hand, args):
    r = subprocess.run([exe, path, mode, hex(fn), hex(flag), ','.join(hex(h) for h in hand)] + list(args),
                       capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('REFUSE: the native run failed: %s' % r.stderr[-800:])
    out = r.stdout
    diffs = {int(m.group(1), 16): (int(m.group(2), 16), int(m.group(3), 16))
             for m in re.finditer(r'^diff (\w+) (\w+) (\w+)$', out, re.M)}
    m = re.search(r'inputs (\d+) differ (\d+)', out)
    mx = re.search(r'maxabs (\S+)', out)
    return int(m.group(1)), int(m.group(2)), diffs, float(mx.group(1)) if mx else 0.0


def grade(port, exe, quick, tooth):
    path, flag, reached, hand = census(port)
    bad = []
    want = PORTS[port]['expect']
    if set(reached) != set(want):
        bad.append('the reached set %s is not %s' % (sorted('%x' % a for a in reached), sorted('%x' % a for a in want)))
    if tooth:
        flag += 4
    for a in sorted(set(reached) & set(want)):
        name = want[a]
        if name in ('expf', 'tanf'):
            rng = QUICK if quick else FULL
            n = nd = 0
            diffs = {}
            for lo, hi in rng:
                k, d, df, _ = native(exe, path, 'ff', a, flag, hand[a], [hex(lo), hex(hi)])
                n += k; nd += d; diffs.update(df)
            expect = EXPF_DIFF if name == 'expf' else {}
            ok = diffs == expect and nd == len(expect)
            print('    %-7s %x: %d inputs, the FMA3 and SSE2 code differ at %d%s: %s' % (
                name, a, n, nd, ''.join(' (%08X: %08X / %08X)' % (x, u, v) for x, (u, v) in sorted(diffs.items())[:3]),
                'as recorded' if ok else 'NOT AS RECORDED (%s)' % ({'%08X' % x for x in expect} or 'none')))
            if not ok:
                bad.append(name)
        elif name == 'sin/cos':
            n = nd = 0
            for lo, hi in (SMALL[2:] if quick else SMALL):
                k, d, _, _ = native(exe, path, 'ff', a, flag, hand[a], [hex(lo), hex(hi)])
                n += k; nd += d
            print('    %-7s %x: %d inputs (|x| < 2^23, infinities, NaNs), differ at %d: %s' % (
                name, a, n, nd, 'none, as recorded' if not nd else 'NOT AS RECORDED'))
            if nd:
                bad.append(name)
        elif name == 'log10':
            k, d, _, m1 = native(exe, path, 'df', a, flag, hand[a], [hex(METER[0][0]), hex(METER[0][1])])
            k2, d2, _, m2 = native(exe, path, 'dl', a, flag, hand[a], CLAMPS)
            mx = max(m1, m2)
            print('    %-7s %x: %d meter inputs, differ at %d, the largest difference %.3g: %s' % (
                name, a, k + k2, d + d2, mx, 'under 1e-12 (the dB step holds)' if mx < 1e-12 else 'OVER 1e-12'))
            if not mx < 1e-12:
                bad.append(name)
    return bad


def main():
    a = sys.argv[1:]
    which = a[a.index('--port-of') + 1] if '--port-of' in a else 'both'
    quick, tooth = '--quick' in a, '--tooth' in a
    if not cpu_ok():
        print('crt_fma_gate: this CPU (or its OS) cannot run FMA3 / AVX code -- the FMA3 paths cannot be executed '
              'here: REFUSE')
        return 2
    tmp = tempfile.mkdtemp(prefix='crtfma_')
    exe = os.path.join(tmp, 'crt_fma_native')
    subprocess.run(['cc', '-O2', '-o', exe, os.path.join(HERE, 'crt_fma_native.c'), '-lm'], check=True)
    bad = []
    for port in (['juno', 'jx'] if which == 'both' else [which]):
        bad += ['%s %s' % (port, b) for b in grade(port, exe, quick or tooth, tooth)]
    if tooth:
        print('crt_fma_gate --tooth (the flag address 4 bytes off): %s' % (
            'BITES (%s)' % '; '.join(bad) if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('crt_fma_gate: %s' % ('GREEN -- every CRT function the port reaches gives the port\'s numbers on an FMA3 CPU '
                                'too' if not bad else 'RED (%s)' % '; '.join(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
