#!/usr/bin/env python3
"""arm_xform.py -- turn a range of src/master_render.c into an engine B module,
MECHANICALLY.

WHY NOT BY HAND. The master's dispatch arms are 160 to 400 lines of decompiled
DSP each, and a hand transcription of that is a typo farm: the null would catch
it, but only after a debugging session per mistake. This rewrites every
`*(float *)(a1 + N)` into `c->kN` or `s->sN` from a cell classification, and it
REFUSES to emit anything while a single `a1 +` reference or unknown cell
remains. It is the same approach tools/translate_voice.py used for the original
port, and eb_delay_t23 -- 182 lines, 42 coefficients, 32 state cells -- compiled
and nulled EXACTLY 0 on its FIRST run because of it.

TWO WAYS THIS SCRIPT HAS ALREADY LIED, both found by checking its output rather
than trusting it. Check both on every new arm:

 1. LINE-BY-LINE MISSES MULTI-LINE ACCESSES. The ring-buffer READS in the
    type-2/3 arm span four source lines each, so a per-line regex left all four
    untouched -- and they still looked like valid C, so the transform "worked".
    The ring rewrite therefore runs on the JOINED text with re.S, and the
    a1-reference count at the end is what proves nothing was left behind.

 2. `a1 + (\\d+)` MATCHES THE 4 IN `4LL * v321 + 6396640`. The classifier duly
    reported a phantom coefficient "cell 4". Harmless here only because the ring
    rewrite runs first and consumes that text. Classify AFTER the ring forms are
    removed, or subtract the phantoms by hand and say so.

THE CLASSIFICATION IS THE INPUT, and it is the part that needs judgement:
  COEF   read in the block, written NOWHERE in the file      -> c->kN
  EXT    read in the block, written ELSEWHERE in the file    -> NOT a
         coefficient: cross-sample feedback from another block, and it must be
         an ARGUMENT (eb_master_in's 84672/84704 are the worked example)
  STATE  read AND written in the block                       -> s->sN
  W-ONLY written, never read in the block                    -> s->sN, and the
         null decides whether it was needed at all
Both accessors must be scanned. master_render.c copies with `_DWORD` exactly as
freely as voice_render.c copies with `JI`, and a one-accessor scan is how the
DCO oscillator levels came to be cached from per-sample cells.

USAGE
    arm_xform.py <first-line> <last-line>        classify only
    arm_xform.py <first-line> <last-line> --emit  print the transformed body
"""
import re, sys, os

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(REPO, "src", "master_render.c")

# Ring buffers: (index-cell, length-cell, base). Add a row per arm; the type-5
# arm has FOUR of these, which is why it is not a one-liner to port.
RINGS = [(6429408, 6429412, 6396640)]

# The type-5 arm's FOUR rings. Each ring's control pair sits immediately AFTER
# the PREVIOUS ring's data, so the index cell of a ring is nowhere near its own
# base -- read the write expression to pair them, never the addresses.
RINGS_E5 = [(101024, 101028, 96928)]

RINGS_T1 = [(6395248, 6395252, 4298096)]

RINGS_T5 = [(8594768,  8594772,  6497616),
            (10691936, 10691940, 8594784),
            (10726256, 10726260, 10693488),
            (10759040, 10759044, 10726272)]


def classify(lo, hi):
    L = open(SRC).read().split("\n")
    blk, whole = "\n".join(L[lo - 1:hi]), "\n".join(L)
    acc = r"\*\((?:float|_DWORD|_WORD|_BYTE) \*\)\(a1 \+ (\d+)\)"
    wr_blk = {int(m.group(1)) for m in re.finditer(acc + r"\s*=(?!=)", blk)}
    wr_all = {int(m.group(1)) for m in re.finditer(acc + r"\s*=(?!=)", whole)}
    cells, rd = set(), set()
    for m in re.finditer(r"a1 \+ (\d+)", blk):
        off = int(m.group(1))
        cells.add(off)
        if not re.match(r"\)\s*=(?!=)", blk[m.end():m.end() + 6]):
            rd.add(off)
    out = {"COEF": [], "EXT": [], "STATE": [], "WONLY": []}
    for c in sorted(cells):
        r, w = c in rd, c in wr_blk
        if r and w:        out["STATE"].append(c)
        elif r:            out["EXT" if c in wr_all else "COEF"].append(c)
        elif w:            out["WONLY"].append(c)
    return out


def carriers(lo, hi):
    """Locals IDA declares `int` that in fact carry FLOAT BIT PATTERNS.

    THE TRAP, and it is the port's own documented one (CLAUDE.md: "typed locals
    CONVERT instead of REINTERPRET"). The decompile writes

        v99 = *(_DWORD *)(a1 + 10692032);      /* bit copy out of a float cell */
        *(_DWORD *)(a1 + 10692064) = v99;      /* bit copy into another        */

    and declares v99 as `int`. Transcribe that literally with a float state
    field and BOTH assignments become numeric CONVERSIONS: the value is
    destroyed twice.

    MEASURED: this made the type-5 arm's v176 output exactly 0 on every sample
    while v177 -- which happened not to pass through a carrier -- tracked the
    port perfectly. The type-2/3 arm has one too (v253), and that module nulled
    EXACTLY 0 anyway, purely because the coefficient it carries holds a value
    the double conversion happens to round-trip. A latent bug that the data hid.

    A local is a carrier when EVERY use of it is a bare cell load or a bare cell
    store -- no arithmetic anywhere. Those are declared `float` in the generated
    module, so both copies stay bit-exact. Ring indices are NOT carriers: they
    are used in arithmetic, and the same test excludes them automatically.
    """
    L = open(SRC).read().split("\n")
    decls = "\n".join(L[:825])
    blk = "\n".join(L[lo - 1:hi])
    out = []
    for loc in sorted({x for x in re.findall(r"\bv\d+\b", blk)}):
        d = re.search(r"^\s*(.*?)\s+%s;" % loc, decls, re.M)
        t = d.group(1) if d else "?"
        if "float" in t or "double" in t:
            continue
        uses = [l for l in blk.split("\n") if re.search(r"\b%s\b" % loc, l)]
        if uses and all(
                re.fullmatch(r"\s*%s = \*\((?:_DWORD|float) \*\)\(a1 \+ \d+\);\s*"
                             % loc, u) or
                re.fullmatch(r"\s*\*\((?:_DWORD|float) \*\)\(a1 \+ \d+\) = %s;\s*"
                             % loc, u) for u in uses):
            out.append(loc)
    return out


def emit(lo, hi, cls, rings=None, ext=None):
    L = open(SRC).read().split("\n")
    blob = "\n".join(L[lo - 1:hi])
    for i, (idx, ln, base) in enumerate(rings if rings is not None else RINGS):
        rs = rings if rings is not None else RINGS
        tag = "" if len(rs) == 1 else str(i)
        # THE SUBTRAHEND IS NOT ALWAYS A PLAIN LOCAL. One type-5 read spells it
        # `(int)(float)(v55 * -16384.0)` inline, so a `(v\d+)` capture silently
        # leaves that access untouched -- and the result still compiles. The
        # capture is a non-greedy anything, and the refusal guard is what proves
        # every access was converted.
        blob = re.sub(
            r"\*\(_DWORD \*\)\(a1\s*\+\s*4\s*\*\s*\(\(\*\(int \*\)\(a1 \+ %d\)"
            r" - 1LL\)\s*&\s*\(\*\(_DWORD \*\)\(a1 \+ %d\) - (.+?) \+ (\d+)LL"
            r"\)\)\s*\+ %d\)" % (ln, idx, base),
            r"RINGR%s(s->s%d - (\1) + \2)" % (tag, idx), blob, flags=re.S)
        blob = re.sub(r"\*\(_DWORD \*\)\(a1 \+ 4LL \* (v\d+) \+ %d\)" % base,
                      r"RINGI%s(\1)" % tag, blob)
    known = {c: "c->k%d" % c for c in cls["COEF"]}
    # EXT cells are cross-block feedback: written by ANOTHER block in the same
    # sample, so they are ARGUMENTS. Passing a name here is what stops them
    # being frozen into a coefficient cache -- the eb_master_in 84672/84704
    # mistake, refused by construction.
    known.update(ext or {})
    known.update({c: "s->s%d" % c for c in cls["STATE"] + cls["WONLY"]})
    blob = re.sub(r"\*\((?:float|_DWORD|_WORD|_BYTE) \*\)\(a1 \+ (\d+)\)",
                  lambda m: known.get(int(m.group(1)),
                                      "/*UNKNOWN %s*/" % m.group(1)), blob)
    blob = re.sub(r"\*\(int \*\)\(a1 \+ (\d+)\)",
                  lambda m: known.get(int(m.group(1)),
                                      "/*UNKNOWN %s*/" % m.group(1)), blob)
    left = len(re.findall(r"a1 \+", blob))
    unk = blob.count("UNKNOWN")
    if left or unk:
        sys.stderr.write(
            "arm_xform: REFUSING TO EMIT -- %d a1 reference(s) and %d unknown "
            "cell(s) remain.\n  A transform that leaves either behind still "
            "produces valid-looking C, which is how the multi-line ring reads "
            "survived once.\n" % (left, unk))
        return None
    return blob


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    lo, hi = int(sys.argv[1]), int(sys.argv[2])
    cls = classify(lo, hi)
    if "--emit" in sys.argv:
        b = emit(lo, hi, cls, RINGS_T5 if "--t5" in sys.argv else RINGS_T1 if "--t1" in sys.argv else RINGS_E5 if "--e5" in sys.argv else None)
        if b is None:
            return 1
        print(b)
        return 0
    print("block %d-%d" % (lo, hi))
    car = carriers(lo, hi)
    print("  CARRIERS (int-declared, float bits -- MUST be float in the module):"
          " %s" % (car or "none"))
    for k in ("COEF", "EXT", "STATE", "WONLY"):
        print("  %-6s %3d  %s" % (k, len(cls[k]), cls[k]))
    if cls["EXT"]:
        print("  ** EXT cells are NOT coefficients. They are written elsewhere "
              "in the function, so they are cross-sample feedback and must be "
              "ARGUMENTS. **")
    return 0


if __name__ == "__main__":
    sys.exit(main())
