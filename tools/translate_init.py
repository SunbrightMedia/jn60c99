#!/usr/bin/env python3
# translate_init.py — mechanical transcription of sub_1803990C0 (the engine/voice
# coefficient initializer) to C99. The routine is purely: read the sample rate,
# pick one of two precomputed coefficient sets (44100 vs else), then ~2293 raw
# dword stores into the engine state. Fully mechanical — no calls, no math.
# Output: src/juno_init.c.
import re

SRC = "init_dump/005_sub_1803990C0_1803990C0.c"
OUT = "src/juno_init.c"

lines = open(SRC).read().splitlines()
start = next(i for i, l in enumerate(lines) if l.startswith("__int64 __fastcall sub_1803990C0"))
body = "\n".join(lines[start:])

# regular translations
body = body.replace(
    "__int64 __fastcall sub_1803990C0(__int64 a1)",
    "uint32_t juno_engine_init(unsigned char *a1)")
body = body.replace("  __int64 result; // rax", "  uint32_t result;")
body = body.replace(
    "  result = (unsigned int)(int)*(float *)(a1 + 16);",
    "  result = (uint32_t)(int)JF(a1, 16);")
body = body.replace("if ( (_DWORD)result == 44100 )", "if ( result == 44100 )")
# raw dword stores -> JI (bit-exact 32-bit writes)
body = re.sub(r"\*\(_DWORD \*\)\(a1 \+ (0x[0-9A-Fa-f]+|\d+)\)", r"JI(a1, \1)", body)
# any stray float read of the rate
body = re.sub(r"\*\(float \*\)\(a1 \+ (0x[0-9A-Fa-f]+|\d+)\)", r"JF(a1, \1)", body)

header = '''/* juno_init.c — exact C99 transcription of sub_1803990C0: fills the engine
 * state with the real coefficients voice_render consumes. Sample-rate aware
 * (one precomputed set for 44100, another otherwise). Set JF(state,16) to the
 * sample rate before calling. The decompile in init_dump is the spec; values
 * are raw float bit-patterns stored verbatim. Build with -fno-strict-aliasing.
 */
#include "juno_engine.h"
#include <stdint.h>

'''
open(OUT, "w").write(header + body + "\n")
print("wrote", OUT)
# hazard scan
rem = [l for l in open(OUT).read().splitlines()
       if re.search(r"sub_18039|_DWORD|__int64|\*\(", l)]
print("remaining hazards:", len(rem))
for l in rem[:10]: print("  ", l.strip()[:90])
