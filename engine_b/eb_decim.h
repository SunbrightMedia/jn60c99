/* eb_decim.h — the 4x polyphase decimator and its correction biquad.
 *
 * WHAT THIS BLOCK IS. The DCO runs at 4x the host rate. Its four sub-samples
 * are pushed into four 8-deep delay lines (the port's cells 4944.., 5072..,
 * 5200.., 5328..), a 32-tap symmetric FIR reduces them to one sample, and a
 * correction biquad follows. This is the anti-imaging filter, so it is part of
 * how the JUNO's aliasing sounds and not an implementation detail that may be
 * improved.
 *
 * PROVENANCE. Every coefficient cell, every tap pairing and the exact order of
 * accumulation are READ from src/voice_render.c:1697-1702 (the line shift) and
 * :2134-2173 (the FIR, the biquad and the output). The port's accumulation is
 * strictly left-nested and is reproduced term for term: a regrouping of a
 * 16-term float sum is a different number, and this project has already been
 * bitten twice by algebraically identical rewrites.
 *
 * WHAT ENGINE B CHANGES, and why it is EXACT.
 *   The port SHIFTS the delay lines: 30 cell-to-cell moves per voice per audio
 *   sample, 240 per sample at full polyphony, purely to make "one sample ago"
 *   live at a fixed address. Engine B keeps a rotating index instead. No
 *   arithmetic changes at all -- the same 32 floats are multiplied by the same
 *   32 coefficients in the same order; only the address they are read from
 *   differs. So the null must be EXACTLY 0, and if it is not, that is a defect
 *   and not a budget.
 *
 * TAP MAP, transcribed and then checked back against the port line by line.
 * Phase p in 0..3 is the sub-sample; k is age in samples, 0 = newest:
 *
 *     phase 0  cells 4944 + 16k      phase 2  cells 5200 + 16k
 *     phase 1  cells 5072 + 16k      phase 3  cells 5328 + 16k
 *
 * and the sixteen pairs, in the port's own accumulation order:
 *
 *     (p2 k7, p1 k0) c5712     (p3 k7, p0 k0) c5696     (p2 k0, p1 k7) c5728
 *     (p3 k0, p0 k7) c5744     (p3 k6, p0 k1) c5760     (p2 k6, p1 k1) c5776
 *     (p2 k1, p1 k6) c5792     (p3 k1, p0 k6) c5808     (p3 k5, p0 k2) c5824
 *     (p1 k2, p2 k5) c5840     (p2 k2, p1 k5) c5856     (p0 k5, p3 k2) c5872
 *     (p3 k4, p0 k3) c5888     (p2 k4, p1 k3) c5904     (p2 k3, p1 k4) c5920
 *     (p3 k3, p0 k4) c5936
 *
 * Note the tenth pair is written (p1, p2) and not (p2, p1). Float addition is
 * commutative and exact for a pair, so that one is presentational -- but it is
 * kept in the port's order anyway, because "this one is safe to reorder" is the
 * reasoning that has been wrong here before.
 */
#ifndef ENGINEB_EB_DECIM_H
#define ENGINEB_EB_DECIM_H

#define EB_HALFOS_RING 32u

typedef struct {
    float h[4][8];        /* four phases, eight samples of history each      */
    unsigned w;           /* rotating index; the newest sample sits at h[p][w] */
    /* HALF-OVERSAMPLING ring (EB_HALF_OS). Declared UNCONDITIONALLY so the
     * struct's size and layout do not depend on a build flag -- a state
     * struct that changes shape with a fork flag is how a saved/restored
     * context silently means something different in two builds. 32 floats is
     * 128 bytes per voice; the 4x path leaves them zero. */
    float hb[32];
    unsigned wb;
    float b1, b2, b3;     /* the biquad state: port cells 5488, 5472, 5504   */
} eb_decim_state;

typedef struct {
    float c[16];          /* the 16 FIR pair coefficients, in the order above */
    float k6256, k6272, k6336;   /* the biquad's three coefficients          */
    /* CELL 5456 IS NOT HERE, AND THAT IS THE POINT. It used to be, and it was
     * wrong: src/voice_render.c WRITES it every sample, at :1717, as
     * fmaxf(0, (cell3776 + k6304) * k6320 + k6288) -- it is eb_dcoprep's third
     * output, derived from the modulated pitch sum. Caching it froze a moving
     * value. It is a per-sample ARGUMENT below, so the type system now refuses
     * the mistake. See tools/engineb/coef_audit.py, which is the check that
     * found it. */
} eb_decim_coef;

/* Push one audio sample's four sub-samples and produce the decimated output.
 * s0..s3 are the port's 4944 / 5072 / 5200 / 5328 for THIS sample; k5456 is
 * this sample's cell 5456 (eb_dcoprep_tick's out5456). */
float eb_decim_tick(eb_decim_state *s, const eb_decim_coef *c, float k5456,
                    float s0, float s1, float s2, float s3);

#endif /* ENGINEB_EB_DECIM_H */
