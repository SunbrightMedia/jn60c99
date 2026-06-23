#!/usr/bin/env python3
# translate_master.py — mechanical transcription of the decompiled master/chorus
# process sub_180363380 (init_dump/020_sub_180363380_180363380.c) into C99.
#
# METHOD (same spirit as translate_voice.py, but minimal-edit):
#   The master is 2875 lines of well-formed Hex-Rays pseudocode that already
#   compiles almost verbatim once IDA's _DWORD/_QWORD/_WORD/__int16 typedefs and
#   LODWORD/HIDWORD macros are provided, and `a1` is an `unsigned char *` (so the
#   `*(float *)(a1 + N)` / `*(_DWORD *)(a1 + expr)` casts — including circular-
#   buffer index math and the host-params pointer chase — are valid C). Keeping
#   the body verbatim is the *safest* transcription: every byte of the algorithm
#   is preserved; we only rewrite the handful of lines Hex-Rays mangled.
#
#   The ONLY rewrites (FIXUPS below) are the sites where the decompiler dropped an
#   XMM argument or rendered a SIMD idiom wrong. Each argument was recovered from
#   the disassembly master_deps/master_sub_180363380_180363380.asm (see
#   docs/MASTER_RENDER_MAP.md for the per-site asm trace). Nothing is guessed.
#
# Output: src/master_render.c
import re

SRC = "init_dump/020_sub_180363380_180363380.c"
OUT = "src/master_render.c"

# ── exact per-line fixups, keyed by the STRIPPED decompile line ───────────────
# value = replacement (indentation of the original line is re-applied to line 1).
FIXUPS = {
 # signature + helper mapping is below; declarations of the four float-carrier
 # temporaries Hex-Rays typed as `double` (they only ever hold a float):
 "double v102; // xmm0_8": "float v102; // xmm0_8 (float carrier)",
 "double v181; // xmm0_8": "float v181; // xmm0_8 (float carrier)",
 "double v256; // xmm6_8": "float v256; // xmm6_8 (float carrier)",
 "double v553; // xmm0_8": "float v553; // xmm0_8 (float carrier)",

 # signature: a1 -> unsigned char* so all the (float*)(a1+N) casts are valid C.
 "float *__fastcall sub_180363380(__int64 a1, float **a2, float **a3)":
   "float *juno_master_render(unsigned char *a1, float **a2, float **a3)",

 # ── chorus LFO stage 1 (offsets 6395xxx) — fully decompiled except DC0 arg ──
 # DC0 = juno_pitch_poly; arg from asm 0x180365139: cvtps2pd(JF(6395312)+JF(6395408)).
 "v254 = sub_180368DC0();":
   "v254 = juno_pitch_poly((double)(float)( *(float *)(a1 + 6395312) + *(float *)(a1 + 6395408) ));",
 # v256 is a float carrier: load the phase float (was *(_QWORD*)&v256 = uint load).
 "*(_QWORD *)&v256 = *(unsigned int *)(a1 + 6395600);":
   "v256 = *(float *)(a1 + 6395600);",
 # triangle of the wrapped phase (Hex-Rays dropped the .m128 union view).
 "v259 = sub_180368FC0(v256).m128_f32[0];": "v259 = juno_triangle(v256);",

 # ── chorus LFO stage 2 (offsets 10692xxx) — Hex-Rays DROPPED the whole phase
 # increment block + the F90/DC0 args. Reconstructed verbatim from asm
 # 0x1803647B9..0x18036485F (identical structure to stage 1). ──
 "v100 = sub_180368DC0();":
   "v100 = juno_pitch_poly((double)(float)( *(float *)(a1 + 10692016) + *(float *)(a1 + 10692112) ));",
 "v102 = sub_180368F90();":
   "{ float _inc2 = (float)(*(float *)(a1 + 10692080) * *(float *)(a1 + 10692352));\n"
   "    if ( _inc2 < 4.0 ) { if ( _inc2 >= 2.0 ) _inc2 = _inc2 + -2.0; } else _inc2 = _inc2 + -4.0;\n"
   "    if ( _inc2 == 0.0 ) _inc2 = *(float *)(a1 + 10692368);\n"
   "    v102 = juno_wrap_hi((float)(*(float *)(a1 + 10692304) + _inc2)); }",
 "v104 = sub_180368FC0(v102).m128_f32[0];": "v104 = juno_triangle(v102);",

 # ── chorus LFO stage 3 (offsets 6429xxx) — same drop as stage 2.
 # Reconstructed from asm 0x1803647B9-region's twin at 0x180364853. ──
 "v179 = sub_180368DC0();":
   "v179 = juno_pitch_poly((double)(float)( *(float *)(a1 + 6429472) + *(float *)(a1 + 6429568) ));",
 "v181 = sub_180368F90();":
   "{ float _inc3 = (float)(*(float *)(a1 + 6429536) * *(float *)(a1 + 6429808));\n"
   "    if ( _inc3 < 4.0 ) { if ( _inc3 >= 2.0 ) _inc3 = _inc3 + -2.0; } else _inc3 = _inc3 + -4.0;\n"
   "    if ( _inc3 == 0.0 ) _inc3 = *(float *)(a1 + 6429824);\n"
   "    v181 = juno_wrap_hi((float)(*(float *)(a1 + 6429760) + _inc3)); }",
 "v183 = sub_180368FC0(v181).m128_f32[0];": "v183 = juno_triangle(v181);",

 # ── stereo-output BBD LFOs: wrap_unit (F30), args dropped. From asm:
 #   0x1803674C3 : JF(96176)+JF(96144)+JF(96352)
 #   0x180367A9C : JF(90672)+JF(90640)+JF(91152)
 #   0x180367C71 : JF(90656)+JF(91168)
 "v553 = sub_180368F30();":
   "v553 = juno_wrap_unit((float)((float)( *(float *)(a1 + 96176) + *(float *)(a1 + 96144) ) + *(float *)(a1 + 96352)));",
 "v595 = sub_180368F30();":
   "v595 = juno_wrap_unit((float)((float)( *(float *)(a1 + 90672) + *(float *)(a1 + 90640) ) + *(float *)(a1 + 91152)));",
 "v611 = fabs(sub_180368F30());":
   "v611 = fabs(juno_wrap_unit((float)( *(float *)(a1 + 90656) + *(float *)(a1 + 91168) )));",

 # wrap24 (D60) — args ARE visible in the decompile, just rename.
 "v599 = sub_180368D60(-v597);": "v599 = juno_wrap24(-v597);",
 "*(float *)(a1 + 90832) = sub_180368D60(-v599);":
   "*(float *)(a1 + 90832) = juno_wrap24(-v599);",
}

HEADER = '''/* master_render.c — exact C99 transcription of sub_180363380 (Cloud 60 master
 * process: 8-voice mix + stereo BBD chorus + true-stereo output).
 *
 * Generated by tools/translate_master.py from init_dump/020_sub_180363380_*.c.
 * The decompile is kept VERBATIM except for ~17 lines where Hex-Rays dropped an
 * XMM argument or mangled a SIMD idiom; each of those was recovered from the
 * disassembly (master_deps/master_sub_180363380_*.asm) and is documented in
 * docs/MASTER_RENDER_MAP.md. Nothing is fitted or guessed.
 *
 * a1 : engine state (unsigned char*); a2 : 8 voice-sample pointers at even
 *      indices a2[0,2,..14]; a3 : {float* L, float* R} output. Output is
 *      2*state[101264] (L) and 2*state[101280] (R).
 * Build with -fno-strict-aliasing (the engine addresses state by raw offset).
 *
 * NOTE: the ~250 chorus/output coefficients produced by sub_180388170 are not
 * yet in our data (Hex-Rays returns None on it; see tools/extract_chorus_coeffs.py).
 * Until they are captured those fields are zero, so the chorus is inert and the
 * output saturator collapses toward silence — this is missing DATA, not a
 * transcription gap. The algorithm here is complete and exact.
 */
#include "juno_engine.h"
#include "juno_dsp.h"
#include <math.h>
#include <stdbool.h>

/* IDA pseudocode primitive types / macros, so the decompile compiles verbatim. */
typedef uint8_t  _BYTE;
typedef uint16_t _WORD;
typedef uint32_t _DWORD;
typedef uint64_t _QWORD;
#define __int16 short            /* so `unsigned __int16` -> `unsigned short` */
#define LODWORD(x)  (*((_DWORD *)&(x)))

'''

def main():
    lines = open(SRC).read().splitlines()
    start = next(i for i, l in enumerate(lines)
                 if l.startswith("float *__fastcall sub_180363380"))
    body = lines[start:]
    out = []
    n_fix = 0
    for l in body:
        key = l.strip()
        if key in FIXUPS:
            indent = l[:len(l) - len(l.lstrip())]
            repl = FIXUPS[key]
            # re-apply original indent to the first physical line only
            out.append(indent + repl)
            n_fix += 1
        else:
            out.append(l)
    open(OUT, "w").write(HEADER + "\n".join(out) + "\n")
    print("wrote", OUT, "— applied", n_fix, "fixups of", len(FIXUPS), "expected")
    # report any helper calls or SIMD idioms still present (should be none)
    leftover = [(i + 1, l) for i, l in enumerate(open(OUT).read().splitlines())
                if re.search(r"sub_18036[0-9A-F]+|m128|__int64 a1|_QWORD \*\)&|unsigned int \*\)\(a1", l)]
    print("REMAINING HAZARD LINES:", len(leftover))
    for ln, l in leftover:
        print("  %d: %s" % (ln, l.strip()[:88]))

if __name__ == "__main__":
    main()
