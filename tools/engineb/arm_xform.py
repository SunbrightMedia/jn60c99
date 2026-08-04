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


def emit(lo, hi, cls):
    L = open(SRC).read().split("\n")
    blob = "\n".join(L[lo - 1:hi])
    for i, (idx, ln, base) in enumerate(RINGS):
        tag = "" if len(RINGS) == 1 else str(i)
        blob = re.sub(
            r"\*\(_DWORD \*\)\(a1\s*\+\s*4\s*\*\s*\(\(\*\(int \*\)\(a1 \+ %d\)"
            r" - 1LL\)\s*&\s*\(\*\(_DWORD \*\)\(a1 \+ %d\) - (v\d+) \+ (\d+)LL"
            r"\)\)\s*\+ %d\)" % (ln, idx, base),
            r"RINGR%s(s->s%d - \1 + \2)" % (tag, idx), blob, flags=re.S)
        blob = re.sub(r"\*\(_DWORD \*\)\(a1 \+ 4LL \* (v\d+) \+ %d\)" % base,
                      r"RINGI%s(\1)" % tag, blob)
    known = {c: "c->k%d" % c for c in cls["COEF"]}
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
        b = emit(lo, hi, cls)
        if b is None:
            return 1
        print(b)
        return 0
    print("block %d-%d" % (lo, hi))
    for k in ("COEF", "EXT", "STATE", "WONLY"):
        print("  %-6s %3d  %s" % (k, len(cls[k]), cls[k]))
    if cls["EXT"]:
        print("  ** EXT cells are NOT coefficients. They are written elsewhere "
              "in the function, so they are cross-sample feedback and must be "
              "ARGUMENTS. **")
    return 0


if __name__ == "__main__":
    sys.exit(main())
