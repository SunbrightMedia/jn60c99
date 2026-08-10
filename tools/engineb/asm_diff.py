#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""asm_diff.py -- OPERATION-MULTISET diff of a hand-scheduled Xtensa .S file
against the compiler's own -S output.  Step A1 of
docs/engineb/ASM_KERNEL_WORKORDER.md.

PURPOSE
    The hand kernel (EB_VCF_ASM) is allowed to REORDER the compiler's
    instructions.  It is not allowed to change WHICH instructions run.  This
    script reads both files, throws away everything that reordering and
    register allocation are permitted to change, and compares what is left as
    a MULTISET.  It refuses retyped constants and dropped operations before a
    single flash is spent.

    Generate the reference exactly like this (the shipping fork flags MUST be
    present -- EB_VCF_DEADCOEF and EB_VCF_RES_LUT change the emitted code, and
    a reference built without them lies):

      xtensa-esp32s3-elf-gcc -S -O2 -flto -ffp-contract=off \
        -fno-strict-aliasing -std=c99 \
        -DEB_FORK_S3 -DEB_DCO_WT=1 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 \
        -DEB_VCF_RES_LUT=256 -DEB_ATREST_BLOCK=1 -DEB_ATREST_O1=1 \
        -DEB_ZEROCOEF=1 -DEB_EXP_MEMO=1 -DEB_HALF_OS_VCF=1 \
        -Iengine_b -Isrc -Iesp32s3/main engine_b/eb_vcf_ladder.c -o ref.s

    Usage:
      asm_diff.py REFERENCE.s CANDIDATE.S [--fn NAME]... [options]

CLASSES AND WHAT IS FATAL
    FUSED    madd.s / msub.s / any fused multiply-add.  ABSOLUTE FAIL, in
             either file, even if the multisets otherwise agree: the
             reference rounds twice, a fused op rounds once, so it cannot be
             bit-exact no matter how it is scheduled.
    FP       float arithmetic, conversions, compares, selects.  FATAL.
    LIT      .literal / .word / .long pool values.  FATAL (retyped constant).
    IMM      movi and friends -- instructions that materialise a constant.
             FATAL (retyped constant).
    MEM      loads and stores, offsets included.  FATAL (changed offset, or
             dropped/added access).  --allow-stack demotes sp-relative
             traffic to informational, for passes that legitimately remove
             spills.
    INT      integer ALU / address arithmetic.  FATAL.
    CALL     call/callx targets.  FATAL.
    CTRL     branches and jumps (targets ignored).  FATAL.
    MOVE     mov / mov.n / mov.s / wfr / rfr / wur / rur.  INFORMATIONAL by
             default: these are pure register plumbing and their count is a
             direct function of register allocation, which is allowed to
             differ.  --strict-moves makes them fatal.
    FRAME    entry / retw / retw.n.  Informational (frame size is allowed to
             differ).
    NOP      nop / nop.n and alignment.  Ignored -- "pure scheduling no-ops".

EXIT CODES
    0 PASS   1 FAIL   2 usage or parse error
"""

# =====================================================================
# WHAT THIS SCRIPT CANNOT PROVE  --  read this before quoting it
# =====================================================================
# It CANNOT prove that the ORDER of operations within a floating-point
# dependency chain is preserved.  It compares MULTISETS; order is exactly
# the thing it throws away, because reordering independent chains is the
# whole point of the hand kernel.
#
# Order changes WITHIN a chain change the rounding.  (a+b)+c and a+(b+c)
# are different float32 numbers; so are (a*b)*c and a*(b*c).  A candidate
# that reassociates one chain has an IDENTICAL multiset, and this script
# will report PASS.  That PASS is NOT a bit-exactness claim and must never
# be quoted as one.
#
# ONLY the on-silicon vector test (S2a in the work order: the C tick and
# the asm kernel run side by side over >=100,000 vectors on the board,
# full state structs compared bytewise every sample) can prove
# order-correctness -- together with S2b, the planted transposition, which
# proves S2a is able to fail at all.
#
# Three further things it does not check, stated so nobody assumes them:
#   1. BASE-REGISTER IDENTITY.  Register names are normalised away by
#      design, so `lsi f0,a2,20` and `lsi f0,a3,20` compare EQUAL.  The
#      offset is checked; which pointer it is added to is not.  (a1/sp is
#      the one exception: it is architecturally fixed, so stack traffic is
#      distinguished from pointer traffic.)
#   2. CONTROL-FLOW SHAPE.  Branch and jump targets are labels, and labels
#      are ignored.  A branch that keeps its opcode but jumps somewhere
#      else reads as identical here.
#   3. DYNAMIC counts.  This is a static listing diff.  Loop trip counts
#      and which side of a branch executes are outside its reach.
# =====================================================================

import argparse
import os
import re
import sys
from collections import Counter, OrderedDict

# ----------------------------------------------------------------------
# opcode classification
# ----------------------------------------------------------------------

# Fused multiply-add family.  Compared on the opcode's BASE (text before the
# first '.') so that madd.s, msub.s, maddn.s, nmadd.s ... are all caught.
FUSED_BASES = {
    "madd", "msub", "maddn", "nmadd", "nmsub", "fmadd", "fmsub",
    "madd_s", "msub_s",
}

FP_OPS = {
    # arithmetic
    "add.s", "sub.s", "mul.s", "div.s", "divn.s", "sqrt.s", "sqrt0.s",
    "neg.s", "abs.s", "recip.s", "recip0.s", "rsqrt.s", "rsqrt0.s",
    "addexp.s", "addexpm.s", "mkdadj.s", "mksadj.s", "divn.s", "const.s",
    # conversions
    "float.s", "ufloat.s", "trunc.s", "utrunc.s", "round.s", "ceil.s",
    "floor.s",
    # compares (write a boolean register)
    "oeq.s", "olt.s", "ole.s", "ueq.s", "ult.s", "ule.s", "un.s",
    # conditional selects -- semantics-carrying, not plumbing
    "movf.s", "movt.s", "moveqz.s", "movnez.s", "movltz.s", "movgez.s",
}

MEM_OPS = {
    "lsi", "lsiu", "lsx", "lsxu", "ssi", "ssiu", "ssx", "ssxu",
    "l32i", "l32i.n", "l32ai", "l16si", "l16ui", "l8ui",
    "s32i", "s32i.n", "s32ri", "s16i", "s8i",
    "l32e", "s32e",
}

# l32r is a load, but of a LITERAL POOL entry.  Handled specially: the
# literal is resolved to its value so that pool-label renaming is invisible
# and a retyped constant is not.
LIT_LOAD_OPS = {"l32r"}

IMM_OPS = {"movi", "movi.n", "const16", "const.s"}

MOVE_OPS = {
    "mov", "mov.n", "mov.s", "wfr", "rfr", "wur", "rur", "rsr", "wsr",
    "xsr", "moveqz", "movnez", "movltz", "movgez", "movf", "movt",
}

FRAME_OPS = {"entry", "retw", "retw.n", "ret", "ret.n"}

NOP_OPS = {"nop", "nop.n", "isync", "rsync", "esync", "dsync", "memw",
           "extw"}

CALL_OPS = {"call0", "call4", "call8", "call12",
            "callx0", "callx4", "callx8", "callx12"}

CTRL_PREFIXES = ("b",)   # beqz, bnez, bbci, bf, bt, bge, ...
CTRL_OPS = {"j", "j.l", "jx", "loop", "loopnez", "loopgtz"}

FATAL_CLASSES_DEFAULT = {"FUSED", "FP", "LIT", "IMM", "MEM", "INT", "CALL",
                         "CTRL"}

# ----------------------------------------------------------------------
# parsing
# ----------------------------------------------------------------------

REG_RE = re.compile(r"^(?:a(?:[0-9]|1[0-5])|f(?:[0-9]|1[0-5])|"
                    r"b(?:[0-9]|1[0-5])|m[0-3]|sp)$")
SP_RE = re.compile(r"^(?:sp|a1)$")
LABEL_DEF_RE = re.compile(r"^([A-Za-z_.$][\w.$]*)\s*:\s*(.*)$")
NUM_RE = re.compile(r"^[-+]?(?:0[xX][0-9a-fA-F]+|\d+)$")


def _strip_comments(line):
    # GAS for Xtensa: '#' starts a comment; gcc also emits '//' and
    # /* ... */ never appears in -S output but is cheap to allow.
    line = re.sub(r"/\*.*?\*/", " ", line)
    for mark in ("#", "//", ";"):
        idx = line.find(mark)
        if idx >= 0:
            line = line[:idx]
    return line


def _parse_int(tok):
    tok = tok.strip()
    if not NUM_RE.match(tok):
        return None
    try:
        return int(tok, 0)
    except ValueError:
        return None


def _split_operands(text):
    """Split an operand list on top-level commas."""
    out, depth, cur = [], 0, ""
    for ch in text:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


class Insn(object):
    __slots__ = ("op", "ops", "func", "lineno", "raw", "cls", "key")

    def __init__(self, op, ops, func, lineno, raw):
        self.op = op
        self.ops = ops
        self.func = func
        self.lineno = lineno
        self.raw = raw
        self.cls = None
        self.key = None

    def __repr__(self):
        return "%s %s" % (self.op, ",".join(self.ops))


class AsmFile(object):
    def __init__(self, path):
        self.path = path
        self._last_label = None
        self.literals = OrderedDict()   # name -> value (int or str)
        self.lit_values = []            # every pool value, incl. .word/.long
        self.insns = []
        self._parse()
        self._classify()

    # -- pass 1: text -> instructions + literal pool ---------------------
    def _parse(self):
        cur_func = None
        pending_labels = []
        with open(self.path, "r") as fh:
            lines = fh.readlines()

        for lineno, raw in enumerate(lines, 1):
            line = _strip_comments(raw).strip()
            while line:
                m = LABEL_DEF_RE.match(line)
                if not m:
                    break
                name, rest = m.group(1), m.group(2)
                # remembered so that a hand .S which builds its constant pool
                # as "label: .word VALUE" in .rodata resolves its l32r the
                # same way gcc's ".literal NAME, VALUE" does
                self._last_label = name
                if not name.startswith(".L"):
                    pending_labels.append(name)
                line = rest.strip()
            if not line:
                continue

            if line.startswith("."):
                self._directive(line, lineno)
                # .type NAME, @function names the function that follows
                mt = re.match(r"^\.type\s+([\w.$]+)\s*,\s*@function", line)
                if mt:
                    cur_func = mt.group(1)
                continue

            parts = line.split(None, 1)
            op = parts[0]
            ops = _split_operands(parts[1]) if len(parts) > 1 else []
            fn = cur_func
            if pending_labels:
                # a plain global label immediately before code: that is the
                # function name in hand-written .S that omits .type
                fn = pending_labels[-1]
                cur_func = fn
                pending_labels = []
            self.insns.append(Insn(op, ops, fn, lineno, line))

    def _directive(self, line, lineno):
        m = re.match(r"^\.literal\s+([\w.$]+)\s*,\s*(.+)$", line)
        if m:
            name, val = m.group(1), m.group(2).strip()
            iv = _parse_int(val)
            self.literals[name] = iv if iv is not None else val
            self.lit_values.append(self.literals[name])
            return
        m = re.match(r"^\.(?:word|long|int|float)\s+(.+)$", line)
        if m:
            first = True
            for tok in _split_operands(m.group(1)):
                iv = _parse_int(tok)
                val = iv if iv is not None else tok
                self.lit_values.append(val)
                if first and self._last_label:
                    self.literals.setdefault(self._last_label, val)
                    self._last_label = None
                first = False
            return

    # -- pass 2: normalise + classify ------------------------------------
    def _norm_operand(self, tok, op):
        if REG_RE.match(tok):
            if SP_RE.match(tok):
                return "<SP>"
            k = tok[0]
            return {"a": "<A>", "f": "<F>", "b": "<B>", "m": "<M>"}[k]
        iv = _parse_int(tok)
        if iv is not None:
            return str(iv)
        if op in LIT_LOAD_OPS and tok in self.literals:
            return "lit(%s)" % (self.literals[tok],)
        if tok.startswith(".L") or re.match(r"^\.?L\w+$", tok):
            return "<LBL>"
        return tok            # a real symbol: call target, extern, ...

    def _classify(self):
        for ins in self.insns:
            op = ins.op
            base = op.split(".")[0]
            ins.key = (op, tuple(self._norm_operand(o, op) for o in ins.ops))
            if base in FUSED_BASES:
                ins.cls = "FUSED"
            elif op in FP_OPS:
                ins.cls = "FP"
            elif op in LIT_LOAD_OPS:
                ins.cls = "LIT"
            elif op in IMM_OPS:
                ins.cls = "IMM"
            elif op in MEM_OPS:
                ins.cls = "MEM"
            elif op in CALL_OPS:
                ins.cls = "CALL"
            elif op in FRAME_OPS:
                ins.cls = "FRAME"
            elif op in NOP_OPS:
                ins.cls = "NOP"
            elif op in MOVE_OPS:
                ins.cls = "MOVE"
            elif op in CTRL_OPS or (op.startswith(CTRL_PREFIXES)
                                    and op not in MEM_OPS):
                ins.cls = "CTRL"
            else:
                ins.cls = "INT"

    # -- selection --------------------------------------------------------
    def functions(self):
        seen = OrderedDict()
        for ins in self.insns:
            if ins.func:
                seen[ins.func] = True
        return list(seen.keys())

    def select(self, fns):
        if not fns:
            return list(self.insns)
        return [i for i in self.insns if i.func in fns]


# ----------------------------------------------------------------------
# diffing
# ----------------------------------------------------------------------

def keystr(key):
    return "%-10s %s" % (key[0], ",".join(key[1]))


def _one_field_differs(a, b):
    """True if two keys share an opcode and arity and differ in exactly one
    operand, which is numeric on both sides.  Used only to phrase the
    finding ('offset changed' rather than 'one missing, one extra')."""
    if a[0] != b[0] or len(a[1]) != len(b[1]):
        return None
    diffs = [i for i in range(len(a[1])) if a[1][i] != b[1][i]]
    if len(diffs) != 1:
        return None
    i = diffs[0]
    x, y = a[1][i], b[1][i]
    if NUM_RE.match(x or "") and NUM_RE.match(y or ""):
        return (i, x, y)
    if x.startswith("lit(") and y.startswith("lit("):
        return (i, x, y)
    return None


CLASS_PHRASE = {
    "FP":   ("DROPPED ARITHMETIC OPERATION", "ADDED ARITHMETIC OPERATION",
             "ARITHMETIC OPERAND/IMMEDIATE CHANGED"),
    "MEM":  ("DROPPED MEMORY ACCESS", "ADDED MEMORY ACCESS",
             "LOAD/STORE OFFSET CHANGED"),
    "IMM":  ("DROPPED CONSTANT", "ADDED CONSTANT", "RETYPED CONSTANT"),
    "LIT":  ("DROPPED LITERAL LOAD", "ADDED LITERAL LOAD",
             "RETYPED CONSTANT (literal load)"),
    "INT":  ("DROPPED INTEGER OPERATION", "ADDED INTEGER OPERATION",
             "INTEGER IMMEDIATE CHANGED"),
    "CALL": ("DROPPED CALL", "ADDED CALL", "CALL CHANGED"),
    "CTRL": ("DROPPED BRANCH/JUMP", "ADDED BRANCH/JUMP", "BRANCH CHANGED"),
    "MOVE": ("fewer register moves", "extra register moves",
             "register move changed"),
    "FRAME": ("dropped frame op", "extra frame op", "frame size changed"),
}


def diff_class(cls, ref_keys, cand_keys, findings, fatal):
    missing = ref_keys - cand_keys          # in reference, not in candidate
    extra = cand_keys - ref_keys            # in candidate, not in reference
    if not missing and not extra:
        return
    drop_p, add_p, chg_p = CLASS_PHRASE.get(
        cls, ("DROPPED OPERATION", "ADDED OPERATION", "OPERATION CHANGED"))

    mlist = list(missing.elements())
    elist = list(extra.elements())
    paired = []
    for m in list(mlist):
        for e in list(elist):
            info = _one_field_differs(m, e)
            if info:
                paired.append((m, e, info))
                mlist.remove(m)
                elist.remove(e)
                break

    for m, e, (idx, old, new) in paired:
        findings.append((fatal, cls, chg_p,
                         "operand %d: %s -> %s" % (idx, old, new),
                         "  reference: %s\n  candidate: %s"
                         % (keystr(m), keystr(e))))
    for m in Counter(mlist).items():
        findings.append((fatal, cls, drop_p, "x%d" % m[1],
                         "  reference: %s\n  candidate: (absent)"
                         % keystr(m[0])))
    for e in Counter(elist).items():
        findings.append((fatal, cls, add_p, "x%d" % e[1],
                         "  reference: (absent)\n  candidate: %s"
                         % keystr(e[0])))


def run(ref_path, cand_path, fns, allow_stack, strict_moves, verbose):
    ref = AsmFile(ref_path)
    cand = AsmFile(cand_path)

    ref_i = ref.select(fns)
    cand_i = cand.select(fns)
    if not ref_i:
        sys.stderr.write("asm_diff: no instructions selected in %s\n"
                         % ref_path)
        return 2
    if not cand_i:
        sys.stderr.write("asm_diff: no instructions selected in %s\n"
                         % cand_path)
        return 2

    findings = []

    # ---- rule 0: fused multiply-add.  ABSOLUTE, checked in both files,
    # before and independently of any multiset comparison.
    for tag, insns in (("reference", ref_i), ("candidate", cand_i)):
        for ins in insns:
            if ins.cls == "FUSED":
                findings.append(
                    (True, "FUSED", "FUSED MULTIPLY-ADD PRESENT",
                     "%s rounds once; the reference rounds twice" % ins.op,
                     "  %s:%d (%s): %s" % (os.path.basename(
                         ref_path if tag == "reference" else cand_path),
                         ins.lineno, tag, ins.raw)))

    # ---- literal pool values (retyped constants that never reach an insn)
    lref = Counter(ref.lit_values)
    lcand = Counter(cand.lit_values)
    # The pool is file-scoped, so a whole-value comparison of it is only
    # meaningful on whole files.  Under --fn the l32r operands still carry
    # their resolved values, so a retyped constant that is actually LOADED is
    # still caught; a pool entry nothing loads is not.
    if not fns:
        for v, n in (lref - lcand).items():
            findings.append((True, "LIT", "RETYPED CONSTANT (pool value)",
                             "value %s missing from candidate (x%d)" % (v, n),
                             ""))
        for v, n in (lcand - lref).items():
            findings.append((True, "LIT", "RETYPED CONSTANT (pool value)",
                             "value %s not in reference (x%d)" % (v, n), ""))

    # ---- per-class multisets
    classes = ["FP", "LIT", "IMM", "MEM", "INT", "CALL", "CTRL", "MOVE",
               "FRAME"]
    counts = OrderedDict()
    for cls in classes + ["FUSED", "NOP"]:
        r = Counter(i.key for i in ref_i if i.cls == cls)
        c = Counter(i.key for i in cand_i if i.cls == cls)
        counts[cls] = (sum(r.values()), sum(c.values()))
        if cls in ("NOP", "FUSED"):
            continue           # NOP ignored by design; FUSED already handled
        if cls == "MEM" and allow_stack:
            rs = Counter(k for k in r.elements() if "<SP>" in k[1])
            cs = Counter(k for k in c.elements() if "<SP>" in k[1])
            r, c = r - rs, c - cs
            diff_class("MEM", rs, cs, findings, False)
        fatal = cls in FATAL_CLASSES_DEFAULT
        if cls in ("MOVE", "FRAME") and strict_moves:
            fatal = True
        diff_class(cls, r, c, findings, fatal)

    # ---- report
    print("=" * 72)
    print("asm_diff  reference : %s" % ref_path)
    print("          candidate : %s" % cand_path)
    print("          functions : %s"
          % (", ".join(fns) if fns else "ALL (%s | %s)"
             % (",".join(ref.functions()), ",".join(cand.functions()))))
    if fns:
        print("NOTE: --fn given, so the whole-pool .literal comparison is "
              "skipped;\n      only constants an l32r actually loads are "
              "compared.")
    print("=" * 72)
    print("  %-8s %8s %8s" % ("class", "ref", "cand"))
    for cls, (a, b) in counts.items():
        flag = "" if a == b else "   <-- differs"
        print("  %-8s %8d %8d%s" % (cls, a, b, flag))
    print("  %-8s %8d %8d" % ("TOTAL", len(ref_i), len(cand_i)))
    print("-" * 72)

    hard = [f for f in findings if f[0]]
    soft = [f for f in findings if not f[0]]

    if not findings:
        print("no differences in any compared class.")
    for tag, group in (("FAIL", hard), ("note", soft)):
        for fatal, cls, phrase, detail, ctx in group:
            print("%s [%s] %s: %s" % (tag, cls, phrase, detail))
            if ctx and verbose >= 0:
                print(ctx)
    print("-" * 72)
    if hard:
        print("VERDICT: FAIL  (%d hard finding%s, %d note%s)"
              % (len(hard), "" if len(hard) == 1 else "s",
                 len(soft), "" if len(soft) == 1 else "s"))
        print("REMINDER: a PASS here would still not prove order-correctness "
              "within an FP chain -- only the on-silicon vector test does.")
        return 1
    print("VERDICT: PASS  (operation multiset matches; %d note%s)"
          % (len(soft), "" if len(soft) == 1 else "s"))
    print("THIS IS NOT A BIT-EXACTNESS CLAIM.  The multiset matches; the")
    print("ORDER inside each FP dependency chain is NOT checked here and a")
    print("reassociated chain rounds differently.  Only the on-silicon")
    print("vector test (S2a, with its planted negative S2b) can prove that.")
    return 0


def main(argv):
    ap = argparse.ArgumentParser(
        description="operation-multiset diff of a hand .S against the "
                    "compiler's -S reference")
    ap.add_argument("reference")
    ap.add_argument("candidate")
    ap.add_argument("--fn", action="append", default=[],
                    help="restrict to this function symbol (repeatable); "
                         "default is every function in each file, compared "
                         "as one pool so that merged routines still diff")
    ap.add_argument("--allow-stack", action="store_true",
                    help="demote sp-relative load/store differences to notes "
                         "(for passes that legitimately remove spills)")
    ap.add_argument("--strict-moves", action="store_true",
                    help="make register-move and frame differences fatal")
    ap.add_argument("-q", "--quiet", action="store_const", dest="verbose",
                    const=-1, default=0)
    a = ap.parse_args(argv[1:])
    for p in (a.reference, a.candidate):
        if not os.path.exists(p):
            sys.stderr.write("asm_diff: no such file: %s\n" % p)
            return 2
    return run(a.reference, a.candidate, a.fn, a.allow_stack,
               a.strict_moves, a.verbose)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
