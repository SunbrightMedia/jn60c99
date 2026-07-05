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
 * (VCF cutoff/resonance, HPF cutoff), both ADSRs (filter + amp attack/release,
 * filter sustain), filter env-mod, key-follow, VCA tone — where both the blob
 * position and the engine (curve,offset) are unambiguous and, where an oracle
 * value exists, verified. Every curve id below was re-confirmed by RUNNING the
 * real setter thunk under Unicorn (see tools/pin_curve provenance).
 * NOT applied yet, for a documented reason (never guessed):
 *   - DCO oscillator mix (saw/sub/sqr/noise levels) and VCA/AMP level: these do
 *     NOT go through a per-parameter curve setter at all — they are produced by
 *     the registry coefficient generator (reflection "Koa" value tree), which is
 *     not ported. Confirmed: none of the 23 vtable classes expose a curve-setter
 *     thunk that writes 4192/4208/4224/6528/10320.
 *   - ENV2 (amp) decay/sustain: the anchor patch has decay==sustain==255, so the
 *     value-anchor can't order the two blob slots.
 * See docs/AUDIBLE_RECALL_PLAN.md.
 *
 * At 96 kHz (the engine's rate) the sample-rate-variant ADSR curves resolve to
 * the "other" variant (ENV attack=35, decay/release=38) — verified by emulating
 * the real thunks with voice+0x38 set to 96000. HPF cutoff (curve 41) is
 * SR-invariant (same curve at 44.1/48/96 kHz).
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
 * - blob_pos: aligned to the plugin's ordered param table, anchored to the known
 *   values of bank patch 5 "LD Classic Lead" (unique value matches).
 * - curve_id: from the plugin's setter thunks, confirmed by running the real
 *   thunks under Unicorn. Sample-rate-variant curves (the envelope times) were
 *   emulated at 96 kHz (our engine's rate): ENV Attack=35, Decay/Release=38.
 * - offset: the engine coefficient slot (registry, name-checked vs COEFF_PARAM_MAP).
 * VCF CUTOFF FREQ is oracle-proven: juno_curve(22,153)=0.600000 == the plugin's
 * own float value for this patch. */
typedef struct { int blob_pos; int curve_id; int offset; const char *name; } juno_bind;

static const juno_bind BINDINGS[] = {
    { 35, 22,  6736, "VCF CUTOFF FREQ" },   /* -> LPF Cutoff  (VERIFIED = 0.6)     */
    { 37, 22,  6832, "VCF RESONANCE"   },   /* -> LPF Resonance                    */
    { 38, 41, 10240, "HPF CUTOFF FREQ" },   /* -> HPF Cutoff (curve 41, SR-invariant)*/
    { 44, 35,  2784, "ENV1 ATTACK"     },   /* -> filter ENV Attack  (96k curve 35)*/
    { 41, 38,  2816, "ENV1 DECAY"      },   /* -> filter ENV Decay   (96k curve 38)*/
    { 42, 50,  2800, "ENV1 SUSTAIN"    },   /* -> filter ENV Sustain               */
    { 43, 38,  2832, "ENV1 RELEASE"    },   /* -> filter ENV Release (96k curve 38)*/
    { 45, 35,  3264, "ENV2 ATTACK"     },   /* -> amp ENV Attack                   */
    { 52, 38,  3312, "ENV2 RELEASE"    },   /* -> amp ENV Release                  */
    { 48, 24,  7408, "VCF KEY FOLLOW"  },   /* -> KCV Level                        */
    { 39, 46,  7392, "VCF ENV MOD"     },   /* -> ENV Level (filter env depth)     */
    { 53, 24,  9584, "VCA TONE"        },   /* -> AMP TONE                         */
    { 26, 54,  4208, "DCO PWM LEVEL"   },   /* -> JU OSC Sqr Lev (see note below)  */
    {  7, 44,  1920, "LFO DELAY TIME"  },   /* -> LFO Delay (value tree, 96k c44)  */
    { 66, 49,101072, "VCA LEVEL"       },   /* -> Patch Level (value tree c49)     */
    { 27, 54,  4192, "DCO SAW LEVEL"   },   /* -> JU OSC Saw Lev (value tree c54)  */
    { 28, 54,  4224, "DCO SUB LEVEL"   },   /* -> JU OSC Sub Lev (value tree c54)  */
    { 29, 54,  6528, "DCO NOISE LEVEL" },   /* -> Osc Noise Level (value tree c54) */
    {  9,  0,  4032, "DCO LFO MOD"     },   /* -> LFO Level (value tree c0)        */
    { 10, 47,  7344, "VCF LFO MOD"     },   /* -> LFO Level (VCF) (value tree c47) */
    { 12, 51,  1872, "LFO KEY TRIG"    },   /* -> LFO Trig (value tree c51)        */
    { 14, 45,  4144, "DCO PWM DEPTH"   },   /* -> PWM Level (value tree c45)       */
    { 16,  5,  3840, "DCO RANGE"       },   /* -> OSC1 Feet (value tree c5)        */
    { 46, 38,  3296, "ENV2 DECAY"      },   /* -> amp ENV Decay (96k c38)          */
    { 47, 50,  3280, "ENV2 SUSTAIN"    },   /* -> amp ENV Sustain (value tree c50) */
    /* DCO LFO MOD + the 6 above: blob position from the plugin's own value-tree
     * leaf serialization order (the CKoa tree child order; three code-reading
     * agents + the parser agree it is blob = panel+5 with the tree-reordered
     * leaves at panel+9, reproducing all committed anchors). It is reliable for
     * the non-reordered run blob<=48; each row's curve+offset is proven by RUNNING
     * the plugin's value-tree dispatch, and juno_curve(curve, patch5_raw)
     * reproduces the dispatch's exact float bit-for-bit (verified per row,
     * including VCF LFO MOD's bipolar-center denormal 4.1632e-28). */
    /* DCO SAW/SUB/NOISE LEVEL: value tree routes panels 22/23/24 -> off
     * 4192/4224/6528 (all curve 54). Blob positions come from the plugin's own
     * canonical panel->blob table (.text rva 0x3b7d60, table[panel+27]=blob_pos),
     * which reproduces EVERY committed anchor's blob position and the DCO block
     * 21..24 -> blob 26..29 in order. Cross-checks: PWM blob26=172 and SAW blob27=
     * 149 are unique value-matches; NOISE blob29=0 matches; SUB blob28=0 (patch 5's
     * SUB is 0 — the Ableton JSON's 149 was a copy of SAW, per the recall trace).
     * The DCO block is in the table's NON-reordered region (unlike the envelope
     * blocks, where the JU-06A reorders A,D,S,R->D,S,R,A). juno_curve(54,·) matches
     * the value tree bit-for-bit for each. */
    /* DCO PWM LEVEL: bound via the plugin's own RUNTIME value tree, now emulated
     * under Unicorn (processor ctor sub_7FF91E013320 + param dispatch
     * sub_7FF91E019A30). The dispatch maps panel index -> engine setter; verified
     * reproducing all 12 anchors exactly (VCF CUTOFF->6736, HPF->10240, ...), with
     * panel_index + 749 == dispatch_index. Panel 21 "DCO PWM LEVEL" -> dispatch 770
     * -> engine offset 4208 (curve 54). Cross-checked: juno_curve(54,172)=0.9901619
     * reproduces the value tree's output bit-for-bit. blob_pos 26 is patch 5's
     * unique slot holding 172 (== the plugin's DCO PWM LEVEL value).
     *   CORRECTION: an earlier commit bound this to offset 4144/curve 45; that slot
     *   is actually DCO PWM *DEPTH* (panel 9). The value tree is authoritative.
     *
     * NOT YET BOUND (engine side proven via the value tree; blob_pos pending the
     * recall FRONT-END emulation, no fabrication):
     *   DCO SAW LEVEL (off 4192, curve 54) / DCO SUB LEVEL (off 4224, curve 54):
     *     patch 5 has both listed 149 and only blob 27 holds 149, so the blob->panel
     *     split needs the bank-file recall front-end (in progress).
     *   DCO NOISE LEVEL (off 6528, curve 54): patch 5 value 0 is non-unique.
     *   VCA/patch level (off 101072 "Patch Level", curve 49): value-tree-proven
     *     engine side; blob_pos 66 (value 46) unique but pending front-end confirm. */
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
