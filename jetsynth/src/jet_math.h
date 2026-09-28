/* jet_math.h -- the few math functions the jetsynth engine uses, self-contained
 * so the engine builds for wasm32 with no libc. Accuracy ~1e-6 relative,
 * plenty for a synthesiser (these never touch the JUNO FX arithmetic, which
 * keeps its own libm calls -- see jet_libc.c for the exact fmodf). */
#ifndef JET_MATH_H
#define JET_MATH_H
#include <stdint.h>
#include <stddef.h>

typedef union { float f; uint32_t u; } jet_fu;

static inline float jabs(float x) { jet_fu v; v.f = x; v.u &= 0x7fffffffu; return v.f; }
static inline float jsqrt(float x) { return x > 0.0f ? __builtin_sqrtf(x) : 0.0f; }

/* 2^x */
static inline float jexp2(float x)
{
    float fi, f, p;
    int i;
    jet_fu v;
    if (x < -126.0f) return 0.0f;
    if (x > 127.0f) x = 127.0f;
    fi = (float)(int)x;
    if (fi > x) fi -= 1.0f;                 /* floor */
    i = (int)fi;
    f = x - fi;                             /* [0,1) */
    /* 2^f, degree-6 Taylor in f*ln2 */
    {
        float t = f * 0.69314718f;
        p = 1.0f + t * (1.0f + t * (0.5f + t * (0.16666667f + t * (0.041666668f
            + t * (0.0083333333f + t * 0.0013888889f)))));
    }
    v.u = (uint32_t)(i + 127) << 23;
    return p * v.f;
}

/* log2(x), x > 0 */
static inline float jlog2(float x)
{
    jet_fu v;
    int e;
    float m, z, z2;
    if (!(x > 0.0f)) return -126.0f;
    v.f = x;
    e = (int)((v.u >> 23) & 0xff) - 127;
    v.u = (v.u & 0x007fffffu) | 0x3f800000u;  /* m in [1,2) */
    m = v.f;
    if (m > 1.41421356f) { m *= 0.5f; e += 1; }
    z = (m - 1.0f) / (m + 1.0f);
    z2 = z * z;
    return (float)e + 2.8853901f * z * (1.0f + z2 * (0.33333333f + z2 * (0.2f
           + z2 * (0.14285714f + z2 * 0.11111111f))));
}

/* sin(2*pi*t), any t */
static inline float jsin_turn(float t)
{
    float x, x2;
    t -= (float)(int)t;
    if (t < 0.0f) t += 1.0f;               /* [0,1) */
    if (t > 0.75f) t -= 1.0f;              /* (-0.25, 0.75] */
    if (t > 0.25f) t = 0.5f - t;           /* [-0.25, 0.25] */
    x = t * 6.2831853f;
    x2 = x * x;
    return x * (1.0f - x2 * (0.16666667f - x2 * (0.0083333333f - x2 * (0.00019841270f
           - x2 * 2.7557319e-6f))));
}
static inline float jsin(float rad) { return jsin_turn(rad * 0.15915494f); }
static inline float jcos(float rad) { return jsin_turn(rad * 0.15915494f + 0.25f); }
static inline float jcos_deg(float d) { return jsin_turn(d * (1.0f / 360.0f) + 0.25f); }

/* smooth limiter: linear near 0, |y| < 1 always */
static inline float jsoftclip(float x)
{
    if (x > 3.0f) return 1.0f;
    if (x < -3.0f) return -1.0f;
    return x * (27.0f + x * x) / (27.0f + 9.0f * x * x);
}

static inline void jmemset(void *d, int c, size_t n)
{
    unsigned char *p = (unsigned char *)d;
    while (n--) *p++ = (unsigned char)c;
}
#endif
