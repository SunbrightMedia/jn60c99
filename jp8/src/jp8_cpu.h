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
/* ---- build flavours (every flag OFF = the identity path layers 1-3 were proven on, byte for byte) ----
 * JP8_RELOC        guest addresses stay the oracle's 64-bit values; every access is translated to a host arena through
 *                  a 256 MB band table (no MAP_FIXED, no fixed host address; wasm32 / AArch64 / any 64-bit host).
 * JP8_RELOC_CHECK  + bounds check on every access: an access outside every mapped region traps (gate RED).
 * JP8_SOFTFP=1     FTZ/DAZ in software, the ORACLE's semantics (Unicorn 2.1.4): DAZ on inputs, a denormal IEEE result
 *                  becomes a signed zero, min/max compare the flushed values but return the ORIGINAL bits, MXCSR flags
 *                  never set. For hosts without x86 FTZ/DAZ (WASM, ARM) and for the oracle-judged gates.
 * JP8_SOFTFP=2     FTZ/DAZ in software, x86 HARDWARE semantics: tininess AFTER rounding (a product/quotient/narrowing
 *                  that rounds to FLT_MIN/DBL_MIN only through gradual underflow is flushed), min/max return the
 *                  flushed operand. (Flags are not modelled in either mode.) */
#if !defined(JP8_SOFTFP) && !(defined(__x86_64__) || defined(_M_X64))
#error "non-x86-64 host: define JP8_SOFTFP (the plugin runs at MXCSR 0x9FC0 = FTZ|DAZ|RNE; plain C floats give other bits on denormals)"
#endif
#ifndef JP8_SOFTFP
#include <xmmintrin.h>
#endif

typedef union { float f[4]; double d[2]; uint32_t u[4]; uint64_t q[2]; int32_t i[4]; int64_t l[2]; uint8_t b[16]; uint16_t w[8]; } X;
typedef struct {
    uint64_t r[16];          /* rax rcx rdx rbx rsp rbp rsi rdi r8..r15 */
    X x[16];
    int zf, sf, cf, of, pf;
    uint32_t mxcsr;
    uint64_t trap_rva;       /* set by jp8_trap before longjmp/abort */
    long ninstr;
} CPU;

#ifdef JP8_RELOC
#define JP8_NBANDS 128u                          /* 256 MB bands: guest addresses below 0x800000000 */
extern uintptr_t jp8_bdelta[JP8_NBANDS];         /* host = (uintptr_t)guest + delta (mod the host pointer width) */
extern uint32_t jp8_blo[JP8_NBANDS], jp8_bhi[JP8_NBANDS];  /* mapped band offsets [lo, hi); 0,0 = unmapped */
extern void jp8_fault(uint64_t a, unsigned n);   /* longjmps to the caller of jp8_call (gate RED); never returns */
extern uint32_t jp8_badacc;                      /* CHECK=2: sticky "an access missed every region", tested after each call */
extern unsigned char jp8_sink[64];               /* CHECK=2: where such an access lands instead */
static inline void *jp8_h(uint64_t a, unsigned n) {
    uint64_t i = a >> 28; uint32_t k = (uint32_t)(i & (JP8_NBANDS - 1));
#if JP8_RELOC_CHECK == 1                         /* gates: trap at the access (branchy: ~3.7x slower, measured) */
    uint32_t off = (uint32_t)(a & 0x0FFFFFFFu);
    if (i >= JP8_NBANDS || off < jp8_blo[k] || off + n > jp8_bhi[k]) jp8_fault(a, n);
#elif JP8_RELOC_CHECK == 2                       /* ship: branchless, the bad access is diverted and reported after the call */
    uint32_t off = (uint32_t)(a & 0x0FFFFFFFu);
    uint32_t bad = (uint32_t)(i >= JP8_NBANDS) | (uint32_t)(off < jp8_blo[k]) | (uint32_t)(off + n > jp8_bhi[k]);
    jp8_badacc |= bad;
    return bad ? (void *)jp8_sink : (void *)((uintptr_t)a + jp8_bdelta[k]);
#endif
    return (void *)((uintptr_t)a + jp8_bdelta[k]);
}
#define JP8_H(a, n) jp8_h((uint64_t)(a), (n))
#define JP8_GS_BASE 0x0ULL       /* the oracle's gs base is 0: gs:[x] = guest page 0 = band 0, exactly as under Unicorn */
#else
#define JP8_H(a, n) ((void *)(uintptr_t)(a))
#define JP8_GS_BASE 0x700020000ULL   /* the oracle's page 0 (gs base 0) mirrored here: BUF_BASE + 0x20000 */
#endif
#define R(n)      (c->r[n])
#define XF(n,l)   (c->x[n].f[l])
#define XD(n,l)   (c->x[n].d[l])
#define XU(n,l)   (c->x[n].u[l])
#define XQ(n,l)   (c->x[n].q[l])
#define XI(n,l)   (c->x[n].i[l])
#define XL(n,l)   (c->x[n].l[l])
#ifndef JP8_MQ
#define JP8_MQ volatile          /* the proven qualifier; -DJP8_MQ= drops it (speed; must be re-gated) */
#endif
#define M8(a)     (*(JP8_MQ uint8_t  *)JP8_H(a, 1))
#define M16(a)    (*(JP8_MQ uint16_t *)JP8_H(a, 2))
#define M32(a)    (*(JP8_MQ uint32_t *)JP8_H(a, 4))
#define M64(a)    (*(JP8_MQ uint64_t *)JP8_H(a, 8))
#define MF(a)     (*(JP8_MQ float    *)JP8_H(a, 4))
#define MD(a)     (*(JP8_MQ double   *)JP8_H(a, 8))
#define JP8_MX(a) (*(X *)JP8_H(a, 16))  /* a 128-bit memory source (was the inline (*(X*)(uintptr_t)a)) */
#define MS8(a)    ((int64_t)(int8_t)M8(a))
#define MS16(a)   ((int64_t)(int16_t)M16(a))
#define MS32(a)   ((int64_t)(int32_t)M32(a))

static inline void jp8_ldx(X *d, uint64_t a) { memcpy(d, (const void *)JP8_H(a, 16), 16); }
static inline void jp8_stx(uint64_t a, const X *s) { memcpy(JP8_H(a, 16), s, 16); }
/* rep movsb: the proven default is memcpy (NOT x86's forward byte copy when dst overlaps src ahead of it; site 0x72e4be
 * never reached); the relocated build uses the exact forward loop through M8 */
#ifdef JP8_RELOC
#define JP8_MOVSB() do { while (R(1)) { M8(R(7)) = M8(R(6)); R(7)++; R(6)++; R(1)--; } } while (0)
#else
#define JP8_MOVSB() do { memcpy((void*)(uintptr_t)R(7),(const void*)(uintptr_t)R(6),(size_t)R(1)); R(7)+=R(1); R(6)+=R(1); R(1)=0; } while (0)
#endif

extern void jp8_trap(CPU *c, uint64_t rva, const char *what);
extern void jp8_tr(CPU *c, uint64_t rva);        /* per-instruction trace record (lift --trace builds only) */
extern void jp8_icall(CPU *c, uint64_t target);   /* indirect call/jump through the lifted-function table */
extern void jp8_alloc(CPU *c);                   /* the CRT allocator hook point: ecx = size -> rax = bump pointer (zeroed) */
extern void jp8_import(CPU *c, int idx);         /* an import stub reached: shimmed exactly as jp8_emu._imp does */

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

/* ---- SSE arithmetic entry points (the lifter emits these; default = the proven plain C expression) ---- */
#ifndef JP8_SOFTFP
#define JP8_ADDSS(a,b) ((a)+(b))
#define JP8_SUBSS(a,b) ((a)-(b))
#define JP8_MULSS(a,b) ((a)*(b))
#define JP8_DIVSS(a,b) ((a)/(b))
#define JP8_ADDSD(a,b) ((a)+(b))
#define JP8_SUBSD(a,b) ((a)-(b))
#define JP8_MULSD(a,b) ((a)*(b))
#define JP8_DIVSD(a,b) ((a)/(b))
#define JP8_CVTSS2SD(a) ((double)(a))
#define JP8_CVTSD2SS(a) ((float)(a))
#define JP8_SQRTSS(a) sqrtf(a)
#define JP8_SQRTSD(a) sqrt(a)
#define JP8_DAZF(a) (a)
#define JP8_DAZD(a) (a)
#define JP8_LDMXCSR(c,v) do { (c)->mxcsr=(v); _mm_setcsr((c)->mxcsr); } while (0)
#define JP8_STMXCSR(c) _mm_getcsr()
#else
static inline uint32_t jp8_fb(float x) { uint32_t u; memcpy(&u, &x, 4); return u; }
static inline float jp8_bf(uint32_t u) { float x; memcpy(&x, &u, 4); return x; }
static inline uint64_t jp8_db(double x) { uint64_t u; memcpy(&u, &x, 8); return u; }
static inline double jp8_bd(uint64_t u) { double x; memcpy(&x, &u, 8); return x; }
/* DAZ (and FTZ of an already-rounded result): exponent field 0 -> zero of the same sign. Hardware == oracle here. */
/* branchless on purpose: a branch per operand costs ~20 cycles in code this large (BTB misses; measured 5x) */
static inline float jp8_dazf(float x) { uint32_t u = jp8_fb(x); return jp8_bf(u & (0x80000000u | (0u - (uint32_t)((u & 0x7F800000u) != 0)))); }
static inline double jp8_dazd(double x) { uint64_t u = jp8_db(x); return jp8_bd(u & (0x8000000000000000ULL | (0ULL - (uint64_t)((u & 0x7FF0000000000000ULL) != 0)))); }
#if defined(__GNUC__)
#define JP8_RARE(x) __builtin_expect(!!(x), 0)
#else
#define JP8_RARE(x) (x)
#endif
#define JP8_DAZF(a) jp8_dazf(a)
#define JP8_DAZD(a) jp8_dazd(a)
/* |r| == FLT_MIN / DBL_MIN after gradual-underflow rounding: x86 hardware flushes iff the value rounded with an
 * UNBOUNDED exponent is below MIN; the same operation on operands scaled by 2^64 (2^600) cannot underflow, so its
 * rounding IS the unbounded one (threshold scaled alike). add/sub never need it: a tiny sum is exact. */
static inline int jp8_isminf(float r) { return (jp8_fb(r) & 0x7FFFFFFFu) == 0x00800000u; }
static inline int jp8_ismind(double r) { return (jp8_db(r) & 0x7FFFFFFFFFFFFFFFULL) == 0x0010000000000000ULL; }
static inline float jp8_sz_f(float r) { return jp8_bf(jp8_fb(r) & 0x80000000u); }
static inline double jp8_sz_d(double r) { return jp8_bd(jp8_db(r) & 0x8000000000000000ULL); }
/* the x86 SSE NaN rules, enforced (ARM makes 0x7FC00000 for an invalid op, WASM leaves sign/payload open; PROVEN on
 * AArch64: the boot writes 3,851 x86 default NaNs 0xFFC00000 into the state): an operand NaN wins, first source
 * first, quieted; an invalid operation gives 0xFFC00000 / 0xFFF8000000000000. Then FTZ. */
static inline float jp8_fixf(float r, float a, float b) {
    uint32_t u = jp8_fb(r);
    if (JP8_RARE((u & 0x7F800000u) == 0x7F800000u) && (u & 0x007FFFFFu)) {
        uint32_t ua = jp8_fb(a), ub = jp8_fb(b);
        if ((ua & 0x7FFFFFFFu) > 0x7F800000u) return jp8_bf(ua | 0x00400000u);
        if ((ub & 0x7FFFFFFFu) > 0x7F800000u) return jp8_bf(ub | 0x00400000u);
        return jp8_bf(0xFFC00000u);
    }
    return jp8_dazf(r);
}
static inline double jp8_fixd(double r, double a, double b) {
    uint64_t u = jp8_db(r);
    if (JP8_RARE((u & 0x7FF0000000000000ULL) == 0x7FF0000000000000ULL) && (u & 0x000FFFFFFFFFFFFFULL)) {
        uint64_t ua = jp8_db(a), ub = jp8_db(b);
        if ((ua & 0x7FFFFFFFFFFFFFFFULL) > 0x7FF0000000000000ULL) return jp8_bd(ua | 0x0008000000000000ULL);
        if ((ub & 0x7FFFFFFFFFFFFFFFULL) > 0x7FF0000000000000ULL) return jp8_bd(ub | 0x0008000000000000ULL);
        return jp8_bd(0xFFF8000000000000ULL);
    }
    return jp8_dazd(r);
}
static inline float jp8_addss(float a, float b) { a = jp8_dazf(a); b = jp8_dazf(b); return jp8_fixf(a + b, a, b); }
static inline float jp8_subss(float a, float b) { a = jp8_dazf(a); b = jp8_dazf(b); return jp8_fixf(a - b, a, b); }
static inline double jp8_addsd(double a, double b) { a = jp8_dazd(a); b = jp8_dazd(b); return jp8_fixd(a + b, a, b); }
static inline double jp8_subsd(double a, double b) { a = jp8_dazd(a); b = jp8_dazd(b); return jp8_fixd(a - b, a, b); }
static inline float jp8_mulss(float a, float b) {
    float r; a = jp8_dazf(a); b = jp8_dazf(b); r = a * b;
#if JP8_SOFTFP == 2
    if (JP8_RARE(jp8_isminf(r)) && fabsf((a * 0x1p64f) * b) < 0x1p-62f) return jp8_sz_f(r);
#endif
    return jp8_fixf(r, a, b);
}
static inline float jp8_divss(float a, float b) {
    float r; a = jp8_dazf(a); b = jp8_dazf(b); r = a / b;
#if JP8_SOFTFP == 2
    if (JP8_RARE(jp8_isminf(r)) && fabsf((a * 0x1p64f) / b) < 0x1p-62f) return jp8_sz_f(r);
#endif
    return jp8_fixf(r, a, b);
}
static inline double jp8_mulsd(double a, double b) {
    double r; a = jp8_dazd(a); b = jp8_dazd(b); r = a * b;
#if JP8_SOFTFP == 2
    if (JP8_RARE(jp8_ismind(r)) && fabs((a * 0x1p600) * b) < 0x1p-422) return jp8_sz_d(r);
#endif
    return jp8_fixd(r, a, b);
}
static inline double jp8_divsd(double a, double b) {
    double r; a = jp8_dazd(a); b = jp8_dazd(b); r = a / b;
#if JP8_SOFTFP == 2
    if (JP8_RARE(jp8_ismind(r)) && fabs((a * 0x1p600) / b) < 0x1p-422) return jp8_sz_d(r);
#endif
    return jp8_fixd(r, a, b);
}
static inline float jp8_cvtsd2ss(double x) {
    float r; uint64_t ux = jp8_db(x);
    if (JP8_RARE((ux & 0x7FFFFFFFFFFFFFFFULL) > 0x7FF0000000000000ULL))      /* NaN: quiet, keep the top 22 payload bits */
        return jp8_bf((uint32_t)(ux >> 32 & 0x80000000u) | 0x7FC00000u | (uint32_t)((ux >> 29) & 0x003FFFFFu));
    x = jp8_dazd(x); r = (float)x;
#if JP8_SOFTFP == 2
    if (JP8_RARE(jp8_isminf(r)) && fabs(x) < 0x1.ffffffp-127) return jp8_sz_f(r);   /* 2^-126 - 2^-151, exact in double */
#endif
    return jp8_dazf(r);
}
#define JP8_ADDSS(a,b) jp8_addss((a),(b))
#define JP8_SUBSS(a,b) jp8_subss((a),(b))
#define JP8_MULSS(a,b) jp8_mulss((a),(b))
#define JP8_DIVSS(a,b) jp8_divss((a),(b))
#define JP8_ADDSD(a,b) jp8_addsd((a),(b))
#define JP8_SUBSD(a,b) jp8_subsd((a),(b))
#define JP8_MULSD(a,b) jp8_mulsd((a),(b))
#define JP8_DIVSD(a,b) jp8_divsd((a),(b))
static inline double jp8_cvtss2sd(float x) {
    uint32_t u = jp8_fb(x);
    if (JP8_RARE((u & 0x7FFFFFFFu) > 0x7F800000u))                          /* NaN: quiet, payload widened */
        return jp8_bd((uint64_t)(u & 0x80000000u) << 32 | 0x7FF8000000000000ULL | (uint64_t)(u & 0x003FFFFFu) << 29);
    return (double)jp8_dazf(x);
}
static inline float jp8_sqrtss(float x) { x = jp8_dazf(x); return jp8_fixf(sqrtf(x), x, x); }
static inline double jp8_sqrtsd(double x) { x = jp8_dazd(x); return jp8_fixd(sqrt(x), x, x); }
#define JP8_CVTSS2SD(a) jp8_cvtss2sd(a)
#define JP8_CVTSD2SS(a) jp8_cvtsd2ss(a)
#define JP8_SQRTSS(a) jp8_sqrtss(a)
#define JP8_SQRTSD(a) jp8_sqrtsd(a)
/* MXCSR is a software register: the engine is only defined at FTZ|DAZ|RNE (0x9FC0 class); any other mode traps. The
 * oracle never sets exception flags (PROVEN: stmxcsr after an inexact mulss reads 0x9FC0 under Unicorn 2.1.4). */
#define JP8_LDMXCSR(c,v) do { (c)->mxcsr=(v); if (((c)->mxcsr & 0xE040u) != 0x8040u) jp8_trap((c), 0, "ldmxcsr: mode other than FTZ|DAZ|RNE"); } while (0)
#define JP8_STMXCSR(c) ((c)->mxcsr)
#endif

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
    a = JP8_DAZF(a); b = JP8_DAZF(b);
    if (a != a || b != b) { c->zf = c->pf = c->cf = 1; } else { c->zf = (a == b); c->cf = (a < b); c->pf = 0; } c->of = c->sf = 0;
}
static inline void cmp_d(CPU *c, double a, double b) {
    a = JP8_DAZD(a); b = JP8_DAZD(b);
    if (a != a || b != b) { c->zf = c->pf = c->cf = 1; } else { c->zf = (a == b); c->cf = (a < b); c->pf = 0; } c->of = c->sf = 0;
}
/* hardware min/max: return the SECOND operand when the compare is false (NaN, equal, signed zeros) */
#if !defined(JP8_SOFTFP)       /* NOTE: gcc -O1 turns these into minss/maxss (hardware DAZ result), -O0 into comiss+select */
static inline float  fmin_ss(float a, float b)   { return (a < b) ? a : b; }
static inline float  fmax_ss(float a, float b)   { return (a > b) ? a : b; }
static inline double fmin_sd(double a, double b) { return (a < b) ? a : b; }
static inline double fmax_sd(double a, double b) { return (a > b) ? a : b; }
#elif JP8_SOFTFP == 2          /* hardware: the flushed operand is returned (PROVEN T5 T6 T11) */
static inline float  fmin_ss(float a, float b)   { a = jp8_dazf(a); b = jp8_dazf(b); return (a < b) ? a : b; }
static inline float  fmax_ss(float a, float b)   { a = jp8_dazf(a); b = jp8_dazf(b); return (a > b) ? a : b; }
static inline double fmin_sd(double a, double b) { a = jp8_dazd(a); b = jp8_dazd(b); return (a < b) ? a : b; }
static inline double fmax_sd(double a, double b) { a = jp8_dazd(a); b = jp8_dazd(b); return (a > b) ? a : b; }
#else                          /* oracle: compares flushed, returns the ORIGINAL bits (PROVEN T5 T6 T11) */
static inline float  fmin_ss(float a, float b)   { return (jp8_dazf(a) < jp8_dazf(b)) ? a : b; }
static inline float  fmax_ss(float a, float b)   { return (jp8_dazf(a) > jp8_dazf(b)) ? a : b; }
static inline double fmin_sd(double a, double b) { return (jp8_dazd(a) < jp8_dazd(b)) ? a : b; }
static inline double fmax_sd(double a, double b) { return (jp8_dazd(a) > jp8_dazd(b)) ? a : b; }
#endif
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
    a = JP8_DAZF(a); b = JP8_DAZF(b);
    int r;
    switch (p & 7) { case 0: r = (a == b); break; case 1: r = (a < b); break; case 2: r = (a <= b); break; case 3: r = (a != a || b != b); break;
                     case 4: r = !(a == b); break; case 5: r = !(a < b); break; case 6: r = !(a <= b); break; default: r = !(a != a || b != b); }
    return r ? 0xFFFFFFFFu : 0;
}
static inline uint64_t cmp_pred_d(int p, double a, double b) {
    a = JP8_DAZD(a); b = JP8_DAZD(b);
    int r;
    switch (p & 7) { case 0: r = (a == b); break; case 1: r = (a < b); break; case 2: r = (a <= b); break; case 3: r = (a != a || b != b); break;
                     case 4: r = !(a == b); break; case 5: r = !(a < b); break; case 6: r = !(a <= b); break; default: r = !(a != a || b != b); }
    return r ? ~0ULL : 0;
}
#endif
