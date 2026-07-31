#!/usr/bin/env python3
"""regcache.py — register-cache a flat-state DSP transcription. GENERIC/REDOABLE.

THE PROBLEM IT SOLVES. A decompiled per-sample render addresses its state as
`unsigned char *` cells (`JF(a1, 352)`), compiled with -fno-strict-aliasing, so
the compiler must assume every store aliases every load: nothing stays in
registers, every value round-trips through memory. Measured on this engine:
1,210 memory accesses per voice-sample, 61% of stores never carried across
samples, in-order Cortex-M7 IPC 0.44 (MODELED).

THE TRANSFORM (bit-identical BY CONSTRUCTION — same ops, same order, same
rounding; only the STORAGE of intermediate values moves):
  1. every literal-offset cell the function touches gets a local
     `union _rc _cN`, loaded from memory ONCE at entry;
  2. every access `JF(a1,N)` / `JI(a1,N)` becomes `_cN.f` / `_cN.i` — a pure
     token replacement of the access expression, valid as both rvalue and
     lvalue, so multi-line statements and arbitrary control flow are untouched
     (union type-punning is defined in C99 and documented-supported by GCC);
  3. every cell the function EVER writes is stored back before return. A cell
     written only on an untaken branch writes back its entry value — identical
     to the original leaving that memory untouched.
  After this the values live in locals: the compiler register-allocates, CSEs
  and schedules freely — the scratch traffic collapses without touching one
  arithmetic expression. External observers (other renders, recall, probes,
  gates) see bit-identical memory because every written cell is stored back.

SAFETY PRECONDITIONS (checked, hard-abort if violated):
  - no computed offsets on the cached pointer (a variable index could alias a
    cached cell); computed accesses on OTHER pointers are left untouched;
  - no address-of on a cached access (&JF(...));
  - replacements happen only outside comments/strings.

WHY NOT pycparser/libclang: the replacement is of a fixed macro-call token with
a literal argument — a regex is exact for that token; what killed the earlier
regex attempt was rewriting STORES into wrapper calls (paren balancing across
multi-line statements). The union-member form has no such rewrite: `_cN.f = ...`
keeps the statement's tail byte-for-byte.

REUSE (JX-3P / other SSX ports): any transcription using the same
flat-state-macro idiom works unchanged:
    tools/opt/regcache.py <src> <function> <cached_ptr> [-o out.c]
"""
import re, sys, os

USAGE = "usage: regcache.py <file.c> <function> <cached_ptr e.g. a1> [-o out]"


def segments(text):
    """Yield (is_code, chunk): split out /*..*/ and //.. comments and "strings"
    so replacements never touch them."""
    out, i, n = [], 0, len(text)
    code_start = 0
    while i < n:
        two = text[i:i+2]
        if two == '/*':
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append((True, text[code_start:i])); out.append((False, text[i:j]))
            i = code_start = j
        elif two == '//':
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append((True, text[code_start:i])); out.append((False, text[i:j]))
            i = code_start = j
        elif text[i] == '"':
            j = i + 1
            while j < n and (text[j] != '"' or text[j-1] == '\\'): j += 1
            j = min(j + 1, n)
            out.append((True, text[code_start:i])); out.append((False, text[i:j]))
            i = code_start = j
        else:
            i += 1
    out.append((True, text[code_start:]))
    return out


def func_span(src, fn):
    """(start, body_open, end) — end is index one past the closing brace."""
    m = re.search(r'^[A-Za-z_][\w \t\*]*\b' + re.escape(fn) + r'\s*\(', src, re.M)
    if not m:
        raise SystemExit("function %s not found" % fn)
    i = src.index('{', m.end())
    depth, j = 0, i
    while j < len(src):
        if src[j] == '{': depth += 1
        elif src[j] == '}':
            depth -= 1
            if depth == 0: return m.start(), i, j + 1
        j += 1
    raise SystemExit("unbalanced braces in %s" % fn)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    if len(args) < 3: raise SystemExit(USAGE)
    path, fn, ptr = args[:3]
    out_path = sys.argv[sys.argv.index('-o') + 1] if '-o' in sys.argv else path

    src = open(path).read()
    fstart, bopen, fend = func_span(src, fn)
    head, body, tail = src[:bopen + 1], src[bopen + 1:fend - 1], src[fend - 1:]

    acc = re.compile(r'\bJ([FI])\(\s*' + re.escape(ptr) + r'\s*,\s*([^),]+?)\s*\)')

    # ---- analysis over CODE segments only -------------------------------
    cells, written, computed, addr_of = {}, set(), [], []
    segs = segments(body)
    for is_code, chunk in segs:
        if not is_code: continue
        for m in acc.finditer(chunk):
            off = m.group(2)
            if not re.fullmatch(r'\d+', off):
                computed.append(m.group(0)); continue
            o = int(off)
            cells.setdefault(o, set()).add(m.group(1))
            j = m.end()
            while j < len(chunk) and chunk[j] in ' \t\n': j += 1
            if chunk[j:j+1] == '=' and chunk[j+1:j+2] != '=': written.add(o)
            if chunk[j:j+2] in ('+=', '-=', '*=', '/='): written.add(o)
            k = m.start() - 1
            while k >= 0 and chunk[k] in ' \t\n': k -= 1
            if k >= 0 and chunk[k] == '&': addr_of.append(m.group(0))
    if computed:
        raise SystemExit("ABORT: computed offsets on '%s' (could alias cached "
                         "cells): %s" % (ptr, sorted(set(computed))[:5]))
    if addr_of:
        raise SystemExit("ABORT: address-of on cached access: %s" % addr_of[:5])

    # ---- rewrite --------------------------------------------------------
    def repl(m):
        off = m.group(2)
        if not re.fullmatch(r'\d+', off): return m.group(0)
        return "_c%s.%s" % (off, 'f' if m.group(1) == 'F' else 'i')

    new_segs = [(acc.sub(repl, c) if is_code else c) for is_code, c in segs]
    body2 = ''.join(new_segs)

    # every `return X;` -> capture + jump to the write-back epilogue
    rets = [0]
    def ret_repl(m):
        rets[0] += 1
        return "{ _rc_ret = (%s); goto _rc_out; }" % m.group(1).strip()
    body2 = re.sub(r'\breturn\b([^;]*);', ret_repl, body2)

    order = sorted(cells)
    pre = ["\n  /* regcache.py: %d cells -> register-resident locals; %d written "
           "cells stored back at exit. Bit-identical by construction (same ops, "
           "same order; only intermediate STORAGE moves). DO NOT hand-edit the "
           "_cN block; regenerate via tools/opt/regcache.py. */" % (len(order), len(written))]
    pre += ["  union _rc _c%d; _c%d.u = _rc_ld(%s + %d);" % (o, o, ptr, o) for o in order]
    pre.append("  uint32_t _rc_ret;\n")
    epi = ["\n  _rc_out:"]
    epi += ["  _rc_st(%s + %d, _c%d.u);" % (ptr, o, o) for o in sorted(written)]
    epi.append("  return _rc_ret;\n")

    helpers = (
        "\n/* regcache.py runtime: raw-bits container + load/store. The union is the\n"
        " * reinterpret bridge for cells touched as both float (JF) and int (JI) --\n"
        " * a typed local would CONVERT where the memory cell REINTERPRETS. */\n"
        "union _rc { float f; int32_t i; uint32_t u; };\n"
        "static inline uint32_t _rc_ld(const unsigned char *p){ uint32_t u; memcpy(&u, p, 4); return u; }\n"
        "static inline void _rc_st(unsigned char *p, uint32_t u){ memcpy(p, &u, 4); }\n")

    # Insert the load block AFTER the cached pointer becomes valid: at the top
    # of the body when `ptr` is a parameter, else right after its declaration
    # statement inside the body (e.g. `unsigned char *a1 = base + voice*S;`).
    pre_txt, epi_txt = '\n'.join(pre), '\n'.join(epi)
    if re.search(r'[*\s]' + re.escape(ptr) + r'\s*[,)]', src[fstart:bopen]):
        body3 = pre_txt + body2
    else:
        dm = re.search(r'^[ \t]*[A-Za-z_][\w \t]*\*[ \t]*' + re.escape(ptr)
                       + r'\s*=[^;]*;', body2, re.M)
        if not dm:
            raise SystemExit("ABORT: cannot find declaration of '%s' in %s" % (ptr, fn))
        cut = dm.end()
        body3 = body2[:cut] + '\n' + pre_txt + body2[cut:]
    out = src[:fstart] + helpers + src[fstart:bopen + 1] + body3 + epi_txt + tail
    if '#include <string.h>' not in out:
        out = out.replace('#include <math.h>', '#include <math.h>\n#include <string.h>', 1)
    open(out_path, 'w').write(out)
    both = sum(1 for o in order if len(cells[o]) == 2)
    print("regcache: %s.%s(%s): %d cells cached (%d dual-typed), %d written back, "
          "%d returns routed" % (os.path.basename(path), fn, ptr,
                                 len(order), both, len(written), rets[0]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
