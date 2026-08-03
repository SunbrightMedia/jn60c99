/* GENERATED FILE -- DO NOT EDIT.
 * tools/engineb/merge_shims.py built this from the individual shims:
 *     cvgate, dco, decim, env, glide, lfo, noise_svf, noisemix, notecv, pitch, pwm_cv, vca_hpf, vcf_cv, vcf_ladder, vcf_res
 * Edit those, then re-run the generator (make engineb does it).
 * Its purpose: engine B cannot be tested as a WHOLE ENGINE while each
 * module shadows the same port file -- see docs/engineb/HARNESS_AUDIT.md
 * finding F1, where a composite build silently linked 2 modules of 10.
 */
/* ---- from shim 'cvgate' ---- */
/* SHIM — MODULE CVGATE (engine_b/eb_cvgate.{h,c}).
 * Replaces the ARITHMETIC of src/voice_render.c:657-680. The cell writes keep
 * the port's own positions and order -- see the note inside. STATELESS, so no
 * home for state and no power-on marker. */
#include "eb_cvgate.h"
/* ---- from shim 'dco' ---- */
/* engine_b/shim/dco/voice_render.c — VERBATIM FORK of src/voice_render.c with
 * ONE block replaced: the DCO oscillator, src/voice_render.c:1718-2136 (the
 * four 4x-oversampled sub-blocks; the brief's 1718-1830 is sub-block one).
 * Everything else in this file is the port's own code, byte for byte, so a
 * divergence under tools/engineb/null_b.py --module dco is attributable to the
 * DCO module and to nothing else. See engine_b/eb_dco.h.
 */
#include "eb_dco.h"     /* -I engine_b/ is supplied by the harness */

/* ---- from shim 'decim' ---- */
/* SHIM — MODULE DECIM (engine_b/eb_decim.{h,c}).
 * Replaces two separate pieces of src/voice_render.c that belong to ONE block:
 * the 30-cell delay-line shift at :1697-1702 and the 32-tap polyphase FIR plus
 * correction biquad at :2134-2173. Nothing else in this file differs from the
 * port -- diff them -- so a divergence under `null_b.py --module decim` is
 * attributable to the decimator and to nothing else.
 *
 * The per-voice state lives in engine B, not in the port's cells, so the cells
 * the shift used to maintain (4944..5440, 5472, 5488, 5504) are no longer
 * written. That is only safe because the FIR is their sole reader, which was
 * checked by grep over src/ before this shim was written and is re-checked by
 * the null: if anything else read them, the residual would not be zero. */
#include "eb_decim.h"
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

#include "eb_types.h"
/* ENGINE B OWNS THIS STATE, in eb_voice -- not in the port's cells.
 *
 * THE PROBLEM A SHIM HAS, and it is why this module could not be gated at all
 * before: a shim has nowhere per-context to put state. The harness builds a NEW
 * engine context for every scenario, so a plain `static` array carries scenario
 * N's filter history into scenario N+1. Keying on the context pointer does not
 * fix it either -- malloc reuses addresses, so a fresh context can land on the
 * old pointer and skip the reset. That is a silent wrong answer, which is the
 * one kind of failure this project cannot afford.
 *
 * THE MARKER. src/chorus_init.c:218 zeroes cell 5440 at power-on. Once this
 * shim removes the 30-move shift, NOTHING else in the engine writes 5440: the
 * DCO writes only 4944/5072/5200/5328 (:1807, :1911, :2015, :2117) and the only
 * reader of 5440 was the FIR itself, which now lives in engine B. So a zero in
 * 5440 means "this context has just been built", exactly once per context, and
 * it survives address reuse because it is the PORT that zeroes it.
 *
 * LIMITATION, stated rather than discovered later: EBV is one array, so exactly
 * one engine context may be rendered at a time in a process. The harness renders
 * scenarios sequentially, so that holds today. It stops being a limitation at
 * all in the standalone engine, where eb_voice lives inside the eb_engine the
 * caller owns (docs/engineb/STANDALONE.md). */
static eb_voice EBV[8];
static eb_decim_coef EBDC[8];
static float EBDRAW[8][20];
static unsigned char EBDHAVE[8];
static unsigned long EBDGEN_SEEN[8];
#include <string.h>

/* ---- from shim 'env' ---- */
/* engine_b/shim/env/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the two ADSR envelope generators (module M7).
 * Everything else in this file is the port's own code, byte for byte, so a
 * divergence under tools/engineb/null_b.py --module env is attributable to the
 * envelope module and to nothing else. See engine_b/eb_envgen.h.
 */
#include "eb_envgen.h"
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif
     /* -I engine_b/ is supplied by the harness */

/* ---- from shim 'glide' ---- */
/* engine_b/shim/glide/voice_render.c — VERBATIM FORK of src/voice_render.c with
 * ONE block replaced: portamento/glide + the pitch CV + the LFO rate and
 * delay-envelope chain, lines 682-796, module engine_b/eb_glide.{h,c}.
 */
#include "eb_glide.h"
#include <string.h>
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu).\n",              \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_glide_coef  EBGC[8];
static unsigned char  EBGHAVE[8];
static unsigned long  EBGGEN_SEEN[8];

/* ---- from shim 'lfo' ---- */
/* engine_b/shim/lfo/voice_render.c — VERBATIM FORK of src/voice_render.c with
 * ONE block replaced: the LFO, lines 797-963, which is module
 * engine_b/eb_lfo.{h,c}. Diff this file against src/voice_render.c: that block
 * and this preamble are the only changes, so a divergence under
 * tools/engineb/null_b.py --module lfo is attributable to the LFO and to
 * nothing else.
 */
#include "eb_lfo.h"
#include <string.h>
/* COEFFICIENT GENERATION GUARD -- see the note on eb_coef_gen in
 * gui/juno_bridge.c and the identical preamble in the other shims. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_lfo_coef   EBLC[8];
static unsigned char EBLHAVE[8];
static unsigned long EBLGEN_SEEN[8];

/* ---- from shim 'noise_svf' ---- */
/* SHIM — MODULE NOISE_SVF (engine_b/eb_noise_svf.{h,c}).
 * Replaces src/voice_render.c:1129-1140, the Chamberlin noise filter. Nothing
 * else in this file differs from the port, so a divergence under
 * `null_b.py --module noise_svf` is attributable to this filter alone.
 *
 * State lives in eb_voice, not the port's cells, with the same power-on marker
 * the decimator uses -- cell 5440 is zeroed by src/chorus_init.c:218 and, once
 * the decimator's shim removes the 30-move shift, nothing else writes it. Here
 * the marker cell must be one THIS shim owns, so it uses 4288 instead: the port
 * zeroes it at power-on (chorus_init) and only this filter writes it.
 */
#include "eb_noise_svf.h"
#include <string.h>
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_nsvf_coef EBNC[8];
static unsigned char EBNCHAVE[8];
static unsigned long EBNGEN_SEEN[8];

#include "eb_types.h"
static eb_nsvf_state EBN[8];
static unsigned char EBN_seen[8];
/* ---- from shim 'noisemix' ---- */
/* engine_b/shim/noisemix/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the noise SVF output mix, lines 1141-1149, module
 * engine_b/eb_noisemix.{h,c}.
 */
#include "eb_noisemix.h"
#include <string.h>
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu).\n",              \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_noisemix_coef EBXC[8];
static unsigned char    EBXHAVE[8];
static unsigned long    EBXGEN_SEEN[8];

/* ---- from shim 'notecv' ---- */
/* engine_b/shim/notecv/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the shared noise generator and the note/gate/
 * velocity conditioning, lines 594-681, module engine_b/eb_notecv.{h,c}.
 */
#include "eb_notecv.h"
#include <string.h>
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu).\n",              \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_notecv_coef EBTC[8];
static unsigned char  EBTHAVE[8];
static unsigned long  EBTGEN_SEEN[8];

/* ---- from shim 'pitch' ---- */
/* SHIM — MODULE PITCH (engine_b/eb_pitch.{h,c}).
 * Replaces src/voice_render.c:1641-1664, the pitch polynomial. STATELESS, so
 * unlike every other module written this week it needs no home for its state
 * and no power-on marker. Nothing else in this file differs from the port. */
#include "eb_pitch.h"
/* ---- from shim 'pwm_cv' ---- */
/* engine_b/shim/pwm_cv/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE range replaced: the pitch / PWM modulation CV block,
 * src/voice_render.c:1076-1128, which is module M-MODCV
 * (engine_b/eb_pwm_cv.{h,c}). Plus one line at the port's :2174 that hands the
 * module its one-sample delay input. Nothing else in this file differs.
 */
#include "eb_pwm_cv.h"
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif
     /* -I engine_b/ is supplied by the harness */

/* ENGINE B M-MODCV: file scope so the delay can be fed at the port's :2174,
 * after the block that reads it. JUNO_NUM_VOICES comes from the port headers
 * included below. */
static eb_modcv_coef  EBMC[8];
static unsigned long  EBMGEN_SEEN[8];
static float          EBMRAW[8][24];
static int            EBMHAVE[8];

/* ---- from shim 'vca_hpf' ---- */
/* engine_b/shim/vca_hpf/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the VCA + HPF output stage, lines 1516-1640, which
 * is module M-VCA (engine_b/eb_vca_hpf.{h,c}). Diff this file against
 * src/voice_render.c: that block and this include are the only changes, so a
 * divergence under tools/engineb/null_b.py --module vca_hpf is attributable to
 * the VCA/HPF stage and to nothing else.
 */
#include "eb_vca_hpf.h"        /* -I engine_b/ is supplied by the harness */

/* ---- from shim 'vcf_cv' ---- */
/* engine_b/shim/vcf_cv/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the VCF cutoff CV summing network, lines 1150-1229,
 * which is module M-VCFCV (engine_b/eb_vcf_cv.{h,c}). Diff this file against
 * src/voice_render.c: that block and this include are the only changes, so a
 * divergence under tools/engineb/null_b.py --module vcf_cv is attributable to
 * the CV summing and to nothing else.
 */
#include "eb_vcf_cv.h"
#include <string.h>
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_vcf_cv_coef EBKC[8];
static eb_vcf_cv_derived EBKD[8];
static unsigned char EBKHAVE[8];
static unsigned long EBKGEN_SEEN[8];
     /* -I engine_b/ is supplied by the harness */

/* ---- from shim 'vcf_ladder' ---- */
/* engine_b/shim/vcf_ladder/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the 4-pole VCF ladder core, lines 1298-1515, which
 * is module M-VCF (engine_b/eb_vcf_ladder.{h,c}). Diff this file against
 * src/voice_render.c: that block and this include are the only changes, so a
 * divergence under tools/engineb/null_b.py --module vcf_ladder is attributable
 * to the ladder and to nothing else.
 */
#include "eb_vcf_ladder.h"
/* COEFFICIENT GENERATION GUARD. See the note on eb_coef_gen in
 * gui/juno_bridge.c. The full memcmp check below is skipped while nothing can
 * have changed. Build with -DEB_VERIFY_GEN to run the check ANYWAY and abort if
 * the counter ever said "clean" while the cells had changed -- that build is
 * run over all 30 scenarios, so this is proven by execution, not by reading. */
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu). The counter is "  \
                     "missing a writer and the fast path is UNSOUND.\n",        \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_vcf_state EBF[8];
#include <string.h>
static eb_vcf_coef EBFC[8];
static float EBFRAW[8][30];
static unsigned char EBFHAVE[8];
static unsigned long EBFGEN_SEEN[8];     /* -I engine_b/ is supplied by the harness */

/* The port's four dispersion lines are ONE 4x-oversampled history in engine B.
 * (line, slot) -> delay:  A/B/C/D are delays 0/1/2/3 modulo 4, slot = delay/4.
 * READ src/voice_render.c:1307-1334 (the shifts) and :1489-1511 (the folded
 * FIR); the mapping is what makes those two agree. */
#define EB_HCELL(i)  ( (((i) & 3) == 0 ? 8432 : ((i) & 3) == 1 ? 8560 : \
                        ((i) & 3) == 2 ? 8688 : 8816) + 16 * ((i) >> 2) )

/* ---- from shim 'vcf_res' ---- */
/* engine_b/shim/vcf_res/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the VCF resonance/drive shaper, lines 1230-1297,
 * module engine_b/eb_vcf_res.{h,c}.
 */
#include "eb_vcf_res.h"
#include <string.h>
extern unsigned long eb_coef_gen;
#ifdef EB_VERIFY_GEN
#include <stdio.h>
#include <stdlib.h>
#define EB_GEN_STALE(slot, seen)  (1)
#define EB_GEN_CHECK(slot, seen, changed, name)                                \
    do { if ((changed) && (seen) == eb_coef_gen) {                             \
             fprintf(stderr, "EB_VERIFY_GEN: %s coefficients CHANGED while the "\
                     "generation counter was unchanged (%lu).\n",              \
                     name, eb_coef_gen);                                       \
             abort(); }                                                        \
         (seen) = eb_coef_gen; } while (0)
#else
#define EB_GEN_STALE(slot, seen)  ((seen) != eb_coef_gen)
#define EB_GEN_CHECK(slot, seen, changed, name)  do { (seen) = eb_coef_gen; } while (0)
#endif

static eb_vcf_res_coef EBRC[8];
static unsigned char   EBRHAVE[8];
static unsigned long   EBRGEN_SEEN[8];

/* voice_render.c — exact C99 transcription of sub_180369070 (Cloud 60 voice
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

/* Render one voice (0..7) of the 8-voice engine.
 *
 * The plugin compiled 8 specialised copies of this function (sub_180369070 =
 * voice 0 .. sub_180383F20 = voice 7). Diffing their decompiled offset constants
 * proves each copy is byte-identical modulo THREE region strides (derived, not
 * guessed — see docs/POLYPHONY.md):
 *   - main per-voice block  offsets [176,10672]  -> +voice*10512   (via a1 below)
 *   - shared global block   offsets [84272,84432] -> +0 (all voices, chained)
 *   - aux one-shot edge      offset 101504         -> +voice*32
 * So this one exact transcription serves every voice: `a1` is the voice's main
 * base (base + voice*10512), the 15 shared sites use `base` unshifted, and the 3
 * aux sites use `base` at 101504+voice*32. voice==0 gives a1==base -> identical
 * to the original voice-0 function bit-for-bit. Render voices in order 0..7 each
 * sample so the shared block chains exactly as the plugin's 8 calls do. */
uint32_t juno_voice_render(unsigned char *base, int voice, float *outL, float *outR)
{
  /* PILOT 2: scratch-cell register promotion, SINGLE-TYPED cells only.
   * These cells are written before read, never carry across samples, and are
   * touched through exactly one of JF/JI -- so the int/float reinterpret hazard
   * that broke pilot 1 (155 dual-typed cells) cannot arise. The memory STORE is
   * kept so master_render/recall/probes are unaffected; only redundant RELOADS
   * go away, which is what stalls an in-order M7 (measured IPC 0.44). Seeded
   * from the cell so any control-flow path is safe. Bit-identical by
   * construction; render A/B + fuzz are the proof. */
  float _s4656 = _s4656;
  float _s4784 = _s4784;
  float _s4800 = _s4800;
  float _s4816 = _s4816;
  float _s4896 = _s4896;
  float _s8336 = _s8336;
  float _s8352 = _s8352;
  float _s8368 = _s8368;
  float _s8384 = _s8384;
  float _s8400 = _s8400;
  float _s8416 = _s8416;
  float _s9008 = _s9008;
  float _s9024 = _s9024;

  float v2; // xmm4_4
  float v5; // xmm0_4
  float v6; // xmm1_4
  float v7; // xmm2_4
  int v8; // edx
  int v9; // edx
  int v10; // eax
  float v11; // xmm3_4
  float v12; // xmm6_4
  int v13; // eax
  float v14; // xmm8_4
  int v15; // ecx
  float v16; // xmm7_4
  signed int v17; // edx
  float v18; // xmm1_4
  double v19; // xmm10_8
  float v20; // xmm0_4
  float v21; // xmm0_4
  float v22; // xmm1_4
  float v23; // xmm2_4
  float v24; // xmm1_4
  float v25; // xmm0_4
  float v26; // xmm2_4
  float v27; // xmm1_4
  float v28; // xmm6_4
  float v29; // xmm3_4
  float v30; // xmm1_4
  float v31; // xmm3_4
  double v32; // xmm0_8
  float v33; // xmm15_4
  float v34; // xmm5_4
  float v35; // xmm0_4
  float v36; // xmm5_4
  float v37; // xmm2_4
  float v38; // xmm1_4
  int v39; // eax
  float v40; // xmm4_4
  float v41; // xmm3_4
  double v42; // xmm12_8
  float v43; // xmm5_4
  float v44; // xmm0_4
  float v45; // xmm5_4
  float v46; // xmm1_4
  float v47; // xmm2_4
  float v48; // xmm2_4
  float v49; // xmm1_4
  float v50; // xmm2_4
  float v51; // xmm2_4
  float v52; // xmm2_4
  float v53; // xmm1_4
  double v54; // xmm0_8
  float v55; // xmm1_4
  float v56; // xmm1_4
  float v57; // xmm7_4
  float v58; // xmm0_4
  float v59; // xmm2_4
  int v60; // xmm9_4
  float v61; // xmm7_4
  int v62; // xmm8_4
  int v63; // eax
  float v64; // xmm7_4
  float v65; // xmm1_4
  int v66; // eax
  float v67; // xmm0_4
  float v68; // xmm2_4
  float v69; // xmm1_4
  float v70; // xmm2_4
  double v71; // xmm0_8
  float v72; // xmm1_4
  double v73; // xmm0_8
  float v74; // xmm6_4
  float v75; // xmm0_4
  float v76; // xmm1_4
  float v77; // xmm0_4
  float v78; // xmm3_4
  float v79; // xmm7_4
  float v80; // xmm2_4
  float v81; // xmm4_4
  int v82; // eax
  float v83; // xmm1_4
  float v84; // xmm0_4
  float v85; // xmm7_4
  float v86; // xmm7_4
  float v87; // xmm6_4
  float v88; // xmm6_4
  float v89; // xmm0_4
  float v90; // xmm0_4
  float v91; // xmm6_4
  float v92; // xmm2_4
  float v93; // xmm6_4
  float v94; // xmm1_4
  float v95; // xmm11_4
  float v96; // xmm0_4
  float v97; // xmm0_4
  float v98; // xmm6_4
  double v99; // xmm1_8
  float v100; // xmm0_4
  float v101; // xmm7_4
  float v102; // xmm7_4
  float v103; // xmm8_4
  float v104; // xmm0_4
  float v105; // xmm8_4
  float v106; // xmm0_4
  float v107; // xmm8_4
  float v108; // xmm7_4
  float v109; // xmm0_4
  float v110; // xmm7_4
  float v111; // xmm0_4
  float v112; // xmm6_4
  float v113; // xmm7_4
  float v114; // xmm6_4
  float v115; // xmm4_4
  float v116; // xmm3_4
  float v117; // xmm6_4
  float v118; // xmm4_4
  float v119; // xmm2_4
  float v120; // xmm3_4
  float v121; // xmm4_4
  int v122; // xmm0_4
  float v123; // xmm0_4
  float v124; // xmm1_4
  float v125; // xmm8_4
  float v126; // xmm5_4
  float v127; // xmm7_4
  float v128; // xmm4_4
  float v129; // xmm7_4
  float v130; // xmm6_4
  float v131; // xmm2_4
  float v132; // xmm3_4
  float v133; // xmm4_4
  float v134; // xmm3_4
  float v135; // xmm5_4
  float v136; // xmm7_4
  float v137; // xmm4_4
  float v138; // xmm0_4
  float v139; // xmm3_4
  float v140; // xmm5_4
  float v141; // xmm2_4
  float v142; // xmm3_4
  float v143; // xmm3_4
  float v144; // xmm0_4
  float v145; // xmm0_4
  float v146; // xmm1_4
  float v147; // xmm8_4
  float v148; // xmm5_4
  float v149; // xmm6_4
  float v150; // xmm4_4
  float v151; // xmm6_4
  float v152; // xmm7_4
  float v153; // xmm0_4
  float v154; // xmm2_4
  float v155; // xmm4_4
  float v156; // xmm3_4
  float v157; // xmm5_4
  float v158; // xmm6_4
  float v159; // xmm4_4
  float v160; // xmm0_4
  float v161; // xmm3_4
  float v162; // xmm5_4
  float v163; // xmm2_4
  float v164; // xmm3_4
  float v165; // xmm3_4
  float v166; // xmm0_4
  float v167; // xmm0_4
  float v168; // xmm8_4
  float v169; // xmm8_4
  float v170; // xmm7_4
  int v171; // xmm1_4
  int v172; // xmm2_4
  int v173; // xmm0_4
  float v174; // xmm4_4
  float v175; // xmm5_4
  float v176; // xmm7_4
  float v177; // xmm4_4
  float v178; // xmm2_4
  float v179; // xmm3_4
  float v180; // xmm7_4
  float v181; // xmm6_4
  float v182; // xmm5_4
  float v183; // xmm0_4
  float v184; // xmm3_4
  float v185; // xmm6_4
  float v186; // xmm3_4
  int v187; // xmm0_4
  float v188; // xmm2_4
  int v189; // xmm0_4
  float v190; // xmm4_4
  float v191; // xmm2_4
  float v192; // xmm3_4
  float v193; // xmm0_4
  float v194; // xmm3_4
  float v195; // xmm4_4
  float v196; // xmm1_4
  float v197; // xmm1_4
  float v198; // xmm1_4
  float v199; // xmm0_4
  float v200; // xmm4_4
  float v201; // xmm0_4
  double v202; // xmm0_8
  float v203; // xmm1_4
  float v204; // xmm0_4
  float v205; // xmm1_4
  float v206; // xmm0_4
  float v207; // xmm1_4
  float v208; // xmm0_4
  float v209; // xmm3_4
  float v210; // xmm2_4
  float v211; // xmm3_4
  float v212; // xmm0_4
  float v213; // xmm3_4
  float v214; // xmm1_4
  float v215; // xmm0_4
  float v216; // xmm0_4
  float v217; // xmm7_4
  float v218; // xmm7_4
  float v219; // xmm1_4
  float v220; // xmm0_4
  float v221; // xmm7_4
  float v222; // xmm4_4
  float v223; // xmm5_4
  float v224; // xmm6_4
  float v225; // xmm0_4
  float v226; // xmm3_4
  float v227; uint32_t v227_bits;
  float v228; // xmm7_4
  float v229; // xmm8_4
  float v230; // xmm0_4
  float v231; // xmm6_4
  float v232; // xmm6_4
  float v233; // xmm2_4
  float v234; // xmm1_4
  int v235; // ecx
  float v236; // xmm9_4
  float v237; // xmm6_4
  float v238; // xmm4_4
  float v239; // xmm3_4
  float v240; // xmm8_4
  float v241; // xmm8_4
  float v242; // xmm1_4
  float v243; // xmm9_4
  float v244; // xmm0_4
  float v245; // xmm6_4
  float v246; // xmm6_4
  float v247; // xmm3_4
  float v248; // xmm1_4
  float v249; // xmm5_4
  float v250; // xmm5_4
  float v251; // xmm2_4
  float v252; // xmm1_4
  float v253; // xmm0_4
  float v254; // xmm5_4
  float v255; // xmm5_4
  float v256; // xmm5_4
  float v257; // xmm3_4
  float v258; // xmm4_4
  float v259; // xmm1_4
  float v260; // xmm3_4
  float v261; // xmm4_4
  float v262; // xmm3_4
  float v263; // xmm5_4
  float v264; // xmm2_4
  float v265; // xmm5_4
  float v266; // xmm4_4
  float v267; // xmm2_4
  float v268; // xmm5_4
  float v269; // xmm0_4
  float v270; // xmm5_4
  float v271; // xmm5_4
  float v272; // xmm5_4
  float v273; // xmm5_4
  float v274; // xmm1_4
  float v275; // xmm3_4
  float v276; // xmm4_4
  float v277; // xmm1_4
  float v278; // xmm3_4
  float v279; // xmm4_4
  float v280; // xmm3_4
  float v281; // xmm5_4
  float v282; // xmm2_4
  float v283; // xmm5_4
  float v284; // xmm1_4
  float v285; // xmm4_4
  float v286; // xmm2_4
  float v287; // xmm5_4
  float v288; // xmm0_4
  float v289; // xmm5_4
  float v290; // xmm5_4
  float v291; // xmm5_4
  float v292; // xmm5_4
  float v293; // xmm1_4
  float v294; // xmm3_4
  float v295; // xmm4_4
  float v296; // xmm1_4
  float v297; // xmm3_4
  float v298; // xmm4_4
  float v299; // xmm3_4
  float v300; // xmm5_4
  float v301; // xmm2_4
  float v302; // xmm5_4
  float v303; // xmm3_4
  float v304; // xmm1_4
  float v305; // xmm5_4
  float v306; // xmm0_4
  float v307; // xmm5_4
  float v308; // xmm5_4
  float v309; // xmm5_4
  float v310; // xmm5_4
  float v311; // xmm3_4
  float v312; // xmm4_4
  float v313; // xmm1_4
  float v314; // xmm3_4
  float v315; // xmm4_4
  float v316; // xmm3_4
  float v317; // xmm5_4
  float v318; // xmm2_4
  float v319; // xmm5_4
  float v320; // xmm8_4
  float v321; // xmm3_4
  float v322; // xmm4_4
  float v323; // xmm5_4
  float v324; // xmm5_4
  float v325; // xmm0_4
  float v326; // xmm4_4
  int v327; // xmm0_4
  float v328; // xmm2_4
  float v329; // xmm0_4
  float v330; // xmm2_4
  float v331; // xmm2_4
  float v332; // xmm1_4
  float v333; // xmm3_4
  double v334; // xmm0_8
  float v335; // xmm0_4
  float v336; // xmm1_4
  float v337; // xmm2_4
  float v338; // xmm3_4
  double v339; // xmm0_8
  float v340; // xmm0_4
  float v341; // xmm5_4
  float v342; // xmm6_4
  float v343; // xmm4_4
  float v344; // xmm3_4
  float v345; // xmm4_4
  float v346; // xmm2_4
  float v347; // xmm0_4
  float v348; // xmm7_4
  float v349; // xmm6_4
  float v350; // xmm3_4
  int v351; // xmm0_4
  int v352; // xmm1_4
  float v353; // xmm4_4
  float v354; // xmm2_4
  float v355; // xmm3_4
  float v356; // xmm1_4
  float v357; // xmm6_4
  float v358; // xmm4_4
  float v359; // xmm3_4
  float v360; // xmm1_4
  float v361; // xmm6_4
  float v362; // xmm1_4
  float v363; // xmm7_4
  double v364; // xmm0_8
  float v365; // xmm4_4
  float v366; // xmm5_4
  float v367; // xmm5_4
  float v368; // xmm6_4
  float v369; // xmm2_4
  float v370; // xmm3_4
  float v371; // xmm4_4
  float v372; // xmm0_4
  float v373; // xmm1_4
  float v374; // xmm4_4
  float v375; // xmm2_4
  float v376; // xmm6_4
  float v377; // xmm5_4
  float v378; // xmm4_4
  double v379; // xmm0_8
  float v380; // xmm3_4
  float v381; // xmm3_4
  float v382; // xmm1_4
  float v383; // xmm2_4
  float v384; // xmm2_4
  double v385; // xmm12_8
  double v386; int v386_lo;
  const double *v387;
  double v388; // xmm4_8
  double v389; // xmm8_8
  double v390; // xmm10_8
  float v391; // xmm3_4
  float v392; // xmm5_4
  int v393; // xmm0_4
  int v394; // xmm1_4
  float v395; // xmm5_4
  float v396; // xmm3_4
  float v397; // xmm0_4
  float v398; // xmm2_4
  float v399; // xmm5_4
  double v400; // xmm0_8
  float v401; // xmm6_4
  int v402; // xmm1_4
  float v403; // xmm6_4
  float v404; // xmm7_4
  double v405; // xmm0_8
  float v406; // xmm5_4
  float v407; // xmm5_4
  float v408; // xmm5_4
  float v409; // xmm0_4
  float v410; // xmm3_4
  float v411; // xmm4_4
  float v412; // xmm0_4
  float v413; // xmm6_4
  float v414; // xmm8_4
  float v415; // xmm6_4
  double v416; // xmm0_8
  float v417; // xmm4_4
  float v418; // xmm0_4
  float v419; // xmm7_4
  float v420; // xmm4_4
  float v421; // xmm4_4
  float v422; // xmm4_4
  float v423; // xmm7_4
  float v424; // xmm9_4
  double v425; // xmm0_8
  float v426; // xmm7_4
  float v427; // xmm8_4
  float v428; // xmm8_4
  float v429; // xmm8_4
  float v430; // xmm6_4
  int v431; // xmm5_4
  float v432; // xmm6_4
  float v433; // xmm7_4
  double v434; // xmm0_8
  float v435; // xmm5_4
  float v436; // xmm5_4
  float v437; // xmm5_4
  float v438; // xmm0_4
  float v439; // xmm3_4
  float v440; // xmm4_4
  float v441; // xmm0_4
  float v442; // xmm6_4
  float v443; // xmm8_4
  float v444; // xmm6_4
  double v445; // xmm0_8
  float v446; // xmm4_4
  float v447; // xmm0_4
  float v448; // xmm7_4
  float v449; // xmm4_4
  float v450; // xmm4_4
  float v451; // xmm4_4
  float v452; // xmm7_4
  float v453; // xmm9_4
  double v454; // xmm0_8
  float v455; // xmm7_4
  float v456; // xmm8_4
  float v457; // xmm8_4
  float v458; // xmm8_4
  float v459; // xmm6_4
  int v460; // xmm5_4
  float v461; // xmm6_4
  float v462; // xmm7_4
  double v463; // xmm0_8
  float v464; // xmm5_4
  float v465; // xmm5_4
  float v466; // xmm5_4
  float v467; // xmm0_4
  float v468; // xmm3_4
  float v469; // xmm4_4
  float v470; // xmm0_4
  float v471; // xmm6_4
  float v472; // xmm8_4
  float v473; // xmm6_4
  double v474; // xmm0_8
  float v475; // xmm4_4
  float v476; // xmm0_4
  float v477; // xmm7_4
  float v478; // xmm4_4
  float v479; // xmm4_4
  float v480; // xmm4_4
  float v481; // xmm7_4
  float v482; // xmm9_4
  double v483; // xmm0_8
  float v484; // xmm7_4
  float v485; // xmm8_4
  float v486; // xmm8_4
  float v487; // xmm8_4
  float v488; // xmm6_4
  int v489; // xmm5_4
  float v490; // xmm6_4
  float v491; // xmm7_4
  double v492; // xmm0_8
  float v493; // xmm5_4
  float v494; // xmm5_4
  float v495; // xmm5_4
  float v496; // xmm0_4
  float v497; // xmm3_4
  float v498; // xmm4_4
  float v499; // xmm0_4
  float v500; // xmm6_4
  float v501; // xmm8_4
  float v502; // xmm6_4
  double v503; // xmm0_8
  float v504; // xmm4_4
  float v505; // xmm0_4
  float v506; // xmm7_4
  float v507; // xmm4_4
  float v508; // xmm4_4
  float v509; // xmm4_4
  float v510; // xmm7_4
  float v511; // xmm8_4
  float v512; // xmm0_4
  float v513; // xmm7_4
  float v514; // xmm0_4
  float v515; // xmm15_4
  int v516; // xmm5_4
  int v517; // xmm6_4
  float v518; // xmm2_4
  float v519; // xmm5_4
  float v520; // xmm2_4
  float v521; // xmm4_4
  float v522; // xmm5_4
  float v523; // xmm1_4
  float v524; // xmm5_4
  float v525; // xmm3_4
  float v526; // xmm4_4
  uint32_t result;
  int v528; // [rsp+D0h] [rbp+8h]
  float v529; // [rsp+E0h] [rbp+18h]

  /* Per-voice region bases (see the header comment above). */
  unsigned char *a1 = base + (unsigned)voice * JUNO_VOICE_MAIN_STRIDE;
  unsigned auxoff  = JUNO_VOICE_AUX_BASE0 + (unsigned)voice * JUNO_VOICE_AUX_STRIDE;

  v2 = JF(a1, 320);
  v528 = 0;
  if ( JF(base, auxoff) == 1.0 )
  {
    v528 = JI(a1, 320);
    v2 = 0.0;
    JI(a1, 320) = 0;
  }
  /* ============ ENGINE B MODULE M-NOTECV — the shared noise generator ====
   * REPLACES src/voice_render.c:595-656. The boundary is set by module
   * 'cvgate', which owns :657-681 -- see eb_notecv.h.
   *
   * The plain recall reads the port makes inside this range stay here: they
   * are cell reads, so reading them here is identical to reading them there.
   * NOT written back: eleven dead stores, listed in eb_notecv.h.
   */
  {
    eb_notecv_state ebns;

    if (!EBTGEN_SEEN[voice] || EB_GEN_STALE(15, EBTGEN_SEEN[voice])) {
      eb_notecv_coef ebn;
      int _ch;
      ebn.n84272 = JF(base, 84272); ebn.n84304 = JF(base, 84304);
      ebn.n84400 = JF(base, 84400); ebn.n84416 = JF(base, 84416);
      _ch = !EBTHAVE[voice] || memcmp(&EBTC[voice], &ebn, sizeof ebn) != 0;
      EB_GEN_CHECK(15, EBTGEN_SEEN[voice], _ch, "notecv");
      if (_ch) { EBTC[voice] = ebn; EBTHAVE[voice] = 1; }
    }

    ebns.n84336 = JF(base, 84336);
    ebns.n84368 = JF(base, 84368);
    JF(base, 84432) = eb_notecv_tick(&ebns, &EBTC[voice]);
    JF(base, 84336) = ebns.n84336;
    JF(base, 84368) = ebns.n84368;

    v11 = JF(a1, 208);
    v12 = JF(a1, 176);
    v14 = JF(a1, 368);
    v16 = JF(a1, 384);
    v19 = 0.0;
    v23 = JF(a1, 272);
    v25 = JF(a1, 240);
    v26 = v23 * v25;
    v27 = JF(a1, 304);
  }
  /* ==== ENGINE B MODULE CVGATE =========================================
   * Only the ARITHMETIC is replaced. The port's cell writes stay exactly where
   * and in the order the port has them -- an earlier version of this shim moved
   * all five writes to the end of the block, proved every value bit-identical
   * by assertion, and STILL diverged at 6.9 dB on all 30 scenarios. The values
   * were never the problem; the ORDER was. Recorded because "the numbers match,
   * so the change is safe" is exactly the reasoning that failed. */
  {
    eb_cvgate_in _gi;
    eb_cvgate_out _go;
    _gi.t28 = v12;  _gi.t29 = v11;  _gi.k = v26;
    _gi.p28 = v27;  _gi.p29 = v2;   _gi.gate_off = JF(a1, 544);
    eb_cvgate(&_gi, &_go);
    v28 = _go.c464;  v29 = _go.c480;  v34 = _go.c496;  v33 = _go.sign;
  }
  JF(a1, 464) = v28;
  JF(a1, 480) = v29;
  JF(a1, 496) = v34;
  v34 = v33;
  /* ==== END ENGINE B MODULE CVGATE ===================================== */
  /* ============ ENGINE B MODULE M-GLIDE ==================================
   * REPLACES src/voice_render.c:682-796 verbatim. State lives in the port's
   * own cells (seven floats), as every other shim does.
   *
   * KEPT OUTSIDE THE MODULE, because the port hoisted them into this range but
   * they belong to code after it: the constant v42 = 1.0, and the three
   * external-LFO coefficient reads v60/v62/v64. They are plain cell reads, so
   * reading them here is identical to reading them there.
   *
   * NOT written back: the ten dead stores 528/576/720/736/896/928/960/992/
   * 1024/1120, grepped to have no reader in src/ or gui/.
   */
  v42 = 1.0;
  v60 = JI(a1, 1008);
  v62 = JI(a1, 976);
  v64 = JF(a1, 944);
  {
    eb_glide_state ebgs;

    if (!EBGGEN_SEEN[voice] || EB_GEN_STALE(14, EBGGEN_SEEN[voice])) {
      eb_glide_coef ebg;
      int _ch;
      ebg.k592  = JF(a1, 592);  ebg.k608  = JF(a1, 608);
      ebg.k624  = JF(a1, 624);  ebg.k768  = JF(a1, 768);
      ebg.k784  = JF(a1, 784);  ebg.k800  = JF(a1, 800);
      ebg.k816  = JF(a1, 816);  ebg.k832  = JF(a1, 832);
      ebg.k848  = JF(a1, 848);  ebg.k864  = JF(a1, 864);
      ebg.k912  = JF(a1, 912);  ebg.k1040 = JF(a1, 1040);
      ebg.k1088 = JF(a1, 1088); ebg.k1152 = JF(a1, 1152);
      ebg.k1168 = JF(a1, 1168);
      _ch = !EBGHAVE[voice] || memcmp(&EBGC[voice], &ebg, sizeof ebg) != 0;
      EB_GEN_CHECK(14, EBGGEN_SEEN[voice], _ch, "glide");
      if (_ch) { EBGC[voice] = ebg; EBGHAVE[voice] = 1; }
    }

    ebgs.s560  = JF(a1, 560);  ebgs.s656  = JF(a1, 656);
    ebgs.s672  = JF(a1, 672);  ebgs.s688  = JF(a1, 688);
    ebgs.s704  = JF(a1, 704);  ebgs.s880  = JF(a1, 880);
    ebgs.s1104 = JF(a1, 1104);

    {
      float eb752;
      v73 = eb_glide_tick(&ebgs, &EBGC[voice], v34, v14, v16, v28, &eb752);
      JF(a1, 752) = eb752;
    }

    JF(a1, 560)  = ebgs.s560;  JF(a1, 656)  = ebgs.s656;
    JF(a1, 672)  = ebgs.s672;  JF(a1, 688)  = ebgs.s688;
    JF(a1, 704)  = ebgs.s704;  JF(a1, 880)  = ebgs.s880;
    JF(a1, 1104) = ebgs.s1104;
  }

  /* ============ ENGINE B MODULE M-LFO — the LFO ==========================
   * REPLACES src/voice_render.c:797-963 verbatim.
   *
   * STATE LIVES IN THE PORT'S OWN CELLS, as every other shim does: the
   * module's FIVE state floats are loaded from [1488]/[1504]/[1536]/[1568]/
   * [1600] at the top and stored back at the bottom, so it inherits the port's
   * create/destroy/eight-voice lifecycle. That copying and the coefficient
   * gather are HARNESS cost.
   *
   * The three int-copied cells are passed as FLOATS: the port does
   * `JI(dst)=JI(src)` then reads `JF(dst)`, which is a reinterpret and is
   * therefore exactly the float at `src`. See eb_lfo.h.
   *
   * NOT written back: the seven dead stores 1136/1520/1648/1664/1744/1776/
   * 1840, grepped to have no reader in src/ or gui/ (master_render.c's
   * pointer-arithmetic forms included).
   */
  {
    eb_lfo_state ebls;
    float eb1808, eb1824;

    if (!EBLGEN_SEEN[voice] || EB_GEN_STALE(13, EBLGEN_SEEN[voice])) {
      eb_lfo_coef ebl;
      int _ch;
      ebl.k1056 = JF(a1, 1056); ebl.k1072 = JF(a1, 1072);
      ebl.k1184 = JF(a1, 1184); ebl.k1200 = JF(a1, 1200);
      ebl.k1216 = JF(a1, 1216); ebl.k1856 = JF(a1, 1856);
      ebl.k1872 = JF(a1, 1872); ebl.k1888 = JF(a1, 1888);
      ebl.k1904 = JF(a1, 1904); ebl.k1920 = JF(a1, 1920);
      ebl.k1936 = JF(a1, 1936); ebl.k1952 = JF(a1, 1952);
      ebl.k1968 = JF(a1, 1968); ebl.k1984 = JF(a1, 1984);
      ebl.k2000 = JF(a1, 2000); ebl.k2016 = JF(a1, 2016);
      ebl.k2032 = JF(a1, 2032); ebl.k2048 = JF(a1, 2048);
      ebl.k2064 = JF(a1, 2064); ebl.k2080 = JF(a1, 2080);
      ebl.k2096 = JF(a1, 2096); ebl.k2112 = JF(a1, 2112);
      ebl.k2128 = JF(a1, 2128); ebl.k2144 = JF(a1, 2144);
      ebl.k2160 = JF(a1, 2160); ebl.k2176 = JF(a1, 2176);
      ebl.k2192 = JF(a1, 2192); ebl.k2208 = JF(a1, 2208);
      ebl.k2224 = JF(a1, 2224); ebl.k2240 = JF(a1, 2240);
      ebl.k2256 = JF(a1, 2256); ebl.k2272 = JF(a1, 2272);
      ebl.k2288 = JF(a1, 2288); ebl.k2304 = JF(a1, 2304);
      ebl.k2320 = JF(a1, 2320); ebl.k2336 = JF(a1, 2336);
      ebl.k2352 = JF(a1, 2352); ebl.k2368 = JF(a1, 2368);
      ebl.k2384 = JF(a1, 2384); ebl.k2400 = JF(a1, 2400);
      ebl.k2416 = JF(a1, 2416); ebl.k2432 = JF(a1, 2432);
      ebl.k2448 = JF(a1, 2448); ebl.k2464 = JF(a1, 2464);
      ebl.k2480 = JF(a1, 2480); ebl.k2496 = JF(a1, 2496);
      ebl.k2512 = JF(a1, 2512);
      _ch = !EBLHAVE[voice] || memcmp(&EBLC[voice], &ebl, sizeof ebl) != 0;
      EB_GEN_CHECK(13, EBLGEN_SEEN[voice], _ch, "lfo");
      if (_ch) { EBLC[voice] = ebl; EBLHAVE[voice] = 1; }
    }

    ebls.s1488 = JF(a1, 1488);
    ebls.s1504 = JF(a1, 1504);
    ebls.s1536 = JF(a1, 1536);
    ebls.s1568 = JF(a1, 1568);
    ebls.s1600 = JF(a1, 1600);

    JF(a1, 1792) = eb_lfo_tick(&ebls, &EBLC[voice],
                               v73, v64,
                               JF(a1, 976), JF(a1, 1008), JF(base, 84432),
                               &eb1808, &eb1824);
    JF(a1, 1808) = eb1808;
    JF(a1, 1824) = eb1824;

    JF(a1, 1488) = ebls.s1488;
    JF(a1, 1504) = ebls.s1504;
    JF(a1, 1536) = ebls.s1536;
    JF(a1, 1568) = ebls.s1568;
    JF(a1, 1600) = ebls.s1600;
  }

  /* ================= ENGINE B MODULE M7 — the two ADSR envelopes ==========
   * REPLACES src/voice_render.c:964-1075 verbatim. Diff this file against
   * src/voice_render.c: this block is the ONLY change, plus the include above.
   *
   * The port's 111 lines here do three separable things: shuffle ten shadow
   * cells so that last sample's values can be read back, recompute six
   * loop-invariant products from cells that only a patch recall can change, and
   * run two identical ADSR state machines. Engine B keeps the third and deletes
   * the first two. eb_envgen.c holds the arithmetic; this block is only the
   * plumbing that connects it to the port's cells.
   *
   * STATE LIVES IN THE PORT'S OWN STATE CELLS (2592/2624/2640/2672/2720 and the
   * +480 ENV2 twins) rather than in a static of this file. That is deliberate
   * and it is not laziness: those five cells are zeroed at power-on by
   * chorus_init.c:118-127 and replicated per voice, so using them gives the
   * module the port's exact lifecycle -- create, destroy, re-create, eight
   * voices -- with no ownership question for the harness to get wrong.
   * engine_b/shim/README.md sanctions exactly this ("a shim may read and write
   * the port's cells"). The <1 KB/voice layout arrives when the module owns the
   * whole voice; the CYCLE claim is measured on eb_envgen.c itself, never here.
   *
   * The TEN shadow cells (2608/2656/2688/2736 + ENV2 twins, and 2576/3056) and
   * the four write-only outputs (2528/2544/2768/3248) are NOT written. GREPPED:
   * no reader outside this block anywhere in src/ or gui/. Audio is unaffected;
   * per-cell state parity is not, and that is a sonic-identity claim.
   */
  {
    static eb_env_coef  EBC[JUNO_NUM_VOICES][2];
    static unsigned long EBGEN_SEEN[JUNO_NUM_VOICES][2];
    static float        EBRAW[JUNO_NUM_VOICES][2][15];
    static int          EBHAVE[JUNO_NUM_VOICES][2];
    int ei;

    for ( ei = 0; ei < 2; ++ei )
    {
      unsigned off = (unsigned)ei * 480u;            /* ENV2 = ENV1 + 480 */
      float raw[15];
      eb_env_state es;
      float k, gin;
      int j, same;


      /* Rebuild only on change. In a real host that is once per recall; the
       * comparison is here rather than in a parameter callback because this
       * shim has no parameter path of its own to hook. It is HARNESS cost and
       * is excluded from every cycle figure reported for this module. */
      /* CHANGE DETECTION BY memcmp, not float-by-float. MEASURED: the
       * float loop below cost 1,776 executed instructions per sample -- it
       * is a loop-carried condition over 15 elements, per voice, per sample,
       * and it is pure HARNESS cost: the shipped engine computes these
       * coefficients once at recall and never checks again.
       *
       * memcmp is EXACT here and is in fact STRICTER than the float compare.
       * It differs only where the bits differ but the floats compare equal --
       * +0.0 against -0.0 -- and there it says "changed" and recomputes. A
       * needless recompute produces the same coefficients, so the result is
       * unchanged; the only cost is doing the work occasionally when it was
       * not required. Being conservative in that direction is safe; the
       * reverse would not be. */
      /* STEP 4: THE GATHER MOVED INSIDE THE GENERATION CHECK. Reading these
       * fifteen cells, twice per voice, was itself MEASURED at 336 executed
       * instructions per sample, and there is no point gathering values to
       * compare when the counter already says nothing can have changed. Under
       * -DEB_VERIFY_GEN the branch is always taken, so the verification build
       * still gathers and still compares every sample. */
      if (!EBGEN_SEEN[voice][ei] || EB_GEN_STALE(0, EBGEN_SEEN[voice][ei])) {
        int _ch;
        /* the fifteen cells the coefficients are a pure function of */
      raw[0]  = JF(a1, 2784 + off);   /* A */
      raw[1]  = JF(a1, 2800 + off);   /* S */
      raw[2]  = JF(a1, 2816 + off);   /* D */
      raw[3]  = JF(a1, 2832 + off);   /* R */
      raw[4]  = JF(a1, 2864 + off);
      raw[5]  = JF(a1, 2880 + off);
      raw[6]  = JF(a1, 2896 + off);
      raw[7]  = JF(a1, 2912 + off);
      raw[8]  = JF(a1, 2928 + off);
      raw[9]  = JF(a1, 2944 + off);
      raw[10] = JF(a1, 2960 + off);
      raw[11] = JF(a1, 2848 + off);
      raw[12] = JF(a1, 2976 + off);
      raw[13] = JF(a1, 2992 + off);
      raw[14] = JF(a1, 3008 + off);
        _ch = !EBHAVE[voice][ei] ||
              memcmp(EBRAW[voice][ei], raw, 15 * sizeof(float)) != 0;
        EB_GEN_CHECK(0, EBGEN_SEEN[voice][ei], _ch, "env");
        same = !_ch;
      } else same = 1;
      if ( !same )
      {
        memcpy(EBRAW[voice][ei], raw, 15 * sizeof(float));
        eb_env_set_rate_consts(&EBC[voice][ei], raw[4], raw[5], raw[6], raw[7],
                               raw[8], raw[9], raw[10], raw[11], raw[12],
                               raw[13], raw[14]);
        eb_env_set_adsr(&EBC[voice][ei], raw[0], raw[1], raw[2], raw[3]);
        EBHAVE[voice][ei] = 1;
      }

      /* gated input: gate x LFO-pulse polarity, unless the per-envelope LFO
       * TRIG switch (2560 / 3040) is off, in which case the gate passes. Both
       * operands belong to other modules, so they are read, not recomputed. */
      if ( JF(a1, 1824) <= 0.0f ) k = 0.0f; else k = 1.0f;
      if ( JF(a1, 2560 + off) == 0.0f ) k = 1.0f;
      gin = JF(a1, 560) * k;

      es.y = JF(a1, 2592 + off);
      es.h = JF(a1, 2624 + off);
      es.p = JF(a1, 2640 + off);
      es.t = JF(a1, 2672 + off);
      es.r = JF(a1, 2720 + off);

      JF(a1, 2752 + off) = eb_env_tick(&es, &EBC[voice][ei], gin);

      JF(a1, 2592 + off) = es.y;
      JF(a1, 2624 + off) = es.h;
      JF(a1, 2640 + off) = es.p;
      JF(a1, 2672 + off) = es.t;
      JF(a1, 2720 + off) = es.r;
    }
  }
  /* =============== END ENGINE B MODULE M7 ================================ */

  /* ============ ENGINE B MODULE M-MODCV — pitch / PWM modulation CV ========
   * REPLACES src/voice_render.c:1076-1128 verbatim. Diff this file against
   * src/voice_render.c: this block, the one below at :2174 that feeds the
   * module's single delay, and the include at the top are the ONLY changes, so
   * a divergence under tools/engineb/null_b.py --module pwm_cv is attributable
   * to this module and to nothing else. See engine_b/eb_pwm_cv.h.
   *
   * STATE AND COEFFICIENTS LIVE IN THIS SHIM, not in the port's cells, because
   * the module owns both: eb_modcv_state is one float per voice and the
   * coefficient set is rebuilt only when one of the 24 recall cells it is a
   * pure function of changes. The rebuild COMPARISON is harness cost (this shim
   * has no parameter path of its own to hook) and is excluded from every cycle
   * figure reported for this module; the cost rig measures eb_pwm_cv.c alone.
   *
   * The five dead cells ([3568], [3616], [3632], [3696], [3824]) are NOT
   * written — GREPPED, no reader outside the block that writes them. The four
   * STAGING copies ([3792], [4240], [4256], [4272]) ARE written, because their
   * consumers at :1664 and :1667-1669 are the port's own code.
   */
  {
    static const int      EBMCELL[24] = { 3584, 3600, 3856, 3872, 3888, 3904,
                                          3920, 3936, 3952, 3968, 3984, 4000,
                                          4016, 4032, 4048, 4064, 4080, 4096,
                                          4112, 4128, 4144, 4160, 4176, 3552 };
    float raw[24];
    float pitch_sum, pwm_sum;
    int j, same;


      /* CHANGE DETECTION BY memcmp, not float-by-float. MEASURED: the
       * float loop below cost 2,192 executed instructions per sample -- it
       * is a loop-carried condition over 24 elements, per voice, per sample,
       * and it is pure HARNESS cost: the shipped engine computes these
       * coefficients once at recall and never checks again.
       *
       * memcmp is EXACT here and is in fact STRICTER than the float compare.
       * It differs only where the bits differ but the floats compare equal --
       * +0.0 against -0.0 -- and there it says "changed" and recomputes. A
       * needless recompute produces the same coefficients, so the result is
       * unchanged; the only cost is doing the work occasionally when it was
       * not required. Being conservative in that direction is safe; the
       * reverse would not be. */
      /* STEP 4: THE GATHER MOVED INSIDE THE GENERATION CHECK.
       * Reading these cells was itself the cost -- MEASURED 768 executed
       * instructions per sample -- and there is no point gathering values in
       * order to compare them when the counter already says nothing can have
       * changed. Under -DEB_VERIFY_GEN the branch is always taken, so the
       * verification build still gathers and still compares every sample. */
    if (!EBMGEN_SEEN[voice] || EB_GEN_STALE(1, EBMGEN_SEEN[voice])) {
      int _ch;
      for ( j = 0; j < 24; ++j ) raw[j] = JF(a1, EBMCELL[j]);
      _ch = !EBMHAVE[voice] ||
            memcmp(EBMRAW[voice], raw, 24 * sizeof(float)) != 0;
      EB_GEN_CHECK(1, EBMGEN_SEEN[voice], _ch, "modcv");
      same = !_ch;
    } else same = 1;
    if ( !same )
    {
      memcpy(EBMRAW[voice], raw, 24 * sizeof(float));
      eb_modcv_set(&EBMC[voice], raw[0], raw[1], raw[2], raw[3], raw[4],
                   raw[5], raw[6], raw[7], raw[8], raw[9], raw[10], raw[11],
                   raw[12], raw[13], raw[14], raw[15], raw[16], raw[17],
                   raw[18], raw[19], raw[20], raw[21], raw[22], raw[23]);
      EBMHAVE[voice] = 1;
    }

    /* The range's one-sample delay: [3536] = last sample's [3520] (:1076).
     * The state is BOUND TO THE PORT'S OWN CELL [3520] here rather than kept in
     * a static of this file: the port writes that cell at :2174, i.e. after
     * this block, and binding it gives the module the port's exact create /
     * destroy / eight-voice lifecycle with no ownership question for the
     * harness to get wrong (engine_b/shim/README.md sanctions this). In the
     * finished engine the same float is eb_modcv_state. */
    {
      eb_modcv_state ds;
      eb_modcv_latch(&ds, JF(a1, 3520));
      JF(a1, 3536) = eb_modcv_tap(&ds);
    }

    eb_modcv_tick(&EBMC[voice],
                  JF(a1, 752), JF(a1, 880), JF(a1, 1792), JF(a1, 1808),
                  JF(a1, 2752), JF(a1, 3232),
                  &pitch_sum, &pwm_sum);
    JF(a1, 3776) = pitch_sum;
    JF(a1, 3808) = pwm_sum;

    /* staging copies of recall constants (:1115, :1126-1128) */
    JI(a1, 3792) = JI(a1, 3840);
    JI(a1, 4240) = JI(a1, 4192);
    JI(a1, 4256) = JI(a1, 4208);
    JI(a1, 4272) = JI(a1, 4224);
  }
  /* =============== END ENGINE B MODULE M-MODCV ============================ */
  /* ==== ENGINE B MODULE NOISE_SVF ====================================== */
  {
    eb_nsvf_coef _nc;
    float _n04, _n20;
    /* COEFFICIENT CACHE + GENERATION GUARD -- five recall-rate cells that
     * were being read every sample per voice. Under -DEB_VERIFY_GEN the branch
     * is always taken. */
    if (!EBNGEN_SEEN[voice] || EB_GEN_STALE(5, EBNGEN_SEEN[voice])) {
      eb_nsvf_coef _t; int _ch;
      _t.k36 = JF(a1, 4336); _t.k52 = JF(a1, 4352); _t.k68 = JF(a1, 4368);
      _t.k84 = JF(a1, 4384); _t.k00 = JF(a1, 4400);
      _ch = !EBNCHAVE[voice] || memcmp(&EBNC[voice], &_t, sizeof _t) != 0;
      EB_GEN_CHECK(5, EBNGEN_SEEN[voice], _ch, "noise_svf");
      if (_ch) { EBNC[voice] = _t; EBNCHAVE[voice] = 1; }
    }
    _nc = EBNC[voice];
    if (!EBN_seen[voice] || JF(a1, 4288) == 0.0f) {
      /* fresh context: the port zeroes 4288 at power-on and only this filter
       * writes it, so a zero there means "just built" -- the same trick the
       * decimator uses on cell 5440, and for the same reason: a static array
       * outlives the engine context and malloc reuses addresses. */
      EBN[voice].s88 = JF(a1, 4288);
      EBN[voice].s04 = JF(a1, 4304);
      EBN_seen[voice] = 1;
    }
    _n20 = eb_nsvf_tick(&EBN[voice], &_nc, JF(base, 84432), &_n04);
    /* the port's cells are still written: other code may read them, and this
     * module is not the place to prove it does not. */
    JF(a1, 4288) = EBN[voice].s88;
    JF(a1, 4304) = _n04;
    JF(a1, 4320) = _n20;
  }
  /* ==== END ENGINE B MODULE NOISE_SVF ================================== */
  /* ============ ENGINE B MODULE M-NOISEMIX ==============================
   * REPLACES src/voice_render.c:1141-1149 verbatim. This is the block
   * eb_noise_svf.h deliberately left in the port; now that its neighbours are
   * modules it can be proven.
   *
   * Cell 3536 is passed PER SAMPLE, not cached: it is written at :1076 as a
   * delayed copy. See eb_noisemix.h.
   * NOT written back: five dead stores (6432, 6464, 6480, 6496, 6560).
   */
  {
    if (!EBXGEN_SEEN[voice] || EB_GEN_STALE(17, EBXGEN_SEEN[voice])) {
      eb_noisemix_coef ebx;
      int _ch;
      ebx.k6416 = JF(a1, 6416); ebx.k6448 = JF(a1, 6448);
      ebx.k6512 = JF(a1, 6512); ebx.k6528 = JF(a1, 6528);
      _ch = !EBXHAVE[voice] || memcmp(&EBXC[voice], &ebx, sizeof ebx) != 0;
      EB_GEN_CHECK(17, EBXGEN_SEEN[voice], _ch, "noisemix");
      if (_ch) { EBXC[voice] = ebx; EBXHAVE[voice] = 1; }
    }
    JF(a1, 6544) = eb_noisemix_tick(&EBXC[voice], JF(a1, 4320), JF(a1, 3536));
  }
  /* ============ ENGINE B MODULE M-VCFCV — the cutoff CV summing =========
   * REPLACES src/voice_render.c:1150-1229 verbatim.
   *
   * STATE LIVES IN THE PORT'S OWN CELLS, exactly as modules M7 and M-VCF do
   * and as engine_b/shim/README.md sanctions: the module's three state floats
   * are loaded from [6896]/[7088]/[7168] at the top and stored back at the
   * bottom, so it inherits the port's create/destroy/eight-voice lifecycle.
   * That copying, and the coefficient gather, are HARNESS cost and are
   * excluded from every cycle figure reported for this module — the cost rig
   * measures eb_vcf_cv.c alone.
   *
   * NOT written back: the 16 dead stores enumerated in eb_vcf_cv.c. GREPPED:
   * no reader outside this block anywhere in src/ or gui/.
   */
  {
    eb_vcf_cv_coef ebk;
    eb_vcf_cv_derived ebd;
    eb_vcf_cv_state ebst;
    float eb6704, eb6848;

    /* COEFFICIENT CACHE + GENERATION GUARD. This gather is 38 cells per
     * voice per sample and MEASURED at 312 executed instructions per sample,
     * and eb_vcf_cv_prepare() ran on top of it every sample. Both are
     * recall-rate. Under -DEB_VERIFY_GEN the branch is always taken, so the
     * verification build still gathers, still compares and still re-prepares
     * every sample. */
    if (!EBKGEN_SEEN[voice] || EB_GEN_STALE(4, EBKGEN_SEEN[voice])) {
      int _ch;
      ebk.x6576 = JF(a1, 6576); ebk.x6608 = JF(a1, 6608);
      ebk.x6640 = JF(a1, 6640); ebk.x6672 = JF(a1, 6672);
      ebk.k6720 = JF(a1, 6720); ebk.k6736 = JF(a1, 6736);
      ebk.k6752 = JF(a1, 6752); ebk.k6768 = JF(a1, 6768);
      ebk.k6784 = JF(a1, 6784); ebk.k6800 = JF(a1, 6800);
      ebk.k6816 = JF(a1, 6816); ebk.x6832 = JF(a1, 6832);
      ebk.k6864 = JF(a1, 6864); ebk.k6928 = JF(a1, 6928);
      ebk.k6944 = JF(a1, 6944); ebk.k6960 = JF(a1, 6960);
      ebk.k7008 = JF(a1, 7008); ebk.k7024 = JF(a1, 7024);
      ebk.k7120 = JF(a1, 7120); ebk.k7136 = JF(a1, 7136);
      ebk.k7152 = JF(a1, 7152); ebk.k7200 = JF(a1, 7200);
      ebk.k7216 = JF(a1, 7216); ebk.k7232 = JF(a1, 7232);
      ebk.k7296 = JF(a1, 7296); ebk.k7312 = JF(a1, 7312);
      ebk.k7328 = JF(a1, 7328); ebk.k7344 = JF(a1, 7344);
      ebk.k7360 = JF(a1, 7360); ebk.k7376 = JF(a1, 7376);
      ebk.k7392 = JF(a1, 7392); ebk.k7408 = JF(a1, 7408);
      ebk.k7424 = JF(a1, 7424); ebk.k7440 = JF(a1, 7440);
      ebk.k7456 = JF(a1, 7456); ebk.k7472 = JF(a1, 7472);
      ebk.k7488 = JF(a1, 7488); ebk.k7504 = JF(a1, 7504);

      _ch = !EBKHAVE[voice] || memcmp(&EBKC[voice], &ebk, sizeof ebk) != 0;
      EB_GEN_CHECK(4, EBKGEN_SEEN[voice], _ch, "vcf_cv");
      if (_ch) {
        EBKC[voice] = ebk;
        eb_vcf_cv_prepare(&EBKD[voice], &ebk);
        EBKHAVE[voice] = 1;
      }
    }
    ebd = EBKD[voice];

    ebst.s_env = JF(a1, 6896);
    ebst.s_a   = JF(a1, 7088);
    ebst.s_b   = JF(a1, 7168);

    v227 = eb_vcf_cv_tick(&ebst, &ebd,
                          JF(a1, 752), JF(a1, 880), JF(a1, 1792),
                          JF(a1, 1808), JF(a1, 2752), JF(a1, 3232),
                          &eb6704, &eb6848);

    JF(a1, 6704) = eb6704;
    JF(a1, 6848) = eb6848;
    JF(a1, 6896) = ebst.s_env;
    JF(a1, 7088) = ebst.s_a;
    JF(a1, 7168) = ebst.s_b;
  }
  /* ============ ENGINE B MODULE M-VCFRES ================================
   * REPLACES src/voice_render.c:1230-1297 verbatim.
   *
   * FOUR state cells -- 7520/7536/7552/7568. Two of them (7520, 7536) are
   * written only inside the block's `if` arm and read in its `else` arm, so
   * they carry across samples even though a read-before-write scan calls them
   * locals. See eb_vcf_res.h.
   *
   * Cell 8192 is gathered with JF here even though the port reaches it as
   * *(float *)(a1 + 0x2000); same address, same load.
   */
  {
    eb_vcf_res_state ebrs;
    float ebr7536;

    if (!EBRGEN_SEEN[voice] || EB_GEN_STALE(16, EBRGEN_SEEN[voice])) {
      eb_vcf_res_coef ebr;
      int _ch;
      ebr.k7600 = JF(a1, 7600);
      ebr.k7616 = JF(a1, 7616);
      ebr.k7632 = JF(a1, 7632);
      ebr.k7648 = JF(a1, 7648);
      ebr.k7664 = JF(a1, 7664);
      ebr.k7680 = JF(a1, 7680);
      ebr.k7696 = JF(a1, 7696);
      ebr.k7712 = JF(a1, 7712);
      ebr.k7728 = JF(a1, 7728);
      ebr.k7744 = JF(a1, 7744);
      ebr.k7760 = JF(a1, 7760);
      ebr.k7776 = JF(a1, 7776);
      ebr.k7792 = JF(a1, 7792);
      ebr.k7824 = JF(a1, 7824);
      ebr.k7840 = JF(a1, 7840);
      ebr.k7856 = JF(a1, 7856);
      ebr.k7872 = JF(a1, 7872);
      ebr.k7888 = JF(a1, 7888);
      ebr.k7904 = JF(a1, 7904);
      ebr.k7920 = JF(a1, 7920);
      ebr.k7936 = JF(a1, 7936);
      ebr.k7952 = JF(a1, 7952);
      ebr.k7968 = JF(a1, 7968);
      ebr.k7984 = JF(a1, 7984);
      ebr.k8000 = JF(a1, 8000);
      ebr.k8016 = JF(a1, 8016);
      ebr.k8032 = JF(a1, 8032);
      ebr.k8048 = JF(a1, 8048);
      ebr.k8064 = JF(a1, 8064);
      ebr.k8080 = JF(a1, 8080);
      ebr.k8096 = JF(a1, 8096);
      ebr.k8112 = JF(a1, 8112);
      ebr.k8128 = JF(a1, 8128);
      ebr.k8144 = JF(a1, 8144);
      ebr.k8160 = JF(a1, 8160);
      ebr.k8176 = JF(a1, 8176);
      ebr.k8192 = JF(a1, 8192);
      _ch = !EBRHAVE[voice] || memcmp(&EBRC[voice], &ebr, sizeof ebr) != 0;
      EB_GEN_CHECK(16, EBRGEN_SEEN[voice], _ch, "vcf_res");
      if (_ch) { EBRC[voice] = ebr; EBRHAVE[voice] = 1; }
    }

    ebrs.s7520 = JF(a1, 7520);
    ebrs.s7536 = JF(a1, 7536);
    ebrs.s7552 = JF(a1, 7552);
    ebrs.s7568 = JF(a1, 7568);

    v241 = eb_vcf_res_tick(&ebrs, &EBRC[voice], v227,
                           JF(a1, 6704), JF(a1, 6848), &ebr7536);

    JF(a1, 7520) = ebrs.s7520;
    JF(a1, 7536) = ebrs.s7536;
    JF(a1, 7552) = ebrs.s7552;
    JF(a1, 7568) = ebrs.s7568;
  }
  /* ============ ENGINE B MODULE M-VCF — the 4-pole ladder core ===========
   * REPLACES src/voice_render.c:1298-1515 verbatim.
   *
   * STATE LIVES IN THE PORT'S OWN CELLS, exactly as module M7's shim does and
   * as engine_b/shim/README.md sanctions: the module's 41 floats are loaded
   * from the port's cells at the top of the sample and stored back at the
   * bottom, so the module inherits the port's create/destroy/eight-voice
   * lifecycle with no ownership question for the harness to get wrong. That
   * copying is HARNESS cost and is excluded from every cycle figure reported
   * for this module -- the cost rig measures eb_vcf_ladder.c alone.
   *
   * NOT written back (the SHADOW stores named in eb_vcf_ladder.h item 3):
   * [8992] and the six scratch cells [8336..8416]. GREPPED: no reader outside
   * this block anywhere in src/ or gui/.
   */
  {
    static eb_vcf_coef ebc;
    eb_vcf_state ebs;
    int ebi;
    float ebprev, ebs2in;

    if ( JF(a1, 9056) == 1.0f )
    {
      /* COEFFICIENT CACHE -- see the note in the decimator's shim. These 30
       * cells are recall-rate, and the shim was reloading all of them every
       * sample per voice; the sixteen-tap loop alone MEASURED 776 executed
       * instructions per sample. Cached on a memcmp of the raw cells, which is
       * stricter than a float compare and therefore safe. */
      {
        float _raw[30];
        int _k = 0;
        int _ch = 0;
        if (!EBFGEN_SEEN[voice] || EB_GEN_STALE(2, EBFGEN_SEEN[voice])) {
        _raw[_k++] = JF(a1, 9520); _raw[_k++] = JF(a1, 9536);
        _raw[_k++] = JF(a1, 9184);
        _raw[_k++] = JF(a1, 9072); _raw[_k++] = JF(a1, 9088);
        _raw[_k++] = JF(a1, 9104);
        _raw[_k++] = JF(a1, 9200); _raw[_k++] = JF(a1, 9216);
        _raw[_k++] = JF(a1, 9232); _raw[_k++] = JF(a1, 9248);
        _raw[_k++] = JF(a1, 9120); _raw[_k++] = JF(a1, 9136);
        _raw[_k++] = JF(a1, 9168); _raw[_k++] = JF(a1, 9152);
        for ( ebi = 0; ebi < 16; ++ebi )
          _raw[_k++] = JF(a1, 9504 - 16 * ebi);
          _ch = !EBFHAVE[voice] || memcmp(EBFRAW[voice], _raw, sizeof _raw) != 0;
          EB_GEN_CHECK(2, EBFGEN_SEEN[voice], _ch, "ladder");
        }
        if (_ch) {
          eb_vcf_coef *q = &EBFC[voice];
          memcpy(EBFRAW[voice], _raw, sizeof _raw);
          q->c9520 = _raw[0];  q->c9536 = _raw[1];  q->c9184 = _raw[2];
          q->c9072 = _raw[3];  q->c9088 = _raw[4];  q->c9104 = _raw[5];
          q->c9200 = _raw[6];  q->c9216 = _raw[7];  q->c9232 = _raw[8];
          q->c9248 = _raw[9];  q->c9120 = _raw[10]; q->c9136 = _raw[11];
          q->c9168 = _raw[12]; q->c9152 = _raw[13];
          for ( ebi = 0; ebi < 16; ++ebi ) q->fir[ebi] = _raw[14 + ebi];
          EBFHAVE[voice] = 1;
        }
        ebc = EBFC[voice];
      }

      /* ==== THE STATE LIVES IN ENGINE B, NOT IN THE PORT'S CELLS =========
       * This copy in and out was the single largest cost in the whole engine:
       * MEASURED, host, 8 voices, 48 kHz, the two hist accessors alone were
       * 3,072 executed instructions per sample and the surrounding block
       * 17,008 -- 62 % of the port function's self cost and 34 % of the entire
       * engine. None of it is DSP. It exists only so one module can be
       * substituted at a time.
       *
       * IT IS SAFE TO STOP MAINTAINING THESE CELLS, and that was CHECKED
       * rather than assumed: an exact search over every src/*.c for each of
       * 8208/8224/8240/8256/8272/8288/8304/8320/8944/8960/8976 and the four
       * history bases 8432/8560/8688/8816 finds NO reader outside this block.
       * The only other code that touches them is src/chorus_init.c, which
       * zeroes them at power-on -- and that is what gives the fresh-context
       * marker below.
       *
       * THE MARKER is cell 8320. chorus_init zeroes it at power-on; the only
       * other writer was this block (the delayed copy of s2), and nothing reads
       * it, so engine B claims it. A static array outlives the engine context
       * and malloc reuses addresses, so the "is this context new?" question has
       * to be answered by the PORT, not by a pointer. Same pattern as the
       * decimator (cell 5440) and the noise SVF (cell 4288). */
      if (JF(a1, 8320) == 0.0f) {
        eb_vcf_reset(&EBF[voice]);
        JF(a1, 8320) = 1.0f;
      }

      JF(a1, 9040) = eb_vcf_tick(&EBF[voice], &ebc,
                                 JF(a1, 6544), v241, JF(a1, 7536));
      (void)ebs; (void)ebs2in; (void)ebprev; (void)ebi;
    }
    else
    {
      /* The gate cell [9056] is 1.0 from juno_prepare.c:88 and has no other
       * writer, so this arm is unreachable in the port. It is the port's own
       * unconditional shift block (:1300-1337) reproduced verbatim, because
       * "unreachable" is a claim about today's recall and not a licence to
       * change behaviour. */
      JI(a1, 8320) = JI(a1, 8304); JI(a1, 8304) = JI(a1, 8288);
      JI(a1, 8288) = JI(a1, 8272); JI(a1, 8272) = JI(a1, 8256);
      JI(a1, 8256) = JI(a1, 8240); JI(a1, 8240) = JI(a1, 8224);
      JI(a1, 8224) = JI(a1, 8208);
      for ( ebi = 7; ebi >= 1; --ebi )
      {
        JI(a1, 8432 + 16 * ebi) = JI(a1, 8432 + 16 * (ebi - 1));
        JI(a1, 8560 + 16 * ebi) = JI(a1, 8560 + 16 * (ebi - 1));
        JI(a1, 8688 + 16 * ebi) = JI(a1, 8688 + 16 * (ebi - 1));
        JI(a1, 8816 + 16 * ebi) = JI(a1, 8816 + 16 * (ebi - 1));
      }
      JI(a1, 8960) = JI(a1, 8944);
      JF(a1, 8992) = JF(a1, 8976);
    }
  }
  /* =============== END ENGINE B MODULE M-VCF ============================= */
  /* ========= ENGINE B MODULE M-VCA — the VCA + HPF output stage ==========
   * REPLACES src/voice_render.c:1516-1640 verbatim.
   *
   * STATE LIVES IN THE PORT'S OWN CELLS, exactly as modules M7 and M-VCF do
   * and as engine_b/shim/README.md sanctions: the module's 10 floats are
   * loaded from the port's cells at the top and stored back at the bottom, so
   * the module inherits the port's create/destroy/eight-voice lifecycle AND
   * the port's per-sample denormal flush (src/juno_ftz.c flushes 9904, 10432,
   * 10480 and 10496 — every one of the module's cells that the port flushes).
   * That copying is HARNESS cost and is excluded from every cycle figure
   * reported for this module: the cost rig measures eb_vca_hpf.c alone.
   *
   * NOT written back (the SHADOW stores named in eb_vca_hpf.h item 2):
   * [9568] [9696] [9728] [9760] [9792] [9840] [9872] [9920] [9936] [10048]
   * [10064] [10080] [10112] [10144] [10160] [10416] [10448] [10544] [10656].
   * GREPPED across src/ and gui/: each is write-only or read only inside this
   * block.
   */
  {
    static eb_vca_coef ebvc;
    eb_vca_state ebvs;

    ebvc.c9552  = JF(a1, 9552);  ebvc.c9584  = JF(a1, 9584);
    ebvc.c9600  = JF(a1, 9600);  ebvc.c9616  = JF(a1, 9616);
    ebvc.c9680  = JF(a1, 9680);  ebvc.c9744  = JF(a1, 9744);
    ebvc.c9808  = JF(a1, 9808);  ebvc.c9824  = JF(a1, 9824);
    ebvc.c9888  = JF(a1, 9888);  ebvc.c9952  = JF(a1, 9952);
    ebvc.c9968  = JF(a1, 9968);  ebvc.c9984  = JF(a1, 9984);
    ebvc.c10000 = JF(a1, 10000); ebvc.c10016 = JF(a1, 10016);
    ebvc.c10032 = JF(a1, 10032); ebvc.c10176 = JF(a1, 10176);
    ebvc.c10192 = JF(a1, 10192); ebvc.c10208 = JF(a1, 10208);
    ebvc.c10224 = JF(a1, 10224); ebvc.c10240 = JF(a1, 10240);
    ebvc.c10256 = JF(a1, 10256); ebvc.c10272 = JF(a1, 10272);
    ebvc.c10288 = JF(a1, 10288); ebvc.c10304 = JF(a1, 10304);
    ebvc.c10320 = JF(a1, 10320); ebvc.c10336 = JF(a1, 10336);
    ebvc.c10352 = JF(a1, 10352); ebvc.c10368 = JF(a1, 10368);
    ebvc.c10384 = JF(a1, 10384); ebvc.c10400 = JF(a1, 10400);
    ebvc.c10464 = JF(a1, 10464); ebvc.c10560 = JF(a1, 10560);
    ebvc.c10576 = JF(a1, 10576); ebvc.c10592 = JF(a1, 10592);
    ebvc.c10608 = JF(a1, 10608); ebvc.c10624 = JF(a1, 10624);
    ebvc.c10640 = JF(a1, 10640);

    ebvs.sm     = JF(a1, 9712);  ebvs.g1  = JF(a1, 9776);
    ebvs.g2     = JF(a1, 9856);  ebvs.gate_y = JF(a1, 9904);
    ebvs.lp     = JF(a1, 10096); ebvs.lp2 = JF(a1, 10128);
    ebvs.dcacc  = JF(a1, 10432);
    ebvs.x1     = JF(a1, 10480); ebvs.yA = JF(a1, 10496);
    ebvs.yB     = JF(a1, 10512);

    JF(a1, 10672) = eb_vca_tick(&ebvs, &ebvc,
                                JF(a1, 9040), JF(a1, 2752), JF(a1, 3232),
                                JF(a1, 6848), JF(a1, 560));

    JF(a1, 9712)  = ebvs.sm;    JF(a1, 9776)  = ebvs.g1;
    JF(a1, 9856)  = ebvs.g2;    JF(a1, 9904)  = ebvs.gate_y;
    JF(a1, 10096) = ebvs.lp;    JF(a1, 10128) = ebvs.lp2;
    JF(a1, 10432) = ebvs.dcacc;
    JF(a1, 10480) = ebvs.x1;    JF(a1, 10496) = ebvs.yA;
    JF(a1, 10512) = ebvs.yB;
  }
  /* ==== ENGINE B MODULE PITCH ========================================== */
  {
    float _cv = JF(a1, 4448) + JF(a1, 3776);
    v391 = eb_pitch_eval(_cv, JF(a1, 3792));
  }
  JF(a1, 4416) = v391;
  /* ==== END ENGINE B MODULE PITCH ====================================== */
  v392 = JF(a1, 3776);
  v393 = JI(a1, 4240);
  v394 = JI(a1, 4256);
  v386_lo = JI(a1, 4272);
  JI(a1, 4848) = JI(a1, 4832);
  JI(a1, 4880) = JI(a1, 4864);
    /* ==== ENGINE B MODULE DECIM: the 30-move delay-line and biquad shift
     * is a rotating index in eb_decim.c and moves nothing. ==== */
  JI(a1, 4736) = v393;
  JI(a1, 4752) = v394;
  v395 = v392 + JF(a1, 6304);
  v396 = v391 * JF(a1, 5536);
  v397 = JF(a1, 5520);
  JI(a1, 4768) = v386_lo;
  v398 = fmaxf(JF(a1, 5568), v396);
  v399 = (float)(v395 * JF(a1, 6320)) + JF(a1, 6288);
  JF(a1, 4784) = _s4784 = v398;
  JF(a1, 4816) = _s4816 = v397 + JF(a1, 3808);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  JF(a1, 4800) = _s4800 = 0.00390625 / v398;
  JF(a1, 5456) = v400;
  /* ================= ENGINE B MODULE — THE DCO OSCILLATOR =================
   * REPLACES src/voice_render.c:1718-2136 verbatim. Diff this file against
   * src/voice_render.c: this block is the ONLY change, plus the include above.
   *
   * The port writes the four 4x-rate oscillator samples out to the polyphase
   * cells 4944 / 5072 / 5200 / 5328; those cells are read by the decimator at
   * :2137 (via the shift at :1672-1699), so they are written here too. The
   * NINE cells that only carry a value from the bottom of the sample back to
   * the top or hold an intra-sample tap -- 4640, 4656, 4672, 4848, 4880, 4896,
   * 4912 -- are NOT written. GREPPED: no reader outside this range anywhere in
   * src/ or gui/. Audio is unaffected; per-cell state parity is not, and that
   * is a sonic-identity claim rather than a bit-exact-state one.
   *
   * STATE LIVES IN THE PORT'S OWN CELLS 4864 (phase) and 4832 (sub counter),
   * which are exactly the two the port hands from sample to sample, so the
   * module inherits the port's power-on, create/destroy and eight-voice
   * lifecycle with no ownership question for the harness to get wrong.
   * engine_b/shim/README.md sanctions this. No cycle figure is ever taken from
   * the shim: the cost rig measures eb_dco.c alone.
   */
  {
    eb_dco_state ebs;
    eb_dco_coef  ebc;

    ebc.lvl_saw   = JF(a1, 4736);
    ebc.lvl_pulse = JF(a1, 4752);
    ebc.lvl_sub   = JF(a1, 4768);
    ebc.gn_saw    = JF(a1, 5648);
    ebc.gn_pulse  = JF(a1, 5664);
    ebc.gn_sub    = JF(a1, 5680);
    ebc.amp_saw   = JF(a1, 5600);
    ebc.amp_pulse = JF(a1, 5616);
    ebc.amp_sub   = JF(a1, 5632);
    ebc.sat_in    = JF(a1, 5552);
    ebc.k3        = JF(a1, 5952);
    ebc.k5        = JF(a1, 5968);
    ebc.k7        = JF(a1, 5984);
    ebc.k9        = JF(a1, 6000);
    ebc.k11       = JF(a1, 6016);
    ebc.subthr    = JF(a1, 5584);
    /* inc and pw are the two modulated numbers the CV module hands over; g is
     * rebuilt here rather than copied from cell 4800 so that eb_dco_set_pitch
     * is under the gate too. It is the same divide. */
    eb_dco_set_shape(&ebc);          /* recall-rate in the engine; per sample
                                      * here because this shim has no parameter
                                      * path of its own to hook. HARNESS cost,
                                      * excluded from every cycle figure. */
    eb_dco_set_pitch(&ebc, _s4784, _s4816);

    ebs.phase  = JF(a1, 4864);
    ebs.subcnt = JF(a1, 4832);

    {
      float _o[4];
      eb_dco_step4(&ebs, &ebc, _o);
      JF(a1, 4944) = _o[0];
      JF(a1, 5072) = _o[1];
      JF(a1, 5200) = _o[2];
      JF(a1, 5328) = _o[3];
    }

    JF(a1, 4864) = ebs.phase;
    JF(a1, 4832) = ebs.subcnt;
  }
  v518 = JF(a1, 5440);
  /* =============== END ENGINE B MODULE — DCO ============================== */

  /* ==== ENGINE B MODULE DECIM ============================================
   * The 32-tap polyphase FIR and the correction biquad, in engine_b/eb_decim.c.
   * v518 (the port's JF(a1,5440), the oldest phase-3 tap) is NOT passed in: it
   * is a tap the module already owns. The four fresh sub-samples are. */
  {
    eb_decim_coef _dc;
    eb_decim_state _ds;
    eb_voice *_v = &EBV[voice];
    int _q;
    /* fresh context? the port zeroed cell 5440 -- see the note above */
    if (JF(a1, 5440) == 0.0f) {
        for (_q = 0; _q < 32; ++_q) ((float *)_v->decim_h)[_q] = 0.0f;
        _v->decim_w = 0;
        _v->decim_b1 = _v->decim_b2 = _v->decim_b3 = 0.0f;
        JF(a1, 5440) = 1.0f;              /* claim it; the port never reads it */
    }
    static const int _CC[16] = {5712,5696,5728,5744,5760,5776,5792,5808,
                                5824,5840,5856,5872,5888,5904,5920,5936};
    int _i;
    /* COEFFICIENT CACHE. These twenty cells are recall-rate: only a patch
     * change moves them, yet the shim was reloading all twenty every sample
     * per voice. MEASURED: 512 executed instructions per sample for the
     * sixteen-tap loop alone. Pure HARNESS cost -- the shipped engine computes
     * these once at recall -- so it is cached on a memcmp of the raw cells.
     * memcmp is stricter than a float compare (it separates +0.0 from -0.0)
     * and a needless recompute yields identical coefficients, so being
     * conservative in that direction is safe. */
    {
      /* STEP 4: THE GATHER MOVED INSIDE THE GENERATION CHECK.
       * Reading these cells was itself the cost -- MEASURED 536 executed
       * instructions per sample -- and there is no point gathering values in
       * order to compare them when the counter already says nothing can have
       * changed. Under -DEB_VERIFY_GEN the branch is always taken, so the
       * verification build still gathers and still compares every sample. */
      float _raw[20];
      int _ch = 0;
      if (!EBDGEN_SEEN[voice] || EB_GEN_STALE(3, EBDGEN_SEEN[voice])) {
        for (_i = 0; _i < 16; ++_i) _raw[_i] = JF(a1, _CC[_i]);
        _raw[16] = JF(a1, 6256); _raw[17] = JF(a1, 6272);
        _raw[18] = JF(a1, 6336); _raw[19] = JF(a1, 5456);
        _ch = !EBDHAVE[voice] || memcmp(EBDRAW[voice], _raw, sizeof _raw) != 0;
        EB_GEN_CHECK(3, EBDGEN_SEEN[voice], _ch, "decim");
      }
      if (_ch) {
        memcpy(EBDRAW[voice], _raw, sizeof _raw);
        for (_i = 0; _i < 16; ++_i) EBDC[voice].c[_i] = _raw[_i];
        EBDC[voice].k6256 = _raw[16]; EBDC[voice].k6272 = _raw[17];
        EBDC[voice].k6336 = _raw[18]; EBDC[voice].k5456 = _raw[19];
        EBDHAVE[voice] = 1;
      }
      _dc = EBDC[voice];
    }
    /* eb_decim_state is the module's view; eb_voice is where it LIVES. The
     * copy in and out is temporary scaffolding for the shim only -- in the
     * standalone engine the module reads eb_voice directly and this vanishes. */
    for (_q = 0; _q < 32; ++_q) ((float *)_ds.h)[_q] = ((float *)_v->decim_h)[_q];
    _ds.w = _v->decim_w;
    _ds.b1 = _v->decim_b1; _ds.b2 = _v->decim_b2; _ds.b3 = _v->decim_b3;

    v526 = eb_decim_tick(&_ds, &_dc, JF(a1, 4944), JF(a1, 5072),
                                     JF(a1, 5200), JF(a1, 5328));

    for (_q = 0; _q < 32; ++_q) ((float *)_v->decim_h)[_q] = ((float *)_ds.h)[_q];
    _v->decim_w = _ds.w;
    _v->decim_b1 = _ds.b1; _v->decim_b2 = _ds.b2; _v->decim_b3 = _ds.b3;
  }
  JF(a1, 4928) = v526;
  JF(a1, 3520) = v526;
  /* ==== END ENGINE B MODULE DECIM ======================================= */
  if ( JF(base, auxoff) == 1.0 )
  {
    JI(a1, 320) = v528;
    JI(base, auxoff) = 0;
  }
  *outL = JF(a1, 10672);
  result = JU(a1, 10672);
  *outR = JF(a1, 10672);
  return result;
}

