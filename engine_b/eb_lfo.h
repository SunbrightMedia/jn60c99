/* eb_lfo.h — the LFO: rate, delay envelope, master phase, six waveforms and
 * the internal/external output mix.
 *
 * SCOPE. src/voice_render.c:797-963 exactly. The boundary was not chosen by
 * eye; it was computed. A live-variable analysis over that range finds
 * FOUR live-in scalars and, decisively, **ZERO live-out scalars** — every
 * value the block computes either dies inside it or leaves through a memory
 * cell. A block with no live-out registers is a block that can be lifted into
 * a function without threading anything back, which is why this range and not
 * a tidier-looking one.
 *
 * WHAT THE STATE ACTUALLY IS, and this is the part that had to be measured
 * rather than assumed. The block touches eighteen cells with both a read and a
 * write. Only FIVE of them are state: for the other thirteen the WRITE comes
 * first and the read afterwards, so the old value is never used and the cell is
 * a local wearing a cell's clothes. Six of those thirteen are the port's
 * delayed-copy idiom (1584 <- 1568, 1616 <- 1600, 1552 <- 1536 ...), which
 * looks like carried state and is not: the copy is made at the top of the
 * sample and consumed further down the same sample.
 *
 * This is the same finding as the noise SVF's cell 4320, and it is the reason
 * that analysis is done by script here (see the classification in the commit
 * that added this file) instead of by reading. Getting it wrong in the other
 * direction — carrying a cell that is really a local — would silently couple
 * consecutive samples.
 *
 *   TRUE STATE (read before written), 5 floats:
 *     1488  ext-gate sample-and-hold           (v80 = old value)
 *     1504  delay-envelope ramp                (v78 = old value)
 *     1536  LFO master phase                   (v81 = old value)
 *     1568  key-trigger smoother               (via its 1584 copy)
 *     1600  sample-and-hold register           (via its 1616 copy)
 *
 * SEVEN DEAD STORES are not reproduced: 1136, 1520, 1648, 1664, 1744, 1776,
 * 1840. Each was GREPPED across all of src/ and gui/ including
 * master_render.c's pointer-arithmetic forms: no reader anywhere. 1744 is the
 * "LFO sine out" cell and is genuinely dead — the sine value reaches the mix
 * through the C local v117, not through the cell.
 *
 * ONE DISCARDED CALL is not reproduced either: the port computes
 * `fmodf(v107 +/- 1, 2)` and throws the result away, then passes the UNWRAPPED
 * v107 to juno_triangle, which wraps internally. fmodf has no side effects, so
 * dropping the discarded call cannot change a bit. (The comment at
 * src/voice_render.c:899 records why v107 and v108 are different phases; that
 * distinction is preserved here.)
 *
 * THE INT/FLOAT CELLS. 1424, 1440 and 1456 are written with JI (a raw 32-bit
 * copy) and read back with JF. That is a REINTERPRET, not a conversion — the
 * hazard that broke the project's scratch-cell pilot 1 on 155 dual-typed
 * cells. Here the chain is `JI(dst) = JI(src); ... JF(dst)`, which is exactly
 * the float value at `src`, so the module takes them as floats and the
 * reinterpret disappears. The shim passes JF of the source cells, not JI.
 */
#ifndef ENGINEB_EB_LFO_H
#define ENGINEB_EB_LFO_H

typedef struct {
    float s1488;               /* ext-gate S&H            */
    float s1504;               /* delay-envelope ramp     */
    float s1536;               /* master phase            */
    float s1568;               /* key-trigger smoother    */
    float s1600;               /* sample-and-hold         */
} eb_lfo_state;

/* 47 recall-rate coefficients. Named by their port cell offset on purpose:
 * every one of them is checkable against src/voice_render.c by grep. */
typedef struct {
    float k1056, k1072, k1184, k1200, k1216;
    float k1856, k1872, k1888, k1904, k1920, k1936, k1952, k1968, k1984;
    float k2000, k2016, k2032, k2048, k2064, k2080, k2096, k2112, k2128;
    float k2144, k2160, k2176, k2192, k2208, k2224, k2240, k2256, k2272;
    float k2288, k2304, k2320, k2336, k2352, k2368, k2384, k2400, k2416;
    float k2432, k2448, k2464, k2480, k2496, k2512;
} eb_lfo_coef;

/* One sample.
 *
 *   dly_env  the clamped delay-envelope level  (the port's v73, live-in)
 *   ext_gate cell 944, the external gate input (v64)
 *   ext0     cell 976  read as a FLOAT          (see the note above)
 *   ext1     cell 1008 read as a FLOAT
 *   noise    the engine-wide noise sample, base+84432, read as a FLOAT
 *
 * Returns the LFO OUT value the port stores in cell 1792. `out1808` returns
 * the pre-switch waveform mix (cell 1808) and `out1824` the pulse comparator
 * output (cell 1824); both are read later in the port's voice function, so
 * they are outputs and not internal values. */
#ifndef EB_LFO_TAIL_CR
#define EB_LFO_TAIL_CR 0     /* L-B (b24 §4.1): trunk cannot move */
#endif
#if EB_LFO_TAIL_CR
/* ⚠ L-B's EXACTNESS IS BORROWED FROM THE CR FLAGS, so it must not compile
 * without them (b29 hunt, the lever's one latent defect: it had NO guard).
 *
 * The tail publishes lfo_del / lfo_und / lfo_pul. Skipping it on odd cr_ph is
 * exact ONLY because every consumer reads on even cr_ph:
 *   env gate k0/k1   inside CR_RUN(EB_CR_ENV,   EB_CR_NE)
 *   eb_modcv_tick    inside CR_RUN(EB_CR_MODCV, EB_CR_NP)
 *   eb_vcf_cv_tick   inside CR_RUN(EB_CR_VCFCV, EB_CR_NC)
 * Turn any of those off, or make its period ODD, and a consumer reads a
 * one-sample-stale LFO -> the fork null is no longer EXACTLY 0. Measured
 * silently wrong is exactly what this project refuses to ship, so it is a
 * hard compile error rather than a comment. */
#if !EB_CR_VCFCV || !EB_CR_MODCV || !EB_CR_ENV
#error "EB_LFO_TAIL_CR needs EB_CR_VCFCV, EB_CR_MODCV and EB_CR_ENV all ON: its skip is exact only because every LFO-tail consumer is gated to even cr_ph."
#endif
#if (EB_CR_NC % 2) || (EB_CR_NP % 2) || (EB_CR_NE % 2)
#error "EB_LFO_TAIL_CR needs EB_CR_NC, EB_CR_NP and EB_CR_NE all EVEN: an odd period puts a consumer on an odd cr_ph, where the LFO tail was skipped."
#endif
#endif
#if EB_LFO_TAIL_CR
void eb_lfo_advance(eb_lfo_state *s, const eb_lfo_coef *c,
                    float dly_env, float ext_gate,
                    float ext0, float ext1, float noise);
#endif
float eb_lfo_tick(eb_lfo_state *s, const eb_lfo_coef *c,
                  float dly_env, float ext_gate,
                  float ext0, float ext1, float noise,
                  float *out1808, float *out1824);

#endif /* ENGINEB_EB_LFO_H */
