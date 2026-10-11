#!/usr/bin/env python3
"""nan_sites.py -- every float compare and min / max of a transcribed render function, mapped to the plugin's own
instruction by EXECUTION, and graded for NaN (playbook 81, 219).

After `comiss A, B` (or ucomiss / comisd / ucomisd) a NaN sets CF = ZF = PF = 1: the machine reads "A < B", "A <= B"
and "A == B" as TRUE and "A > B", "A >= B" as FALSE. Hex-Rays prints the flag predicate that selects a block as a
relation in the instruction's operand order -- so a transcribed `A < B` / `A <= B` is FALSE on NaN where the plugin's
predicate is TRUE (2026-10-11: the JUNO voice's `if ( v333 <= 0.0 ) v334 = 0.0` is `comiss; jbe` -- the plugin
clamps a NaN to 0, the port kept it). `minss A, B` returns B when either is NaN; C's fminf(A, B) returns the one that
is not NaN. Which relation came from which instruction, and in which operand order, cannot be read from the C alone
(a decompiler may swap operands): this tool MEASURES it.

ORACLE (--oracle, its own process): the plugin's function under Unicorn (tools/verify/e2e_emu.py for the JUNO-60,
        tools/verify/jx_emu.py for the JX-3P), a hook on every compare / min / max instruction of the function
        (recursive descent from its entry; voice 0's executions only), the operands' values at the first K
        executions per site.
PORT    (--port, its own process): the C file rewritten into a temporary copy -- every relational compare
        `A op B` and every fminf / fmaxf call wrapped in a logger that keeps the original types and result --, the
        port built with it and run on the same scene; the operands' values per C site.
MATCH   a C site and an instruction whose first executions saw the same operand values -- in order (A, B) or
        swapped (B, A) -- are one site. Verdict per C site, by the flag rule above:
          compare, same order:    <  <=  WRONG on NaN (must be !(A >= B), !(A > B));  >  >=  right
          compare, swapped order: >  >=  WRONG (must be !(A <= B), !(A < B));         <  <=  right
          fminf / fmaxf vs minss / maxss: WRONG when the instruction's second operand can be NaN -- must be the
          instruction's own select, (A < B ? A : B) / (A > B ? A : B) in its operand order
          == / != : reported with the instruction's parity jump (jp / jnp) or its absence
        A compare matched to a min / max instruction (a select the compiler made branchless), and a site matched to
        no instruction, are reported for review.

    python3 tools/verify/nan_sites.py --port-of juno|jx --func voice|master [--patch 5] [--frames 64]
                                      [--fixes FILE]   write the WRONG sites' rewrites (JSON) for --apply
                                      [--all-minmax]   also rewrite the min / max sites whose second operand is a
                                                       constant (NaN cannot reach them; a denormal operand can: the
                                                       oracle's minss returns it unflushed, the C library flushes it)
    python3 tools/verify/nan_sites.py --apply FILE   rewrite the C file in place from a fixes file (each site's text
                                      checked unchanged first)
    ... --tooth   every `!(A op B)` site planted back in the decompiler's `A cop B` form: WRONG must be seen
exit 0 = every executed site matched and right; 1 = a WRONG or unmatched site (listed).
"""
import atexit
import ctypes
import glob
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
K = 16
WARM = 16                          # JX: blocks of 256 rendered before the note

TARGETS = {
    ('juno', 'voice'): dict(c='src/voice_render.c', fn='juno_voice_render', voice='voice', rva=0x369070,
                            vst3='truth/JUNO60.vst3'),
    ('juno', 'master'): dict(c='src/master_render.c', fn='juno_master_render', voice=None, rva=0x363380,
                             vst3='truth/JUNO60.vst3'),
    ('jx', 'voice'): dict(c='jx3p/src/jx_voice_render.c', fn='jx_voice_render', voice='v', rva=0x3A22C0,
                          vst3='jx3p/truth/JX3P.vst3'),
    ('jx', 'master'): dict(c='jx3p/src/jx_master_render.c', fn='jx_master_render', voice=None, rva=0x39A2B0,
                           vst3='jx3p/truth/JX3P.vst3'),
}
CMP = ('comiss', 'ucomiss', 'comisd', 'ucomisd', 'vcomiss', 'vucomiss', 'vcomisd', 'vucomisd')
MINMAX = ('minss', 'maxss', 'minsd', 'maxsd', 'vminss', 'vmaxss', 'vminsd', 'vmaxsd')


# ------------------------------------------------------------------ the C side: tokens, operands, the rewrite
OPS = sorted(['<<=', '>>=', '->', '++', '--', '<<', '>>', '<=', '>=', '==', '!=', '&&', '||', '+=', '-=', '*=', '/=',
              '%=', '&=', '^=', '|=', '-', '+', '*', '/', '%', '&', '|', '^', '!', '~', '<', '>', '=', '?', ':', ';',
              ',', '.', '(', ')', '{', '}', '[', ']'], key=len, reverse=True)
TOKRE = re.compile(r'(?P<ws>\s+)|(?P<com>/\*.*?\*/|//[^\n]*)|(?P<pp>(?<![^\n])[ \t]*\#(?:\\\n|[^\n])*)'
                   r'|(?P<str>"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\')'
                   r'|(?P<num>0[xX][0-9a-fA-F]+[uUlL]*|(?:\d+\.\d*|\.\d+)(?:[eE][+-]?\d+)?[fFlL]?|\d+[eE][+-]?\d+[fFlL]?'
                   r'|\d+[uUlL]*)|(?P<id>[A-Za-z_]\w*)|(?P<op>' + '|'.join(re.escape(o) for o in OPS) + ')', re.S)
REL = ('<', '<=', '>', '>=')
STOP = {'==', '!=', '&&', '||', '?', ':', '=', '+=', '-=', '*=', '/=', '%=', '&=', '^=', '|=', '<<=', '>>=', ',', ';',
        '{', '}', '<', '<=', '>', '>=', 'return', 'case'}
LOWBIN = {'&', '|', '^'}


def tokenize(src):
    out, i = [], 0
    while i < len(src):
        m = TOKRE.match(src, i)
        if not m:
            raise SystemExit('REFUSE: cannot tokenize at %r' % src[i:i + 40])
        out.append((m.lastgroup, m.group(), m.start()))
        i = m.end()
    return out


def sig(toks, j, step):
    """the next significant token index from j (exclusive) in direction step"""
    j += step
    while 0 <= j < len(toks) and toks[j][0] in ('ws', 'com'):
        j += step
    return j


def operand_end(t):
    return t[0] in ('id', 'num', 'str') or t[1] in (')', ']')


def is_cast(toks, close):
    """the parenthesized group that ends at index close holds a type only: `(float *)`, `(unsigned __int8)`"""
    depth, j, inner = 0, close, []
    while j >= 0:
        s = toks[j][1]
        if toks[j][0] == 'op' and s == ')':
            depth += 1
        elif toks[j][0] == 'op' and s == '(':
            depth -= 1
            if depth == 0:
                break
        elif toks[j][0] not in ('ws', 'com'):
            inner.append(toks[j])
        j -= 1
    return bool(inner) and any(k == 'id' for k, _, _ in inner) and all(
        k == 'id' or (k == 'op' and v == '*') for k, v, _ in inner)


def binary_at(toks, p):
    """the low-precedence & | ^ at p is binary: the token before it ends an operand, and is not a cast's ')'"""
    q = sig(toks, p, -1)
    if q < 0 or not operand_end(toks[q]):
        return False
    return not (toks[q][1] == ')' and is_cast(toks, q))


def span_left(toks, k):
    j, depth, last = k, 0, None
    while True:
        p = sig(toks, j, -1)
        if p < 0:
            break
        kind, s, _ = toks[p]
        if kind == 'pp':
            break
        if s in (')', ']'):
            depth += 1
        elif s in ('(', '['):
            if depth == 0:
                break
            depth -= 1
        elif depth == 0:
            if s in STOP or (kind == 'id' and s in ('return', 'case')):
                break
            if s in LOWBIN and binary_at(toks, p):
                break
        j = last = p
    return last


def span_right(toks, k):
    j, depth, last = k, 0, None
    while True:
        p = sig(toks, j, 1)
        if p >= len(toks):
            break
        kind, s, _ = toks[p]
        if kind == 'pp':
            break
        if s in ('(', '['):
            depth += 1
        elif s in (')', ']'):
            if depth == 0:
                break
            depth -= 1
        elif depth == 0:
            if s in STOP:
                break
            if s in LOWBIN and last is not None and binary_at(toks, p):
                break
        j = last = p
    return last


def sites_of(src, fn):
    """the C sites inside function fn: relational compares and fminf / fmaxf / fmin / fmax calls"""
    toks = tokenize(src)
    m = re.search(r'\b%s\s*\([^;{]*\)\s*\{' % re.escape(fn), src)
    if not m:
        raise SystemExit('REFUSE: function %s not found' % fn)
    body0 = m.end() - 1
    depth, body1 = 0, None
    for kind, s, pos in toks:
        if pos < body0 or kind != 'op':
            continue
        if s == '{':
            depth += 1
        elif s == '}':
            depth -= 1
            if depth == 0:
                body1 = pos
                break
    out, used = [], []
    for k, (kind, s, pos) in enumerate(toks):
        if not (body0 < pos < body1):
            continue
        if kind == 'op' and s in REL:
            a, b = span_left(toks, k), span_right(toks, k)
            if a is None or b is None:
                continue
            lo, hi = toks[a][2], toks[b][2] + len(toks[b][1])
            if any(not (hi <= u or lo >= v) for u, v in used):
                continue                                   # nested in another site's operand: left as is
            used.append((lo, hi))
            # `!( A op B )`: the C value on NaN is TRUE -- a site written in the machine's own form
            p0, p1 = sig(toks, a, -1), sig(toks, b, 1)
            neg = (0 <= p0 and p1 < len(toks) and toks[p0][1] == '(' and toks[p1][1] == ')' and
                   sig(toks, p0, -1) >= 0 and toks[sig(toks, p0, -1)][1] == '!')
            out.append(dict(kind='cmp', op=s, lo=lo, hi=hi, A=src[lo:pos].strip(), neg=neg,
                            B=src[pos + len(s):hi].strip(), line=src.count('\n', 0, pos) + 1))
        elif kind == 'id' and s in ('fminf', 'fmaxf', 'fmin', 'fmax'):
            q = sig(toks, k, 1)
            if q < len(toks) and toks[q][1] == '(':
                depth, comma, end = 0, None, None
                for r in range(q, len(toks)):
                    t = toks[r][1]
                    if toks[r][0] != 'op':
                        continue
                    if t in ('(', '['):
                        depth += 1
                    elif t in (')', ']'):
                        depth -= 1
                        if depth == 0:
                            end = r
                            break
                    elif t == ',' and depth == 1:
                        comma = r
                if comma is None or end is None:
                    continue
                lo, hi = pos, toks[end][2] + 1
                if any(not (hi <= u or lo >= v) for u, v in used):
                    continue
                out.append(dict(kind=s, lo=lo, hi=hi, open=toks[q][2] + 1, line=src.count('\n', 0, pos) + 1,
                                A=src[toks[q][2] + 1:toks[comma][2]].strip(), B=src[toks[comma][2] + 1:toks[end][2]].strip()))
    return out, body0


RUNTIME = r'''
#define NANSITE_N %d
#define NANSITE_K %d
double nansite_a[NANSITE_N][NANSITE_K], nansite_b[NANSITE_N][NANSITE_K];
int nansite_n[NANSITE_N];
int nansite_voice;
static void nansite_log(int id, double a, double b)
{
    if (nansite_voice == 0) { int k = nansite_n[id]++; if (k < NANSITE_K) { nansite_a[id][k] = a; nansite_b[id][k] = b; } }
}
#define NANSITE_CMP(id, OP, A, B) ({ __typeof__(A) nsa_ = (A); __typeof__(B) nsb_ = (B); \
    nansite_log(id, (double)nsa_, (double)nsb_); nsa_ OP nsb_; })
#define NANSITE_FMINF(id, A, B) ({ float nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fminf(nsa_, nsb_); })
#define NANSITE_FMAXF(id, A, B) ({ float nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmaxf(nsa_, nsb_); })
#define NANSITE_FMIN(id, A, B) ({ double nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmin(nsa_, nsb_); })
#define NANSITE_FMAX(id, A, B) ({ double nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmax(nsa_, nsb_); })
'''


CELL = re.compile(r'^\(?\s*(?:\*\s*\(\s*(?:float|double|int|unsigned int|_DWORD|__int64)\s*\*\s*\)\s*\(\s*(?:st|a1)\s*\+\s*(\d+)'
                  r'(?:\s*\+\s*16128\s*\*\s*\(\s*v\s*\))?\s*\)|J[FI]\(\s*a1\s*,\s*(\d+)\s*\))\s*\)?$')


def cell_of(text):
    """the state offset an operand reads when the operand is exactly one cell (voice 0's offset), else None"""
    m = CELL.match(text.strip())
    return int(m.group(1) or m.group(2)) if m else None


def instrument(src, sites, body0, voice_var):
    """the C file with every site wrapped in the logger (types and results unchanged)"""
    out, cur = [], 0
    for i, st in sorted(enumerate(sites), key=lambda x: x[1]['lo']):
        out.append(src[cur:st['lo']])
        if st['kind'] == 'cmp':
            out.append('NANSITE_CMP(%d, %s, %s, %s)' % (i, st['op'], st['A'], st['B']))
        else:
            out.append('NANSITE_%s(%d, ' % (st['kind'].upper(), i))
            cur = st['open']
            continue
        cur = st['hi']
    out.append(src[cur:])
    body = ''.join(out)
    # the voice filter: the function's first statement records its voice (the master logs as voice 0)
    m = re.search(r'\{', body[body0:])
    at = body0 + m.start() + 1
    body = body[:at] + ' nansite_voice = %s;' % (voice_var or '0') + body[at:]
    # the runtime after the last #include
    inc = list(re.finditer(r'^[ \t]*#[ \t]*include[^\n]*\n', body, re.M))
    at = inc[-1].end() if inc else 0
    return body[:at] + RUNTIME % (len(sites), K) + body[at:]


# ------------------------------------------------------------------ the machine side
def descend(img, rva, cs):
    """the function's instructions by recursive descent from its entry (calls not followed)"""
    seen, work, ins = set(), [rva], {}
    while work:
        a = work.pop()
        while a not in seen:
            seen.add(a)
            x = next(cs.disasm(img[a:a + 16], a), None)
            if x is None:
                break
            ins[a] = x
            m = x.mnemonic
            if m == 'ret' or m.startswith('int3'):
                break
            if m == 'jmp':
                if x.operands and x.operands[0].type == 2:        # immediate: a jump inside the function
                    t = x.operands[0].imm
                    if abs(t - rva) < 0x40000:
                        work.append(t)
                break
            if m.startswith('j') and x.operands and x.operands[0].type == 2:
                work.append(x.operands[0].imm)
            a = x.address + x.size
    return ins


def oracle(port, func, scn, frames, release):
    import capstone
    import pefile
    from capstone import x86 as cx
    from unicorn import UC_HOOK_CODE
    from unicorn import x86_const as U
    t = TARGETS[(port, func)]
    pe = pefile.PE(os.path.join(REPO, t['vst3']))
    img = pe.get_memory_mapped_image()
    cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    cs.detail = True
    ins = descend(img, t['rva'], cs)
    sites = {a: x for a, x in ins.items() if x.mnemonic in CMP + MINMAX + ('cmp',) or
             (x.mnemonic == 'test' and len(x.operands) == 2 and x.operands[0].type == x.operands[1].type == 1 and
              x.operands[0].reg == x.operands[1].reg)}      # `test r, r`: an integer compare with 0
    kind, _, arg = scn.partition(':')
    if port == 'juno':
        import e2e_emu as E, real_recall as R, recall_render_ab as RA
        e = RA.prepare_recall(int(arg), E.bank_bytes(), R.leaf_table(), E, R, RA.SR)
        e.note_on(60, 105)
        IB, uc = E.IB, e.uc
    else:
        import jx_emu as J
        if kind == 'v':                           # a variant: records no factory patch holds (the bisect's --modes)
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_records
            e = J.JX().boot(44100.0, snap=False, product=True)
            e.host_records(jx_records.variant_records(arg))
        else:
            e = J.JX().boot(44100.0, snap=False, product=True, patch=int(arg))
        IB, uc = J.IB, e.uc
    log = {a: [] for a in sites}
    cur = {'armed': False}

    def regval(r):
        name = cs.reg_name(r)
        return uc.reg_read(getattr(U, 'UC_X86_REG_' + name.upper()))

    def opval(x, op, width):
        if op.type == cx.X86_OP_REG:
            v = regval(op.reg)
            return v & ((1 << (8 * width)) - 1)
        m = op.mem
        addr = m.disp
        if m.base:
            addr += (x.address + x.size + IB) if cs.reg_name(m.base) == 'rip' else regval(m.base)
        if m.index:
            addr += regval(m.index) * m.scale
        return int.from_bytes(uc.mem_read(addr & 0xFFFFFFFFFFFFFFFF, width), 'little')

    def tod(bits, width):
        return struct.unpack('<f', struct.pack('<I', bits))[0] if width == 4 else \
            struct.unpack('<d', struct.pack('<Q', bits))[0]

    def hook(u, addr, size, user):
        a = addr - IB
        x = sites.get(a)
        if x is None or not cur['armed'] or len(log[a]) >= K:
            return
        if x.mnemonic in ('cmp', 'test'):         # an integer compare: signed values of the operand size
            vals = []
            for op in (x.operands if x.mnemonic == 'cmp' else x.operands[:1]):
                w = op.size
                v = op.imm if op.type == cx.X86_OP_IMM else opval(x, op, w)
                v &= (1 << (8 * w)) - 1
                vals.append(float(v - (1 << (8 * w)) if v >> (8 * w - 1) else v))
            log[a].append(tuple(vals) if x.mnemonic == 'cmp' else (vals[0], 0.0))
            return
        width = 8 if x.mnemonic.endswith('sd') else 4
        ops = x.operands[-2:]                     # vminss d, a, b: the last two are the operands
        log[a].append((tod(opval(x, ops[0], width), width), tod(opval(x, ops[1], width), width)))

    # the hooks go in BEFORE any render: Unicorn keeps a translated block without a hook added later (2026-10-11:
    # the JX warm-up translated the voice code first and the hooks saw 1 execution in 306 sites). The function is
    # voice 0's own copy (each voice has its copy: the JUNO's, the JX's wrapper jump table at rva 0x3771B4).
    for a in sites:
        uc.hook_add(UC_HOOK_CODE, hook, begin=IB + a, end=IB + a)
    if port == 'jx':
        for _ in range(WARM):                     # past the voice wrapper's start-up countdown (+0xAAC308, per block)
            e.render(256, 256)
        e.note_on(60, 105)
    cur['armed'] = True
    e.render(frames)
    if release:                                   # the key up: the release paths run too
        e.note_off(60)
        e.render(release)
    jumps = {}
    for a, x in sites.items():                    # the flags' consumers up to the next flag writer
        seq, b = [], a + x.size
        for _ in range(12):
            y = ins.get(b)
            if y is None:
                break
            if y.mnemonic.startswith(('j', 'set', 'cmov')) and y.mnemonic != 'jmp':
                seq.append(y.mnemonic)
            if y.mnemonic in CMP or y.mnemonic in ('cmp', 'test', 'sub', 'add', 'and', 'or', 'xor', 'dec', 'inc'):
                break
            b = y.address + y.size
        jumps[a] = seq
    def disps(x):
        """per operand: the displacement of a memory operand on a base register (a state cell), else None"""
        out = []
        for op in (x.operands if x.mnemonic in ('cmp', 'test') else x.operands[-2:]):
            if op.type == cx.X86_OP_MEM and op.mem.base and cs.reg_name(op.mem.base) not in ('rip', 'rsp', 'rbp') \
                    and not op.mem.index:
                out.append(op.mem.disp)
            else:
                out.append(None)
        return out
    return {'sites': {'%x' % a: dict(m=x.mnemonic, ops=x.op_str, vals=log[a], jumps=jumps[a], mem=disps(x))
                      for a, x in sites.items()}, 'ninsn': len(ins)}


def build_port(port, func, cfile_text, so_dir):
    """the port built with the instrumented C file in place of the original"""
    t = TARGETS[(port, func)]
    path = os.path.join(so_dir, os.path.basename(t['c']))
    open(path, 'w').write(cfile_text)
    inc = ['-I', os.path.join(REPO, os.path.dirname(t['c']))]
    if port == 'juno':
        units = [f for f in sorted(glob.glob(os.path.join(REPO, 'src', '*.c'))) if os.path.basename(f) !=
                 os.path.basename(t['c'])] + [os.path.join(REPO, 'gui', 'juno_bridge.c'),
                                              os.path.join(REPO, 'gui', 'juno_pm.c')]
        inc += ['-I', os.path.join(REPO, 'src'), '-I', os.path.join(REPO, 'gui')]
    else:
        sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
        import jx_master_bisect as B
        units = [os.path.join(REPO, s) for s in B.SRCS if os.path.basename(s) != os.path.basename(t['c'])]
        inc += ['-I', os.path.join(REPO, 'jx3p', 'src'), '-I', os.path.join(REPO, 'jx3p', 'gui')]
    so = os.path.join(so_dir, 'libport.so')
    r = subprocess.run(['cc', '-std=gnu99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                        '-w'] + inc + ['-o', so, path] + units + ['-lm'], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('REFUSE: the instrumented port did not build:\n' + r.stderr[-3000:])
    return ctypes.CDLL(so)


def scene(lib, port, scn, frames, release, nsites):
    """one scene on the port: the patch, the note, FRAMES frames; the sites' values (counters reset at the note)"""
    if port == 'juno':
        import truth
        bank = open(truth.BANK, 'rb').read()      # the factory bank (e2e_emu.bank_bytes reads the same file)
        lib.juno_gui_create.restype = ctypes.c_void_p
        lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
        lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
        lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
        lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
        lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
        lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
        lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
        lib.juno_set_fp_oracle_mode(1)            # the oracle's mode: DAZ on, FTZ off (playbook 120)
        rate = float(os.environ.get('JUNO_RENDER_SR', '48000'))
        ctx = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), int(scn.partition(':')[2]))
        ctypes.memset(ctypes.addressof(ctypes.c_int.in_dll(lib, 'nansite_n')), 0, 4 * nsites)   # the recall's runs
        lib.juno_gui_note_on(ctx, 60, 105)
        buf = (ctypes.c_float * (2 * max(frames, release)))()
        lib.juno_gui_render(ctx, buf, frames)
        if release:
            lib.juno_gui_note_off(ctx, 60)
            lib.juno_gui_render(ctx, buf, release)
        lib.juno_gui_destroy(ctx)
    else:
        lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
        import jx_guest
        if not lib.jx3p_init(jx_guest.path(44).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             None):
            raise SystemExit('jx3p_init failed')
        kind, _, arg = scn.partition(':')
        if kind == 'v':
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_records
            pr = jx_records.pairs(jx_records.variant_records(arg))
            lib.jx3p_records((ctypes.c_uint32 * (2 * len(pr)))(*[x for kv in pr for x in kv]), len(pr))
        else:
            lib.jx3p_recall(int(arg))
        lib.jx3p_host_stage(0)
        Lb = (ctypes.c_float * max(frames, release, 256))()
        Rb = (ctypes.c_float * max(frames, release, 256))()
        for _ in range(WARM):
            lib.jx3p_render(Lb, Rb, 256)
        ctypes.memset(ctypes.addressof(ctypes.c_int.in_dll(lib, 'nansite_n')), 0, 4 * nsites)
        lib.jx3p_note_on(60, 105)
        lib.jx3p_render(Lb, Rb, frames)
        if release:
            lib.jx3p_note_off(60)
            lib.jx3p_render(Lb, Rb, release)
    na = (ctypes.c_double * (nsites * K)).in_dll(lib, 'nansite_a')
    nb = (ctypes.c_double * (nsites * K)).in_dll(lib, 'nansite_b')
    nn = (ctypes.c_int * nsites).in_dll(lib, 'nansite_n')
    return [[(na[i * K + k], nb[i * K + k]) for k in range(min(K, nn[i]))] for i in range(nsites)]


def key(vals):
    return tuple((struct.pack('<d', x).hex(), struct.pack('<d', y).hex()) for x, y in vals)


def kind_of(m):
    return 'icmp' if m in ('cmp', 'test') else 'fcmp' if m in CMP else 'mm'


def literal(t):
    return re.fullmatch(r'[-+]?\(?\s*[-+]?(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?[fFlL]?\s*\)?', t) is not None


def grade(sites, vals, asm, port):
    """one scene's verdict per site: ('right'|'wrong'|'int'|'exact', addr, swapped) or ('review', why, cands) or
    ('unmatched',) or None (not run)"""
    def cells_ok(i, v, swapped):
        """a C operand that is one cell and an instruction operand read from memory must name the same cell"""
        ca, cb = cell_of(sites[i].get('A', '')), cell_of(sites[i].get('B', ''))
        ma, mb = (v.get('mem') or [None, None])[:2] if len(v.get('mem') or []) >= 2 else (None, None)
        if swapped:
            ma, mb = mb, ma
        return all(c is None or m is None or c == m for c, m in ((ca, ma), (cb, mb)))

    def cands(i):
        out = []
        for ad, v in asm.items():
            n = min(len(v['vals']), len(vals[i]))
            if not n:
                continue
            if key(v['vals'][:n]) == key(vals[i][:n]) and cells_ok(i, v, False):
                out.append((ad, False))
            elif kind_of(v['m']) != 'mm' or sites[i]['kind'] != 'cmp':
                if key(v['vals'][:n]) == key([(y, x) for x, y in vals[i][:n]]) and cells_ok(i, v, True):
                    out.append((ad, True))
        return out
    cand = [cands(i) if vals[i] else [] for i in range(len(sites))]
    # a tie (one value pair seen at several instructions) is broken by program order: the instruction must lie
    # between the instructions of the nearest uniquely matched sites before and after it
    uniq = [(sites[i]['lo'], c[0][0]) for i, c in enumerate(cand) if len({ad for ad, _ in c}) == 1]
    for i, c in enumerate(cand):
        if len({ad for ad, _ in c}) > 1:
            before = [ad for lo, ad in uniq if lo < sites[i]['lo']]
            after = [ad for lo, ad in uniq if lo > sites[i]['lo']]
            lo_ad, hi_ad = (before[-1] if before else 0), (after[0] if after else 1 << 40)
            keep = [(ad, sw) for ad, sw in c if lo_ad < ad < hi_ad]
            if keep:
                cand[i] = keep
    out = []
    for i, s in enumerate(sites):
        c = cand[i]
        if not vals[i]:
            out.append(None)
            continue
        if not c:
            out.append(('unmatched',))
            continue
        kinds = {kind_of(asm[ad]['m']) for ad, _ in c}
        orders = {sw for _, sw in c}
        if kinds == {'icmp'} and s['kind'] == 'cmp':
            out.append(('int', c[0][0], False))
            continue
        if len(kinds) > 1 or len(orders) > 1 or len({ad for ad, _ in c}) > 1 and kinds != {'fcmp'}:
            out.append(('review', 'ambiguous', c))
            continue
        ad, sw = c[0]
        m = asm[ad]['m']
        if s['kind'] == 'cmp' and kind_of(m) == 'fcmp':
            if all(x == y for x, y in vals[i]):
                # equal values cannot give the order; a cell read from memory can: the C operand that is cell X
                # stands where the instruction reads X
                mem = asm[ad].get('mem') or [None, None]
                ca, cb = cell_of(s['A']), cell_of(s['B'])
                order = None
                if ca is not None and ca in mem[:2]:
                    order = mem.index(ca) == 1
                elif cb is not None and cb in mem[:2]:
                    order = mem.index(cb) == 0
                if order is None or len({a_ for a_, _ in c}) > 1:
                    out.append(('review', 'operands equal in every execution: the order cannot be told', c))
                    continue
                sw = order
            # the machine reads its predicate TRUE on NaN for < <= (operands in its order); C: false, or true under !( )
            mach = (s['op'] in ('<', '<=')) if not sw else (s['op'] in ('>', '>='))
            if s['neg']:                              # !(A op B) stands for the complement relation's predicate
                mach = not mach
                out.append(('right' if mach else 'wrong', ad, sw))
            else:
                out.append(('wrong' if mach else 'right', ad, sw))
        elif s['kind'] != 'cmp' and kind_of(m) == 'mm':
            if ('min' if 'min' in m else 'max') not in s['kind']:
                out.append(('review', 'a %s call matched a %s instruction' % (s['kind'], m), c))
                continue
            second = s['A'] if sw else s['B']
            out.append(('exact' if literal(second) else 'wrong', ad, sw))
        else:
            out.append(('review', 'a %s site matched a %s instruction' % (s['kind'], m), c))
    return out


def fix_of(s, src, port, ad, sw, m):
    if s['kind'] == 'cmp' and s['neg']:
        raise SystemExit('REFUSE: line %d is written !( ) and still wrong -- fix it by hand' % s['line'])
    if s['kind'] == 'cmp':
        neg = {'<': '>=', '<=': '>', '>': '<=', '>=': '<'}[s['op']]
        new = '!(%s %s %s)' % (s['A'], neg, s['B'])
    else:
        mm = 'min' if 'min' in m else 'max'
        first, second = (s['B'], s['A']) if sw else (s['A'], s['B'])
        new = '%s_%s%s(%s, %s)' % (port, mm, 'sd' if m.endswith('sd') else 'ss', first, second)
    return dict(lo=s['lo'], hi=s['hi'], line=s['line'], old=src[s['lo']:s['hi']], new=new, rva='%x' % ad, insn=m,
                swapped=sw)


def main():
    a = sys.argv[1:]
    opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d
    if a[:1] == ['--oracle']:
        json.dump(oracle(a[1], a[2], a[3], int(a[4]), int(a[5])), sys.stdout)
        return 0
    if '--apply' in a:
        fx = json.load(open(opt('--apply')))
        path = os.path.join(REPO, fx['file'])
        src = open(path).read()
        for s in sorted(fx['fixes'], key=lambda s: -s['lo']):
            if src[s['lo']:s['hi']] != s['old']:
                raise SystemExit('REFUSE: the text at line %d changed since the fixes were made' % s['line'])
            src = src[:s['lo']] + s['new'] + src[s['hi']:]
        open(path, 'w').write(src)
        print('nan_sites --apply: %d sites rewritten in %s' % (len(fx['fixes']), fx['file']))
        return 0
    port, func = opt('--port-of', 'juno'), opt('--func', 'voice')
    frames = int(opt('--frames', '64'))
    spec = opt('--patches', opt('--patch', '5'))
    release = int(opt('--release', '0'))
    scenes = []
    for part in spec.split(','):
        if not part:
            continue
        lo, _, hi = part.partition('-')
        scenes += ['p:%d' % k for k in range(int(lo), int(hi or lo) + 1)]
    if opt('--variants'):                         # JX: the bisect's variant records (modes | fx | SPEC;SPEC)
        sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
        import jx_master_bisect as B
        v = opt('--variants')
        specs = B.mode_variants() if v == 'modes' else B.fx_variants() if v == 'fx' else v.split(';')
        scenes += ['v:' + x for x in specs]
    t = TARGETS[(port, func)]
    src = open(os.path.join(REPO, t['c'])).read()
    if '--tooth' in a:
        # THE TOOTH: every site written in the machine's form, `!(A op B)`, back to the decompiler's `A cop B` (the
        # defect class itself, planted in a copy of the text): each must be graded WRONG again
        n0 = len(re.findall(r'!\(', src))
        plines = set()

        def plant(m):
            plines.add(src.count('\n', 0, m.start()) + 1)
            return '(%s %s %s)' % (m.group(1), {'>=': '<', '>': '<=', '<=': '>', '<': '>='}[m.group(2)], m.group(3))
        src = re.sub(r'!\(([^()]*?(?:\([^()]*\)[^()]*?)*?)\s(>=|<=|>|<)\s([^()]*?(?:\([^()]*\)[^()]*?)*?)\)',
                     plant, src)
        planted = n0 - len(re.findall(r'!\(', src))
        if not planted:
            raise SystemExit('REFUSE --tooth: no site written !( ) in %s' % t['c'])
    sites, body0 = sites_of(src, t['fn'])
    tmp = tempfile.mkdtemp(prefix='nansites_')
    atexit.register(shutil.rmtree, tmp, True)
    # the port side in this process (no Unicorn here: the two-process rule); the oracle one process per scene
    lib = build_port(port, func, instrument(src, sites, body0, t['voice']), tmp)
    per = [[] for _ in sites]
    asm_m, ninsn, ran_asm = {}, 0, set()
    for pt in scenes:
        o = subprocess.run([sys.executable, __file__, '--oracle', port, func, pt, str(frames), str(release)],
                           capture_output=True, text=True)
        if o.returncode:
            raise SystemExit('oracle failed (scene %s): %s' % (pt, o.stderr[-2000:]))
        ref = json.loads(o.stdout)
        asm = {int(k, 16): v for k, v in ref['sites'].items()}
        ninsn = ref['ninsn']
        asm_m.update({ad: v['m'] for ad, v in asm.items()})
        ran_asm |= {ad for ad, v in asm.items() if v['vals']}
        vals = scene(lib, port, pt, frames, release, len(sites))
        for i, g in enumerate(grade(sites, vals, asm, port)):
            if g is not None:
                per[i].append((pt, g))
    # merge the scenes: a definite verdict wins over review / unmatched; two definite verdicts must agree
    right = ints = exact = 0
    wrong, review, unmatched, conflict, fixes = [], [], [], [], []
    for i, s in enumerate(sites):
        # one C site can be several instructions (a block the compiler duplicated): the verdict and the operand
        # order must agree, the address may differ
        defin = {(g[0], g[2]) for _, g in per[i] if g[0] in ('right', 'wrong', 'int', 'exact')}
        addrs = sorted({g[1] for _, g in per[i] if g[0] in ('right', 'wrong', 'int', 'exact')})
        if len(defin) > 1:
            conflict.append((s, sorted(defin)))
            continue
        if defin:
            (v, sw), ad = next(iter(defin)), addrs[0]
            if v == 'right':
                right += 1
            elif v == 'int':
                ints += 1
            elif v == 'exact':
                exact += 1
                if '--all-minmax' in a:                   # the denormal class too: the select of the instruction
                    fixes.append(fix_of(s, src, port, ad, sw, asm_m[ad]))
            else:
                wrong.append((s, ad, sw))
                fixes.append(fix_of(s, src, port, ad, sw, asm_m[ad]))
            continue
        rev = [(pt, g) for pt, g in per[i] if g[0] == 'review']
        if rev:
            review.append((s, rev[0]))
        elif per[i]:
            unmatched.append(s)
    ran = sum(1 for p_ in per if p_)
    print('%s %s (%s, rva 0x%x), patches %s: %d C sites, %d ran; %d instructions graded (%d ran) of %d' % (
        port, func, t['c'], t['rva'], spec, len(sites), ran, len(asm_m), len(ran_asm), ninsn))
    print('  right %d   integer %d   min/max with a constant second operand %d   WRONG on NaN %d   for review %d   '
          'unmatched %d   conflicting %d   never ran %d' % (right, ints, exact, len(wrong), len(review),
                                                            len(unmatched), len(conflict), len(sites) - ran))
    for s, ad, sw in wrong:
        print('  WRONG  line %-5d %-34s <- rva 0x%x %s%s' % (
            s['line'], ('%s %s %s' % (s['A'][-14:], s['op'], s['B'][:14])) if s['kind'] == 'cmp' else
            '%s(%s, %s)' % (s['kind'], s['A'][-10:], s['B'][:10]), ad, asm_m[ad], ' (swapped)' if sw else ''))
    for s, (pt, g) in review:
        print('  REVIEW line %-5d %s: %s (scene %s: %s)' % (s['line'], s.get('op') or s['kind'], g[1], pt, ', '.join(
            '0x%x %s%s' % (ad, asm_m[ad], ' sw' if sw else '') for ad, sw in g[2][:4])))
    for s in unmatched:
        print('  UNMATCHED line %-5d %s' % (s['line'], s.get('op') or s['kind']))
    for s, d in conflict:
        print('  CONFLICT line %-5d %s: %s' % (s['line'], s.get('op') or s['kind'], d))
    if opt('--fixes'):
        json.dump(dict(file=t['c'], fixes=fixes), open(opt('--fixes'), 'w'), indent=1)
        print('  fixes for %d sites written to %s' % (len(fixes), opt('--fixes')))
    if '--tooth' in a:
        hit = [w for w in wrong if w[0]['line'] in plines]
        print('nan_sites --tooth: %d sites planted back in the decompiler\'s form, %d of them ran: %s' % (
            planted, sum(1 for s_, p_ in zip(sites, per) if p_ and s_['line'] in plines),
            'BITES (%d graded WRONG)' % len(hit) if hit else 'DID NOT BITE'))
        return 0 if hit else 1
    return 1 if (wrong or unmatched or conflict) else 0


if __name__ == '__main__':
    sys.exit(main())
