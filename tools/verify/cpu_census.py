#!/usr/bin/env python3
"""cpu_census.py -- every question a plugin asks the CPU, every answer it keeps, every place the port's code reads one.

THE GAP (playbooks 226, 228). The oracle runs a model of a CPU (Unicorn: SSE4.2, no AVX, no FMA); the user runs a
real one. Where the plugin asks the CPU what it can do and picks code by the answer, the oracle and the user's PC can
run different code. crt_fma_gate.py grades one such answer (the CRT's FMA3 flag); this census finds ALL of them.

(1) THE QUESTIONS: each function holding cpuid / xgetbv, and the code before .text's first .pdata entry (OpenSSL's
    OPENSSL_ia32_cpuid: it returns its answer, its caller stores it); the globals each writes.
(2) THE READERS: every instruction that reads one of those globals by its address (lea included); the port's REACH:
    the functions its sources name by rva and their direct callees (a `rip + 0x..` displacement in a lifted
    instruction's comment names no function -- one in jx_lift.c fell in JUCE's CPU-info getter, playbook 228; nor
    does a number in hand-written code that starts no function -- the exe scripts' MIDI words, masks: the JX-3P.exe's
    0x6401B0, CC 1 value 100, fell in a function that reaches wcsstr, playbook 258); the JX's reach also reads the
    sources outside jx3p/ its products compile (gui/juno_pm.c, src/juno_conv.c: the JUNO-60's addresses), each name
    taken as its JX twins (JX_TWINS: fw_map's equal code; a cited number with no row makes the census REFUSE).
(3) THE ANSWERS, three sets: the CRT's own inits (__isa_available_init, the FMA3 init) run NATIVELY on this CPU
    (tools/verify/cpu_census_native.c), run in UNICORN (the oracles' CPU model: the process() oracles run DllMain, so
    they hold these), and not run at all -- the image's STATIC values (the engine oracles skip DllMain).
(4) EVERY REACHED READER, graded:
    FMA3    a CRT math function crt_fma_gate.py grades (its EXPECT set)
    SAME    every test it makes on an answer decides the same under all three sets
    DRIVER  the render driver: its ISA tests sit behind `cmp r13d, 8; jb` (8+ channel pointers; the plugin renders
            2 -- the process() oracle asserts it); run here in the process() oracle, they must be reached 0 times
    PATH    a reached CRT routine run in Unicorn under the STATIC and the UNICORN answers, random inputs: the code
            it runs must differ (the answer reached it) and every result must be the same (memmove, memset; strrchr
            over the characters its reached calls pass: its SSE4.2 path compares a sign-extended byte with the int
            argument in its unaligned head, so a character 128-255 passed as a positive int is missed there -- the
            SSE2 path finds it; the one reached call passes 'e'. The JX's wcsstr, which no reached call uses, gives
            different results on its two paths too: the plugin's CRT, outside the port)
    NATIVE  a leaf CRT routine whose path for __isa_available >= 5 is AVX2 code (strnlen, wcslen, wcsnlen: Unicorn
            cannot run it), run NATIVELY under the oracles' answers and this CPU's (cpu_census_native.c --path):
            3000 random strings each, equal results, and an int3 on the AVX2 path's first instruction must fire
            under this CPU's answer only
    The DRIVER count's control: the driver's loads of __isa_available (each block) must be seen by the same hooks.
    MXCSR: the plugin's own FTZ + DAZ switch (ScopedNoDenormals in process()) must load 0x9FC0 in the process() oracle
    -- a host's 0x1F80 with FTZ and DAZ, the mode the port's product build renders in (Unicorn starts at MXCSR 0; the
    oracles start a thread as Windows does, 0x1F80).
    A leaf function (no .pdata entry: MSVC writes none for code that never touches the stack) starts at each direct
    call target outside .pdata: without them these string routines' reads were invisible (playbook 228).
    any other reached reader FAILS the census until it is graded here.

    python3 tools/verify/cpu_census.py [--port-of juno|jx|both] [--no-driver]
    python3 tools/verify/cpu_census.py --tooth          the PATH and NATIVE proofs with the answers written 4 bytes
                                                        off their globals: no path may move, and the proofs must
                                                        refuse
    python3 tools/verify/cpu_census.py --tooth-mxcsr    the process() oracle entered with Unicorn's reset MXCSR 0 (as
                                                        before playbook 228): the FTZ + DAZ switch must not load 0x9FC0
    python3 tools/verify/cpu_census.py --tooth-roots    memory-operand displacements admitted as names again (the
                                                        lifted code's comments): the JX reaches JUCE's CPU-info
                                                        getter and OpenSSL, ungraded readers -- the census must fail
    python3 tools/verify/cpu_census.py --tooth-data     hand-written code's numbers admitted as names again: the
                                                        JX-3P.exe's MIDI words reach wcsstr, whose two paths differ --
                                                        the census must fail
    python3 tools/verify/cpu_census.py --twins          JX_TWINS made again from the two images (minutes); exit 1 when
                                                        the committed table differs
    python3 tools/verify/cpu_census.py --tooth-twins    one number taken out of JX_TWINS: the census must refuse
exit 0 = every reached reader graded (or, a tooth, the defect seen); 1 = not; 2 = the harness failed.
"""
import bisect
import collections
import os
import random
import re
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)

PORTS = {   # READ from each image: the CRT inits and the CRT routines the port's reach reads an answer in
    'juno': dict(pe=None, srcs=('src', 'gui'), isa_init=0x676080, fma_init=0x713C70, driver=0x320B20,
                 routines={0x6ADC00: 'memmove', 0x6AF460: 'memset', 0x6B079C: 'strrchr'},
                 native={0x6F54D0: 'strnlen', 0x6F5620: 'wcslen', 0x6F574C: 'wcsnlen'}),
    'jx': dict(pe=os.path.join(REPO, 'jx3p', 'truth', 'JX3P.vst3'), srcs=('jx3p/src', 'jx3p/gui'), isa_init=0x6AC490,
               fma_init=0x74A920, driver=0x320A00,
               routines={0x6E4010: 'memmove', 0x6E5870: 'memset', 0x6E6BAC: 'strrchr', 0x6E6990: 'wcsstr'},
               native={0x72B2B0: 'strnlen', 0x72B400: 'wcslen', 0x72B52C: 'wcsnlen'}),
}   # native: leaf routines (no .pdata entry) whose path for __isa_available >= 5 is AVX2 code Unicorn cannot run


RUNTIME = ('jp8/src/',)     # the lifter's runtime the JX includes: plumbing, its sites the JUPITER-8's addresses
# made by `cpu_census.py --twins` (2026-10-15): each number the JX's shared sources cite -> the JX functions whose
# code equals its JUNO-60 function's (several: every equal copy; none: it names no function -- a table, a global)
JX_TWINS = {0x283120: (0x283000,), 0x283db0: (0x283c90,), 0x2853c0: (0x2852a0,), 0x2de890: (0x2de770,), 0x320420:
    (0x320300,), 0x3222f0: (0x3221d0,), 0x322e60: (0x322d40,), 0x3232f6: (0x322d40,), 0x323fd0: (0x323eb0,), 0x3245c0:
    (0x3244a0,), 0x324850: (0x324730,), 0x325c60: (0x325b40,), 0x3262c0: (0x3261a0,), 0x326930: (0x326810,), 0x3278c0:
    (0x3277a0,), 0x327cf8: (0x3277a0,), 0x327d70: (0x327c50,), 0x327e95: (0x327c50,), 0x328038: (0x327c50,), 0x328330:
    (0x328210,), 0x3285f0: (0x3284d0,), 0x32c6e0: (0x32c5c0,), 0x32c970: (0x32c850,), 0x32ca60: (0x32c940,), 0x32d180:
    (0x32d060,), 0x32d6e0: (0x32d5c0,), 0x32d950: (0x32d830,), 0x32ddc0: (0x32dca0,), 0x32e070: (0x32df50,), 0x32e190:
    (0x32e070,), 0x32ead0: (0x32e9b0,), 0x32eec0: (0x32eda0,), 0x32f100: (0x32efe0,), 0x32f280: (0x32f160,), 0x32f2b0:
    (0x32f190,), 0x32fd50: (0x32fc30,), 0x3307c0: (0x3306a0,), 0x3308c0: (0x3307a0,), 0x330a80: (0x330960,), 0x330d10:
    (0x330bf0,), 0x330e10: (0x330cf0,), 0x330ed0: (0x330db0,), 0x331530: (0x331410,), 0x331d50: (0x331c30,), 0x3326a0:
    (0x332580,), 0x332960: (0x332840,), 0x332d30: (0x332c10,), 0x333480: (0x333360,), 0x333960: (0x333840,), 0x333be0:
    (0x333ac0,), 0x334070: (0x333f50,), 0x3344c0: (0x3343a0,), 0x3346b0: (0x334590,), 0x334e20: (0x334d00,), 0x334e90:
    (0x334d70,), 0x334ea0: (0x334d80,), 0x334f20: (0x334e00,), 0x335640: (0x335520,), 0x335850: (0x335730,), 0x335990:
    (0x335870,), 0x335ae0: (0x3359c0,), 0x336830: (0x336710,), 0x336a80: (0x336960,), 0x336fd0: (0x336eb0,), 0x337cc0:
    (0x337ba0,), 0x338090: (0x337f70,), 0x338220: (0x338100,), 0x33bc80: (0x33bb60,), 0x33cda0: (0x33cc80,), 0x33ea70:
    (0x33e950,), 0x33ecc0: (0x33eba0,), 0x33f0a0: (0x33ef80,), 0x33f190: (0x33f070,), 0x33f200: (0x33f0e0,), 0x33f260:
    (0x33f140,), 0x33f402: (0x33f140,), 0x33f4c2: (0x33f140,), 0x33f4f0: (0x33f3d0,), 0x340b80: (0x340a50,), 0x341f10:
    (0x341dd0,), 0x343a80: (0x343940,), 0x343e30: (0x343cf0,), 0x343ed8: (0x343cf0,), 0x344270: (), 0x344280:
    (0x344140,), 0x34b260: (0x34b120,), 0x34e170: (0x413140, 0x413150,), 0x3e33f0: (0x419800, 0x4198f0,), 0x3e3d30:
    (0x4199a0, 0x41a140,), 0x3e3f20: (0x41a330,), 0x3f2700: (0x428b10,), 0x40b5d0: (0x279d70, 0x292330, 0x297700,
    0x2a0fb0, 0x2a1020, 0x2a28e0, 0x2ad930, 0x2ed2b0, 0x2eeec0, 0x3148e0, 0x341ab0, 0x346e30, 0x34dea0, 0x4292e0,
    0x42c270, 0x430330, 0x43dfa0, 0x43f380, 0x4419e0, 0x44c480, 0x77f750, 0x78b110, 0x7bb590, 0x7dfc70,), 0x6bea7c:
    (0x6f4e8c,), 0x94ab80: (), 0xc43b50: (), 0xc43c30: (), 0xcb05b8: ()}
NAME_RE = re.compile(r'(?:rva|sub_18|f_|0x)\s*(?:0x)?([0-9a-fA-F]{5,6})\b')
SPAN_RE = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'', re.S)


def cites(src, tooth_roots=False):
    """every rva-shaped number of a C source: (value, in prose -- a comment or a string --, in lifted code, the bare
    0x form)"""
    lifted = re.search(r'^L_[0-9a-f]{5,6}:', src, re.M) is not None
    parts, pos = [], 0
    for m in SPAN_RE.finditer(src):
        parts += [(src[pos:m.start()], False), (m.group(0), True)]
        pos = m.end()
    parts.append((src[pos:], False))
    out = []
    for t, prose in parts:
        if not tooth_roots:   # a memory operand's displacement is no name: `[rip + 0x79fb9d]`, `[rcx + 0x12a60]` in a
            t = re.sub(r'\[[^\]\n]*\]', '', t)     # lifted instruction's comment
        out += [(int(m.group(1), 16), prose, lifted, m.group(0).startswith('0x')) for m in NAME_RE.finditer(t)]
    return out


def is_name(fn_of, v, prose, lifted, bare, tooth_data=False):
    """the function a cited number names, or None: an rva in a comment or a string, a lifted identifier (f_...,
    sub_18...), a number in the lifted code (its trap sites); a number in hand-written code is data -- the exe scripts'
    MIDI words (0x6401B0: CC 1, value 100, lies in the JX's 0x63ff20, which reaches wcsstr), masks (0x200000) --
    unless it starts a function (playbook 258)"""
    f = fn_of(v)
    return f if f and (prose or lifted or tooth_data or not bare or f[0] == v) else None


def jx_shared():
    """the files outside jx3p/ the JX's products compile or include (the build lists' SRCS, every #include reached),
    less the lifter's runtime: they cite the JUNO-60's addresses (gui/juno_pm.c, src/juno_conv.c)"""
    todo = []
    for t in ('jx3p/tools/make_native_jx.py', 'jx3p/tools/jx_patch_manager_gate.py'):
        m = re.search(r'^SRCS = \[(.*?)\]', open(os.path.join(REPO, t)).read(), re.S | re.M)
        todo += re.findall(r"'([^']+)'", m.group(1))
    for d in PORTS['jx']['srcs']:
        for root, _, files in os.walk(os.path.join(REPO, d)):
            todo += [os.path.relpath(os.path.join(root, n), REPO) for n in files if n.endswith(('.c', '.h'))]
    seen, out = set(), set()
    while todo:
        f = os.path.normpath(todo.pop())
        if f in seen or not os.path.isfile(os.path.join(REPO, f)):
            continue
        seen.add(f)
        if f.startswith(RUNTIME):
            continue
        if not f.startswith('jx3p/'):
            out.add(f)
        src = open(os.path.join(REPO, f), errors='replace').read()
        todo += [os.path.join(os.path.dirname(f), i) for i in re.findall(r'^\s*#\s*include\s+"([^"]+)"', src, re.M)]
    return sorted(out)


def shared_cites():
    """{number: [occurrences]} over the JX's shared sources, and the numbers JX_TWINS lacks"""
    occ = collections.defaultdict(list)
    for fl in jx_shared():
        for c in cites(open(os.path.join(REPO, fl), errors='replace').read()):
            occ[c[0]].append(c[1:])
    return occ, sorted(v for v in occ if v not in JX_TWINS)


def twins_table():
    """JX_TWINS made again: each number the shared sources cite that names a JUNO-60 function (is_name, in the JUNO's
    image) -> the JX functions whose normalized code equals that function's (jx3p/tools/fw_map.py; a leaf by its
    prefix up to a branch, against the JX's function and leaf starts; every match kept when there are several); ()
    for a number that names nothing"""
    sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
    import fw_map
    C, X = census('juno'), census('jx', twins=False)
    m = fw_map.Map()
    (jimg, jib, _), (timg, tib, _) = m.j, m.t
    pre = {}                                    # a leaf's twin starts where a JX function or leaf does
    def leaf(rva):
        p = fw_map.norm(jimg, jib, rva, rva + 0x400, stop_at_branch=True)
        if not pre:
            pre.update((t, fw_map.norm(timg, tib, t, t + 0x400, stop_at_branch=True)) for t in X['starts'])
        return [t for t, q in pre.items() if q[:len(p)] == p]
    occ, _ = shared_cites()
    tab = {}
    for v in sorted(occ):
        f = next((g for g in (is_name(C['fn_of'], v, *o) for o in occ[v]) if g), None)
        tab[v] = tuple(sorted(set(m.find(f[0])[0] if f[0] in m.jend else leaf(f[0])))) if f else ()
    return tab


def pe_path(port):
    p = PORTS[port]['pe']
    if p is None:
        import truth
        p = truth.VST3
    return p


def census(port, tooth_roots=False, tooth_data=False, twins=True, tooth_dead=None):
    import pefile
    import capstone
    shared = {}
    if port == 'jx' and twins:
        shared, stale = shared_cites()
        if stale:
            print('cpu_census: the JX\'s shared sources (%s) cite %s, not in JX_TWINS -- run `cpu_census.py --twins` '
                  'and paste its table -- REFUSE' % (', '.join(jx_shared()), ', '.join('%#x' % v for v in stale)))
            raise SystemExit(2)
    path = pe_path(port)
    pe = pefile.PE(path)
    base = pe.OPTIONAL_HEADER.ImageBase
    rf = sorted((e.struct.BeginAddress, e.struct.EndAddress) for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    starts = [b for b, _ in rf]

    def fn_pd(a):
        i = bisect.bisect_right(starts, a) - 1
        return rf[i] if i >= 0 and rf[i][0] <= a < rf[i][1] else None
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.skipdata = True
    ins, lo, hi = [], None, None
    for s in pe.sections:
        if s.Name.startswith(b'.text'):
            ins += list(md.disasm(s.get_data(), base + s.VirtualAddress))
            lo, hi = s.VirtualAddress, s.VirtualAddress + s.Misc_VirtualSize
    # a leaf function needs no .pdata entry (MSVC writes none for code that never touches the stack): each direct
    # call target outside .pdata, and each jump target outside .pdata jumped to from a .pdata function, starts one,
    # which runs to the next start -- without them a read in a small helper (the CRT's MXCSR accessors, playbook
    # 228) and every call into one would be invisible
    leaf_starts = set()
    for x in ins:
        if (x.mnemonic == 'call' or x.mnemonic.startswith('j')) and x.op_str.startswith('0x'):
            t = int(x.op_str, 16) - base
            if lo <= t < hi and fn_pd(t) is None and (x.mnemonic == 'call' or fn_pd(x.address - base)):
                leaf_starts.add(t)
    if tooth_dead:              # a DEAD routine called: its start a leaf start, cut after its first instruction, so its
        leaf_starts.add(tooth_dead[0])          # read is reached by code flow only
    bounds = sorted(set(starts) | set(e for _, e in rf) | leaf_starts | {hi} | ({tooth_dead[1]} if tooth_dead else set()))
    lst = sorted(leaf_starts)

    def fn_of(a):
        f = fn_pd(a)
        if f:
            return f
        i = bisect.bisect_right(lst, a) - 1
        if i < 0:
            return None
        t = lst[i]
        end = bounds[bisect.bisect_right(bounds, t)]
        return (t, end) if a < end else None

    def rip(x):
        m = re.search(r'rip ([+-]) (0x[0-9a-f]+)', x.op_str)
        return None if not m else x.address - base + x.size + int(m.group(2), 16) * (1 if m.group(1) == '+' else -1)
    # (1) the questions
    qf = collections.OrderedDict()
    first = rf[0][0]
    for x in ins:
        if x.mnemonic in ('cpuid', 'xgetbv'):
            a = x.address - base
            f = fn_pd(a) or ((a, None) if a < first else fn_of(a) or (a, None))
            qf.setdefault(f, []).append(a)
    leaf = [f for f in qf if f[1] is None]
    edges, callers = collections.defaultdict(set), collections.defaultdict(set)
    for x in ins:
        if (x.mnemonic == 'call' or x.mnemonic.startswith('j')) and x.op_str.startswith('0x'):
            f, g = fn_of(x.address - base), fn_of(int(x.op_str, 16) - base)
            if f and g and f != g:
                edges[f].add(g)
                callers[g].add(f)
    targets = sorted(set(int(x.op_str, 16) - base for x in ins if x.mnemonic == 'call' and x.op_str.startswith('0x')
                         and int(x.op_str, 16) - base < first))
    entries = set()     # each question site before .pdata: the nearest call target at or below it is its function
    for f in leaf:
        i = bisect.bisect_right(targets, f[0]) - 1
        if i >= 0:
            entries.add(targets[i])
    leaf_callers = set(fn_of(x.address - base) for x in ins if x.mnemonic == 'call' and x.op_str.startswith('0x')
                       and int(x.op_str, 16) - base in entries) - {None}
    writers = [f for f in qf if f[1] is not None] + sorted(leaf_callers)
    store = lambda x: (x.op_str.split(',')[0].strip().startswith(('byte ptr [rip', 'word ptr [rip', 'dword ptr [rip',
                                                                   'qword ptr [rip'))
                       and x.mnemonic.startswith(('mov', 'or', 'and', 'add', 'sub', 'inc', 'dec', 'xor', 'bt')))
    glob = {}
    for f in writers:
        glob[f] = set(rip(x) for x in ins if f[0] <= x.address - base < f[1] and store(x))
    allg = set().union(*glob.values())
    # (2) the readers and the reach
    roots = set()
    for d in PORTS[port]['srcs']:
        for root, _, files in os.walk(os.path.join(REPO, d)):
            for n in files:
                if n.endswith(('.c', '.h')):
                    for c in cites(open(os.path.join(root, n), errors='replace').read(), tooth_roots):
                        f = is_name(fn_of, *c, tooth_data=tooth_data)
                        if f:
                            roots.add(f)
    twins = set()
    for v in shared:                            # the JX's shared sources' JUNO-60 names, as their JX twins
        twins |= set(f for f in map(fn_of, JX_TWINS[v]) if f)
    roots |= twins
    if tooth_dead:                              # ... from a function the port names
        edges[min(roots)].add(fn_of(tooth_dead[0]))
    seen, q = set(roots), list(roots)
    while q:
        for g in edges[q.pop()]:
            if g not in seen:
                seen.add(g)
                q.append(g)
    wset = set(writers)
    reads = collections.defaultdict(list)    # reader function -> [(insn, global)]
    lost = []
    for k, x in enumerate(ins):
        a = rip(x)
        if a in allg:
            f = fn_of(x.address - base)
            if f is None:
                lost.append((k, a))
            elif f not in wset:
                reads[f].append((k, a))
    # a read outside every function's extent belongs to each function whose code FLOWS to it outside .pdata (from a
    # leaf start or a call target before .pdata: fall-through, direct jumps, a call returning); a read no code flows
    # to is DEAD -- unless an instruction or a pointer in the image takes its routine's address: an indirect call can
    # enter it, and the census fails (playbook 258: 10 reads in each image had been dropped unseen)
    idx = {x.address - base: k for k, x in enumerate(ins)}
    want, owner = {k for k, _ in lost}, collections.defaultdict(set)
    for s0 in sorted(leaf_starts | set(t for t in targets if lo <= t < hi)) if lost else ():
        stack, vis = [idx.get(s0)], set()
        while stack:
            k = stack.pop()
            if k is None or k in vis or k >= len(ins) or fn_pd(ins[k].address - base) is not None:
                continue
            vis.add(k)
            x = ins[k]
            if k in want:
                owner[k].add(s0)
            if x.mnemonic in ('ret', 'int3', 'ud2') or (x.mnemonic == 'jmp' and not x.op_str.startswith('0x')):
                continue
            if x.mnemonic.startswith('j') and x.op_str.startswith('0x'):
                stack.append(idx.get(int(x.op_str, 16) - base))
                if x.mnemonic == 'jmp':
                    continue
            stack.append(k + 1)
    dead, taken = [], []
    img, bset = None, set(bounds)
    for k, g in lost:
        for f in set(map(fn_of, owner[k])) - {None} - wset:
            reads[f].append((k, g))
        if owner[k]:
            continue
        j, e = k, k             # its routine: back to padding, a ret, a jump or a bound; on to padding or a bound
        while j > 0 and ins[j - 1].mnemonic not in ('int3', 'ret', 'jmp') and ins[j].address - base not in bset:
            j -= 1
        while e < len(ins) - 1 and ins[e].mnemonic != 'int3' and ins[e + 1].address - base not in bset:
            e += 1
        r0, r1 = ins[j].address - base, ins[e].address - base + ins[e].size
        refs = ['lea %x' % (y.address - base) for y in ins if y.mnemonic == 'lea' and r0 <= (rip(y) or -1) < r1
                and not r0 <= y.address - base < r1]
        if img is None:
            img = pe.get_memory_mapped_image()
            disp = collections.defaultdict(list)    # MSVC's switch tables: [base + index*4 + table] -> its indexers
            for y in ins:
                m = re.search(r'\*\s*4\s*\+\s*(0x[0-9a-f]+)\]', y.op_str)
                if m:
                    disp[int(m.group(1), 16)].append(y.address - base)
            tabs = sorted(disp)
        hits = (img.find(struct.pack('<Q', base + t)) for t in range(r0, r1))
        refs += ['pointer %x' % h for h in hits if h >= 0]
        for t in range(r0, r1):     # a 4-byte rva of it in a switch table (its first 256 entries) indexed from outside
            q = img.find(struct.pack('<I', t))      # it within 64 KB: a switch's cases lie in the indexing function
            while q >= 0:
                i = bisect.bisect_right(tabs, q) - 1
                if i >= 0 and q - tabs[i] < 0x400 and (q - tabs[i]) % 4 == 0:
                    refs += ['switch table %x (indexed at %x)' % (q, d) for d in disp[tabs[i]]
                             if not r0 <= d < r1 and abs(d - t) < 0x10000]
                q = img.find(struct.pack('<I', t), q + 1)
        (taken if refs else dead).append((ins[k].address - base, g, r0, r1, refs))
    return dict(path=path, base=base, ins=ins, fn_of=fn_of, questions=qf, leaf=leaf, leaf_callers=leaf_callers, entries=entries,
                glob=glob, allg=allg, reads=reads, reach=seen, roots=roots, callers=callers, twins=twins, dead=dead,
                taken=taken,
                starts=sorted(set(starts) | leaf_starts))


def decisions(C, f):
    """each test reader function f makes on an answer: (test insn index, global, kind, operand) -- kind 'cmp' (cmp
    [g], imm or a register loaded from g then cmp reg, imm), 'bt' (bt [g], bit), 'cmpreg' (cmp reg, [g]: decided by
    a run-time value -- a PATH routine's business), 'lea' (an address taken)"""
    ins, out = C['ins'], []
    for k, g in C['reads'][f]:
        x = ins[k]
        if x.mnemonic == 'cmp' and x.op_str.startswith('dword ptr [rip') and ', ' in x.op_str:
            out.append((k, g, 'cmp', int(x.op_str.split(', ')[1], 0)))
        elif x.mnemonic == 'bt':
            out.append((k, g, 'bt', int(x.op_str.split(', ')[1], 0)))
        elif x.mnemonic == 'mov' and x.op_str.split(',')[0].strip().startswith('r'):
            reg, found = x.op_str.split(',')[0].strip(), False
            for j in range(k + 1, len(ins)):
                y = ins[j]
                if C['fn_of'](y.address - C['base']) != f:
                    break
                if y.mnemonic == 'cmp' and y.op_str.startswith(reg + ', ') and \
                        re.fullmatch(r'0x[0-9a-f]+|\d+', y.op_str.split(', ')[1]):
                    out.append((j, g, 'cmp', int(y.op_str.split(', ')[1], 0)))
                    found = True
                elif reg in y.op_str.split(',')[0]:
                    break
            if not found:               # a value loaded and used some other way: not decoded here, so not graded
                out.append((k, g, 'other', None))
        elif x.mnemonic == 'cmp':
            out.append((k, g, 'cmpreg', None))
        elif x.mnemonic == 'lea':
            out.append((k, g, 'lea', None))
        else:
            out.append((k, g, 'other', None))
    return out


class Mini:
    """the image in a bare Unicorn: sections mapped at the preferred base, a stack, a buffer area, a stop page"""
    STACK, BUF, STOP = 0x7F0000000, 0x7E0000000, 0x7D0000000

    def __init__(self, path):
        import pefile
        from unicorn import Uc, UC_ARCH_X86, UC_MODE_64
        pe = pefile.PE(path)
        self.base = pe.OPTIONAL_HEADER.ImageBase
        img = pe.get_memory_mapped_image()
        self.uc = Uc(UC_ARCH_X86, UC_MODE_64)
        size = (len(img) + 0xFFF) & ~0xFFF
        self.uc.mem_map(self.base, size)
        self.uc.mem_write(self.base, img)
        self.uc.mem_map(self.STACK, 0x100000)
        self.uc.mem_map(self.BUF, 0x200000)
        self.uc.mem_map(self.STOP, 0x1000)
        self.uc.mem_write(self.STOP, b'\xC3')

    def call(self, rva, *args, cov=None):
        from unicorn import UC_HOOK_CODE
        from unicorn.x86_const import (UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9,
                                       UC_X86_REG_RAX)
        uc = self.uc
        rsp = self.STACK + 0xF0000
        uc.mem_write(rsp, struct.pack('<Q', self.STOP))
        uc.reg_write(UC_X86_REG_RSP, rsp)
        for r, v in zip((UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9), args):
            uc.reg_write(r, v & (2 ** 64 - 1))
        h = None
        if cov is not None:
            h = uc.hook_add(UC_HOOK_CODE, lambda u, a, s, d: cov.add(a - self.base), begin=self.base + rva,
                            end=self.base + rva + 0x2000)
        try:
            uc.emu_start(self.base + rva, self.STOP, count=50_000_000)
        finally:
            if h is not None:
                uc.hook_del(h)
        return uc.reg_read(UC_X86_REG_RAX)

    def rd(self, rva):
        return struct.unpack('<I', bytes(self.uc.mem_read(self.base + rva, 4)))[0]

    def wr(self, rva, v):
        self.uc.mem_write(self.base + rva, struct.pack('<I', v & 0xFFFFFFFF))


def answers(port, C):
    """the three answer sets, {global: value} over every global the reached readers read"""
    p = PORTS[port]
    gl = sorted(set(g for f in C['reads'] if f in C['reach'] for _, g in C['reads'][f]))
    m = Mini(C['path'])
    static = {g: m.rd(g) for g in gl}
    m.call(p['isa_init'])
    m.call(p['fma_init'])
    uni = {g: m.rd(g) for g in gl}
    d = tempfile.mkdtemp(prefix='cpuc_')
    exe = os.path.join(d, 'cpu_census_native')
    subprocess.run(['cc', '-O1', '-o', exe, os.path.join(HERE, 'cpu_census_native.c')], check=True)
    out = subprocess.run([exe, C['path'], '%#x,%#x' % (p['isa_init'], p['fma_init']), ','.join('%#x' % g for g in gl)],
                         capture_output=True, text=True, check=True).stdout.split()
    cpu = {int(k, 16): int(v) for k, v in (w.split('=') for w in out)}
    return gl, static, uni, cpu


def decide(kind, opnd, v, jcc):
    if kind == 'cmp':           # signed compare (jl / jge / jg / jle) or unsigned (jb / jae / ...): both decided
        sv = v - (1 << 32) if v >= 1 << 31 else v
        return (sv < opnd, sv == opnd, v < (opnd & 0xFFFFFFFF), jcc)
    if kind == 'bt':
        return (v >> opnd) & 1
    return None


def char_args(C, rva):
    """the character each reached direct call of rva passes (edx / dl set by an immediate within the 8 instructions
    before it); None for a call whose character is not a constant there"""
    base, ins, out = C['base'], C['ins'], []
    for k, x in enumerate(ins):
        if x.mnemonic in ('call', 'jmp') and x.op_str.startswith('0x') and int(x.op_str, 16) - base == rva:
            f = C['fn_of'](x.address - base)
            if f not in C['reach']:
                continue
            v = None
            for y in reversed(ins[max(0, k - 8):k]):
                d = y.op_str.split(',')[0].strip()
                if d in ('edx', 'dl', 'rdx', 'dx'):
                    if y.mnemonic == 'mov' and re.fullmatch(r'0x[0-9a-f]+|\d+', y.op_str.split(', ')[1]):
                        v = int(y.op_str.split(', ')[1], 0)
                    break
            out.append((x.address - base, v))
    return out


def path_proof(port, C, need, tooth=False):
    """each reached CRT routine in Unicorn under the STATIC and the UNICORN answers: the code run must differ, the
    results must not (random inputs; every size boundary memmove / memset test: 16, 32, 128, the non-temporal limit)"""
    p = PORTS[port]
    rnd = random.Random(1)
    bad, refused = 0, 0
    gl = sorted(set(g for f in C['reads'] if f in C['reach'] for _, g in C['reads'][f]))
    for rva, kind in sorted((f[0], p['routines'][f[0]]) for f in need):
        sets = []
        for which in ('static', 'unicorn'):
            m = Mini(C['path'])
            if which == 'unicorn':
                m.call(p['isa_init'])
                m.call(p['fma_init'])
            if tooth:                       # the harness defect: the answers written 4 bytes off their globals
                vals = {g: m.rd(g) for g in gl}
                m2 = Mini(C['path'])
                for g, v in vals.items():
                    m2.wr(g + 4, v)
                m = m2
            sets.append(m)
        cov = [set(), set()]
        res = [[], []]
        cases = []
        if kind in ('memmove', 'memset'):
            sizes = [0, 1, 2, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 127, 128, 129, 255, 256, 257, 1000, 4095, 4096,
                     8238, 8239, 8240, 8241, 12345, 65536, 70001]
            for n in sizes:
                for _ in range(3):
                    cases.append((n, rnd.randrange(16), rnd.randrange(16), rnd.choice((0, 0, -1, 1)), rnd.randrange(256)))
        else:
            chars = None
            if kind == 'strrchr':
                ca = char_args(C, rva)
                if not ca or any(v is None for _, v in ca):
                    print('  PATH %s %x (strrchr): a reached call passes a character not known here (%s) -- REFUSE' % (
                        port, rva, ', '.join('%x: %s' % (a, v) for a, v in ca) or 'no reached call'))
                    bad = 1
                    continue
                chars = sorted(set(v & 0xFF for _, v in ca))
                print('  PATH %s %x (strrchr): its reached calls pass %s' % (port, rva, ', '.join(
                    '%x: %#x' % (a, v) for a, v in ca)))
            for _ in range(400):
                ln = rnd.randrange(0, 300)
                cases.append((ln, rnd.randrange(16), rnd.randrange(64), rnd.randrange(4), rnd.randrange(1, 6)))
        for i, m in enumerate(sets):
            r2 = random.Random(7)
            for case in cases:
                B = m.BUF
                if kind == 'memmove':
                    n, ad, as_, ov, _ = case
                    data = bytes(r2.randrange(256) for _ in range(min(n + 64, 140000)))
                    m.uc.mem_write(B, b'\x55' * 0x80000)
                    src = B + 0x20000 + as_          # an overlap either way stays inside the buffer
                    dst = (src + (n // 3 if ov > 0 else -(n // 3) if ov < 0 else 0x30000) + ad) if n else B + 0x70000
                    m.uc.mem_write(src, data[:n + 32])
                    ret = m.call(rva, dst, src, n, cov=cov[i])
                    res[i].append((ret - dst, bytes(m.uc.mem_read(B, 0x80000))))
                elif kind == 'memset':
                    n, ad, _, _, c = case
                    m.uc.mem_write(B, b'\x55' * (n + 0x100))
                    ret = m.call(rva, B + 0x40 + ad, c, n, cov=cov[i])
                    res[i].append((ret - (B + 0x40 + ad), bytes(m.uc.mem_read(B, n + 0x100))))
                else:
                    ln, al, pos, mode, alpha = case
                    s = [r2.randrange(1, 1 + alpha * 40) for _ in range(ln)]
                    w = 2 if kind == 'wcsstr' else 1
                    m.uc.mem_write(B, b'\x00' * 0x2000)
                    if kind == 'strrchr':     # the callers' characters, placed in the string or not
                        c = chars[pos % len(chars)]
                        if ln and mode:
                            for j in range(mode):
                                s[(pos * (j + 3)) % ln] = c
                        m.uc.mem_write(B + al, bytes(s) + b'\0')
                        ret = m.call(rva, B + al, c, cov=cov[i])
                    else:
                        nd = s[pos % ln:pos % ln + 1 + mode] if ln and mode else [r2.randrange(1, 9) for _ in range(mode)]
                        m.uc.mem_write(B + 2 * al, b''.join(struct.pack('<H', v) for v in s) + b'\0\0')
                        m.uc.mem_write(B + 0x1000, b''.join(struct.pack('<H', v) for v in nd) + b'\0\0')
                        ret = m.call(rva, B + 2 * al, B + 0x1000, cov=cov[i])
                    res[i].append(ret - B if ret else None)
        same = res[0] == res[1]
        moved = cov[0] != cov[1]
        print('  PATH %s %x (%s): %d inputs; the code run %s; the results %s' % (
            port, rva, kind, len(cases), 'differs between the two answer sets' if moved else 'is THE SAME (no answer '
            'reached it)', 'equal' if same else 'DIFFER'))
        bad |= not same
        refused |= not moved
    return bad, refused


def native_proof(port, C, entries, ans, tooth=False):
    """each leaf routine whose AVX2 path Unicorn cannot run, NATIVELY (cpu_census_native.c --path): random strings
    under the oracles' answers (static, Unicorn) and this CPU's, the results compared; an int3 on the first
    instruction of the path the test `cmp eax, k; jl` selects must fire under this CPU's answer only"""
    p = PORTS[port]
    static, uni, cpu = ans
    d = tempfile.mkdtemp(prefix='cpun_')
    exe = os.path.join(d, 'cpu_census_native')
    subprocess.run(['cc', '-O1', '-o', exe, os.path.join(HERE, 'cpu_census_native.c')], check=True)
    ins, base = C['ins'], C['base']
    idx = {x.address - base: k for k, x in enumerate(ins)}
    bad, refused = 0, 0
    for rva in sorted(entries):
        kind = p['native'][rva]
        k = idx[rva]
        g = C['ins'][k].address - base + C['ins'][k].size + int(re.search(r'rip \+ (0x[0-9a-f]+)', ins[k].op_str).group(1), 16)
        j = next(j for j in range(k, k + 8) if ins[j].mnemonic in ('jl', 'jb'))
        trap = ins[j + 1].address - base      # the fall-through: the path taken when the answer is high enough
        for a in (static[g], uni[g]):
            out = subprocess.run([exe, C['path'], '--path', kind, '%#x' % rva, '%#x' % (g + 4 if tooth else g),
                                  str(a), str(cpu[g]), '3000', '7', '%#x' % trap],
                                 capture_output=True, text=True).stdout
            moved = ('trap %d no' % a) in out and ('trap %d yes' % cpu[g]) in out
            same = 'differ 0' in out
            print('  NATIVE %s %x (%s): __isa_available %d vs %d, 3000 inputs: the AVX2 path %s; the results %s' % (
                port, rva, kind, a, cpu[g], 'runs under this CPU\'s answer only' if moved else 'is NOT the one that '
                'moved', 'equal' if same else 'DIFFER'))
            bad |= not same
            refused |= not moved
    return bad, refused


def daz_switch(C):
    """the plugin's own FTZ + DAZ switch (JUCE's ScopedNoDenormals in process()): the one `ldmxcsr` that follows
    `or eax, 0x40` (DAZ) -- the MXCSR the plugin renders in"""
    ins = C['ins']
    hits = [ins[j] for k, x in enumerate(ins) if x.mnemonic == 'or' and x.op_str == 'eax, 0x40'
            for j in range(k + 1, k + 4) if ins[j].mnemonic == 'ldmxcsr']
    if len(hits) != 1:
        raise SystemExit('REFUSE: %d FTZ + DAZ switches found (expected 1)' % len(hits))
    m = re.fullmatch(r'dword ptr \[(\w+)(?: \+ (0x[0-9a-f]+|\d+))?\]', hits[0].op_str)
    return hits[0].address, m.group(1), int(m.group(2) or '0', 0)


def driver_count(port, C, tooth_mxcsr=False):
    """in the process() oracle over a chain: the render driver's ISA tests (reached how often), and the MXCSR the
    plugin's own FTZ + DAZ switch loads (it must be 0x9FC0: a host's 0x1F80 with FTZ and DAZ -- the product mode the
    port renders in; the tooth enters process() with Unicorn's reset value 0, as the oracles did before playbook
    228: 0x8040, every exception unmasked)"""
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_MXCSR
    p = PORTS[port]
    f = C['fn_of'](p['driver'])
    tests = [k for k, g, kind, _ in decisions(C, f) if kind == 'cmp']
    addrs = [C['ins'][k].address for k in tests]
    loads = [C['ins'][k].address for k, _ in C['reads'][f] if C['ins'][k].mnemonic == 'mov']   # run every block
    if port == 'juno':
        import host_process_emu as H
        h = H.HostProcess()
    else:
        sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
        import jx_host_emu as X
        h = X.JXHost()
    if tooth_mxcsr:
        h.uc.reg_write(UC_X86_REG_MXCSR, 0)
    import unicorn.x86_const as K
    sw, reg, disp = daz_switch(C)
    loaded = collections.Counter()
    h.uc.hook_add(UC_HOOK_CODE, lambda u, addr, s, d: loaded.update([struct.unpack('<I', bytes(u.mem_read(
        u.reg_read(getattr(K, 'UC_X86_REG_' + reg.upper())) + disp, 4)))[0]]), begin=sw, end=sw)
    h.start(48000.0, 512)
    hits = collections.Counter()
    for a in addrs:
        h.uc.hook_add(UC_HOOK_CODE, lambda u, addr, s, d: hits.update([addr]), begin=a, end=a)
    drv, ld = collections.Counter(), collections.Counter()
    h.uc.hook_add(UC_HOOK_CODE, lambda u, addr, s, d: drv.update([1]), begin=C['base'] + p['driver'],
                  end=C['base'] + p['driver'])
    for a in loads:     # the hooks' own control: the loads of __isa_available before the tests must be seen
        h.uc.hook_add(UC_HOOK_CODE, lambda u, addr, s, d: ld.update([addr]), begin=a, end=a)
    ev = [('on', 0, 0, 60, 0.8)] if port == 'jx' else []
    if port == 'juno':
        import host_process_gate as G
        ev = [G.ev_on(0, 60, 0.8)]
    h.process(512, events=ev)
    h.process(512)
    return len(addrs), sum(hits.values()), drv[1], sum(ld.values()), sw - C['base'], dict(loaded)


def run(port, tooth=False, tooth_roots=False, tooth_data=False, no_driver=False, tooth_dead=None):
    import crt_fma_gate as F
    C = census(port, tooth_roots, tooth_data, tooth_dead=tooth_dead)
    print('%s: %d functions ask (%s); %d globals; the port reaches %d functions from %d it names%s' % (
        port, sum(1 for f in C['questions'] if f[1] is not None), ', '.join(
            '%x' % f[0] for f in C['questions'] if f[1] is not None) + ' + %d sites '
        'before .pdata (function %s, called from %s)' % (sum(len(v) for f, v in C['questions'].items() if f[1] is None),
                                                         ' '.join('%x' % e for e in sorted(C['entries'])),
                                                         ' '.join('%x' % c[0] for c in sorted(C['leaf_callers']))),
        len(C['allg']), len(C['reach']), len(C['roots']), ' (%d of them the JX twins of the JUNO-60 functions its shared '
        'sources name)' % len(C['twins']) if port == 'jx' else ''))
    gl, static, uni, cpu = answers(port, C)
    print('  answers (global: static / Unicorn / this CPU): %s' % ', '.join('%x: %d / %d / %d' % (
        g, static[g], uni[g], cpu[g]) for g in gl))
    fma = set(F.PORTS[port]['expect'])
    ungraded, path_needed, native_needed, drv = [], [], [], False
    for f in sorted(C['reads']):
        if f not in C['reach']:
            continue
        if f[0] in fma:
            print('  FMA3   %x-%x: crt_fma_gate.py grades it' % f)
            continue
        if f[0] == PORTS[port]['driver']:
            drv = True
            print('  DRIVER %x-%x: %d tests on __isa_available, behind `cmp r13d, 8`' % (
                f[0], f[1], sum(1 for d in decisions(C, f) if d[2] == 'cmp')))
            continue
        ds = decisions(C, f)
        if ds and all(C['ins'][k].address - C['base'] in PORTS[port]['native'] for k, _ in C['reads'][f]):
            native_needed.extend(C['ins'][k].address - C['base'] for k, _ in C['reads'][f])
            print('  NATIVE %x-%x (%s)' % (f[0], f[1], ', '.join(PORTS[port]['native'][a] for a in sorted(set(
                C['ins'][k].address - C['base'] for k, _ in C['reads'][f])))))
            continue
        nxt = lambda k: C['ins'][k + 1].mnemonic
        same = ds and all(d[2] in ('cmp', 'bt') and decide(d[2], d[3], static[d[1]], nxt(d[0])) ==
                   decide(d[2], d[3], uni[d[1]], nxt(d[0])) == decide(d[2], d[3], cpu[d[1]], nxt(d[0])) for d in ds)
        if same:
            print('  SAME   %x-%x: %d tests decide alike under every answer set' % (f[0], f[1], len(ds)))
        elif f[0] in PORTS[port]['routines']:
            path_needed.append(f)
            print('  PATH   %x-%x (%s): %s' % (f[0], f[1], PORTS[port]['routines'][f[0]], '; '.join(
                '%s %x' % (d[2], d[1]) for d in ds)))
        else:
            ungraded.append(f)
            print('  UNGRADED %x-%x: %s' % (f[0], f[1], '; '.join('%x: %s %s' % (
                C['ins'][d[0]].address - C['base'], C['ins'][d[0]].mnemonic, C['ins'][d[0]].op_str) for d in ds)))
    for a, g, r0, r1, _ in C['dead']:
        print('  DEAD   %x: reads %x in %x-%x -- no code flows there, no instruction or pointer takes its address' % (
            a, g, r0, r1))
    for a, g, r0, r1, refs in C['taken']:
        ungraded.append(a)
        print('  UNGRADED %x: reads %x in %x-%x, which no code flows to but %s takes -- an indirect call can enter it' % (
            a, g, r0, r1, ', '.join(refs[:4])))
    bad = len(ungraded)
    if tooth_roots:
        return bad
    if tooth and not path_needed:
        print('  the tooth needs a reached PATH routine -- REFUSE')
        return 0
    pb, pr = path_proof(port, C, path_needed, tooth)
    nb, nr = native_proof(port, C, set(native_needed), (static, uni, cpu), tooth) if native_needed else (0, 0)
    if tooth:
        return pr and (nr or not native_needed)
    bad += pb + pr + nb + nr
    if drv and not no_driver:
        nt, nh, nd, nl, sw, loaded = driver_count(port, C)
        print('  DRIVER in the process() oracle (2 channels): the driver ran %d times, its loads of __isa_available '
              '%d times, its %d ISA tests %d times' % (nd, nl, nt, nh))
        print('  MXCSR  the plugin\'s FTZ + DAZ switch (rva %x) loaded %s -- %s' % (sw, ', '.join(
            '%#x x%d' % kv for kv in sorted(loaded.items())) or 'nothing', 'the product mode (0x9FC0)' if set(loaded) ==
            {0x9FC0} else 'NOT the product mode 0x9FC0'))
        bad += nh != 0 or nd == 0 or nl == 0 or set(loaded) != {0x9FC0}
    return bad


def main():
    a = sys.argv[1:]
    which = a[a.index('--port-of') + 1] if '--port-of' in a else 'both'
    ports = ('juno', 'jx') if which == 'both' else (which,)
    if '--tooth' in a:
        bites = all(run(p, tooth=True) for p in ports)
        print('cpu_census --tooth: %s' % ('BITES (the answers written off their globals: no path moved, the proof '
                                           'refused)' if bites else 'DID NOT BITE'))
        return 0 if bites else 1
    if '--tooth-mxcsr' in a:     # the process() oracle entered with Unicorn's reset MXCSR 0 (before playbook 228)
        bites = True
        for p in ports:
            C = census(p)
            loaded = driver_count(p, C, tooth_mxcsr=True)[5]
            print('  %s: the FTZ + DAZ switch loaded %s' % (p, ', '.join('%#x x%d' % kv for kv in sorted(loaded.items()))))
            bites &= bool(loaded) and set(loaded) != {0x9FC0}
        print('cpu_census --tooth-mxcsr: %s' % ('BITES (an oracle entering process() with MXCSR 0 is seen)' if bites
                                                 else 'DID NOT BITE'))
        return 0 if bites else 1
    if '--twins' in a:          # JX_TWINS made again (fw_map: about 2 minutes, a leaf's prefix scan longer)
        tab = twins_table()
        print('JX_TWINS = {%s}' % ', '.join('%#x: (%s)' % (v, ''.join('%#x, ' % t for t in tw)) for v, tw in tab.items()))
        same = tab == JX_TWINS
        print('cpu_census --twins: %d numbers, %d with a JX twin (%d with several), %d naming no JUNO-60 function or '
              'none with a twin; %s' % (len(tab), sum(1 for v in tab.values() if v), sum(1 for v in tab.values() if
              len(v) > 1), sum(1 for v in tab.values() if not v), 'the committed table is THE SAME' if same else
              'the committed table DIFFERS -- paste the one above'))
        return 0 if same else 1
    if '--tooth-twins' in a:    # one number of JX_TWINS taken out: the census must refuse before it reads the image
        occ, _ = shared_cites()
        drop = sorted(occ)[len(occ) // 2]
        del JX_TWINS[drop]
        try:
            census('jx')
            code = 0
        except SystemExit as e:
            code = e.code
        print('cpu_census --tooth-twins: %#x taken out of JX_TWINS -- %s' % (drop, 'BITES (refused)' if code == 2 else
                                                                            'DID NOT BITE'))
        return 0 if code == 2 else 1
    if '--tooth-dead' in a:     # a DEAD read made reachable by code flow alone: the census must grade it -- and fail
        bites = True
        for p in ports:
            C = census(p)
            pick = next(((r0, C['ins'][C['ins'].index(next(x for x in C['ins'] if x.address - C['base'] == r0)) + 1]
                          .address - C['base'], a) for a, g, r0, r1, _ in C['dead'] if a > r0), None)
            if pick is None:
                print('  %s: no DEAD read past its routine\'s first instruction -- REFUSE' % p)
                return 2
            print('  %s: the DEAD routine at %x called by a named function, cut at %x: its read at %x by flow only' % (
                p, pick[0], pick[1], pick[2]))
            bites &= run(p, tooth_dead=pick[:2], no_driver=True) > 0
        print('cpu_census --tooth-dead: %s' % ('BITES (a read reached by code flow alone is graded)' if bites else
                                                'DID NOT BITE'))
        return 0 if bites else 1
    if '--tooth-data' in a:     # hand-written code's numbers names again: the JX-3P.exe's MIDI words reach wcsstr
        bites = run('jx', tooth_data=True, no_driver=True) > 0
        print('cpu_census --tooth-data: %s' % ('BITES (a data word as a name: a routine whose paths differ reached)'
                                                if bites else 'DID NOT BITE'))
        return 0 if bites else 1
    if '--tooth-roots' in a:
        bites = run('jx', tooth_roots=True) > 0
        print('cpu_census --tooth-roots: %s' % ('BITES (a displacement as a name: an ungraded reader)' if bites else
                                                 'DID NOT BITE'))
        return 0 if bites else 1
    bad = sum(run(p, no_driver='--no-driver' in a) for p in ports)
    print('cpu_census: %s' % ('every reached reader of a CPU answer graded' if not bad else 'NOT ALL GRADED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
