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
    ... --all-run the REACH guard: every C site must run in some scene (a site no scene reaches is not graded), and the
                  CENSUS: every float compare / min-max instruction that ran is graded through a site (READ_INLINE
                  lists the plugin's inlined helper tests the port keeps outside the function)
    ... --tooth-census LINE:RVA:TEXT   the C site(s) on LINE taken out of the map: the census must report the
                                  instruction RVA (the one LINE grades) UNCLAIMED. TEXT, a piece of LINE's source: an
                                  edit that moves the line makes the tooth REFUSE at once, naming where TEXT went
    python3 tools/verify/nan_sites.py --check-census-teeth [--self-test]   static, for `make static`: every census
                                  tooth in the Makefile and jx3p/tools/jx_verify.sh names a line that holds a site and
                                  its TEXT (2026-10-14: a 2-line edit above moved the JX tooth's site; the full verify
                                  found it 17 hours in -- playbook 257); --self-test: each tooth moved one line down
                                  must be seen STALE
exit 0 = every executed site matched and right; 1 = a WRONG, unmatched, conflicting or unresolved (review) site, or
with --all-run a site that never ran or an instruction no site grades (listed).
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
# float tests the plugin INLINED from a helper the port keeps outside the render function (no C site the tool can map
# there): READ against the instruction, each named; the census accepts these and no others
_LFO = 'jx_lfo_step (jx_master_render.c): comiss t, 4 / 2; jb skips the step on NaN; ucomiss t, 0; jne takes alt on NaN'
READ_INLINE = {('jx', 'master'): {a: _LFO for a in (0x39AF45, 0x39AF58, 0x39AF69, 0x39B884, 0x39B894, 0x39B8A2,
                                                    0x39C1D2, 0x39C1E2, 0x39C1F0, 0x39EA97, 0x39EAAA, 0x39EAB7)}}
MINMAX = ('minss', 'maxss', 'minsd', 'maxsd', 'vminss', 'vmaxss', 'vminsd', 'vmaxsd')


# ------------------------------------------------------------------ the C side: tokens, operands, the rewrite
OPS = sorted(['<<=', '>>=', '->', '++', '--', '<<', '>>', '<=', '>=', '==', '!=', '&&', '||', '+=', '-=', '*=', '/=',
              '%=', '&=', '^=', '|=', '-', '+', '*', '/', '%', '&', '|', '^', '!', '~', '<', '>', '=', '?', ':', ';',
              ',', '.', '(', ')', '{', '}', '[', ']'], key=len, reverse=True)
TOKRE = re.compile(r'(?P<ws>\s+)|(?P<com>/\*.*?\*/|//[^\n]*)|(?P<pp>(?<![^\n])[ \t]*\#(?:\\\n|[^\n])*)'
                   r'|(?P<str>"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\')'
                   r'|(?P<num>0[xX][0-9a-fA-F]+[uUlL]*|(?:\d+\.\d*|\.\d+)(?:[eE][+-]?\d+)?[fFlL]?|\d+[eE][+-]?\d+[fFlL]?'
                   r'|\d+[uUlL]*)|(?P<id>[A-Za-z_]\w*)|(?P<op>' + '|'.join(re.escape(o) for o in OPS) + ')', re.S)
REL = ('<', '<=', '>', '>=', '==', '!=')
SELECTS = tuple('%s_%s%s' % (p, m, w) for p in ('jx', 'juno') for m in ('min', 'max') for w in ('ss', 'sd'))
EQS = tuple('%s_f%s' % (p, e) for p in ('jx', 'juno') for e in ('eq', 'ne'))   # ucomiss + je / jne, no parity test
MMNAMES = ('fminf', 'fmaxf', 'fmin', 'fmax') + SELECTS + EQS  # the selects: the instruction's own, written out
# instructions that write EFLAGS (a compare's flags end there); SSE arithmetic, moves, lea and conversions do not
FLAG_WRITERS = set(CMP) | {'cmp', 'test', 'add', 'sub', 'and', 'or', 'xor', 'inc', 'dec', 'neg', 'shl', 'shr', 'sar',
                           'sal', 'rol', 'ror', 'rcl', 'rcr', 'imul', 'mul', 'div', 'idiv', 'adc', 'sbb', 'bt', 'bts',
                           'btr', 'btc', 'bsf', 'bsr', 'popcnt', 'lzcnt', 'tzcnt', 'sahf', 'popf', 'popfq', 'ptest',
                           'xadd', 'cmpxchg', 'shld', 'shrd', 'andn', 'blsi', 'blsr', 'blsmsk', 'bzhi'}
ZF_USERS = ('je', 'jne', 'jz', 'jnz', 'sete', 'setne', 'setz', 'setnz', 'cmove', 'cmovne', 'cmovz', 'cmovnz')
CF_USERS = ('jb', 'jbe', 'ja', 'jae', 'jnb', 'jnbe', 'jna', 'jnae', 'jc', 'jnc', 'setb', 'setbe', 'seta', 'setae',
            'setnb', 'setnbe', 'setna', 'setnae', 'cmovb', 'cmovbe', 'cmova', 'cmovae', 'cmovnb', 'cmovnbe', 'cmovna',
            'cmovnae')
PARITY = ('jp', 'jnp', 'jpe', 'jpo', 'setp', 'setnp', 'setpe', 'setpo', 'cmovp', 'cmovnp', 'lahf')
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
        elif kind == 'id' and s in MMNAMES:
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
signed char nansite_real[NANSITE_N];   /* 2: an operand of real type (float / double); 1: two integers / pointers */
int nansite_voice;
static void nansite_log(int id, double a, double b)
{
    if (nansite_voice == 0) { int k = nansite_n[id]++; if (k < NANSITE_K) { nansite_a[id][k] = a; nansite_b[id][k] = b; } }
}
#define NANSITE_CMP(id, OP, A, B) ({ __typeof__(A) nsa_ = (A); __typeof__(B) nsb_ = (B); \
    nansite_real[id] = (signed char)(1 + (__builtin_classify_type(nsa_) == 8 || __builtin_classify_type(nsb_) == 8)); \
    nansite_log(id, (double)nsa_, (double)nsb_); nsa_ OP nsb_; })
#define NANSITE_FMINF(id, A, B) ({ float nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fminf(nsa_, nsb_); })
#define NANSITE_FMAXF(id, A, B) ({ float nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmaxf(nsa_, nsb_); })
#define NANSITE_FMIN(id, A, B) ({ double nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmin(nsa_, nsb_); })
#define NANSITE_FMAX(id, A, B) ({ double nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); fmax(nsa_, nsb_); })
#define NANSITE_SEL_F(id, F, A, B) ({ float nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); F(nsa_, nsb_); })
#define NANSITE_SEL_D(id, F, A, B) ({ double nsa_ = (A), nsb_ = (B); nansite_log(id, nsa_, nsb_); F(nsa_, nsb_); })
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
        elif st['kind'] in SELECTS:
            out.append('NANSITE_SEL_%s(%d, %s, ' % ('D' if st['kind'].endswith('sd') else 'F', i, st['kind']))
            cur = st['open']
            continue
        elif st['kind'] in EQS:
            out.append('NANSITE_SEL_D(%d, %s, ' % (i, st['kind']))
            cur = st['open']
            continue
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


def event_of(arg):
    """'P:N:IDX=VAL,.../N:IDX=VAL,...' -> [(N, [(record id, value)])]: with the key down, N blocks of 256, then
    factory patch P's records IDX (its patch-load list, as jx_records gives it) set to VAL; step after step. A DELAY
    or REVERB TYPE change arms the delay's clear (the fade counts down, then the buffer is wiped: JX master lines
    2318-2350); a DELAY TIME change glides the delay's read head (lines 2785-3129)"""
    sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
    import jx_records
    p, steps = arg.split(':', 1)
    recs = jx_records.records()['patches'][int(p)]
    out = []
    for step in steps.split('/'):
        n, edits = step.split(':', 1)
        rs = []
        for ed in filter(None, edits.split(',')):
            i, _, v = ed.partition('=')
            assert recs[int(i)][0] == 2, 'record %s of patch %s is no engine parameter' % (i, p)
            rs.append((recs[int(i)][1], int(v, 0) & 0xFFFFFFFF))
        out.append((int(n), rs))
    return out


def juno_variant(bank, arg):
    """JUNO-60 'P:BB=VAL,...' -> (bank, P): factory patch P with its recall bytes BB (blob offsets, the leaf table's)
    set to VAL -- the record's nibble pair, as the plugin's bank parser reads it (real_bank_parse.py: header 23,
    stride 20223, blob at +16); the plugin's and the port's recall then load the same record"""
    p, _, edits = arg.partition(':')
    b = bytearray(bank)
    base = 23 + int(p) * 20223 + 16
    for ed in filter(None, edits.split(',')):
        bb, _, v = ed.partition('=')
        bb, v = int(bb), int(v, 0)
        assert 0 <= v <= 255, 'a recall byte is 0..255'
        b[base + bb] = (v >> 4) & 0xF
        b[base + bb + 1] = v & 0xF
    return bytes(b), int(p)


JUNO_VOICE_STRIDE = 10512                 # src/juno_engine.h JUNO_VOICE_MAIN_STRIDE: voice v's cells at v * stride


def juno_scene_bank(bank, kind, arg):
    """the bank and the patch a JUNO scene recalls first: 'p:P', 'v:P:BB=VAL', 'e:P:...', 'w:P[:BB=VAL]|...'"""
    if kind == 'w':
        arg = arg.split('|')[0]
        kind = 'v' if ':' in arg else 'p'
    if kind == 'v':
        return juno_variant(bank, arg)
    return bank, int(arg.split(':')[0])


def juno_events(bank, arg):
    """JUNO-60 'P:N:BB=VAL,.../N:...' -> [(N, bank, P)]: after N blocks of 256 with the key down, a settled warm
    recall of patch P with its recall bytes BB set to VAL (the warm render gate's settled pair: the plugin's
    recall_render_ab.apply_recall, the port's juno_gui_apply_bank on the running engine)"""
    p, steps = arg.split(':', 1)
    out = []
    for step in steps.split('/'):
        n, _, edits = step.partition(':')
        wbank, wp = juno_variant(bank, '%s:%s' % (p, edits))
        out.append((int(n), wbank, wp))
    return out


def pokes_of(text):
    """'OFF=VALUE,...' -> [(state offset, 32-bit value)]: OFF decimal, VALUE a float (its bits are written)"""
    out = []
    for p in filter(None, text.split(',')):
        off, _, val = p.partition('=')
        out.append((int(off, 0), struct.unpack('<I', struct.pack('<f', float(val)))[0]))
    return out


def scene_frames(scn, frames):
    """a scene's own length: 'SCENE@N' renders N frames with the key down"""
    s, _, n = scn.partition('@')
    return s, int(n) if n else frames


def oracle(port, func, scn, frames, release):
    import capstone
    import pefile
    from capstone import x86 as cx
    from unicorn import UC_HOOK_CODE
    from unicorn import x86_const as U
    t = TARGETS[(port, func)]
    scn, frames = scene_frames(scn, frames)
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
        bank, p = juno_scene_bank(E.bank_bytes(), kind, arg)
        e = RA.prepare_recall(p, bank, R.leaf_table(), E, R, RA.SR)
        if kind == 'w':                           # cells written after the recall: a voice cell (below the voice
            for off, bits in pokes_of(arg.split('|')[1]):    # stride) in voice 0's unit, any other in all nine
                for u in ([0] if off < JUNO_VOICE_STRIDE else range(9)):
                    e.uc.mem_write(e.state[u] + off, struct.pack('<I', bits))
        e.note_on(60, 105)
        IB, uc = E.IB, e.uc
    else:
        import jx_emu as J
        rate = float(os.environ.get('NANSITES_RATE', '44100'))     # --rate: the engine's rate (44100 / 96000)
        if kind == 'v':                           # a variant: records no factory patch holds (the bisect's --modes)
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_records
            e = J.JX().boot(rate, snap=False, product=True)
            e.host_records(jx_records.variant_records(arg))
        elif kind == 'e':                         # an event: a patch, then records while the note sounds
            e = J.JX().boot(rate, snap=False, product=True, patch=int(arg.split(':')[0]))
        elif kind == 'w':                         # a variant, then master-state cells written: a state no parameter
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))   # reaches, the same on both sides
            import jx_records
            spec, pokes = arg.split('|')
            e = J.JX().boot(rate, snap=False, product=True)
            e.host_records(jx_records.variant_records(spec))
            for off, bits in pokes_of(pokes):
                e.uc.mem_write(e.state[8] + off, struct.pack('<I', bits))
        else:
            e = J.JX().boot(rate, snap=False, product=True, patch=int(arg))
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
    if os.environ.get('NANSITES_FROM_BOOT'):     # --from-boot: the warm-up's executions are logged too (ramps)
        cur['armed'] = True
    if port == 'jx':
        for _ in range(WARM):                     # past the voice wrapper's start-up countdown (+0xAAC308, per block)
            e.render(256, 256)
        e.note_on(60, 105)
    cur['armed'] = True
    if port == 'jx' and kind == 'e':              # the events: N blocks with the key down, then the records
        for nblk, recs in event_of(arg):
            e.render(256 * nblk)
            e.host_records([(2, pid, val) for pid, val in recs])
    if port == 'juno' and kind == 'e':            # N blocks with the key down, then a settled warm recall of the
        for nblk, wbank, wp in juno_events(E.bank_bytes(), arg):     # patch (its bytes edited): the recall re-arms
            e.render(256 * nblk)                  # the reverb tank's clear, so the fade counts down
            RA.apply_recall(e, wp, wbank, R.leaf_table(), E, R)
    e.render(frames)
    if release:                                   # the key up: the release paths run too
        e.note_off(60)
        e.render(release)
    jumps = {}
    for a, x in sites.items():
        # the flags' consumers on every path until an instruction writes the flags: SSE arithmetic leaves them, so the
        # compiler may put many instructions between a compare and its jump (JUNO voice rva 0x36B64E: its je is 13
        # instructions later; a 12-instruction window saw none, playbook 225); both ways of a jcc are followed
        seq, seen, work, budget = [], set(), [a + x.size], 256
        while work and budget > 0:
            b = work.pop()
            while b not in seen and budget > 0:
                seen.add(b)
                budget -= 1
                y = ins.get(b)
                if y is None:
                    break
                m = y.mnemonic
                if (m.startswith(('j', 'set', 'cmov')) and m != 'jmp') or m == 'lahf':
                    seq.append(m)
                if m in FLAG_WRITERS or m.startswith(('ret', 'call', 'int3')):
                    break
                if m == 'jmp':
                    if y.operands and y.operands[0].type == 2:
                        work.append(y.operands[0].imm)
                    break
                if m.startswith('j') and y.operands and y.operands[0].type == 2:
                    work.append(y.operands[0].imm)
                b = y.address + y.size
        jumps[a] = sorted(set(seq))
    # the constant registers: written in the function only by a constant load (xorps r, r / a load from rip-relative
    # data); Win64 keeps xmm6..xmm15 across calls, and a call-clobbered register written by a call is no constant
    writes = {}
    NOWRITE = CMP + ('cmp', 'test', 'push', 'call', 'ret', 'nop', 'jmp') + tuple(
        m for m in set(y.mnemonic for y in ins.values()) if m.startswith('j'))
    for y in ins.values():
        if y.mnemonic in NOWRITE or not y.operands or y.operands[0].type != cx.X86_OP_REG:
            continue
        r = cs.reg_name(y.operands[0].reg)
        const = (y.mnemonic in ('xorps', 'xorpd', 'pxor') and len(y.operands) == 2 and
                 y.operands[1].type == cx.X86_OP_REG and y.operands[1].reg == y.operands[0].reg) or \
            (y.mnemonic in ('movss', 'movsd', 'movaps', 'movups', 'movapd') and len(y.operands) == 2 and
             y.operands[1].type == cx.X86_OP_MEM and cs.reg_name(y.operands[1].mem.base or 0) == 'rip')
        restore = (y.mnemonic in ('movaps', 'movups', 'movdqa') and len(y.operands) == 2 and
                   y.operands[1].type == cx.X86_OP_MEM and cs.reg_name(y.operands[1].mem.base or 0) in ('rsp', 'r11', 'rbp'))
        if restore:                               # the epilogue restores a callee-saved register: not in the body
            continue
        writes.setdefault(r, set()).add('const' if const else 'var')
    const_reg = {r for r, w in writes.items() if w == {'const'} and r.startswith('xmm') and int(r[3:]) >= 6}

    # the control flow, for the definitions that reach a compare
    preds = {}
    for y in ins.values():
        nxt = []
        if y.mnemonic not in ('jmp', 'ret') and not y.mnemonic.startswith('int3'):
            nxt.append(y.address + y.size)
        if y.mnemonic.startswith('j') and y.operands and y.operands[0].type == cx.X86_OP_IMM:
            nxt.append(y.operands[0].imm)
        for t in nxt:
            preds.setdefault(t, []).append(y.address)

    def const_load(y, r):
        if y.mnemonic in ('xorps', 'xorpd', 'pxor') and len(y.operands) == 2 and \
                y.operands[1].type == cx.X86_OP_REG and cs.reg_name(y.operands[1].reg) == r:
            return True
        return y.mnemonic in ('movss', 'movsd', 'movaps', 'movups', 'movapd') and len(y.operands) == 2 and \
            y.operands[1].type == cx.X86_OP_MEM and cs.reg_name(y.operands[1].mem.base or 0) == 'rip'

    def reaching_const(at, r):
        """every definition of register r that reaches the instruction at `at` is a constant load (the walk may
        cover the whole function: the JX master's xmm12 = 0 is set 2000-2900 instructions before its compares; a cap
        of 600 left four sites unresolved and two NaN defects unseen -- lines 2334 and 3634, 2026-10-11)"""
        seen, work, found = set(), list(preds.get(at, [])), []
        while work:
            b = work.pop()
            if b in seen:
                continue
            seen.add(b)
            if len(seen) > len(ins):
                return False
            y = ins.get(b)
            if y is None:
                return False
            if y.mnemonic == 'call' and not (r.startswith('xmm') and int(r[3:]) >= 6):
                return False                      # a call clobbers the volatile registers
            if y.operands and y.operands[0].type == cx.X86_OP_REG and cs.reg_name(y.operands[0].reg) == r and \
                    y.mnemonic not in NOWRITE:
                found.append(const_load(y, r))
                continue
            work.extend(preds.get(b, []))
            if not preds.get(b):
                return False                      # the function's entry: the value came from outside
        return bool(found) and all(found)

    def consts(x):
        """per operand: a constant (rip-relative data, or a register whose reaching definitions are constant
        loads)"""
        out = []
        for op in (x.operands if x.mnemonic in ('cmp', 'test') else x.operands[-2:]):
            if op.type == cx.X86_OP_MEM:
                out.append(cs.reg_name(op.mem.base or 0) == 'rip')
            elif op.type == cx.X86_OP_REG:
                r = cs.reg_name(op.reg)
                out.append(r in const_reg or reaching_const(x.address, r))
            else:
                out.append(op.type == cx.X86_OP_IMM)
        return out

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
    return {'sites': {'%x' % a: dict(m=x.mnemonic, ops=x.op_str, vals=log[a], jumps=jumps[a], mem=disps(x),
                                     const=consts(x)) for a, x in sites.items()}, 'ninsn': len(ins)}


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
    r = subprocess.run(['cc', '-std=gnu99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans', '-fno-strict-aliasing', '-shared', '-fPIC',
                        '-w'] + inc + ['-o', so, path] + units + ['-lm'], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('REFUSE: the instrumented port did not build:\n' + r.stderr[-3000:])
    # the sites the preprocessor keeps: a site in a branch no build compiles (`#if JX_NAN_TOOTH`) is no site
    e = subprocess.run(['cc', '-std=gnu99', '-E', '-w'] + inc + [path], capture_output=True, text=True)
    if e.returncode:
        raise SystemExit('REFUSE: the instrumented file did not preprocess:\n' + e.stderr[-3000:])
    return ctypes.CDLL(so), {int(x) for x in re.findall(r'\bnansite_log\((\d+)\s*,', e.stdout)}


def scene(lib, port, scn, frames, release, nsites):
    """one scene on the port: the patch, the note, FRAMES frames; the sites' values (counters reset at the note)"""
    scn, frames = scene_frames(scn, frames)
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
        kind, _, arg = scn.partition(':')
        bank0 = bank
        bank, p = juno_scene_bank(bank, kind, arg)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), p)
        if kind == 'w':
            lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
            for off, bits in pokes_of(arg.split('|')[1]):
                lib.juno_gui_poke(ctx, off, bits)
        ctypes.memset(ctypes.addressof(ctypes.c_int.in_dll(lib, 'nansite_n')), 0, 4 * nsites)   # the recall's runs
        lib.juno_gui_note_on(ctx, 60, 105)
        buf = (ctypes.c_float * (2 * max(frames, release, 256)))()
        if kind == 'e':
            for nblk, wbank, wp in juno_events(bank0, arg):
                for _ in range(nblk):
                    lib.juno_gui_render(ctx, buf, 256)
                lib.juno_gui_apply_bank(ctx, wbank, len(wbank), wp)
        lib.juno_gui_render(ctx, buf, frames)
        if release:
            lib.juno_gui_note_off(ctx, 60)
            lib.juno_gui_render(ctx, buf, release)
        lib.juno_gui_destroy(ctx)
    else:
        lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
        import jx_guest
        rk = 96 if os.environ.get('NANSITES_RATE', '44100') == '96000' else 44
        if not lib.jx3p_init(jx_guest.path(rk).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             None):
            raise SystemExit('jx3p_init failed')
        kind, _, arg = scn.partition(':')
        if kind == 'v':
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_records
            pr = jx_records.pairs(jx_records.variant_records(arg))
            lib.jx3p_records((ctypes.c_uint32 * (2 * len(pr)))(*[x for kv in pr for x in kv]), len(pr))
        elif kind == 'e':
            lib.jx3p_recall(int(arg.split(':')[0]))
        elif kind == 'w':
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_records
            spec, pokes = arg.split('|')
            pr = jx_records.pairs(jx_records.variant_records(spec))
            lib.jx3p_records((ctypes.c_uint32 * (2 * len(pr)))(*[x for kv in pr for x in kv]), len(pr))
            lib.jx3p_mstate.restype = ctypes.c_void_p
            st = lib.jx3p_mstate()
            for off, bits in pokes_of(pokes):
                ctypes.memmove(st + off, struct.pack('<I', bits), 4)
        else:
            lib.jx3p_recall(int(arg))
        lib.jx3p_host_stage(0)
        Lb = (ctypes.c_float * max(frames, release, 256))()
        Rb = (ctypes.c_float * max(frames, release, 256))()
        if os.environ.get('NANSITES_FROM_BOOT'):
            ctypes.memset(ctypes.addressof(ctypes.c_int.in_dll(lib, 'nansite_n')), 0, 4 * nsites)
        for _ in range(WARM):
            lib.jx3p_render(Lb, Rb, 256)
        if not os.environ.get('NANSITES_FROM_BOOT'):
            ctypes.memset(ctypes.addressof(ctypes.c_int.in_dll(lib, 'nansite_n')), 0, 4 * nsites)
        lib.jx3p_note_on(60, 105)
        if kind == 'e':
            for nblk, recs in event_of(arg):
                for _ in range(nblk):
                    lib.jx3p_render(Lb, Rb, 256)
                lib.jx3p_records((ctypes.c_uint32 * (2 * len(recs)))(*[x for kv in recs for x in kv]), len(recs))
        lib.jx3p_render(Lb, Rb, frames)
        if release:
            lib.jx3p_note_off(60)
            lib.jx3p_render(Lb, Rb, release)
    na = (ctypes.c_double * (nsites * K)).in_dll(lib, 'nansite_a')
    nb = (ctypes.c_double * (nsites * K)).in_dll(lib, 'nansite_b')
    nn = (ctypes.c_int * nsites).in_dll(lib, 'nansite_n')
    real = (ctypes.c_byte * nsites).in_dll(lib, 'nansite_real')
    return [[(na[i * K + k], nb[i * K + k]) for k in range(min(K, nn[i]))] for i in range(nsites)], list(real)


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

    def cell_hit(i, v, swapped):
        """positive evidence: a C operand that is one cell is read from that cell by the instruction"""
        ca, cb = cell_of(sites[i].get('A', '')), cell_of(sites[i].get('B', ''))
        ma, mb = (v.get('mem') or [None, None])[:2] if len(v.get('mem') or []) >= 2 else (None, None)
        if swapped:
            ma, mb = mb, ma
        return any(c is not None and c == m for c, m in ((ca, ma), (cb, mb))) and cells_ok(i, v, swapped)

    def kind_ok(i, m):
        """a min / max site only as its own kind; a compare that saw a non-integer is no integer compare"""
        sk = sites[i]['kind']
        if sk in EQS:
            return kind_of(m) == 'fcmp'
        if sk != 'cmp':
            return kind_of(m) == 'mm' and (('min' in m) == ('min' in sk))
        if kind_of(m) == 'icmp':
            flit = lambda t: literal(t) and re.search(r'[.eEfF]', t) is not None
            if flit(sites[i]['A']) or flit(sites[i]['B']):
                return False                      # a float literal: the compare is a float compare
            return all(float(x).is_integer() and float(y).is_integer() for x, y in vals[i])
        return True

    def cands(i):
        out = []
        for ad, v in asm.items():
            n = min(len(v['vals']), len(vals[i]))
            if not n or not kind_ok(i, v['m']):
                continue
            if key(v['vals'][:n]) == key(vals[i][:n]) and cells_ok(i, v, False):
                out.append((ad, False))
            elif kind_of(v['m']) != 'mm' or sites[i]['kind'] != 'cmp':
                if key(v['vals'][:n]) == key([(y, x) for x, y in vals[i][:n]]) and cells_ok(i, v, True):
                    out.append((ad, True))
        return out
    cand = [cands(i) if vals[i] else [] for i in range(len(sites))]
    grade.raw = [list(c) for c in cand]           # the census's hint: the sites whose values an instruction matched
    # an equality's flags are read by je / jne (ZF), a relation's by jb / ja / jae / jbe (CF): among several candidates
    # an instruction whose flags only the other kind reads is not the site (JUNO voice line 723: an equality whose
    # values three relational compares also saw)
    for i, c in enumerate(cand):
        if len(c) < 2:
            continue
        s = sites[i]
        eq = (s['kind'] == 'cmp' and s.get('op') in ('==', '!=')) or s['kind'] in EQS
        rel = s['kind'] == 'cmp' and s.get('op') in ('<', '<=', '>', '>=')
        if eq or rel:
            want = ZF_USERS if eq else CF_USERS
            keep = [(ad, sw) for ad, sw in c if any(j in want for j in (asm[ad].get('jumps') or []))]
            if keep:
                cand[i] = keep
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
        # still of two kinds or two operand orders: an instruction that READS the C operand's cell from memory
        # is the site; one that only matched values in registers is not (JX voice lines 1422 / 1501: comiss
        # [rdi + 0x660] -- cell 1632 -- against a minss of the same values)
        if len({(kind_of(asm[ad]['m']), sw) for ad, sw in cand[i]}) > 1:
            hit = [(ad, sw) for ad, sw in cand[i] if cell_hit(i, asm[ad], sw)]
            if hit:
                cand[i] = hit
    grade.cands = cand                            # the census: a definite verdict holds for every candidate
    out = []
    for i, s in enumerate(sites):
        c = cand[i]
        if not vals[i]:
            out.append(None)
            continue
        if s['kind'] == 'cmp' and s.get('real') == 1:
            # both C operands are integers (or pointers): no NaN reaches the compare, whatever float instruction its
            # values happen to match (JX master line 2619, `*v490 == 1`, matched a ucomiss on (1, 1)): its C types decide
            out.append(('int-type', 0, False))
            continue
        if not c:
            if s['kind'] == 'cmp' and s.get('real') == 1:
                # both C operands are integers (or pointers): no NaN reaches the compare, whatever instruction the
                # compiler made of it (JX master line 2336, `i < 256` of a loop the compiler rotated)
                out.append(('int-type', 0, False))
                continue
            # one instruction's flags can feed two C tests, the inner one reached only when the outer holds
            # (`if (v >= 0) { if (v > 0) ... }`): the inner site's values are a SUBSEQUENCE of that instruction's
            sub = []
            for ad, v in asm.items():
                if kind_of(v['m']) != 'fcmp':
                    continue
                for swapped in (False, True):
                    want = key([(y, x) for x, y in vals[i]] if swapped else vals[i])
                    have = key(v['vals'])
                    j = 0
                    for h in have:
                        if j < len(want) and h == want[j]:
                            j += 1
                    # every inner value found in order -- or the instruction's capped log ran out first (its later
                    # executions were not logged) after at least 3 values were found
                    if (j == len(want) or (len(have) == K and j >= 3 and have.index(want[0]) >= 0)) and \
                            want[0] in have and cells_ok(i, v, swapped):
                        sub.append((ad, swapped))
            if not sub and s['kind'] == 'cmp':
                # the textual anchor: the nearest earlier compare on the SAME two operands, matched to one
                # instruction, sets the flags this inner test reads (`if (v >= 0) { if (v > 0) ... }`)
                norm = lambda t: re.sub(r'\s+', '', t)
                for j in range(i - 1, max(-1, i - 6), -1):
                    o = sites[j]
                    # the verdict needs the operand ORDER only: several instructions with one order will do
                    if o['kind'] != 'cmp' or not cand[j] or len({sw for _, sw in cand[j]}) != 1 or \
                            {kind_of(asm[ad]['m']) for ad, _ in cand[j]} != {'fcmp'}:
                        continue
                    if (norm(o['A']), norm(o['B'])) == (norm(s['A']), norm(s['B'])):
                        sub = [(cand[j][0][0], cand[j][0][1])]
                    elif (norm(o['A']), norm(o['B'])) == (norm(s['B']), norm(s['A'])):
                        sub = [(cand[j][0][0], not cand[j][0][1])]
                    if sub:
                        break
            if os.environ.get('NANSITES_DEBUG') and not sub:
                for j in range(i - 1, max(-1, i - 4), -1):
                    print('  DEBUG line %d <- line %d %s [%s %s %s] cands %s' % (
                        s['line'], sites[j]['line'], sites[j]['kind'], sites[j].get('A', '')[-20:], sites[j].get('op', ''),
                        sites[j].get('B', '')[:20], [(hex(ad), sw) for ad, sw in cand[j]][:4]), file=sys.stderr)
            if len({sw for _, sw in sub}) == 1 and s['kind'] == 'cmp':
                ad, sw = sub[0]
                mach = (s['op'] in ('<', '<=')) if not sw else (s['op'] in ('>', '>='))
                if s['neg']:
                    mach = not mach
                    out.append(('nested-right' if mach else 'nested-wrong', ad, sw))
                else:
                    out.append(('nested-wrong' if mach else 'nested-right', ad, sw))
                continue
            out.append(('unmatched',))
            continue
        kinds = {kind_of(asm[ad]['m']) for ad, _ in c}
        orders = {sw for _, sw in c}
        if kinds == {'icmp'} and s['kind'] == 'cmp':
            out.append(('int', c[0][0], False))
            continue
        # several instructions of one kind and one operand order give one verdict; min / max must agree in
        # min-or-max and width too
        mms = {(('min' in asm[ad]['m']), asm[ad]['m'].endswith('sd')) for ad, _ in c} if kinds == {'mm'} else set()
        if len(kinds) > 1 or len(orders) > 1 or len(mms) > 1:
            out.append(('review', 'ambiguous', c))
            continue
        ad, sw = c[0]
        m = asm[ad]['m']
        ieee = any(j in PARITY for a_, _ in c for j in (asm[a_].get('jumps') or []))
        if s['kind'] == 'cmp' and kind_of(m) == 'fcmp' and s['op'] in ('==', '!='):
            # ucomiss sets ZF = PF = CF = 1 on an unordered pair: a je / jne with no parity test reads a NaN as
            # EQUAL (MSVC's fast float model); C's == reads it unequal. With a parity test (jp, or lahf; test ah,
            # 44h) the machine's equality is IEEE's, as C's (playbook 222)
            out.append(('wrong' if not ieee else 'right', ad, False))    # !( == ) / !( != ) alike
            continue
        if s['kind'] in EQS:
            out.append(('right' if not ieee else 'wrong', ad, False) if kind_of(m) == 'fcmp' else
                       ('review', 'an equality helper matched a %s instruction' % m, c))
            continue
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
                if order is None and literal(s['A']) != literal(s['B']):
                    side_c = 0 if literal(s['A']) else 1
                    sides = set()
                    for a_, _ in c:
                        k_ = asm[a_].get('const') or [False, False]
                        sides.add(k_.index(True) if k_.count(True) == 1 else None)
                    if len(sides) == 1 and None not in sides:
                        order = sides.pop() != side_c
                        c = [(a_, order) for a_, _ in c]
                if order is None:
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
        elif s['kind'] in SELECTS and kind_of(m) == 'mm':
            ok = (('min' in m) == ('_min' in s['kind'])) and (m.endswith('sd') == s['kind'].endswith('sd')) and not sw
            out.append(('right' if ok else 'wrong', ad, sw))
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
    if s['kind'] in SELECTS:
        raise SystemExit('REFUSE: line %d: the select %s does not match its instruction %s%s -- fix it by hand' % (
            s['line'], s['kind'], m, ' (operands swapped)' if sw else ''))
    if s['kind'] == 'cmp' and s['neg']:
        raise SystemExit('REFUSE: line %d is written !( ) and still wrong -- fix it by hand' % s['line'])
    if s['kind'] == 'cmp' and s['op'] in ('==', '!='):
        new = '%s_f%s(%s, %s)' % (port, 'eq' if s['op'] == '==' else 'ne', s['A'], s['B'])
        return dict(lo=s['lo'], hi=s['hi'], line=s['line'], old=src[s['lo']:s['hi']], new=new, rva='%x' % ad, insn=m,
                    swapped=False)
    if s['kind'] in EQS:
        new = '%s %s %s' % (s['A'], '==' if s['kind'].endswith('eq') else '!=', s['B'])
        return dict(lo=s['lo'], hi=s['hi'], line=s['line'], old=src[s['lo']:s['hi']], new=new, rva='%x' % ad, insn=m,
                    swapped=False)
    if s['kind'] == 'cmp':
        neg = {'<': '>=', '<=': '>', '>': '<=', '>=': '<'}[s['op']]
        new = '!(%s %s %s)' % (s['A'], neg, s['B'])
    else:
        mm = 'min' if 'min' in m else 'max'
        first, second = (s['B'], s['A']) if sw else (s['A'], s['B'])
        new = '%s_%s%s(%s, %s)' % (port, mm, 'sd' if m.endswith('sd') else 'ss', first, second)
    return dict(lo=s['lo'], hi=s['hi'], line=s['line'], old=src[s['lo']:s['hi']], new=new, rva='%x' % ad, insn=m,
                swapped=sw)


def census_spec(spec):
    """LINE:RVA[:TEXT] -> (line, rva, text or None)"""
    f = spec.split(':', 2)
    return int(f[0]), int(f[1], 16), (f[2] if len(f) > 2 else None)


def census_stale(src, fn, spec, need_text=False):
    """why the census tooth `spec` no longer names its site in src (None: it does)"""
    line, rva, text = census_spec(spec)
    sites, _ = sites_of(src, fn)
    lines = src.split('\n')
    if text is None:
        return 'no TEXT named (LINE:RVA:TEXT)' if need_text else (
            None if any(s['line'] == line for s in sites) else 'no site on line %d' % line)
    if not any(s['line'] == line for s in sites) or text not in lines[line - 1]:
        now = sorted({s['line'] for s in sites if text in lines[s['line'] - 1]})
        return 'line %d %s; "%s" is on the site line(s) %s' % (
            line, 'holds no site' if not any(s['line'] == line for s in sites) else 'does not hold the text',
            text, ', '.join(map(str, now)) or 'none')
    return None


def census_teeth():
    """every census tooth the suites run: (where, port, func, spec)"""
    out = []
    for path in ('Makefile', 'jx3p/tools/jx_verify.sh'):
        for n, ln in enumerate(open(os.path.join(REPO, path)), 1):
            if 'nan_sites.py' not in ln or '--tooth-census' not in ln or ln.lstrip().startswith('#'):
                continue
            port = re.search(r'--port-of\s+(\w+)', ln).group(1)
            func = re.search(r'--func\s+(\w+)', ln).group(1)
            spec = re.search(r"--tooth-census\s+(?:'([^']*)'|(\S+))", ln)
            out.append(('%s:%d' % (path, n), port, func, spec.group(1) or spec.group(2)))
    return out


def check_census_teeth(self_test):
    teeth = census_teeth()
    if not teeth:
        raise SystemExit('REFUSE: no census tooth found in the Makefile or jx_verify.sh')
    bad = 0
    for where, port, func, spec in teeth:
        t = TARGETS[(port, func)]
        src = open(os.path.join(REPO, t['c'])).read()
        if self_test:                          # the tooth moved one line down: must be seen STALE
            line, rva, text = census_spec(spec)
            moved = '%d:0x%x:%s' % (line + 1, rva, text or '')
            why = census_stale(src, t['fn'], moved, need_text=True)
            print('  self-test %-34s %s' % (where, 'STALE (seen: %s)' % why if why else 'NOT SEEN'))
            bad += why is None
        else:
            why = census_stale(src, t['fn'], spec, need_text=True)
            print('  %-34s %s %s: %s' % (where, port, func, 'STALE -- ' + why if why else 'line holds its site'))
            bad += why is not None
    if self_test:
        print('nan_sites --check-census-teeth --self-test: %s' % ('BITES' if not bad else 'DID NOT BITE'))
    else:
        print('nan_sites --check-census-teeth: %s' % ('GREEN (%d teeth)' % len(teeth) if not bad else 'RED'))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if '--check-census-teeth' in a:
        return check_census_teeth('--self-test' in a)
    opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d
    if a[:1] == ['--oracle']:
        json.dump(oracle(a[1], a[2], a[3], int(a[4]), int(a[5])), sys.stdout)
        return 0
    if '--apply' in a:
        fx = json.load(open(opt('--apply')))
        path = os.path.join(REPO, fx['file'])
        src = open(path).read()
        fixes = fx['fixes']
        for s in fixes:
            if src[s['lo']:s['hi']] != s['old']:
                raise SystemExit('REFUSE: the text at line %d changed since the fixes were made' % s['line'])
        # nested sites (an fminf call inside a compare's operand): the inner rewrite goes into the outer's old and
        # new text, innermost first, then every site is written from the end of the file back
        for inner in sorted(fixes, key=lambda s: s['hi'] - s['lo']):
            for outer in fixes:
                if outer is inner or not (outer['lo'] <= inner['lo'] and inner['hi'] <= outer['hi']):
                    continue
                if (outer['lo'], outer['hi']) == (inner['lo'], inner['hi']):
                    raise SystemExit('REFUSE: two fixes for one span at line %d' % inner['line'])
                rel = inner['lo'] - outer['lo']
                was = inner['old_now'] if 'old_now' in inner else inner['old']
                if outer.get('old_now', outer['old'])[rel:rel + len(was)] != was or outer['new'].count(was) != 1:
                    raise SystemExit('REFUSE: cannot nest line %d inside line %d' % (inner['line'], outer['line']))
                o = outer.get('old_now', outer['old'])
                outer['old_now'] = o[:rel] + inner['new'] + o[rel + len(was):]
                outer['new'] = outer['new'].replace(was, inner['new'])
        for s in sorted(fixes, key=lambda s: (-s['lo'], s['hi'] - s['lo'])):
            now = s.get('old_now', s['old'])
            if src[s['lo']:s['lo'] + len(now)] != now:
                raise SystemExit('REFUSE: line %d: the text is not what the nested rewrite expects' % s['line'])
            src = src[:s['lo']] + s['new'] + src[s['lo'] + len(now):]
        open(path, 'w').write(src)
        print('nan_sites --apply: %d sites rewritten in %s' % (len(fx['fixes']), fx['file']))
        return 0
    port, func = opt('--port-of', 'juno'), opt('--func', 'voice')
    if '--from-boot' in a:                        # the oracle runs in a child: the flag goes by the environment
        os.environ['NANSITES_FROM_BOOT'] = '1'
    frames = int(opt('--frames', '64'))
    spec = opt('--patches', opt('--patch', '5'))
    release = int(opt('--release', '0'))
    scenes = []
    for part in spec.split(','):
        if not part:
            continue
        lo, _, hi = part.partition('-')
        scenes += ['p:%d' % k for k in range(int(lo), int(hi or lo) + 1)]
    if opt('--variants'):                         # JX: the bisect's variant records (modes | fx | SPEC;SPEC);
        v = opt('--variants')                     # JUNO: 'P:BB=VAL,...;...' (juno_variant)
        if v in ('modes', 'fx'):
            sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
            import jx_master_bisect as B
            specs = B.mode_variants() if v == 'modes' else B.fx_variants()
        else:
            specs = v.split(';')
        scenes += ['v:' + x for x in specs if x]
    if opt('--scenes'):                           # raw scenes (e: events, w: written cells; SCENE@N its length)
        scenes += [x for x in opt('--scenes').split(';') if x]
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
        # the machine's equality helpers planted back as C's == / != (the decompiler's form)
        eqs = [st for st in sites_of(src, t['fn'])[0] if st['kind'] in EQS]
        for st in sorted(eqs, key=lambda st: -st['lo']):
            plines.add(st['line'])
            src = src[:st['lo']] + '(%s %s %s)' % (st['A'], '==' if st['kind'].endswith('eq') else '!=', st['B']) + \
                src[st['hi']:]
        planted += len(eqs)
        if not planted:
            raise SystemExit('REFUSE --tooth: no site written !( ) in %s' % t['c'])
    sites, body0 = sites_of(src, t['fn'])
    if opt('--tooth-census'):                     # the census's tooth: one C site taken out of the map -- the
        why = census_stale(src, t['fn'], opt('--tooth-census'))   # instruction it grades must then be UNCLAIMED
        if why:
            raise SystemExit('REFUSE --tooth-census: %s of %s' % (why, t['c']))
        drop = census_spec(opt('--tooth-census'))[0]
        n0 = len(sites)
        sites = [s for s in sites if s['line'] != drop]
        if len(sites) == n0:
            raise SystemExit('REFUSE --tooth-census: no site on line %d of %s' % (drop, t['c']))
    tmp = tempfile.mkdtemp(prefix='nansites_')
    atexit.register(shutil.rmtree, tmp, True)
    # the port side in this process (no Unicorn here: the two-process rule); the oracle one process per scene
    lib, compiled = build_port(port, func, instrument(src, sites, body0, t['voice']), tmp)
    if '--rate' in a:                             # the JX engine's rate, for both sides (the oracle by the environment)
        if port != 'jx' or opt('--rate') not in ('44100', '96000'):
            raise SystemExit('REFUSE: --rate is 44100 or 96000, for the JX-3P')
        os.environ['NANSITES_RATE'] = opt('--rate')
    per = [[] for _ in sites]
    asm_m, ninsn, ran_asm, claimed, seen_at = {}, 0, set(), set(), {}
    DEF = ('right', 'wrong', 'int', 'exact', 'nested-right', 'nested-wrong', 'int-type')
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
        vals, real = scene(lib, port, pt, frames, release, len(sites))
        for i, r_ in enumerate(real):
            sites[i]['real'] = max(sites[i].get('real', 0), r_)
        for i, g in enumerate(grade(sites, vals, asm, port)):
            if g is not None:
                per[i].append((pt, g))
                for ad, _ in grade.raw[i]:
                    seen_at.setdefault(ad, set()).add(sites[i]['line'])
                if g[0] in DEF:                   # the instruction(s) this verdict graded
                    claimed.add(g[1])
                    if not g[0].startswith('nested'):
                        claimed |= {ad for ad, _ in grade.cands[i]}
    # merge the scenes: a definite verdict wins over review / unmatched; two definite verdicts must agree
    right = ints = exact = 0
    wrong, review, unmatched, conflict, fixes = [], [], [], [], []
    nested, typed = {}, {}
    for i, s in enumerate(sites):
        # one C site can be several instructions (a block the compiler duplicated): the verdict and the operand
        # order must agree, the address may differ
        defin = {(g[0].replace('nested-', '').replace('int-type', 'int'), g[2]) for _, g in per[i] if g[0] in DEF}
        addrs = sorted({g[1] for _, g in per[i] if g[0] in DEF})
        nested[i] = any(g[0].startswith('nested') for _, g in per[i])
        typed[i] = all(g[0] == 'int-type' for _, g in per[i] if g[0] in DEF) and bool(defin)
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
    dead = [s for i, s in enumerate(sites) if i not in compiled]
    print('%s %s (%s, rva 0x%x), patches %s%s: %d C sites (%d in no compiled branch), %d ran; %d instructions graded '
          '(%d ran) of %d' % (port, func, t['c'], t['rva'], spec, ' at %s Hz' % opt('--rate') if opt('--rate') else '',
                              len(sites) - len(dead), len(dead), ran, len(asm_m), len(ran_asm), ninsn))
    print('  right %d   integer %d (%d by their C types)   min/max with a constant second operand %d   WRONG on NaN %d   '
          'for review %d   unmatched %d   conflicting %d   never ran %d   (inner tests of a shared compare: %d)' % (
              right, ints, sum(1 for v in typed.values() if v), exact, len(wrong), len(review), len(unmatched),
              len(conflict), len(sites) - len(dead) - ran, sum(1 for v in nested.values() if v)))
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
    never = [s for i, (s, p_) in enumerate(zip(sites, per)) if not p_ and i in compiled]
    # THE CENSUS (playbook 224): every float compare / min-max instruction the plugin ran is graded through a C site.
    # One no site claims is a test the tool cannot see in the C (an inline helper outside the function: READ, listed)
    # or a tie that gave two sites one instruction (JUNO master lines 2017 / 2109 before this check)
    fl = sorted(ad for ad in ran_asm if asm_m[ad] in CMP + MINMAX)
    rd = READ_INLINE.get((port, func), {})
    uncl = [ad for ad in fl if ad not in claimed and ad not in rd]
    print('  census: %d float compare / min-max instructions ran: %d graded through a C site, %d READ (%s), '
          '%d UNCLAIMED' % (len(fl), sum(1 for ad in fl if ad in claimed), sum(1 for ad in fl if ad in rd and
                                                                                 ad not in claimed),
                            ', '.join(sorted(set(rd.values()))) or 'none', len(uncl)))
    for ad in uncl:
        print('  UNCLAIMED rva 0x%x %s (values matched at C line(s): %s)' % (
            ad, asm_m[ad], ', '.join(map(str, sorted(seen_at.get(ad, ())))) or 'none'))
    if '--list-never' in a or '--all-run' in a:
        for s in never:
            print('  NEVER RAN line %-5d %s' % (s['line'], s.get('op') or s['kind']))
    if opt('--fixes'):
        json.dump(dict(file=t['c'], fixes=fixes), open(opt('--fixes'), 'w'), indent=1)
        print('  fixes for %d sites written to %s' % (len(fixes), opt('--fixes')))
    if '--tooth' in a:
        hit = [w for w in wrong if w[0]['line'] in plines]
        print('nan_sites --tooth: %d sites planted back in the decompiler\'s form, %d of them ran: %s' % (
            planted, sum(1 for s_, p_ in zip(sites, per) if p_ and s_['line'] in plines),
            'BITES (%d graded WRONG)' % len(hit) if hit else 'DID NOT BITE'))
        return 0 if hit else 1
    if opt('--tooth-census'):                     # LINE:RVA -- the very instruction the dropped line grades
        want = census_spec(opt('--tooth-census'))[1]
        print('nan_sites --tooth-census (line %s taken out): %s' % (
            opt('--tooth-census'), 'BITES (rva 0x%x UNCLAIMED)' % want if want in uncl else 'DID NOT BITE'))
        return 0 if want in uncl else 1
    # a site for review is a site nobody graded: it fails the gate like a wrong one (mantra 5); so does a site no
    # scene reached, under --all-run
    if '--all-run' in a and never:
        print('nan_sites: REACH -- %d C sites never ran in these scenes (--all-run)' % len(never))
    return 1 if (wrong or unmatched or conflict or review or ('--all-run' in a and (never or uncl))) else 0


if __name__ == '__main__':
    sys.exit(main())
