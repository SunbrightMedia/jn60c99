#!/usr/bin/env python3
"""jp8_fast.py IN OUT -- the lifted C (jp8_lift.py's output) with its CPU state in C locals: the FAST form.

The lifter writes one C statement per instruction on a CPU struct in memory (jp8_cpu.h: R(n) = c->r[n], the xmm
registers c->x[n], the flags c->zf ..). That is exact and slow: every instruction loads and stores the struct, every
flag op computes five flags (2026-10-12, playbook 230: the JX voice render lifted ran 5.3 times the plugin's own
time). This pass keeps every statement of the lifter -- the same arithmetic, the same memory accesses, in the same
order -- and moves the state into locals of each lifted function:

  REGISTERS  each function holds the registers it names (rN, xN) in locals: loaded from the caller's CPU (cg) at
             entry; before a call, the registers written since the last store (the DIRTY set, a forward dataflow over
             the function's statements) that the callee may read or write (its transitive use / def sets over the
             direct call graph) are stored to cg; after the call, the ones the callee may write are loaded again;
             at a return every dirty register is stored. An indirect call (jp8_icall: a table target, an import)
             stores every dirty register and reloads all of them. A callee that may write a register on some
             path stores its own copy back on every path, so a caller's dirty value it may write is stored first
             (else a path that did not write it would return a stale one).
  FLAGS      each function has its own flags (a local CPU F; the lifter's helpers op_add(c, ..) / cmp_f / CC_*
             work on c = &F unchanged). Exact only if no flag is live where functions meet: a backward liveness
             over every function proves that no flag is read before it is written from the function's entry and
             from the return point of every call. If any function fails, every function keeps its flags in cg
             (loaded at entry, stored before calls and returns, loaded after calls) -- the pass says so.
  REST       memory (M8 .. M64, jp8_ldx / jp8_stx), mxcsr (JP8_LDMXCSR / STMXCSR on cg), traps (jp8_trap(cg ..))
             and the runtime's calls (jp8_icall(cg ..)) are the lifter's own; rep movsb is JP8F_MOVSB (jp8_cpu.h's
             JP8_MOVSB on locals).

Every statement shape the pass rewrites is matched in full; any other statement that calls, jumps or returns is
REFUSED (exit 2), as is any `c->` it does not know. Built and graded as the lifted source is (the gates that grade
jp8_lift.py's output grade this one; the speed against the plugin's own code: playbook 230).

    python3 jp8/tools/jp8_fast.py IN.c OUT.c            prints the counts and the flag verdict
    JP8_FAST_TOOTH=1 ...   the tooth: at every call, xmm0 left out of the stores (a gate on the output must fail)
    JP8_FAST_INLINE=N      the inlining bound in statements (default 80; 0: no inlining)
"""
import collections
import os
import re
import sys

FLAGS = ('zf', 'sf', 'cf', 'of', 'pf')
CC_USE = {'CC_E': 'zf', 'CC_NE': 'zf', 'CC_B': 'cf', 'CC_AE': 'cf', 'CC_BE': 'cf zf', 'CC_A': 'cf zf',
          'CC_L': 'sf of', 'CC_GE': 'sf of', 'CC_LE': 'zf sf of', 'CC_G': 'zf sf of', 'CC_S': 'sf', 'CC_NS': 'sf',
          'CC_P': 'pf', 'CC_NP': 'pf', 'CC_O': 'of', 'CC_NO': 'of'}
ALL5 = frozenset(FLAGS)
# helpers that write all five flags on every path (jp8_cpu.h)
KILL_ALL = ('op_add', 'op_sub', 'op_and', 'op_or', 'op_xor', 'op_neg', 'op_adc', 'op_sbb', 'cmp_f', 'cmp_d')
ASSIGN = r'(?:\+|-|\*|/|%|&|\||\^|<<|>>)?=(?!=)'
ALLREG = frozenset(range(32))          # 0..15 the GPRs, 16..31 the xmm registers
INLINE_MAX = int(os.environ.get("JP8_FAST_INLINE", "80"))
INLINE_ROUNDS = 4
TOOTH = os.environ.get('JP8_FAST_TOOTH') == '1'   # a planted pass defect: every gate on the output must fail   # statements: a leaf function this small is inlined at its direct calls

STMT = re.compile(r'^  /\*([0-9a-f]+) (.*?)\*/ (.*)$')
HDR = re.compile(r'^static void f_([0-9a-f]+)\(CPU \*c\) \{$')
ALLOC = re.compile(r'^static void f_([0-9a-f]+)\(CPU \*c\) \{ jp8_alloc\(c\); \}')
SH_RET = re.compile(r'(?:bnd )?return;')
SH_CALL = re.compile(r'R\(4\)-=8; M64\(R\(4\)\)=(0x[0-9a-f]+ULL); f_([0-9a-f]+)\(c\); R\(4\)\+=8;')
SH_ICALL = re.compile(r'a0=(.*); R\(4\)-=8; M64\(R\(4\)\)=(0x[0-9a-f]+ULL); jp8_icall\(c, a0\); R\(4\)\+=8;')
SH_TAIL = re.compile(r'f_([0-9a-f]+)\(c\); return;')
SH_SWITCH = re.compile(r'a0=(.*); switch \(a0\) \{(.*) default: jp8_icall\(c, a0\); return; \}')
SH_JMP = re.compile(r'goto ((?:L_[0-9a-f]+|Lr)(?:_i[0-9]+)*);')
SH_JCC = re.compile(r'if \((CC_[A-Z]+)\) goto ((?:L_[0-9a-f]+|Lr)(?:_i[0-9]+)*);')
SH_TRAP = re.compile(r'jp8_trap\(c, .*\);')


def die(msg):
    sys.stderr.write('jp8_fast: REFUSE: %s\n' % msg)
    sys.exit(2)


def reg_effects(t):
    """(uses, defs) of one statement's text, as register numbers (xmm n = 16 + n). A pure `=` to a whole register
    is a def only; a lane write (XF(n,l)= ..) or a compound assignment is a use and a def (the rest of the register
    flows through)"""
    uses, defs = set(), set()
    for m in re.finditer(r'(\+\+|--)?\bR\((\d+)\)(\s*(?:' + ASSIGN + r'|\+\+|--))?', t):
        n = int(m.group(2))
        post = (m.group(3) or '').strip()
        if post == '=':
            defs.add(n)
        elif post or m.group(1):
            uses.add(n); defs.add(n)
        else:
            uses.add(n)
    for m in re.finditer(r'\bX[FDUQIL]\((\d+),\d+\)(\s*' + ASSIGN + r')?', t):
        n = 16 + int(m.group(1))
        uses.add(n)
        if m.group(2):
            defs.add(n)
    for m in re.finditer(r'(&)?c->x\[(\d+)\](\s*=(?!=))?', t):
        n = 16 + int(m.group(2))
        if m.group(3):
            defs.add(n)
        elif m.group(1):
            pre = t[:m.start()]
            if re.search(r'jp8_ldx\($', pre) or re.search(r'memset\($', pre):
                defs.add(n)
            elif re.search(r'jp8_stx\(.*,$', pre):
                uses.add(n)
            else:
                uses.add(n); defs.add(n)
        else:
            uses.add(n)
    if 'JP8_MOVSB()' in t:
        uses.update((1, 6, 7)); defs.update((1, 6, 7))
    return uses, defs


def call_args(t, start):
    """the top-level arguments of the call whose '(' is at t[start]"""
    depth, args, cur = 0, [], ''
    for i in range(start, len(t)):
        ch = t[i]
        if ch == '(':
            depth += 1
            if depth == 1:
                continue
        elif ch == ')':
            depth -= 1
            if depth == 0:
                args.append(cur.strip())
                return args
        if ch == ',' and depth == 1:
            args.append(cur.strip()); cur = ''
        else:
            cur += ch
    die('unbalanced call in: %s' % t[:120])


def const(s):
    m = re.fullmatch(r'0x([0-9a-f]+)ULL', s)
    return int(m.group(1), 16) if m else None


def flag_effects(t):
    """(uses, kills) of one statement: kills are flags written on EVERY path through it"""
    uses, kills = set(), set()
    for cc in re.findall(r'\bCC_[A-Z]+\b', t):
        uses.update(CC_USE[cc].split())
    for m in re.finditer(r'\b(op_[a-z0-9]+|cmp_f|cmp_d)\(c,', t):
        fn = m.group(1)
        args = call_args(t, t.index('(', m.start()))
        if fn in ('op_adc', 'op_sbb', 'op_rcl', 'op_rcr'):
            uses.add('cf')
        if fn in KILL_ALL:
            kills |= ALL5
        elif fn in ('op_inc', 'op_dec'):
            kills |= {'zf', 'sf', 'of', 'pf'}
        elif fn in ('op_shl', 'op_shr', 'op_sar', 'op_rol', 'op_ror'):
            sz, n = int(args[1]), const(args[3])
            if fn in ('op_rol', 'op_ror'):
                if n is not None and n % sz:
                    kills |= {'cf', 'of'}
            elif n is not None and n & (63 if sz == 64 else 31):
                kills |= ALL5
        elif fn in ('op_bt',):
            kills.add('cf')
        elif fn in ('op_imul2',):
            kills |= {'cf', 'of'}
        elif fn in ('op_rcl', 'op_rcr'):
            pass
        else:
            die('flag helper %s not known' % fn)
    # explicit flag cells: a write at the statement's top level (not under an `if`) is a kill; any other read is a use
    body = t[1:-1].strip() if t.startswith('{') and t.endswith('}') else t
    top, depth, cur = [], 0, ''
    for ch in body:
        if ch in '({':
            depth += 1
        elif ch in ')}':
            depth -= 1
        cur += ch
        if ch == ';' and depth == 0:
            top.append(cur.strip()); cur = ''
    if cur.strip():
        top.append(cur.strip())
    for part in top:
        cond = part.startswith('if ') or part.startswith('if(') or part.startswith('while')
        for m in re.finditer(r'c->(zf|sf|cf|of|pf)(\s*=(?!=))?', part):
            if m.group(2):
                if not cond:
                    kills.add(m.group(1))
            else:
                uses.add(m.group(1))
    for m in re.finditer(r'c->([a-z_]+)', t):
        if m.group(1) not in FLAGS and m.group(1) != 'x':
            die('c->%s not known: %s' % (m.group(1), t[:120]))
    return uses, kills


def _mask(sz):
    return '0x%xULL' % ((1 << sz) - 1)


def _sx(sz, v):
    return {64: '(int64_t)(%s)', 32: '(int64_t)(int32_t)(%s)', 16: '(int64_t)(int16_t)(%s)',
            8: '(int64_t)(int8_t)(%s)'}[sz] % v


def inline_helper(fn, args):
    """one flag helper of jp8_cpu.h as an expression on the function's locals (flags fz fs fc fo fp, temporaries
    ha_ ..): the helper's own formulas, term for term, so nothing has to be inlined by the compiler (a helper it
    keeps out of line takes the flags' address and puts them in memory for the whole function)"""
    if fn in ('cmp_f', 'cmp_d'):
        v1, v2, daz = ('hf1_', 'hf2_', 'JP8_DAZF') if fn == 'cmp_f' else ('hd1_', 'hd2_', 'JP8_DAZD')
        return ('(%s=%s(%s), %s=%s(%s), (%s!=%s || %s!=%s) ? (fz=fp=fc=1) : (fz=(%s==%s), fc=(%s<%s), fp=0), fo=fs=0)'
                % (v1, daz, args[1], v2, daz, args[2], v1, v1, v2, v2, v1, v2, v1, v2))
    if not re.fullmatch(r'(8|16|32|64)', args[1]):
        die('%s: operand size %r not a literal' % (fn, args[1]))
    sz = int(args[1]); M = _mask(sz); S1 = sz - 1; A = args[2]
    B = args[3] if len(args) > 3 else None
    nm = 63 if sz == 64 else 31
    szp = 'fz=(hr_==0), fs=(int)((hr_>>%d)&1), fp=jp8_parity(hr_)' % S1
    if fn == 'op_add':
        return '(ha_=(%s)&%s, hb_=(%s)&%s, hr_=(ha_+hb_)&%s, fc=hr_<ha_, fo=(int)(((~(ha_^hb_)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, B, M, M, S1, szp)
    if fn == 'op_sub':
        return '(ha_=(%s)&%s, hb_=(%s)&%s, hr_=(ha_-hb_)&%s, fc=ha_<hb_, fo=(int)((((ha_^hb_)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, B, M, M, S1, szp)
    if fn == 'op_adc':
        return ('(hcin_=(uint64_t)fc, ha_=(%s)&%s, hb_=(%s)&%s, hr_=(ha_+hb_+hcin_)&%s, fc=(hr_<ha_)||(hcin_&&hr_==ha_), '
                'fo=(int)(((~(ha_^hb_)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, B, M, M, S1, szp))
    if fn == 'op_sbb':
        return ('(hcin_=(uint64_t)fc, ha_=(%s)&%s, hb_=(%s)&%s, hr_=(ha_-hb_-hcin_)&%s, fc=(ha_<hb_)||(hcin_&&ha_==hb_), '
                'fo=(int)((((ha_^hb_)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, B, M, M, S1, szp))
    if fn in ('op_and', 'op_or', 'op_xor'):
        op = {'op_and': '&', 'op_or': '|', 'op_xor': '^'}[fn]
        return '(hr_=((%s)%s(%s))&%s, fc=0, fo=0, %s, hr_)' % (A, op, B, M, szp)
    if fn == 'op_inc':
        return '(ha_=(%s)&%s, hr_=(ha_+1ULL)&%s, fo=(int)(((~(ha_^1ULL)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, M, S1, szp)
    if fn == 'op_dec':
        return '(ha_=(%s)&%s, hr_=(ha_-1ULL)&%s, fo=(int)((((ha_^1ULL)&(ha_^hr_))>>%d)&1), %s, hr_)' % (A, M, M, S1, szp)
    if fn == 'op_neg':
        return '(hb_=(%s)&%s, hr_=(0ULL-hb_)&%s, fo=(int)(((hb_&hr_)>>%d)&1), %s, fc=(hb_!=0), hr_)' % (A, M, M, S1, szp)
    if fn == 'op_shl':
        return ('(hn_=((unsigned)(%s))&%du, ha_=(%s), hn_ ? (hr_=(ha_<<hn_)&%s, fc=(int)((ha_>>(%d-hn_))&1), '
                'fo=(int)(((hr_>>%d)&1)^(uint64_t)fc), %s, hr_) : (ha_&%s))' % (B, nm, A, M, sz, S1, szp, M))
    if fn == 'op_shr':
        return ('(hn_=((unsigned)(%s))&%du, ha_=(%s)&%s, hn_ ? (hr_=ha_>>hn_, fc=(int)((ha_>>(hn_-1))&1), '
                'fo=(int)((ha_>>%d)&1), %s, hr_) : ha_)' % (B, nm, A, M, S1, szp))
    if fn == 'op_sar':
        return ('(hn_=((unsigned)(%s))&%du, ha_=(%s)&%s, hn_ ? (hs_=%s, hr_=((uint64_t)(hs_>>hn_))&%s, '
                'fc=(int)((ha_>>(hn_-1))&1), fo=0, %s, hr_) : ha_)' % (B, nm, A, M, _sx(sz, 'ha_'), M, szp))
    if fn == 'op_rol':
        return ('(hn_=((unsigned)(%s))%%%du, ha_=(%s)&%s, hn_ ? (hr_=((ha_<<hn_)|(ha_>>(%du-hn_)))&%s, fc=(int)(hr_&1), '
                'fo=(int)(((hr_>>%d)&1)^(uint64_t)fc), hr_) : ha_)' % (B, sz, A, M, sz, M, S1))
    if fn == 'op_ror':
        return ('(hn_=((unsigned)(%s))%%%du, ha_=(%s)&%s, hn_ ? (hr_=((ha_>>hn_)|(ha_<<(%du-hn_)))&%s, fc=(int)((hr_>>%d)&1), '
                'fo=(int)(((hr_>>%d)^(hr_>>%d))&1), hr_) : ha_)' % (B, sz, A, M, sz, M, S1, S1, sz - 2))
    if fn in ('op_rcl', 'op_rcr'):
        return 'jf_%s(&fc,%d,(%s),(unsigned)(%s))' % (fn[3:], sz, A, B)
    if fn == 'op_bt':
        return '(hn_=(unsigned)((uint64_t)(%s)&%dULL), fc=(int)(((uint64_t)(%s)>>hn_)&1), fc)' % (B, S1, A)
    if fn == 'op_imul2':
        if sz == 64:
            return '(hr_=jp8_muls64((%s),(%s),&hh_), fc=fo=(hh_!=((hr_>>63)?~0ULL:0ULL)), hr_)' % (A, B)
        return ('(hp_=%s*%s, hr_=(uint64_t)hp_&%s, fc=fo=(hp_!=%s), hr_)'
                % (_sx(sz, A), _sx(sz, B), M, _sx(sz, 'hr_')))
    die('flag helper %s has no inline form' % fn)


CC_EXPR = {'CC_E': '(fz)', 'CC_NE': '(!fz)', 'CC_B': '(fc)', 'CC_AE': '(!fc)', 'CC_BE': '(fc || fz)',
           'CC_A': '(!fc && !fz)', 'CC_L': '(fs != fo)', 'CC_GE': '(fs == fo)', 'CC_LE': '(fz || (fs != fo))',
           'CC_G': '(!fz && (fs == fo))', 'CC_S': '(fs)', 'CC_NS': '(!fs)', 'CC_P': '(fp)', 'CC_NP': '(!fp)',
           'CC_O': '(fo)', 'CC_NO': '(!fo)'}


def inline_flags(t):
    """every flag helper call, CC_ test and flag cell of one statement on the function's local flags"""
    while True:
        ms = list(re.finditer(r'\b(op_[a-z0-9]+|cmp_f|cmp_d)\(c,', t))
        if not ms:
            break
        m = ms[-1]                                 # the rightmost call: none nests inside it
        k = t.index('(', m.start())
        args = call_args(t, k)
        depth, j = 0, k
        while True:
            if t[j] == '(':
                depth += 1
            elif t[j] == ')':
                depth -= 1
                if depth == 0:
                    break
            j += 1
        t = t[:m.start()] + inline_helper(m.group(1), args) + t[j + 1:]
    t = re.sub(r'\bCC_[A-Z]+\b', lambda mm: CC_EXPR[mm.group(0)], t)
    t = re.sub(r'c->(zf|sf|cf|of|pf)\b', lambda mm: {'zf': 'fz', 'sf': 'fs', 'cf': 'fc', 'of': 'fo', 'pf': 'fp'}[mm.group(1)], t)
    return t


class Fn:
    def __init__(self, rva, lines):
        self.rva = rva
        self.decl = lines[0]          # `  X t0, t1; ...`
        self.entry = lines[1]         # `  goto L_<rva>; ...`
        self.items = []               # ('label', name) | ('stmt', rva, mnem, text)
        for ln in lines[2:]:
            m = STMT.match(ln)
            if m:
                self.items.append(('stmt', m.group(1), m.group(2), m.group(3)))
                continue
            m = re.match(r'^((?:L_[0-9a-f]+|Lr)(?:_i[0-9]+)*):', ln)
            if m:
                self.items.append(('label', m.group(1)))
                continue
            die('f_%s: line not understood: %s' % (rva, ln[:120]))
        if not re.match(r'^  X t0, t1; uint64_t a0, a1;', self.decl) or not self.entry.startswith('  goto L_%s;' % rva):
            die('f_%s: prologue not the lifter\'s' % rva)
        self.ninl = 0
        self.analyze()

    def analyze(self):
        rva = self.rva
        self.st = [it for it in self.items if it[0] == 'stmt']
        self.lab = {}
        k = 0
        for it in self.items:
            if it[0] == 'label':
                self.lab[it[1]] = k
            else:
                k += 1
        self.shape, self.callee, self.succ = [], [], []
        n = len(self.st)
        for i, (_, srva, mnem, t) in enumerate(self.st):
            nxt = [i + 1] if i + 1 < n else []
            if SH_RET.fullmatch(t):
                sh, cal, sc = 'RET', None, []
            elif SH_CALL.fullmatch(t):
                sh, cal, sc = 'CALL', SH_CALL.fullmatch(t).group(2), nxt
            elif SH_ICALL.fullmatch(t):
                sh, cal, sc = 'ICALL', None, nxt
            elif SH_TAIL.fullmatch(t):
                sh, cal, sc = 'TAIL', SH_TAIL.fullmatch(t).group(1), []
            elif SH_SWITCH.fullmatch(t):
                sh, cal = 'SWITCH', None
                sc = [self.lab[x] for x in re.findall(r'goto (L_[0-9a-f]+);', SH_SWITCH.fullmatch(t).group(2))]
            elif SH_JMP.fullmatch(t):
                sh, cal, sc = 'JMP', None, [self.lab[SH_JMP.fullmatch(t).group(1)]]
            elif SH_JCC.fullmatch(t):
                sh, cal, sc = 'JCC', None, [self.lab[SH_JCC.fullmatch(t).group(2)]] + nxt
            elif SH_TRAP.fullmatch(t):
                sh, cal, sc = 'TRAP', None, []
            elif re.search(r'\bgoto\b|\breturn\b|\bf_[0-9a-f]+\(|jp8_icall|jp8_import|jp8_alloc', t):   # a trap inside (div0) never returns: plain
                die('f_%s %s: a statement that calls, jumps or returns in a shape not known: %s' % (rva, srva, t[:160]))
            else:
                sh, cal, sc = 'PLAIN', None, nxt
            self.shape.append(sh); self.callee.append(cal); self.succ.append(sc)
        self.start = self.lab['L_%s' % rva]
        self.ru, self.rd = [], []
        for _, _, _, t in self.st:
            u, d = reg_effects(t)
            self.ru.append(frozenset(u)); self.rd.append(frozenset(d))
        self.uses = frozenset().union(*self.ru) if self.ru else frozenset()
        self.defs = frozenset().union(*self.rd) if self.rd else frozenset()
        self.local = self.uses | self.defs
        self.has_icall = any(s in ('ICALL', 'SWITCH') for s in self.shape)


def inline_calls(f, fns, cand):
    """f's calls to a small leaf function, replaced by the callee's own statements: the call's push, a jump to
    the callee's entry, its statements (labels renamed per site, each return a jump to the site's return label),
    then the call's pop. The same instructions run in the same order; only the C function boundary goes."""
    items, done = [], 0
    for it in f.items:
        if it[0] == 'stmt':
            m = SH_CALL.fullmatch(it[3])
            if m and m.group(2) in cand:
                g = fns[m.group(2)]
                f.ninl += 1
                k = '_i%d' % f.ninl
                ret = 'Lr%s' % k
                items.append(('stmt', it[1], it[2], 'R(4)-=8; M64(R(4))=%s;' % m.group(1)))
                items.append(('stmt', it[1], 'inline', 'goto L_%s%s;' % (g.rva, k)))
                for gi in g.items:
                    if gi[0] == 'label':
                        items.append(('label', gi[1] + k))
                        continue
                    t = re.sub(r'goto ((?:L_[0-9a-f]+|Lr)(?:_i[0-9]+)*);', lambda mm: 'goto %s%s;' % (mm.group(1), k), gi[3])
                    if SH_RET.fullmatch(t):
                        t = 'goto %s;' % ret
                    items.append(('stmt', gi[1], gi[2], t))
                items.append(('label', ret))
                items.append(('stmt', it[1], it[2], 'R(4)+=8;'))
                done += 1
                continue
        items.append(it)
    f.items = items
    return done


def parse(src):
    out, fns, i = [], {}, 0
    while i < len(src):
        m = HDR.match(src[i])
        if m:
            j = i + 1
            while src[j] != '}':
                j += 1
            f = Fn(m.group(1), src[i + 1:j])
            fns[f.rva] = f
            out.append(('fn', f.rva))
            i = j + 1
            continue
        m = ALLOC.match(src[i])
        if m:
            out.append(('alloc', m.group(1), src[i]))
        else:
            out.append(('line', src[i]))
        i += 1
    return out, fns


def transitive(fns, allocs):
    """each function's registers a call may read (use) or write (def), through its direct callees; ALL for one
    that calls through a table or an import"""
    use = {r: (ALLREG if f.has_icall else set(f.uses)) for r, f in fns.items()}
    dfn = {r: (ALLREG if f.has_icall else set(f.defs)) for r, f in fns.items()}
    for a in allocs:
        use[a], dfn[a] = {1}, {0}          # jp8_alloc: rcx in, rax out (jp8_rt.c)
    use = {k: set(v) for k, v in use.items()}
    dfn = {k: set(v) for k, v in dfn.items()}
    changed = True
    while changed:
        changed = False
        for r, f in fns.items():
            for cal in f.callee:
                if cal is None:
                    continue
                if cal not in use:
                    die('f_%s calls f_%s, which is not in the file' % (r, cal))
                if not use[cal] <= use[r]:
                    use[r] |= use[cal]; changed = True
                if not dfn[cal] <= dfn[r]:
                    dfn[r] |= dfn[cal]; changed = True
    return use, dfn


def flags_ok(f):
    """True when no flag is live at f's entry or at the return point of any call in f"""
    n = len(f.st)
    fu, fk = [], []
    for _, _, _, t in f.st:
        u, k = flag_effects(t)
        fu.append(frozenset(u)); fk.append(frozenset(k))
    live_in = [frozenset()] * n
    changed = True
    while changed:
        changed = False
        for i in range(n - 1, -1, -1):
            out = frozenset().union(*[live_in[s] for s in f.succ[i]]) if f.succ[i] else frozenset()
            if f.shape[i] in ('CALL', 'ICALL'):
                if out:
                    return False, 'flags %s live after the call at %s' % (sorted(out), f.st[i][1])
                li = frozenset()
            elif f.shape[i] in ('RET', 'TAIL', 'TRAP'):
                li = fu[i]
            else:
                li = fu[i] | (out - fk[i])
            if li != live_in[i]:
                live_in[i] = li; changed = True
    if n and live_in[f.start]:
        return False, 'flags %s live at the entry' % sorted(live_in[f.start])
    return True, ''


def dirty_in(f, use, dfn):
    """the forward dataflow: per statement, the registers written since they were last stored to cg"""
    n = len(f.st)
    din = [None] * n
    din[f.start] = frozenset()
    work = [f.start]
    while work:
        i = work.pop()
        d = din[i]
        sh = f.shape[i]
        if sh == 'CALL':
            pre = d | {4}
            cal = f.callee[i]
            s = pre & (use[cal] | dfn[cal])
            out = (pre - s - (dfn[cal] & f.local)) | {4}
        elif sh == 'ICALL':
            out = frozenset({4})
        else:
            out = d | f.rd[i]
        for s_ in f.succ[i]:
            nd = out if din[s_] is None else (din[s_] | out)
            if din[s_] is None or nd != din[s_]:
                din[s_] = frozenset(nd)
                work.append(s_)
    return din


def rname(k):
    return 'r%d' % k if k < 16 else 'x%d' % (k - 16)


def cgname(k):
    return 'cg->r[%d]' % k if k < 16 else 'cg->x[%d]' % (k - 16)


def stores(regs, sync_flags):
    s = ''.join('%s=%s;' % (cgname(k), rname(k)) for k in sorted(regs))
    if sync_flags:
        s += 'cg->zf=fz;cg->sf=fs;cg->cf=fc;cg->of=fo;cg->pf=fp;'
    return s


def loads(regs, sync_flags):
    s = ''.join('%s=%s;' % (rname(k), cgname(k)) for k in sorted(regs))
    if sync_flags:
        s += 'fz=cg->zf;fs=cg->sf;fc=cg->cf;fo=cg->of;fp=cg->pf;'
    return s


def rewrite_text(t):
    t = inline_flags(t)
    t = t.replace('JP8_MOVSB()', 'JP8F_MOVSB(r1,r6,r7)')
    t = re.sub(r'\bM(8|16|32|64|F|D|S8|S16|S32)\(', r'FM\1(', t)          # guest memory: the fast macros (one
    t = t.replace('JP8_MX(', 'FMX(').replace('jp8_ldx(', 'JF_LDX(').replace('jp8_stx(', 'JF_STX(')   # bad-access sum)
    t = re.sub(r'\bR\((\d+)\)', r'r\1', t)
    t = re.sub(r'\bX([FDUQIL])\((\d+),(\d+)\)', lambda m: 'x%s.%s[%s]' % (m.group(2), m.group(1).lower(), m.group(3)), t)
    t = re.sub(r'c->x\[(\d+)\]', r'x\1', t)
    t = t.replace('jp8_trap(c,', 'jp8_trap(cg,').replace('JP8_LDMXCSR(c,', 'JP8_LDMXCSR(cg,') \
         .replace('JP8_STMXCSR(c)', 'JP8_STMXCSR(cg)')
    return t


def emit_fn(f, use, dfn, sync_flags, out):
    din = dirty_in(f, use, dfn)
    loc = sorted(f.local)
    gprs = [k for k in loc if k < 16]
    xmms = [k for k in loc if k >= 16]
    # restrict: the lifted code reaches the CPU struct through cg alone (guest memory lies in the guest blocks), so the
    # compiler may keep a stored register in a machine register across guest stores
    out.append('static void f_%s(CPU *restrict cg) {' % f.rva)
    decl = ('  int fz, fs, fc, fo, fp; uint64_t ha_, hb_, hr_, hh_, hcin_; int64_t hp_, hs_; unsigned hn_; float hf1_, hf2_;'
            ' double hd1_, hd2_; uint32_t bad_ = 0; (void)bad_;')
    if gprs:
        decl += ' uint64_t %s;' % ', '.join(rname(k) for k in gprs)
    if xmms:
        decl += ' X %s;' % ', '.join(rname(k) for k in xmms)
    out.append(decl + ' (void)ha_; (void)hb_; (void)hr_; (void)hh_; (void)hcin_; (void)hp_; (void)hs_; (void)hn_;'
               ' (void)hf1_; (void)hf2_; (void)hd1_; (void)hd2_;')
    init = loads(f.local, sync_flags)
    if not sync_flags:
        init += 'fz=fs=fc=fo=fp=0;'
    out.append('  ' + init)
    out.append(f.decl)
    out.append(f.entry)
    k = 0
    for it in f.items:
        if it[0] == 'label':
            out.append(it[1] + ':')
            continue
        _, srva, mnem, t = it
        sh, d = f.shape[k], din[k]
        if d is None:                       # unreachable from the entry: no dataflow value; store nothing extra
            d = frozenset(f.local)
        if sh == 'RET':
            new = '{%s JP8F_FLUSH(); return;}' % stores(d, sync_flags)
        elif sh == 'CALL':
            m = SH_CALL.fullmatch(t)
            cal = m.group(2)
            pre = d | {4}
            s = pre & (use[cal] | dfn[cal])
            if TOOTH and 16 in s:             # TOOTH: xmm0 (the first float argument) not stored before the call
                s = s - {16}
            new = 'r4-=8; M64(r4)=%s; {%s f_%s(cg); %s} r4+=8;' % (m.group(1), stores(s, sync_flags), cal,
                                                                   loads(dfn[cal] & f.local, sync_flags))
        elif sh == 'ICALL':
            m = SH_ICALL.fullmatch(t)
            new = 'a0=%s; r4-=8; M64(r4)=%s; {%s jp8_icall(cg, a0); %s} r4+=8;' % (
                rewrite_text(m.group(1)), m.group(2), stores(d | {4}, sync_flags), loads(f.local, sync_flags))
        elif sh == 'TAIL':
            cal = SH_TAIL.fullmatch(t).group(1)
            s = d & (use[cal] | dfn[cal])
            rest = d - s - (dfn[cal] & f.local)
            new = '{%s f_%s(cg); %s %s JP8F_FLUSH(); return;}' % (stores(s, sync_flags), cal,
                                                               loads(dfn[cal] & f.local, sync_flags), stores(rest, False))
        elif sh == 'SWITCH':
            m = SH_SWITCH.fullmatch(t)
            new = 'a0=%s; switch (a0) {%s default: {%s JP8F_FLUSH(); jp8_icall(cg, a0); return;} }' % (
                rewrite_text(m.group(1)), m.group(2), stores(d, sync_flags))
        else:
            new = rewrite_text(t)
        out.append('  /*%s %s*/ %s' % (srva, mnem, new))
        k += 1
    out.append('}')


def main():
    if len(sys.argv) != 3:
        sys.stderr.write(__doc__)
        return 2
    src = open(sys.argv[1]).read().split('\n')
    plan, fns = parse(src)
    allocs = [p[1] for p in plan if p[0] == 'alloc']
    # inlining in rounds (at most INLINE_ROUNDS): a small function with no table call, no tail call and no call to
    # itself is copied into its direct callers; its own calls stay calls there (and may be inlined next round)
    ninl = 0
    for _ in range(INLINE_ROUNDS):
        cand = {r for r, f in fns.items() if not f.has_icall and r not in f.callee and
                not any(sh == 'TAIL' for sh in f.shape) and len(f.st) <= INLINE_MAX}
        n0 = ninl
        for r, f in fns.items():
            if any(c_ in cand for c_ in f.callee if c_ != r):
                ninl += inline_calls(f, fns, cand - {r})
                f.analyze()
        if ninl == n0:
            break
    use, dfn = transitive(fns, allocs)
    bad = []
    for r, f in sorted(fns.items()):
        ok, why = flags_ok(f)
        if not ok:
            bad.append('f_%s: %s' % (r, why))
    sync_flags = bool(bad)
    out = []
    for p in plan:
        if p[0] == 'fn':
            emit_fn(fns[p[1]], use, dfn, sync_flags, out)
        elif p[0] == 'alloc':
            out.append(p[2])
        else:
            out.append(p[1])
            if p[1].startswith('#include "jp8_cpu.h"'):
                out.append('/* jp8_fast.py: rep movsb on locals, as jp8_cpu.h JP8_MOVSB does on the CPU struct */')
                out.append('/* jp8_fast.py: rcl / rcr on a local carry, as jp8_cpu.h op_rcl / op_rcr */')
                out.append('static inline uint64_t jf_rcr(int *cf, int sz, uint64_t a, unsigned n) { n %= (unsigned)(sz + 1); '
                           'a &= jp8_mask(sz); while (n--) { int c0 = (int)(a & 1); a = (a >> 1) | ((uint64_t)*cf << (sz - 1)); '
                           '*cf = c0; } return a & jp8_mask(sz); }')
                out.append('static inline uint64_t jf_rcl(int *cf, int sz, uint64_t a, unsigned n) { n %= (unsigned)(sz + 1); '
                           'a &= jp8_mask(sz); while (n--) { int c0 = (int)((a >> (sz - 1)) & 1); a = ((a << 1) | (uint64_t)*cf) '
                           '& jp8_mask(sz); *cf = c0; } return a; }')
                out.append('/* jp8_fast.py: guest memory with the bad-access check summed in a local per function (bad_), added')
                out.append(' * to jp8_badacc at every return -- jp8_cpu.h JP8_RELOC_CHECK 2 stores the global at every access */')
                out.append('#if defined(JP8_RELOC) && JP8_RELOC_CHECK == 2')
                out.append('static inline void *jp8f_h(uint64_t a, unsigned n, uint32_t *bad) {')
                out.append('    uint64_t i = a >> 28; uint32_t k = (uint32_t)(i & (JP8_NBANDS - 1)), off = (uint32_t)(a & 0x0FFFFFFFu);')
                out.append('    uint32_t b = (uint32_t)(i >= JP8_NBANDS) | (uint32_t)(off < jp8_blo[k]) | (uint32_t)(off + n > jp8_bhi[k]);')
                out.append('    *bad |= b; return b ? (void *)jp8_sink : (void *)((uintptr_t)a + jp8_bdelta[k]); }')
                out.append('#define JP8F_H(a, n) jp8f_h((uint64_t)(a), (n), &bad_)')
                out.append('#define JP8F_FLUSH() (jp8_badacc |= bad_)')
                out.append('#else')
                out.append('#define JP8F_H(a, n) JP8_H(a, n)')
                out.append('#define JP8F_FLUSH() ((void)0)')
                out.append('#endif')
                out.append('#define FM8(a)  (*(JP8_MQ uint8_t  *)JP8F_H(a, 1))')
                out.append('#define FM16(a) (*(JP8_MQ uint16_t *)JP8F_H(a, 2))')
                out.append('#define FM32(a) (*(JP8_MQ uint32_t *)JP8F_H(a, 4))')
                out.append('#define FM64(a) (*(JP8_MQ uint64_t *)JP8F_H(a, 8))')
                out.append('#define FMF(a)  (*(JP8_MQ float    *)JP8F_H(a, 4))')
                out.append('#define FMD(a)  (*(JP8_MQ double   *)JP8F_H(a, 8))')
                out.append('#define FMX(a)  (*(X *)JP8F_H(a, 16))')
                out.append('#define FMS8(a)  ((int64_t)(int8_t)FM8(a))')
                out.append('#define FMS16(a) ((int64_t)(int16_t)FM16(a))')
                out.append('#define FMS32(a) ((int64_t)(int32_t)FM32(a))')
                out.append('#define JF_LDX(d, a) memcpy((d), (const void *)JP8F_H(a, 16), 16)')
                out.append('#define JF_STX(a, s) memcpy(JP8F_H(a, 16), (s), 16)')
                out.append('#ifdef JP8_RELOC')
                out.append('#define JP8F_MOVSB(c_,s_,d_) do { while (c_) { FM8(d_) = FM8(s_); d_++; s_++; c_--; } } while (0)')
                out.append('#else')
                out.append('#define JP8F_MOVSB(c_,s_,d_) do { memcpy((void*)(uintptr_t)(d_),(const void*)(uintptr_t)(s_),'
                           '(size_t)(c_)); d_+=c_; s_+=c_; c_=0; } while (0)')
                out.append('#endif')
    text = '\n'.join(out)
    left = re.findall(r'\bR\(\d+\)|\bX[FDUQIL]\(\d+,|c->x\[|c->r\[', '\n'.join(
        l for l in out if not l.startswith('#') and 'CPU *c);' not in l))
    if left:
        die('%d register references left unrewritten (first: %s)' % (len(left), left[0]))
    open(sys.argv[2], 'w').write(text)
    nst = sum(len(f.st) for f in fns.values())
    print('jp8_fast: %d functions (%d allocator stubs), %d statements after %d calls inlined; flags %s' % (
        len(fns), len(allocs), nst, ninl, 'LOCAL (no flag live where functions meet)' if not sync_flags else
        'SYNCED through cg: %d functions fail the liveness proof, first: %s' % (len(bad), bad[0])))
    return 0


if __name__ == '__main__':
    sys.exit(main())
