#!/usr/bin/env python3
"""jp8_xlane.py IN OUT -- the fast lift (jp8_fast.py's output) with every xmm register in THREE scalar C locals.

WHY (MEASURED 2026-10-12, HOST_LAYER.md SPEED): the fast pass keeps a function's xmm registers in locals of the union
X (jp8_cpu.h: float f[4], double d[2], uint32_t u[4], uint64_t q[2] ...). GCC cannot keep such a union in an SSE
register: it splits it into two 64-bit integer halves in general registers, so every scalar float instruction of the
guest pays a move to an xmm register, a move back, a mask and a merge -- a guest `addss` became 7 host instructions,
and the eight voice renders cost ~7,470 host instructions per voice per engine sample against the plugin's 3,632.

WHAT: each xmm local N (x0..x15, the temporaries t0, t1) becomes
    float    N_a     bits 0..31   (the scalar float lane: the guest's movss / addss / mulss / comiss work here)
    uint32_t N_b     bits 32..63
    uint64_t N_c     bits 64..127
and every access is rewritten to them: a float lane read / write is the float local itself; an integer view of lane
0 is a bit copy (memcpy: no conversion); a double or 64-bit view of lanes 0..1 is assembled from (a, b) and split back;
lanes 2..3 live in c. A whole register is assembled (jxl_mk) or split where it is copied, saved to the CPU struct or
moved to memory. Every bit is kept: a float is only ever moved, never converted, and the C memcpy / union reads are
bit copies. Any statement whose form this pass does not know -- a byte or word lane, an address taken elsewhere, an
xmm write inside an expression -- keeps its original text on a temporary X assembled from the lanes, and the lanes are
split back after it (the FALLBACK: exact, only slower). The pass changes no arithmetic, no memory access and no order.

Graded like the fast pass: the host gate (jp8_host_gate.sh) builds and grades its output; its tooth JP8_XLANE_TOOTH=1
swaps lanes a and b in every store of a register to the CPU struct (a scalar float then reaches the callee as 0, its
bits one lane up: a gate on the output must fail).
    python3 jp8/tools/jp8_xlane.py IN.c OUT.c       prints the rewrite counts
"""
import os
import re
import sys

TOOTH = os.environ.get('JP8_XLANE_TOOTH') == '1'
HDR = re.compile(r'^static void f_([0-9a-f]+)\(CPU \*restrict cg\) \{$')
XDECL = re.compile(r'\bX ((?:(?:x\d+|t[01])(?:, )?)+);')
ACC = r'\.(f|u|i|d|q|l)\[([0-3])\]'
ASSIGN_OPS = ('<<=', '>>=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '=')

PRE = r'''/* jp8_xlane.py: every xmm register in three scalars (a: bits 0..31 as float, b: bits 32..63, c: bits 64..127) --
 * bit copies only (memcpy, union reads): no value is converted */
static inline uint32_t jxl_fu(float f) { uint32_t u; memcpy(&u, &f, 4); return u; }
static inline float jxl_uf(uint32_t u) { float f; memcpy(&f, &u, 4); return f; }
static inline uint64_t jxl_q(float a, uint32_t b) { return (uint64_t)jxl_fu(a) | ((uint64_t)b << 32); }
static inline double jxl_qd(uint64_t q) { double d; memcpy(&d, &q, 8); return d; }
static inline uint64_t jxl_dq(double d) { uint64_t q; memcpy(&q, &d, 8); return q; }
static inline double jxl_d(float a, uint32_t b) { return jxl_qd(jxl_q(a, b)); }
static inline X jxl_mk(float a, uint32_t b, uint64_t c) { X x; x.f[0] = a; x.u[1] = b; x.q[1] = c; return x; }
'''


HEAD = re.compile(r'^(?:if\s*\(.*\)|else|switch\s*\(.*\)|while\s*\(.*\)|for\s*\(.*\)|do|[A-Za-z_]\w*\s*:|case\s+[^:]+:|default\s*:)$', re.S)


def paren_end(s, i):
    """the index after the parenthesis that closes the one at s[i]"""
    depth = 0
    for j in range(i, len(s)):
        if s[j] == '(':
            depth += 1
        elif s[j] == ')':
            depth -= 1
            if depth == 0:
                return j + 1
    raise ValueError('unbalanced: %r' % s)


def split_head(s):
    """'if (c) stmt' / 'else stmt' / 'L: stmt' -> (head, stmt); else (None, s)"""
    m = re.match(r'^(if|switch|while|for)\s*\(', s)
    if m:
        j = paren_end(s, s.index('(', m.start()))
        if s[j:].strip():
            return s[:j], s[j:].strip()
        return None, s
    m = re.match(r'^(else)\s+(.*)$', s, re.S)
    if m:
        return m.group(1), m.group(2)
    m = re.match(r'^((?:case\s+[^:]+|default|[A-Za-z_]\w*)\s*:)\s*(.+)$', s, re.S)
    if m and not s.startswith(('JF_', 'FMK')) and '?' not in m.group(1):
        return m.group(1), m.group(2)
    return None, s


def split_statements(body):
    """the body of a line -> tokens ('{',), ('}',), ('head', text) (a control head or a label: no ';' after it) or
    ('stmt', text) (a simple statement, its ';' dropped), at paren depth 0; string literals skipped"""
    out, cur, depth, i, n = [], [], 0, 0, len(body)

    def flush(before_brace):
        s = ''.join(cur).strip()
        while s:
            h, rest = split_head(s)
            if h is None:
                if before_brace and HEAD.match(s):
                    out.append(('head', s))
                elif before_brace:
                    raise ValueError('a statement before a block without its ";": %r' % s)
                else:
                    out.append(('stmt', s))
                return
            out.append(('head', h)); s = rest
    while i < n:
        ch = body[i]
        if ch == '"':
            j = i + 1
            while j < n and body[j] != '"':
                j += 2 if body[j] == '\\' else 1
            cur.append(body[i:j + 1]); i = j + 1; continue
        if ch in '([':
            depth += 1
        elif ch in ')]':
            depth -= 1
        if depth == 0 and ch in '{};':
            flush(ch == '{')
            if ch != ';':
                out.append((ch,))
            cur = []; i += 1; continue
        cur.append(ch); i += 1
    flush(False)
    return out


def top_assign(s):
    """(lhs, op, rhs) of a statement's top-level assignment, else None"""
    depth = 0; i = 0; n = len(s)
    while i < n:
        ch = s[i]
        if ch == '"':
            j = i + 1
            while j < n and s[j] != '"':
                j += 2 if s[j] == '\\' else 1
            i = j + 1; continue
        if ch in '([':
            depth += 1
        elif ch in ')]':
            depth -= 1
        elif ch == '=' and depth == 0:
            if i + 1 < n and s[i + 1] == '=':
                i += 2; continue
            if i > 0 and s[i - 1] in '=!<>' and not (i > 1 and s[i - 2:i] in ('<<', '>>')):
                i += 1; continue
            for op in ASSIGN_OPS:
                if s[:i + 1].endswith(op):
                    return s[:i + 1 - len(op)].strip(), op, s[i + 1:].strip()
        i += 1
    return None


class Fn:
    def __init__(self, names):
        self.names = names
        self.rx_name = re.compile(r'\b(' + '|'.join(sorted(names, key=len, reverse=True)) + r')\b(?![_\w])') if names else None
        self.stats = {}

    def bump(self, k):
        self.stats[k] = self.stats.get(k, 0) + 1

    def mentions(self, s):
        return bool(self.rx_name and self.rx_name.search(s))

    def read_lane(self, nm, k, i):
        a, b, c = nm + '_a', nm + '_b', nm + '_c'
        i = int(i)
        if k == 'f':
            return [a, 'jxl_uf(%s)' % b, 'jxl_uf((uint32_t)%s)' % c, 'jxl_uf((uint32_t)(%s >> 32))' % c][i]
        if k in 'ui':
            u = ['jxl_fu(%s)' % a, b, '((uint32_t)%s)' % c, '((uint32_t)(%s >> 32))' % c][i]
            return u if k == 'u' else '((int32_t)%s)' % u
        if i > 1:
            raise KeyError
        if k == 'd':
            return ['jxl_d(%s, %s)' % (a, b), 'jxl_qd(%s)' % c][i]
        q = ['jxl_q(%s, %s)' % (a, b), c][i]
        return q if k == 'q' else '((int64_t)%s)' % q

    def reads(self, expr):
        """every xmm read of an expression rewritten to the lanes; None if a form is not known"""
        if re.search(r'\b(?:%s)\.(?:w|b)\[' % '|'.join(self.names), expr) or \
                re.search(r'(?:^|[^\w)\]\s])\s*&\s*(?:%s)\b' % '|'.join(self.names), expr):   # a unary & (not a bitwise and)
            return None
        bad = []

        def lane(m):
            try:
                return self.read_lane(m.group(1), m.group(2), m.group(3))
            except (KeyError, IndexError):
                bad.append(m.group(0)); return m.group(0)
        e = re.sub(r'\b(%s)%s' % ('|'.join(self.names), ACC), lane, expr)
        if bad:
            return None
        e = self.rx_name.sub(lambda m: 'jxl_mk(%s_a, %s_b, %s_c)' % ((m.group(1),) * 3), e)
        return e

    def write_lane(self, nm, k, i, val):
        a, b, c = nm + '_a', nm + '_b', nm + '_c'
        i = int(i)
        if k == 'f':
            return ['%s=(%s)' % (a, val), '%s=jxl_fu(%s)' % (b, val),
                    '%s=(%s & 0xFFFFFFFF00000000ULL) | (uint64_t)jxl_fu(%s)' % (c, c, val),
                    '%s=(%s & 0xFFFFFFFFULL) | ((uint64_t)jxl_fu(%s) << 32)' % (c, c, val)][i]
        if k in 'ui':
            v = '(uint32_t)(%s)' % val
            return ['%s=jxl_uf(%s)' % (a, v), '%s=%s' % (b, v),
                    '%s=(%s & 0xFFFFFFFF00000000ULL) | (uint64_t)%s' % (c, c, v),
                    '%s=(%s & 0xFFFFFFFFULL) | ((uint64_t)%s << 32)' % (c, c, v)][i]
        if i > 1:
            raise KeyError
        if k == 'd':
            if i == 0:
                return '{ uint64_t jxl_t = jxl_dq(%s); %s=jxl_uf((uint32_t)jxl_t); %s=(uint32_t)(jxl_t >> 32); }' % (val, a, b)
            return '%s=jxl_dq(%s)' % (c, val)
        if i == 0:
            return '{ uint64_t jxl_t = (uint64_t)(%s); %s=jxl_uf((uint32_t)jxl_t); %s=(uint32_t)(jxl_t >> 32); }' % (val, a, b)
        return '%s=(uint64_t)(%s)' % (c, val)

    def fallback(self, s):
        used = sorted(set(m.group(1) for m in self.rx_name.finditer(s)), key=lambda x: (x[0], int(x[1:])))
        self.bump('fallback')
        pre = ' '.join('X %s = jxl_mk(%s_a, %s_b, %s_c);' % ((nm,) * 4) for nm in used)
        post = ' '.join('%s_a=%s.f[0]; %s_b=%s.u[1]; %s_c=%s.q[1];' % ((nm,) * 6) for nm in used)
        return '{ %s %s; %s }' % (pre, s, post)

    def stmt(self, s):
        if not self.mentions(s):
            return s
        if s in ('(void)%s' % nm for nm in self.names):
            nm = s[6:]
            self.bump('void')
            return '(void)%s_a; (void)%s_b; (void)%s_c' % (nm, nm, nm)
        m = re.match(r'^JF_LDXK\((\d+), &(%s),(.*)\)$' % '|'.join(self.names), s)
        if m and not self.mentions(m.group(3)):
            nm = m.group(2); self.bump('ldx')
            return '{ X jxl_v; JF_LDXK(%s, &jxl_v,%s); %s_a=jxl_v.f[0]; %s_b=jxl_v.u[1]; %s_c=jxl_v.q[1]; }' % (m.group(1), m.group(3), nm, nm, nm)
        m = re.match(r'^JF_STXK\((\d+), (.*),&(%s)\)$' % '|'.join(self.names), s)
        if m and not self.mentions(m.group(2)):
            nm = m.group(3); self.bump('stx')
            return '{ X jxl_v = jxl_mk(%s_a, %s_b, %s_c); JF_STXK(%s, %s,&jxl_v); }' % (nm, nm, nm, m.group(1), m.group(2))
        asg = top_assign(s)
        if asg is None:
            e = self.reads(s)
            if e is None or re.search(r'\b(?:%s)%s\s*(?:<<|>>|[-+*/%%&|^])?=(?!=)' % ('|'.join(self.names), ACC), s):
                return self.fallback(s)
            self.bump('read')
            return e
        lhs, op, rhs = asg
        mm = re.match(r'^(%s)%s$' % ('|'.join(self.names), ACC), lhs)
        mw = re.match(r'^(%s)$' % '|'.join(self.names), lhs)
        if re.search(r'\b(?:%s)%s\s*(?:<<|>>|[-+*/%%&|^])?=(?!=)' % ('|'.join(self.names), ACC), rhs):
            return self.fallback(s)                                  # an xmm write inside the expression
        if mm:
            nm, k, i = mm.group(1), mm.group(2), mm.group(3)
            # the movss load / store as a float move: the same bits, one host instruction
            if op == '=' and k == 'u' and i == '0':
                ml = re.match(r'^FMK32\((\d+), (.*)\)$', rhs)
                if ml and not self.mentions(ml.group(2)):
                    self.bump('movss load')
                    return '%s_a=FMKF(%s, %s)' % (nm, ml.group(1), ml.group(2))
            r = self.reads(rhs)
            if r is None:
                return self.fallback(s)
            if op != '=':
                cur = self.reads(lhs)
                if cur is None:
                    return self.fallback(s)
                r = '(%s) %s (%s)' % (cur, op[:-1], r)
            try:
                out = self.write_lane(nm, k, i, r)
            except (KeyError, IndexError):
                return self.fallback(s)
            self.bump('lane write')
            return out
        if mw:
            nm = mw.group(1)
            if op != '=':
                return self.fallback(s)
            ms = re.match(r'^(%s)$' % '|'.join(self.names), rhs)
            if ms:
                src = ms.group(1); self.bump('copy')
                return '%s_a=%s_a; %s_b=%s_b; %s_c=%s_c' % (nm, src, nm, src, nm, src)
            mc = re.match(r'^cg->x\[(\d+)\]$', rhs)
            if mc:
                k = mc.group(1); self.bump('load cg')
                return '%s_a=cg->x[%s].f[0]; %s_b=cg->x[%s].u[1]; %s_c=cg->x[%s].q[1]' % (nm, k, nm, k, nm, k)
            r = self.reads(rhs)
            if r is None:
                return self.fallback(s)
            self.bump('whole write')
            return '{ X jxl_v = %s; %s_a=jxl_v.f[0]; %s_b=jxl_v.u[1]; %s_c=jxl_v.q[1]; }' % (r, nm, nm, nm)
        mc = re.match(r'^cg->x\[(\d+)\]$', lhs)
        if mc and op == '=':
            ms = re.match(r'^(%s)$' % '|'.join(self.names), rhs)
            if ms:
                k, src = mc.group(1), ms.group(1); self.bump('store cg')
                if TOOTH:                       # lanes a and b swapped in every store: a float value always moves
                    Fn.tooth_planted = True
                    return 'cg->x[%s].f[0]=jxl_uf(%s_b); cg->x[%s].u[1]=jxl_fu(%s_a); cg->x[%s].q[1]=%s_c' % (k, src, k, src, k, src)
                return 'cg->x[%s].f[0]=%s_a; cg->x[%s].u[1]=%s_b; cg->x[%s].q[1]=%s_c' % (k, src, k, src, k, src)
        # a store of a float lane to guest memory: a float move (movss's store)
        if op == '=' and re.match(r'^FMK32\((\d+), (.*)\)$', lhs):
            ms = re.match(r'^(%s)\.u\[0\]$' % '|'.join(self.names), rhs)
            ml = re.match(r'^FMK32\((\d+), (.*)\)$', lhs)
            if ms and not self.mentions(ml.group(2)):
                self.bump('movss store')
                return 'FMKF(%s, %s)=%s_a' % (ml.group(1), ml.group(2), ms.group(1))
        l2 = self.reads(lhs); r2 = self.reads(rhs)
        if l2 is None or r2 is None:
            return self.fallback(s)
        self.bump('other write')
        return '%s%s%s' % (l2, op, r2)


def rewrite_line(fn, line):
    m = re.match(r'^(\s*/\*.*?\*/ ?)(.*)$', line)
    head, body = (m.group(1), m.group(2)) if m else (re.match(r'^(\s*)', line).group(1), line.strip())
    if not fn.mentions(body):
        return line
    parts = []
    for tok in split_statements(body):
        if len(tok) == 1:
            parts.append(tok[0])
        elif tok[0] == 'head':
            h = tok[1]
            if fn.mentions(h):
                r = fn.reads(h)
                if r is None:
                    raise SystemExit('jp8_xlane: a control head this pass cannot rewrite: %r' % h)
                h = r; fn.bump('head read')
            parts.append(h)
        else:
            parts.append(fn.stmt(tok[1]) + ';')
    return head + ' '.join(parts)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    lines = open(src).read().split('\n')
    out = []; i = 0; nfn = 0; tot = {}
    inc_done = False
    while i < len(lines):
        line = lines[i]
        if not inc_done and line.startswith('#include "jp8_cpu.h"'):
            out.append(line); out.append(PRE.rstrip('\n')); inc_done = True; i += 1; continue
        if HDR.match(line):
            # the function: up to the line '}' at column 0
            j = i + 1
            while j < len(lines) and lines[j] != '}':
                j += 1
            body = lines[i + 1:j]
            names = []
            for b in body:
                for d in XDECL.finditer(b):
                    names += [x.strip() for x in d.group(1).split(',')]
            fn = Fn(names)
            out.append(line)
            for b in body:
                if names and XDECL.search(b):
                    def decl(d):
                        ns = [x.strip() for x in d.group(1).split(',')]
                        return 'float %s; uint32_t %s; uint64_t %s;' % (', '.join(n + '_a' for n in ns), ', '.join(n + '_b' for n in ns),
                                                                          ', '.join(n + '_c' for n in ns))
                    b = XDECL.sub(decl, b)
                    b = re.sub(r'\(void\)(x\d+|t[01]);', lambda m: '(void)%s_a; (void)%s_b; (void)%s_c;' % ((m.group(1),) * 3), b)
                    out.append(b); continue
                out.append(rewrite_line(fn, b) if names else b)
            out.append('}')
            for k, v in fn.stats.items():
                tot[k] = tot.get(k, 0) + v
            nfn += 1; i = j + 1; continue
        out.append(line); i += 1
    if not inc_done:
        raise SystemExit('jp8_xlane: no #include "jp8_cpu.h" to put the helpers after')
    if TOOTH and not getattr(Fn, 'tooth_planted', False):
        raise SystemExit('jp8_xlane: the tooth found no store of a register to the CPU struct')
    open(dst, 'w').write('\n'.join(out))
    print('jp8_xlane: %d functions; %s%s' % (nfn, ', '.join('%s %d' % kv for kv in sorted(tot.items(), key=lambda kv: -kv[1])),
                                            '; TOOTH planted' if TOOTH else ''))


if __name__ == '__main__':
    main()
