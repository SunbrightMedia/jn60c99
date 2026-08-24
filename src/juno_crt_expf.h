/* juno_crt_expf.h -- the JUNO binary's OWN expf, transcribed from its
 * machine code at rva 0x6EF740 (statically linked CRT; expf is NOT in the
 * import table). The routine opens with a CPU-feature dispatch on a .data
 * flag that is 0 in a fresh image; the Unicorn oracle executes a fresh
 * image, so the non-FMA path transcribed here is the ground truth. Host
 * libm may take an FMA path and differ by 1 ulp (playbook 79: exactly this
 * killed 6 of 64 JX-3P integration patches; the JX copy of this routine at
 * rva 0x722EA0 is instruction- and constant-identical, verified by canonical
 * disassembly compare). Table: JUNO @0xA96C10, byte-identical to JX
 * @0xACC1C0 (512-byte compare).
 * STATUS: READ (static transcription); PROVEN via the same null gates that
 * previously proved the libm call sites, re-run after the swap.
 * Header-only so src/ and engine_b share one copy. */
#ifndef JUNO_CRT_EXPF_H
#define JUNO_CRT_EXPF_H
#include <stdint.h>
#include <string.h>
#include <math.h>   /* lrint: portable round-to-nearest-even (matches x86 cvtsd2si
                     * under the default rounding mode; keeps this header ARM-clean) */

static const uint64_t juno_crt_exp_tab_[64] = {
0x3ff0000000000000ULL,0x3ff02c9a3e778061ULL,0x3ff059b0d3158574ULL,0x3ff0874518759bc8ULL,
0x3ff0b5586cf9890fULL,0x3ff0e3ec32d3d1a2ULL,0x3ff11301d0125b51ULL,0x3ff1429aaea92de0ULL,
0x3ff172b83c7d517bULL,0x3ff1a35beb6fcb75ULL,0x3ff1d4873168b9aaULL,0x3ff2063b88628cd6ULL,
0x3ff2387a6e756238ULL,0x3ff26b4565e27cddULL,0x3ff29e9df51fdee1ULL,0x3ff2d285a6e4030bULL,
0x3ff306fe0a31b715ULL,0x3ff33c08b26416ffULL,0x3ff371a7373aa9cbULL,0x3ff3a7db34e59ff7ULL,
0x3ff3dea64c123422ULL,0x3ff4160a21f72e2aULL,0x3ff44e086061892dULL,0x3ff486a2b5c13cd0ULL,
0x3ff4bfdad5362a27ULL,0x3ff4f9b2769d2ca7ULL,0x3ff5342b569d4f82ULL,0x3ff56f4736b527daULL,
0x3ff5ab07dd485429ULL,0x3ff5e76f15ad2148ULL,0x3ff6247eb03a5585ULL,0x3ff6623882552225ULL,
0x3ff6a09e667f3bcdULL,0x3ff6dfb23c651a2fULL,0x3ff71f75e8ec5f74ULL,0x3ff75feb564267c9ULL,
0x3ff7a11473eb0187ULL,0x3ff7e2f336cf4e62ULL,0x3ff82589994cce13ULL,0x3ff868d99b4492edULL,
0x3ff8ace5422aa0dbULL,0x3ff8f1ae99157736ULL,0x3ff93737b0cdc5e5ULL,0x3ff97d829fde4e50ULL,
0x3ff9c49182a3f090ULL,0x3ffa0c667b5de565ULL,0x3ffa5503b23e255dULL,0x3ffa9e6b5579fdbfULL,
0x3ffae89f995ad3adULL,0x3ffb33a2b84f15fbULL,0x3ffb7f76f2fb5e47ULL,0x3ffbcc1e904bc1d2ULL,
0x3ffc199bdd85529cULL,0x3ffc67f12e57d14bULL,0x3ffcb720dcef9069ULL,0x3ffd072d4a07897cULL,
0x3ffd5818dcfba487ULL,0x3ffda9e603db3285ULL,0x3ffdfc97337b9b5fULL,0x3ffe502ee78b3ff6ULL,
0x3ffea4afa2a490daULL,0x3ffefa1bee615a27ULL,0x3fff50765b6e4540ULL,0x3fffa7c1819e90d8ULL};

static inline float juno_expf_6EF740(float a1)
{
  uint32_t ix, ax; double xd, z, kd, r, r2, p, q, s, s2; int32_t n, top;
  uint32_t idx; uint64_t s2b; float out;
  memcpy(&ix, &a1, 4); ax = ix & 0x7fffffffu;
  if ((int32_t)ax >= 0x7f800000) {          /* inf/nan gate */
    if (ix == 0x7f800000u) return a1;       /* +inf -> +inf */
    if (ix == 0xff800000u) return 0.0f;     /* -inf -> +0   */
    ix |= 0x400000u;                        /* nan  -> quieted */
    memcpy(&out, &ix, 4); return out;
  }
  xd = (double)a1;
  z  = 92.33248261689366 * xd;              /* 64/ln2 */
  if (z >= 8192.0) { ix = 0x7f800000u; memcpy(&out,&ix,4); return out; }
  if (z < -9600.0) return 0.0f;
  /* cvtpd2dq: round to nearest even (default MXCSR) == lrint under default mode */
  n = (int32_t)lrint(z);
  kd  = (double)n;
  r   = xd - kd * 0.010830424696249145;     /* ln2/64 */
  idx = (uint32_t)n & 63u;
  top = (n - (int32_t)idx) >> 6;
  r2  = r * r;
  p   = 0.16666666666666666 * r + 0.5;
  q   = r2 * p + r;
  memcpy(&s, &juno_crt_exp_tab_[idx], 8);
  s2b = (uint64_t)(uint32_t)(top + 0x3ff) << 52;
  memcpy(&s2, &s2b, 8);
  return (float)((q * s + s) * s2);
}
#endif /* JUNO_CRT_EXPF_H */
