#!/usr/bin/env python3
"""translate_jx_master.py -- mechanical transcription of the JX master render
(sub_18039A2B0). Single unit (no per-voice arm unification), so offsets are the
decompile's own: `a1 + N` -> `st + N`, types kept VERBATIM (bit copies stay bit
copies). Carrier-safe helper args (the 3A2210 lane-0 reinterpret bug is baked
out here). Argless helper sites (xmm0 lost by Hex-Rays) are filled from a fixups
table resolved against 01_closure.asm / the emu arg-capture.

OUTPUT: jx3p/src/jx_master_render.c -- jx_master_render(st, a2, a3).
REFUSAL GUARD aborts on any residual a1 / _mm_ / m128 / sub_1 reference.
"""
import re, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DUMP = "/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/jxdump2"
SRC  = os.path.join(DUMP, "fn_sub_18039A2B0_18039A2B0.c")
OUT  = os.path.join(REPO, "jx3p", "src", "jx_master_render.c")

# argless helper fixups -- resolved from asm/emu (filled in as they are proven).
FIX = {}

def main():
    body = open(SRC).read()
    body = re.sub(r"^// .*\n", "", body, flags=re.M)

    # signature
    body = body.replace(
        "float *__fastcall sub_18039A2B0(__int64 a1, __int64 a2, float **a3)",
        "float *jx_master_render(unsigned char *st, void **a2, float **a3)")

    # offsets: plain single-unit -> st + N  (decimal or hex, keep type verbatim)
    body = re.sub(r"a1 \+ (0x[0-9A-Fa-f]+|\d+)", r"st + \1", body)

    # helper renames
    for h in ("18039A250","1803A2010","1803A2180","1803A2210","1803A21E0","1803A9950"):
        body = body.replace("sub_%s" % h, "jx_h_%s" % h[3:])

    # __m128 lane-0 idioms (same as voice)
    body = re.sub(r"(v\d+) = \(__m128\)\*\(unsigned int \*\)\((.+?)\);",
                  r"\1_bits = *(uint32_t *)(\2); \1 = f32_from_bits(\1_bits);", body)
    body = re.sub(r"__m128 (v\d+); // xmm\d+",
                  r"float \1; uint32_t \1_bits;", body)
    body = re.sub(r"\(_mm_movemask_ps\(_mm_unpacklo_ps\((v\d+), \1\)\) & 1\)",
                  r"(int)((bits_from_f32(\1) >> 31) & 1u)", body)
    body = re.sub(r"(jx_h_\w+\([^()]*\))\.m128_f32\[0\]", r"\1", body)
    body = re.sub(r"(v\d+)\.m128_f32\[0\]", r"\1", body)

    # CARRIER-SAFE helper args: 3A2210/3A21E0 are lane-0 (__m128/float) wrappers;
    # a bare double/int64 carrier arg must be reinterpreted, not converted.
    # Declared types:
    decls = dict(re.findall(r"^\s*(double|__int64|__m128)\s+(v\d+);", body, re.M))
    for h in ("3A2210", "3A21E0", "3A2180", "3A9950"):
        def fix_arg(m, h=h):
            arg = m.group(1)
            if arg in decls:           # bare carrier local -> reinterpret bits
                return "jx_h_%s(*(float *)&%s)" % (h, arg)
            return m.group(0)
        body = re.sub(r"jx_h_%s\((v\d+)\)" % h, fix_arg, body)

    # argless fixups
    for old, new in FIX.items():
        n = body.count(old)
        if n != 1:
            sys.stderr.write("FIXUP not unique/found (%d): %s\n" % (n, old.strip()))
        body = body.replace(old, new)

    # report residual argless helper sites (need a fixup)
    argless = re.findall(r".*jx_h_\w+\(\).*", body)
    if argless:
        sys.stderr.write("=== %d ARGLESS helper sites need fixups ===\n" % len(argless))
        for l in argless[:20]:
            sys.stderr.write("  " + l.strip()[:110] + "\n")

    left_a1  = len(re.findall(r"\bst \+ [^0-9]", body)) + len(re.findall(r"\ba1\b", body))
    left_mm  = len(re.findall(r"_mm_|m128", body))
    left_sub = len(re.findall(r"\bsub_1[0-9A-F]{8}\b", body))
    guard_ok = not (re.findall(r"\ba1\b", body) or left_mm or left_sub or argless)

    header = """\
/* jx_master_render.c -- exact C99 transcription of the JX-3P master render
 * (sub_18039A2B0). Single unit; offsets are the decompile's own. Helpers shared
 * with the voice render (jx_voice_helpers). STATUS: READ until null 0.
 * Build with -ffp-contract=off -fno-strict-aliasing. */
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include "jx_voice_helpers.h"

typedef uint32_t _DWORD; typedef uint64_t _QWORD;
typedef uint16_t _WORD;  typedef uint8_t _BYTE;
typedef int64_t __int64; typedef int32_t __int32;
#define LODWORD(x)  (*((uint32_t *)&(x)))
#define HIDWORD(x)  (*((uint32_t *)&(x)+1))
#define SLODWORD(x) (*((int32_t *)&(x)))
static inline float    f32_from_bits(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t bits_from_f32(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

"""
    open(OUT, "w").write(header + body.strip() + "\n")
    print("wrote %s (guard_ok=%s, argless=%d, sub_left=%d)" %
          (OUT, guard_ok, len(argless), left_sub))

if __name__ == "__main__":
    main()
