/* juno_apply.c — apply a JUNO-60 bank patch to the engine coefficient slots.
 *
 * Chain (all pieces below are from the plugin, no captures):
 *   bank blob byte  --(bit-exact curve, src/juno_curve.c)-->  engine coefficient.
 * The bit-exact curve evaluator is PROVEN vs the real machine code (Unicorn).
 * The per-parameter binding {blob_pos -> (curve_id, engine_offset)} is recovered
 * from: (a) the plugin's setter thunks (curve_id + engine_offset per parameter,
 * 105/105 name-checked vs COEFF_PARAM_MAP), and (b) an empirical alignment of
 * the bank blob to the plugin's ordered parameter table, anchored to a known
 * patch (bank patch 5 "LD Classic Lead") whose live Ableton values we have.
 *
 * VERIFIED ANCHOR: patch 5's VCF CUTOFF FREQ = blob 153 -> juno_curve(22,153)
 * = 0.600000 == the plugin's own "VCF CUTOFF FREQ H" float. So this chain
 * reproduces the plugin's stored coefficient exactly for the bound parameters.
 *
 * COVERAGE (honest): this binds the CONFIRMED voice-0 subset — the filter
 * (cutoff/resonance/HPF) and the filter ADSR — where both the blob position and
 * the engine (curve,offset) are unambiguous and, where an oracle value exists,
 * verified. Parameters whose engine binding was left ambiguous in the extracted
 * data (the DCO oscillator levels share one curve across saw/sub/sqr/noise; the
 * second ADSR / FX-chain params were not all captured) are NOT applied yet and
 * are listed in docs/AUDIBLE_RECALL_PLAN.md. Nothing is guessed.
 *
 * At 96 kHz (the engine's rate) the sample-rate-variant ADSR curves resolve to
 * the "other" variant (ENV attack=35, decay/release=36) per the empirical trace.
 */
#include "juno_engine.h"
#include "juno_curve.h"
#include "juno_apply.h"

#define BANK_HEADER   23
#define BANK_STRIDE   20223
#define BANK_NAME     16
#define BANK_BLOB_OFF 16
#define BANK_COUNT    64

/* Confirmed bindings: {blob parameter position, curve id, engine state offset}.
 * blob positions anchored to patch 5; curve+offset from the plugin's thunks. */
typedef struct { int blob_pos; int curve_id; int offset; const char *name; } juno_bind;

static const juno_bind BINDINGS[] = {
    { 35, 22,  6736, "VCF CUTOFF FREQ" },   /* -> LPF Cutoff (verified = 0.6)   */
    { 37, 22,  6832, "VCF RESONANCE"   },   /* -> LPF Resonance                 */
    { 38,  1, 10240, "HPF CUTOFF FREQ" },   /* -> HPF Cutoff                    */
    { 44, 35,  2784, "ENV1 ATTACK"     },   /* -> filter ENV Attack (96k curve) */
    { 41, 36,  2816, "ENV1 DECAY"      },   /* -> filter ENV Decay              */
    { 42, 50,  2800, "ENV1 SUSTAIN"    },   /* -> filter ENV Sustain            */
    { 43, 36,  2832, "ENV1 RELEASE"    },   /* -> filter ENV Release            */
};
#define N_BINDINGS ((int)(sizeof(BINDINGS)/sizeof(BINDINGS[0])))

int juno_bank_num_patches(const unsigned char *bank, unsigned long len)
{
    if (len < BANK_HEADER || bank[0] != 'K') return 0;   /* "KoaBankFile00003" */
    return BANK_COUNT;
}

int juno_bank_patch_name(const unsigned char *bank, int idx, char out[17])
{
    int i;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    const unsigned char *rec = bank + BANK_HEADER + idx * BANK_STRIDE;
    for (i = 0; i < BANK_NAME; ++i) out[i] = (char)rec[i];
    out[BANK_NAME] = 0;
    /* trim trailing spaces */
    for (i = BANK_NAME - 1; i >= 0 && (out[i] == ' ' || out[i] == 0); --i) out[i] = 0;
    return 1;
}

/* Apply patch `idx` from `bank` into the engine `state`. Returns #params set. */
int juno_bank_apply(unsigned char *state, const unsigned char *bank, int idx)
{
    int i, n = 0;
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    for (i = 0; i < N_BINDINGS; ++i) {
        int p = BINDINGS[i].blob_pos;
        int v = ((blob[2 * p] & 0xF) << 4) | (blob[2 * p + 1] & 0xF);  /* hi-nibble */
        JF(state, BINDINGS[i].offset) = juno_curve(BINDINGS[i].curve_id, v);
        ++n;
    }
    return n;
}
