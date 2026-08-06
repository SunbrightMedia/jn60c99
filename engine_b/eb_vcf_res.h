/* eb_vcf_res.h — the VCF resonance/drive shaper: the exp-polynomial that turns
 * the cutoff CV into a filter coefficient, and the rational function that turns
 * that into the ladder's feedback term.
 *
 * SCOPE. src/voice_render.c:1230-1297 exactly. It sits between module
 * 'vcf_cv' (which produces its input, the port's v227) and the ladder.
 *
 * TWO THINGS THE MECHANICAL ANALYSIS GOT WRONG HERE, both caught by reading
 * the code and both worth recording because the scripts will get them wrong
 * again:
 *
 *  1. CELLS 7520 AND 7536 ARE STATE, not locals. The read-before-write
 *     classifier says "written at :1292 and :1242, read at :1296 and later",
 *     i.e. local. But the WRITES are inside the `if (cell 7632 == 1.0)` arm and
 *     the READS are in the `else` arm. Across samples they carry. A
 *     classifier that cannot see branch structure cannot see this, and
 *     treating them as locals would silently zero the filter every time the
 *     block took its else path.
 *
 *  2. CELL 8192 IS INVISIBLE TO A `JF(a1, N)` GREP. The port reaches it as
 *     `*(float *)(a1 + 0x2000)`. A sweep of the whole voice function found
 *     exactly one such raw-pointer access, and this is it -- so the cell
 *     inventory for every other block in this file is sound, but only because
 *     that was checked rather than assumed.
 *
 * STATE: 7520, 7536, 7552, 7568. COEFFICIENTS: 37, including 8192.
 * There are no dead stores in this block.
 *
 * `ebr_wrap24` is a transcription of the port's juno_wrap24 (src/juno_dsp.c),
 * copied rather than called so the module depends on no port CODE. It is the
 * same bit ladder as the noise LFSR's; the bit fiddling IS the algorithm.
 */
#ifndef ENGINEB_EB_VCF_RES_H
#define ENGINEB_EB_VCF_RES_H

typedef struct {
    float s7520, s7536, s7552, s7568;
    int   cr_phase;        /* C2 control-rate counter; unused when CR == 1 */
} eb_vcf_res_state;

typedef struct {
    float k7600, k7616, k7632, k7648, k7664, k7680, k7696, k7712, k7728;
    float k7744, k7760, k7776, k7792, k7824, k7840, k7856, k7872, k7888;
    float k7904, k7920, k7936, k7952, k7968, k7984, k8000, k8016, k8032;
    float k8048, k8064, k8080, k8096, k8112, k8128, k8144, k8160, k8176;
    float k8192;                      /* the raw-pointer cell; see above */
#ifndef EB_VCF_RES_LUT
#define EB_VCF_RES_LUT 0
#endif
#if EB_VCF_RES_LUT
    /* LAST in the struct, so a target can place it. One extra entry so the
     * interpolation's i+1 is always in range without a branch. */
    float lut[EB_VCF_RES_LUT + 1];
#endif
} eb_vcf_res_coef;

#if EB_VCF_RES_LUT
/* Fills the table. MUST be called after the k members are set and before the
 * first tick -- every coefficient builder calls it. */
void eb_vcf_res_prepare(eb_vcf_res_coef *c);
#endif

/* One sample. `cv` is the port's v227 (module vcf_cv's output); `in6704` and
 * `in6848` are that module's two side outputs. Returns the port's v241, the
 * ladder's feedback coefficient. `out7536` returns cell 7536, which later port
 * code reads. */
float eb_vcf_res_tick(eb_vcf_res_state *s, const eb_vcf_res_coef *c,
                      float cv, float in6704, float in6848, float *out7536);

#endif /* ENGINEB_EB_VCF_RES_H */
