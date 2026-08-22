#!/usr/bin/env python3
"""translate_jx_voice.py -- mechanical transcription of the JX voice render.

INPUT: the arm0 decompile (sub_1803A22C0) + jx3p/gen/voice_cell_model.json (the
verified per-position offset model: offset = a + b*voice, arms 3/7 rebuilt
exactly). OUTPUT: jx3p/src/jx_voice_render.c -- ONE C99 function covering all
8 per-voice arm clones, `jx_voice_render(st, v, a2)`.

METHOD (the project's proven one, minimal transformation):
  * every `a1 + N` occurrence is replaced POSITIONALLY from the model (16 arm0
    offsets appear with two strides, so value-keyed replacement would be wrong);
  * the decompile's own access types are KEPT VERBATIM (_DWORD loads stay
    uint32_t) so bit copies remain bit copies -- the carrier trap cannot arise;
  * __m128 lane-0 floor idiom -> exact scalar equivalent via bit views (the
    JUNO's src/voice_render.c precedent);
  * helper calls sub_XXXX -> jx_h_XXXX (shared across all arms, transcribed in
    jx_voice_helpers.c);
  * REFUSAL GUARD: any remaining `a1`, `_mm_`, `m128` or `sub_1` reference
    aborts the emit -- a partial transform still looks like valid C.
"""
import re, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DUMP = "/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/jxdump2"
SRC  = os.path.join(DUMP, "fn_sub_1803A22C0_1803A22C0.c")
MODEL= os.path.join(REPO, "jx3p", "gen", "voice_cell_model.json")
OUT  = os.path.join(REPO, "jx3p", "src", "jx_voice_render.c")

OFFRE = re.compile(r"a1 \+ (0x[0-9A-Fa-f]+|\d+)")   # same tokenization as the model

def main():
    text = open(SRC).read()
    model = json.load(open(MODEL))
    cells = model["cells"]; p2c = model["position_to_cell"]

    def pos_ab(k, arm0_val):
        c = cells[p2c[k]]
        if "a" in c:
            assert c["a"] == arm0_val, "pos %d: arm0 %d != cell a %d" % (k, arm0_val, c["a"])
            return c["a"], c["b"]
        # permutation-cluster cell: keyed on ARM0's text the cell is the one at
        # the arm0 value; its stride is the region's -- shared tail b=0, else
        # the per-voice 16128. (Emission-order swaps sit on commutative ops;
        # IEEE +/* are commutative bit-exactly. The null gate is the arbiter.)
        assert c["table"][0] == arm0_val, "pos %d: arm0 %d != table0 %d" % (k, arm0_val, c["table"][0])
        b = 0 if 129200 <= arm0_val <= 129344 else 16128
        return arm0_val, b

    occs = list(OFFRE.finditer(text))
    if len(occs) != len(p2c):
        sys.exit("POSITION COUNT MISMATCH: %d in text vs %d in model" % (len(occs), len(p2c)))

    outp = []
    last = 0
    for k, m in enumerate(occs):
        v0 = int(m.group(1), 0)
        a, b = pos_ab(k, v0)
        outp.append(text[last:m.start()])
        outp.append("st + %d + %d*(v)" % (a, b) if b else "st + %d" % a)
        last = m.end()
    outp.append(text[last:])
    body = "".join(outp)

    # ---- signature -------------------------------------------------------
    body = body.replace(
        "__int64 __fastcall sub_1803A22C0(__int64 a1, _DWORD **a2)",
        "__int64 jx_voice_render(unsigned char *st, int v, uint32_t **a2)")

    # ---- helper renames (shared across all 8 arms; see jx_voice_helpers) -
    for h in ("18039A250","1803A2010","1803A2180","1803A2210","1803A9950"):
        body = body.replace("sub_%s" % h, "jx_h_%s" % h[3:])

    # ---- __m128 lane-0 idiom -> scalar bit views -------------------------
    # loads: v = (__m128)*(unsigned int *)(EXPR);   (EXPR already rewritten)
    body = re.sub(r"(v\d+) = \(__m128\)\*\(unsigned int \*\)\((.+?)\);",
                  r"\1_bits = *(uint32_t *)(\2); \1 = f32_from_bits(\1_bits);", body)
    # declarations for the two __m128 locals -> float + bits shadow
    body = re.sub(r"__m128 (v\d+); // xmm\d+",
                  r"float \1; uint32_t \1_bits;", body)
    # movemask floor idiom: sign bit of lane 0
    body = re.sub(r"\(_mm_movemask_ps\(_mm_unpacklo_ps\((v\d+), \1\)\) & 1\)",
                  r"(int)((bits_from_f32(\1) >> 31) & 1u)", body)
    # helper returns: jx_h_X(args).m128_f32[0] -> jx_h_X(args)  (declared float)
    body = re.sub(r"(jx_h_\w+\([^()]*\))\.m128_f32\[0\]", r"\1", body)
    # remaining lane reads on locals
    body = re.sub(r"(v\d+)\.m128_f32\[0\]", r"\1", body)
    # strip the dump's leading comment lines before the guard sees them
    body = re.sub(r"^// .*\n", "", body, flags=re.M)

    # ---- judgement fixups: the 4 jx_h_3A9950() sites whose xmm0 arg IDA
    # lost. Each resolved from 01_closure.asm: every site does
    # `xorps xmm0, signmask` immediately before the call, so the argument is
    # the NEGATION of the value then in xmm0 (the JUNO wrap24(-x) idiom):
    #   0x3A2376: xmm0 = load st+129264 (after its bits were copied to
    #             st+129280)                      -> -JF(st,129264)
    #   0x3A38FB: xmm0 = v194 (mulss xmm6,xmm0 builds v195 = coef*v194 - ...)
    #                                             -> -v194
    #   0x3A3B52: xmm0 = v209 (movaps xmm1,xmm0; mulss xmm1,JF(14896) builds
    #             v214 = v210 - v209*JF(14896))   -> -v209
    #   0x3A4155: xmm0 = old JF(st,15600) (movaps xmm11,xmm0 heads the v270
    #             subtraction chain; 15600 is stored only after the call)
    #                                             -> -JF(st,15600)
    FIX = {
      "  v4 = jx_h_3A9950();":
      "  v4 = jx_h_3A9950(-*(float *)(st + 129264));",
      "    *(float *)(st + 13792 + 16128*(v)) = jx_h_3A9950();":
      "    *(float *)(st + 13792 + 16128*(v)) = jx_h_3A9950(-v194);",
      "  *(float *)(st + 14800 + 16128*(v)) = jx_h_3A9950();":
      "  *(float *)(st + 14800 + 16128*(v)) = jx_h_3A9950(-v209);",
      "  *(float *)(st + 15584 + 16128*(v)) = jx_h_3A9950();":
      "  *(float *)(st + 15584 + 16128*(v)) = jx_h_3A9950(-*(float *)(st + 15600 + 16128*(v)));",
    }
    fixed = 0
    for old, new in FIX.items():
        n = body.count(old)
        assert n == 1, "fixup key not unique/found (%d): %s" % (n, old.strip())
        body = body.replace(old, new); fixed += 1
    assert "jx_h_3A9950()" not in body, "an argless 3A9950 site survived"

    # ---- refusal guard ---------------------------------------------------
    left_a1  = len(re.findall(r"\ba1\b", body))
    left_mm  = len(re.findall(r"_mm_|m128", body))
    left_sub = len(re.findall(r"\bsub_1[0-9A-F]{8}\b", body))
    if left_a1 or left_mm or left_sub:
        for pat in (r".*\ba1\b.*", r".*(_mm_|m128).*", r".*\bsub_1[0-9A-F]{8}\b.*"):
            for ln in re.findall(pat, body)[:5]:
                sys.stderr.write("  LEFT: %s\n" % ln.strip()[:110])
        sys.exit("REFUSING TO EMIT: %d a1 refs, %d simd refs, %d sub_ refs remain"
                 % (left_a1, left_mm, left_sub))

    header = """\
/* jx_voice_render.c -- exact C99 transcription of the JX-3P per-voice render.
 * Generated by jx3p/tools/translate_jx_voice.py from the arm0 decompile
 * (sub_1803A22C0) + the PROVEN per-position offset model (offset = a + b*v,
 * verified against arms 3 and 7). One function covers all 8 arm clones.
 * STATUS: READ (unproven) until the null gate vs the Unicorn oracle is 0.
 * Build with -ffp-contract=off -fno-strict-aliasing. */
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include "jx_voice_helpers.h"

typedef uint32_t _DWORD; typedef uint64_t _QWORD;
typedef uint16_t _WORD;  typedef uint8_t _BYTE;
typedef int64_t __int64; typedef int32_t __int32;
typedef int16_t __int16; typedef int8_t __int8;
#define LODWORD(x)  (*((uint32_t *)&(x)))
#define HIDWORD(x)  (*((uint32_t *)&(x)+1))
#define SLODWORD(x) (*((int32_t *)&(x)))
#define SHIDWORD(x) (*((int32_t *)&(x)+1))
static inline float    f32_from_bits(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t bits_from_f32(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

"""
    # strip the dump's leading comment lines
    body = re.sub(r"^// .*\n", "", body, flags=re.M)
    open(OUT, "w").write(header + body.strip() + "\n")
    print("wrote %s" % OUT)
    # hazard report
    hz = [(i+1, l.strip()[:100]) for i, l in enumerate(open(OUT).read().splitlines())
          if re.search(r"JUMPOUT|__asm|goto|\bunk_|\bdword_18", l)]
    print("HAZARD LINES: %d" % len(hz))
    for n, l in hz[:10]: print("  %d: %s" % (n, l))

if __name__ == "__main__":
    main()
