/* jp8_cpu.h -- the runtime under the LIFTED plugin code (jp8/tools/jp8_lift.py emits C that includes this).
 *
 * Model: an x86-64 register file in a struct; memory is the PROCESS ADDRESS SPACE ITSELF, because the gate maps the
 * oracle's regions (image at 0x180000000, heap at 0x310000000, stack, BUF) at the SAME virtual addresses
 * (mmap MAP_FIXED_NOREPLACE) and loads the oracle's dumps into them. Every pointer-valued cell therefore reads
 * identically here and under Unicorn -- no relocation, no mirrors (playbook 86, PORT_LESSONS 8).
 * Flags are computed eagerly by the op_* helpers (ZF SF CF OF PF); SSE scalar ops are plain C float/double
 * arithmetic (bit-exact under -ffp-contract=off, FLT_EVAL_METHOD 0, SSE on x86-64); minss/maxss/comiss carry the
 * exact hardware NaN/zero semantics; ldmxcsr/stmxcsr are applied to the REAL MXCSR so FTZ/DAZ/rounding match.
 * An unsupported instruction is emitted as jp8_trap(): reaching it aborts the run -- the gate goes red, never a
 * silent placeholder (charter section 3). */
#ifndef JP8_CPU_H
#define JP8_CPU_H
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <xmmintrin.h>

typedef union { float f[4]; double d[2]; uint32_t u[4]; uint64_t q[2]; int32_t i[4]; int64_t l[2]; uint8_t b[16]; uint16_t w[8]; } X;
typedef struct {
    uint64_t r[16];          /* rax rcx rdx rbx rsp rbp rsi rdi r8..r15 */
    X x[16];
    int zf, sf, cf, of, pf;
    uint32_t mxcsr;
    uint64_t trap_rva;       /* set by jp8_trap before longjmp/abort */
    long ninstr;
} CPU;

#define R(n)      (c->r[n])
#define XF(n,l)   (c->x[n].f[l])
#define XD(n,l)   (c->x[n].d[l])
#define XU(n,l)   (c->x[n].u[l])
#define XQ(n,l)   (c->x[n].q[l])
#define XI(n,l)   (c->x[n].i[l])
#define XL(n,l)   (c->x[n].l[l])
#define M8(a)     (*(volatile uint8_t  *)(uintptr_t)(a))
#define M16(a)    (*(volatile uint16_t *)(uintptr_t)(a))
#define M32(a)    (*(volatile uint32_t *)(uintptr_t)(a))
#define M64(a)    (*(volatile uint64_t *)(uintptr_t)(a))
#define MF(a)     (*(volatile float    *)(uintptr_t)(a))
#define MD(a)     (*(volatile double   *)(uintptr_t)(a))
#define MS8(a)    ((int64_t)(int8_t)M8(a))
#define MS16(a)   ((int64_t)(int16_t)M16(a))
#define MS32(a)   ((int64_t)(int32_t)M32(a))

static inline void jp8_ldx(X *d, uint64_t a) { memcpy(d, (const void *)(uintptr_t)a, 16); }
static inline void jp8_stx(uint64_t a, const X *s) { memcpy((void *)(uintptr_t)a, s, 16); }

extern void jp8_trap(CPU *c, uint64_t rva, const char *what);
extern void jp8_tr(CPU *c, uint64_t rva);        /* per-instruction trace record (lift --trace builds only) */
extern void jp8_icall(CPU *c, uint64_t target);   /* indirect call/jump through the lifted-function table */

static inline uint64_t jp8_mask(int sz) { return sz == 64 ? ~0ULL : ((1ULL << sz) - 1); }
static inline int jp8_parity(uint64_t v) { v &= 0xFF; v ^= v >> 4; v ^= v >> 2; v ^= v >> 1; return !(v & 1); }
static inline void jp8_szp(CPU *c, int sz, uint64_t r) {
    r &= jp8_mask(sz); c->zf = (r == 0); c->sf = (r >> (sz - 1)) & 1; c->pf = jp8_parity(r);
}
static inline uint64_t op_add(CPU *c, int sz, uint64_t a, uint64_t b) {
    uint64_t m = jp8_mask(sz), r = (a + b) & m; a &= m; b &= m;
    c->cf = r < a; c->of = ((~(a ^ b) & (a ^ r)) >> (sz - 1)) & 1; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_adc(CPU *c, int sz, uint64_t a, uint64_t b) {
    uint64_t m = jp8_mask(sz), cin = c->cf, r = (a + b + cin) & m; a &= m; b &= m;
    c->cf = (r < a) || (cin && r == a); c->of = ((~(a ^ b) & (a ^ r)) >> (sz - 1)) & 1; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_sub(CPU *c, int sz, uint64_t a, uint64_t b) {
    uint64_t m = jp8_mask(sz), r = (a - b) & m; a &= m; b &= m;
    c->cf = a < b; c->of = (((a ^ b) & (a ^ r)) >> (sz - 1)) & 1; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_sbb(CPU *c, int sz, uint64_t a, uint64_t b) {
    uint64_t m = jp8_mask(sz), cin = c->cf, r = (a - b - cin) & m; a &= m; b &= m;
    c->cf = (a < b) || (cin && a == b); c->of = (((a ^ b) & (a ^ r)) >> (sz - 1)) & 1; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_and(CPU *c, int sz, uint64_t a, uint64_t b) { uint64_t r = (a & b) & jp8_mask(sz); c->cf = c->of = 0; jp8_szp(c, sz, r); return r; }
static inline uint64_t op_or (CPU *c, int sz, uint64_t a, uint64_t b) { uint64_t r = (a | b) & jp8_mask(sz); c->cf = c->of = 0; jp8_szp(c, sz, r); return r; }
static inline uint64_t op_xor(CPU *c, int sz, uint64_t a, uint64_t b) { uint64_t r = (a ^ b) & jp8_mask(sz); c->cf = c->of = 0; jp8_szp(c, sz, r); return r; }
static inline uint64_t op_inc(CPU *c, int sz, uint64_t a) { int cf = c->cf; uint64_t r = op_add(c, sz, a, 1); c->cf = cf; return r; }
static inline uint64_t op_dec(CPU *c, int sz, uint64_t a) { int cf = c->cf; uint64_t r = op_sub(c, sz, a, 1); c->cf = cf; return r; }
static inline uint64_t op_neg(CPU *c, int sz, uint64_t a) { uint64_t r = op_sub(c, sz, 0, a); c->cf = (a & jp8_mask(sz)) != 0; return r; }
static inline uint64_t op_shl(CPU *c, int sz, uint64_t a, unsigned n) {
    n &= (sz == 64) ? 63 : 31; if (!n) return a & jp8_mask(sz);
    uint64_t m = jp8_mask(sz), r = (a << n) & m; c->cf = (a >> (sz - n)) & 1; c->of = ((r >> (sz - 1)) & 1) ^ c->cf; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_shr(CPU *c, int sz, uint64_t a, unsigned n) {
    n &= (sz == 64) ? 63 : 31; a &= jp8_mask(sz); if (!n) return a;
    uint64_t r = a >> n; c->cf = (a >> (n - 1)) & 1; c->of = (a >> (sz - 1)) & 1; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_sar(CPU *c, int sz, uint64_t a, unsigned n) {
    n &= (sz == 64) ? 63 : 31; a &= jp8_mask(sz); if (!n) return a;
    int64_t s = (sz == 64) ? (int64_t)a : (sz == 32) ? (int64_t)(int32_t)a : (sz == 16) ? (int64_t)(int16_t)a : (int64_t)(int8_t)a;
    uint64_t r = ((uint64_t)(s >> n)) & jp8_mask(sz); c->cf = (a >> (n - 1)) & 1; c->of = 0; jp8_szp(c, sz, r); return r;
}
static inline uint64_t op_rol(CPU *c, int sz, uint64_t a, unsigned n) {
    n %= sz; a &= jp8_mask(sz); if (!n) return a; uint64_t r = ((a << n) | (a >> (sz - n))) & jp8_mask(sz); c->cf = r & 1; c->of = ((r >> (sz - 1)) & 1) ^ c->cf; return r;
}
static inline uint64_t op_ror(CPU *c, int sz, uint64_t a, unsigned n) {
    n %= sz; a &= jp8_mask(sz); if (!n) return a; uint64_t r = ((a >> n) | (a << (sz - n))) & jp8_mask(sz); c->cf = (r >> (sz - 1)) & 1; c->of = ((r >> (sz - 1)) ^ (r >> (sz - 2))) & 1; return r;
}
static inline uint64_t op_rcr(CPU *c, int sz, uint64_t a, unsigned n) {
    n %= (sz + 1); a &= jp8_mask(sz); while (n--) { int cf = a & 1; a = (a >> 1) | ((uint64_t)c->cf << (sz - 1)); c->cf = cf; } return a & jp8_mask(sz);
}
static inline uint64_t op_rcl(CPU *c, int sz, uint64_t a, unsigned n) {
    n %= (sz + 1); a &= jp8_mask(sz); while (n--) { int cf = (a >> (sz - 1)) & 1; a = ((a << 1) | (uint64_t)c->cf) & jp8_mask(sz); c->cf = cf; } return a;
}
static inline uint64_t op_imul2(CPU *c, int sz, uint64_t a, uint64_t b) {   /* signed, sets CF=OF on overflow */
    __int128 p = (__int128)(int64_t)(sz == 64 ? (int64_t)a : sz == 32 ? (int64_t)(int32_t)a : sz == 16 ? (int64_t)(int16_t)a : (int64_t)(int8_t)a)
               * (int64_t)(sz == 64 ? (int64_t)b : sz == 32 ? (int64_t)(int32_t)b : sz == 16 ? (int64_t)(int16_t)b : (int64_t)(int8_t)b);
    uint64_t r = (uint64_t)p & jp8_mask(sz);
    int64_t s = (sz == 64) ? (int64_t)r : (sz == 32) ? (int64_t)(int32_t)r : (sz == 16) ? (int64_t)(int16_t)r : (int64_t)(int8_t)r;
    c->cf = c->of = (p != (__int128)s); return r;
}
static inline int op_bt(CPU *c, int sz, uint64_t a, uint64_t bit) { bit &= (sz - 1); c->cf = (a >> bit) & 1; return c->cf; }
static inline uint64_t sext(int sz, uint64_t v) { return sz == 64 ? v : sz == 32 ? (uint64_t)(int64_t)(int32_t)v : sz == 16 ? (uint64_t)(int64_t)(int16_t)v : (uint64_t)(int64_t)(int8_t)v; }

/* conditions */
#define CC_E   (c->zf)
#define CC_NE  (!c->zf)
#define CC_B   (c->cf)
#define CC_AE  (!c->cf)
#define CC_BE  (c->cf || c->zf)
#define CC_A   (!c->cf && !c->zf)
#define CC_L   (c->sf != c->of)
#define CC_GE  (c->sf == c->of)
#define CC_LE  (c->zf || (c->sf != c->of))
#define CC_G   (!c->zf && (c->sf == c->of))
#define CC_S   (c->sf)
#define CC_NS  (!c->sf)
#define CC_P   (c->pf)
#define CC_NP  (!c->pf)
#define CC_O   (c->of)
#define CC_NO  (!c->of)

/* SSE compares: (u)comiss/(u)comisd -> ZF PF CF, OF=SF=0 */
static inline void cmp_f(CPU *c, float a, float b) {
    if (a != a || b != b) { c->zf = c->pf = c->cf = 1; } else { c->zf = (a == b); c->cf = (a < b); c->pf = 0; } c->of = c->sf = 0;
}
static inline void cmp_d(CPU *c, double a, double b) {
    if (a != a || b != b) { c->zf = c->pf = c->cf = 1; } else { c->zf = (a == b); c->cf = (a < b); c->pf = 0; } c->of = c->sf = 0;
}
/* hardware min/max: return the SECOND operand when the compare is false (NaN, equal, signed zeros) */
static inline float  fmin_ss(float a, float b)   { return (a < b) ? a : b; }
static inline float  fmax_ss(float a, float b)   { return (a > b) ? a : b; }
static inline double fmin_sd(double a, double b) { return (a < b) ? a : b; }
static inline double fmax_sd(double a, double b) { return (a > b) ? a : b; }
/* conversions with the x86 "integer indefinite" on NaN / overflow */
static inline int32_t cvtt_f2i(float f)  { if (!(f > -2147483904.0f && f < 2147483648.0f)) return INT32_MIN; return (int32_t)f; }
static inline int64_t cvtt_f2l(float f)  { if (!(f > -9223373136366403584.0f && f < 9223372036854775808.0f)) return INT64_MIN; return (int64_t)f; }
static inline int32_t cvtt_d2i(double d) { if (!(d > -2147483649.0 && d < 2147483648.0)) return INT32_MIN; return (int32_t)d; }
static inline int64_t cvtt_d2l(double d) { if (!(d > -9223372036854777856.0 && d < 9223372036854775808.0)) return INT64_MIN; return (int64_t)d; }
static inline int32_t cvtr_f2i(float f)  { if (f != f) return INT32_MIN; float r = nearbyintf(f); if (!(r > -2147483649.0f && r < 2147483648.0f)) return INT32_MIN; return (int32_t)r; }
static inline int32_t cvtr_d2i(double d) { if (d != d) return INT32_MIN; double r = nearbyint(d); if (!(r > -2147483649.0 && r < 2147483648.0)) return INT32_MIN; return (int32_t)r; }
static inline int64_t cvtr_f2l(float f)  { if (f != f) return INT64_MIN; float r = nearbyintf(f); if (!(r > -9223373136366403584.0f && r < 9223372036854775808.0f)) return INT64_MIN; return (int64_t)r; }
static inline int64_t cvtr_d2l(double d) { if (d != d) return INT64_MIN; double r = nearbyint(d); if (!(r > -9223372036854777856.0 && r < 9223372036854775808.0)) return INT64_MIN; return (int64_t)r; }
static inline uint32_t cmp_pred_f(int p, float a, float b) {
    int r;
    switch (p & 7) { case 0: r = (a == b); break; case 1: r = (a < b); break; case 2: r = (a <= b); break; case 3: r = (a != a || b != b); break;
                     case 4: r = !(a == b); break; case 5: r = !(a < b); break; case 6: r = !(a <= b); break; default: r = !(a != a || b != b); }
    return r ? 0xFFFFFFFFu : 0;
}
static inline uint64_t cmp_pred_d(int p, double a, double b) {
    int r;
    switch (p & 7) { case 0: r = (a == b); break; case 1: r = (a < b); break; case 2: r = (a <= b); break; case 3: r = (a != a || b != b); break;
                     case 4: r = !(a == b); break; case 5: r = !(a < b); break; case 6: r = !(a <= b); break; default: r = !(a != a || b != b); }
    return r ? ~0ULL : 0;
}
#endif
