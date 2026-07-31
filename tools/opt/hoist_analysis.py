#!/usr/bin/env python3
"""hoist_analysis.py — how much of juno_voice_render is BLOCK-INVARIANT?

Block-level loop-invariant hoisting only pays if a meaningful share of the
per-sample work depends solely on cells that cannot change during a block. This
measures that share BEFORE any code is touched, so the decision to do the work
(or not) rests on a number rather than on optimism.

METHOD (static, conservative)
  1. A voice-state cell is VARIANT if juno_voice_render ever writes it (envelope
     accumulators, filter state, DCO phase, ...). Otherwise it is a patch
     coefficient: nothing inside the render loop can change it, and the host can
     only change it between juno_gui_render() calls. Those are INVARIANT.
  2. A local is INVARIANT if every input on its right-hand side is an invariant
     cell, a numeric literal, or another invariant local. Iterate to fixpoint.
  3. Conservatism, deliberately erring toward "not hoistable":
       - a local assigned more than once  -> VARIANT (the decompile is not SSA;
         re-assignment across gotos/branches makes single-definition reasoning
         unsound, so we simply refuse those)
       - any call except the known-pure helpers -> VARIANT
       - anything read through `base` that is written anywhere -> VARIANT
  4. Weight by arithmetic operator count, not by statement count: hoisting a
     20-operation expression is worth twenty times hoisting a copy.

The output is an UPPER BOUND on the win from pure invariant hoisting. It says
nothing about what a real transformation costs to verify -- that is what the
existing bit-exact gates are for.
"""
import re, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRC = os.path.join(REPO, "src", "voice_render.c")

# Helpers with no state and no side effects: invariant if their arguments are.
PURE = {"juno_triangle", "juno_wrap24", "juno_wrap_unit", "juno_wrap_hi",
        "juno_pitch_poly", "fabs", "fabsf", "sqrt", "sqrtf", "expf", "fmodf",
        "bits_from_f32", "f32_from_bits"}


def strip_comments(s):
    s = re.sub(r'/\*.*?\*/', ' ', s, flags=re.S)
    s = re.sub(r'//[^\n]*', ' ', s)
    return s


def main():
    src = strip_comments(open(SRC).read())
    # isolate the function body
    i = src.index("uint32_t juno_voice_render(")
    body = src[i:]

    written_a1 = set(re.findall(r'J[FI]\(\s*a1\s*,\s*(\d+)\s*\)\s*=(?!=)', body))
    written_base = set(re.findall(r'J[FI]\(\s*base\s*,\s*(\d+)\s*\)\s*=(?!=)', body))

    # statements: LHS = RHS;   (skip == comparisons)
    stmts = re.findall(r'([A-Za-z_][A-Za-z0-9_]*|J[FI]\([^)]*\))\s*=(?!=)\s*([^;]+);', body)

    assign_count = {}
    for lhs, _ in stmts:
        assign_count[lhs] = assign_count.get(lhs, 0) + 1

    deps, rhs_of = {}, {}
    for lhs, rhs in stmts:
        if not re.fullmatch(r'v\d+', lhs):
            continue
        d = set()
        ok = True
        for cell in re.findall(r'J[FI]\(\s*a1\s*,\s*(\d+)\s*\)', rhs):
            d.add(("a1", cell))
        for cell in re.findall(r'J[FI]\(\s*base\s*,\s*(\d+)\s*\)', rhs):
            d.add(("base", cell))
        for loc in re.findall(r'\bv\d+\b', rhs):
            d.add(("loc", loc))
        for fn in re.findall(r'\b([A-Za-z_][A-Za-z0-9_]*)\s*\(', rhs):
            if fn in ("float", "int", "unsigned", "double", "_DWORD", "JF", "JI"):
                continue
            if fn not in PURE:
                ok = False
        if lhs in deps:            # multiply assigned -> refuse
            ok = False
        deps[lhs] = (d, ok)
        rhs_of[lhs] = rhs

    # fixpoint
    inv = set()
    changed = True
    while changed:
        changed = False
        for lhs, (d, ok) in deps.items():
            if lhs in inv or not ok or assign_count.get(lhs, 0) > 1:
                continue
            good = True
            for kind, val in d:
                if kind == "a1" and val in written_a1: good = False; break
                if kind == "base" and val in written_base: good = False; break
                if kind == "loc" and val != lhs and val not in inv: good = False; break
                if kind == "loc" and val == lhs: good = False; break
            if good:
                inv.add(lhs); changed = True

    def ops(expr):
        return len(re.findall(r'[+\-*/]', expr))

    tot_locals = len(deps)
    tot_ops = sum(ops(rhs_of[k]) for k in deps)
    inv_ops = sum(ops(rhs_of[k]) for k in inv)
    multi = sum(1 for k in deps if assign_count.get(k, 0) > 1)

    print("juno_voice_render — block-invariance analysis")
    print("  voice cells written (VARIANT)      : %d" % len(written_a1))
    print("  single-assignment local statements : %d" % tot_locals)
    print("  refused: multiply-assigned locals  : %d" % multi)
    print()
    print("  INVARIANT locals   : %4d / %4d  = %5.1f%%"
          % (len(inv), tot_locals, 100.0 * len(inv) / max(tot_locals, 1)))
    print("  INVARIANT arith ops: %4d / %4d  = %5.1f%%   <- the hoistable share"
          % (inv_ops, tot_ops, 100.0 * inv_ops / max(tot_ops, 1)))
    print()
    if inv:
        top = sorted(inv, key=lambda k: -ops(rhs_of[k]))[:10]
        print("  largest hoistable expressions:")
        for k in top:
            e = re.sub(r'\s+', ' ', rhs_of[k])[:88]
            print("    %-6s %2d ops  %s" % (k, ops(rhs_of[k]), e))
    return 0


if __name__ == '__main__':
    sys.exit(main())
