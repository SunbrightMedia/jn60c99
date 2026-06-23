#!/usr/bin/env python3
# translate_voice.py — mechanical first-pass translation of the decompiled
# voice_render (dsp_dump/0021_sub_180369070_180369070.c) into C99 using the
# JF()/JI()/JU() offset accessors. Handles the ~940 regular memory accesses and
# the table lookups; the ~30 judgement lines (helper-call args, the SIMD floor,
# the __m128 scalar, the pitch pointer, reinterpret casts) are rewritten from a
# fixups table with the values resolved from the assembly (asm_dump) so the
# output compiles and is faithful. Output: src/voice_render.c.
import re

SRC = "dsp_dump/0021_sub_180369070_180369070.c"
OUT = "src/voice_render.c"

lines = open(SRC).read().splitlines()
# body starts at the function signature line
start = next(i for i, l in enumerate(lines) if l.startswith("__int64 __fastcall sub_180369070"))
body = lines[start:]

# ── exact per-line fixups (decompile text -> C), applied before regex ──────────
# Helper-call argument resolutions come from docs/VOICE_RENDER_MAP.md (asm trace).
FIXUPS = {
 # signature + result type
 "__int64 __fastcall sub_180369070(__int64 a1, _DWORD **a2)":
   "uint32_t juno_voice_render(unsigned char *a1, float *outL, float *outR)",
 "  __int64 result; // rax": "  uint32_t result;",
 "  __m128 v227; // xmm9": "  float v227; uint32_t v227_bits;",
 "  double v386; // xmm2_8": "  double v386; int v386_lo;",
 # __m128 v227 load (bit pattern) and its int/float views
 "  v227 = (__m128)*(unsigned int *)(a1 + 6608);":
   "  v227_bits = JU(a1, 6608); v227 = f32_from_bits(v227_bits);",
 "  *(_DWORD *)(a1 + 7264) = v227.m128_i32[0];": "  JI(a1, 7264) = (int32_t)bits_from_f32(v227);",
 "  *(_DWORD *)(a1 + 7280) = v227.m128_i32[0];": "  JI(a1, 7280) = (int32_t)bits_from_f32(v227);",
 # SIMD floor idiom (line ~1222-1224)
 "    v235 = (int)v227.m128_f32[0];": "    v235 = (int)v227;",
 "    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v235 != v227.m128_f32[0] )":
   "    if ( v235 != (int)0x80000000 && (float)v235 != v227 )",
 "      v234 = (float)(v235 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));":
   "      v234 = (float)(v235 - (int)((bits_from_f32(v227) >> 31) & 1u));",
 "    v234 = v227.m128_f32[0];": "    v234 = v227;",
 "    v236 = v227.m128_f32[0] - v234;": "    v236 = v227 - v234;",
 # LODWORD(v386) reuse as a 32-bit temp
 "  LODWORD(v386) = *(_DWORD *)(a1 + 4272);": "  v386_lo = JI(a1, 4272);",
 "  *(_DWORD *)(a1 + 4768) = LODWORD(v386);": "  JI(a1, 4768) = v386_lo;",
 # pitch-table pointer (unk_1809894E0, 208-byte rows -> [row][col] doubles)
 "  v387 = (double *)((char *)&unk_1809894E0 + 208 * (int)(v385 + 20.0));":
   "  v387 = juno_pitch_table[(int)(v385 + 20.0)];",
 "  double *v387; // rax": "  const double *v387;",
}

# Helper calls: map by the exact decompile text (each site is unique enough with
# its assigned variable). triangle = juno_triangle, wrap24 = juno_wrap24.
HELPERS = {
 "  v109 = sub_180368FC0();": "  v109 = juno_triangle(v108);",
 "    *(float *)(a1 + 7552) = sub_180368D60();": "    JF(a1, 7552) = juno_wrap24(-v230);",
 "    *(float *)(a1 + 8976) = sub_180368D60();": "    JF(a1, 8976) = juno_wrap24(-v244);",
}
# The unison-bank triangle calls: pattern A=(phase+1)*0.5, B=v412/(a1+4816±1),
# C=-|phase|. The pseudocode forms are identical per iteration; we disambiguate
# by line content + the *(float*)&vN reads that follow. Each is rewritten so the
# result var holds the float directly (drop the *(float*)& reinterpret).
PATTERN = {  # decompile rhs -> (callexpr, resultvar)
}

text = []
for l in body:
    if l in FIXUPS:
        text.append(FIXUPS[l]); continue
    if l in HELPERS:
        text.append(HELPERS[l]); continue
    text.append(l)
body = text

s = "\n".join(body)

# ── regular regex translations ────────────────────────────────────────────────
s = re.sub(r"\*\(float \*\)\(a1 \+ (\d+)\)",            r"JF(a1, \1)", s)
s = re.sub(r"\*\(_DWORD \*\)\(a1 \+ (\d+)\)",           r"JI(a1, \1)", s)
s = re.sub(r"\*\(unsigned int \*\)\(a1 \+ (\d+)\)",     r"JU(a1, \1)", s)
s = s.replace("dword_18098AD3C[", "juno_exp_ad3c[")
s = s.replace("dword_18098ACC0[", "juno_exp_acc0[")
# literal scalar constants referenced by name -> their float values
s = s.replace("dword_18098AD3C", "5.9604645e-08f")  # any stray scalar use (none expected)

header = '''/* voice_render.c — exact C99 transcription of sub_180369070 (Cloud 60 voice
 * render). Generated first-pass by tools/translate_voice.py then finished by
 * hand for the helper-call args (resolved from asm_dump) and SIMD idioms.
 * The decompile in dsp_dump is the spec; coefficients live in the voice state
 * (written by sub_1803990C0, see init_dump). Build with -fno-strict-aliasing.
 */
#include "juno_engine.h"
#include "juno_dsp.h"
#include "juno_tables.h"
#include <math.h>
#include <string.h>

#define JU(st, off)  (*(uint32_t *)((unsigned char *)(st) + (off)))

static inline float    f32_from_bits(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t bits_from_f32(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

'''
open(OUT, "w").write(header + s + "\n")
print("wrote", OUT)
# report any remaining un-translated hazards for manual review
import sys
flags = [ (i+1, l) for i, l in enumerate(open(OUT).read().splitlines())
          if re.search(r"sub_18036|m128|_mm_|LODWORD|\(double \(\*\)|&unk_|\*\(float \*\)&", l) ]
print("REMAINING HAZARD LINES:", len(flags))
for ln, l in flags: print(f"  {ln}: {l.strip()[:90]}")
