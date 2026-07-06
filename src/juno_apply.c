/* juno_apply.c — apply a JUNO-60 bank patch to the engine coefficient slots.
 *
 * Chain (all pieces below are from the plugin, no captures):
 *   bank blob byte  --(bit-exact curve, src/juno_curve.c)-->  engine coefficient.
 * The bit-exact curve evaluator is PROVEN vs the real machine code (Unicorn).
 * The per-parameter binding {blob_pos -> (curve_id, engine_offset)} is recovered
 * from: (a) RUNNING the plugin's real value-tree dispatch under Unicorn (curve_id +
 * engine_offset per parameter), and (b) the value-tree leaf SERIALIZATION order:
 * blob_pos = pool_index - 2 (declaration order), with 4 envelope/filter leaves
 * displaced +4 by address-sort (ENV1 ATTACK, VCF KEY FOLLOW, ENV2 RELEASE, VCA TONE).
 *
 * VALIDATED (binary-only, non-circular): decoding the raw .bin blob at blob_pos
 * 70..85 with this same nibble formula spells each patch's NAME exactly ("LD Classic
 * Lead", "SY Poly Synth", ...), because the value tree stores the 16-char patch name
 * as leaves pool 72..87 = blob_pos 70..85. Real ASCII data landing exactly where the
 * pool mapping predicts proves the decode + blob_pos=pool-2 mapping independently of
 * the value tree. Cross-check: patch 5 VCF CUTOFF FREQ = blob 153 -> juno_curve(22,153)
 * = 0.600000 == the value tree's own float for this patch.
 *
 * COVERAGE (honest): 30 distinct parameters — the front-panel synthesis block, which
 * DEFINES the timbre. These are in the 222-byte front-panel window (record byte =
 * 2*pool_index + 12 for pool 2..112; blob_pos = pool_index - 2), verified END-TO-END
 * bit-exact vs the value tree (tools/golden_cmp.py: all 64 patches, 40 offsets).
 *   The EXTENDED params (PATCH2/PATCH3 leaves: velocity/mod/bend sens, cutoff-H,
 *   tune/condition, VCA mode, HPF/effect/delay/reverb TYPE) are NOT bound: the record
 *   is a MULTI-BLOCK structure and those leaves live at higher, non-flat offsets (e.g.
 *   VCF CUTOFF FREQ H is at record byte ~1871, not 2*287+12) whose addresses are the
 *   schema addresses (same external-schema data that blocks the EFX order). An earlier
 *   attempt using a flat offset formula was WRONG (it read empty bytes as 0); reverted.
 *   Remapping PATCH2/PATCH3 needs the record deserializer or the external schema.
 * Bound groups:
 *   - VCF: cutoff, resonance, HPF cutoff (+3 secondary coeffs), env-mod, key-follow,
 *     LFO mod, VCA tone.
 *   - Envelopes: ENV1 A/D/S/R and ENV2 A/D/S/R (all four each).
 *   - DCO: range, PWM depth, PWM level, saw/sub/noise level, LFO mod, PWM SOURCE
 *     (a small-integer enum: LFO/ENV1±/ENV2±/Manual — see apply_pwm_source).
 *   - LFO: delay, rate, key-trig, tempo-sync.  Global: VCA level, portamento,
 *     bend range.
 * The blob->panel order is the plugin's own value-tree leaf SERIALIZATION order
 * (leaf.address = 2*blob_pos, emitted in address order; the schema places ENV1 as
 * D,S,R,A because ATTACK has the highest address). Per-panel (curve,offset,transform)
 * come from RUNNING the plugin's real value-tree dispatch under Unicorn and matching
 * juno_curve(curve, transform(value)) bit-for-bit across a dense value grid.
 * NOT applied yet, for a documented reason (never guessed):
 *   - The four EFX leaves (EFFECT DEPTH, REVERB LEVEL, DELAY LEVEL, DELAY TIME):
 *     these occupy blob {40,49,50,51} (proven: the parser transform table gives
 *     blob50=addr100, blob51=addr102; 80/98 are direct-copy), but the exact
 *     leaf->slot PERMUTATION is provably NOT in this binary — the per-leaf schema
 *     `address` values are read from an EXTERNAL descriptor file (the schema parser
 *     is fed by a std::ifstream; the two in-file name tables are display-order only
 *     and carry no address). Two plausible orderings conflict and the binary cannot
 *     disambiguate, so we refuse to guess. These also route to the master/chorus FX
 *     section (the un-decompiled, silent path), so deferring them costs no audio.
 *   - LEGATO / ASSIGN MODE: probing a FRESH value tree shows these write NO engine
 *     coefficient at all — they are note-allocation flags (mono/poly/legato voice
 *     behaviour) stored in the flat param array, not DSP coefficients, so there is
 *     nothing to apply for bit-exact timbre recall.
 *   - Exponential rate coefficients (LFO Tempo Rate off1072, Delay Time off102352):
 *     no juno_curve matches; need the specific formula ported from the decompile.
 *     Both are tempo-synced (inaudible in the free-running dry preview).
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
/* Value transforms applied to the raw blob byte before juno_curve(). Recovered by
 * RUNNING the value tree over a dense grid and finding, per engine coefficient, the
 * unique (curve_id, transform) whose juno_curve(curve, tf(v)) reproduces the tree's
 * float for EVERY grid value bit-for-bit (see tools/genfull2). Most params are T_ID;
 * a few driven coefficients (e.g. HPF Boost Thru) use a bipolar/halved input. */
enum { T_ID, T_HALF, T_BIP, T_INV, T_INVHALF };
static int apply_tf(int tf, int v)
{
    switch (tf) {
        case T_HALF:    return v >> 1;
        case T_BIP:     return (v >> 1) + 128;
        case T_INV:     return 255 - v;
        case T_INVHALF: return ((255 - v) >> 1) + 1;
        default:        return v;              /* T_ID */
    }
}

typedef struct { int blob_pos; int curve_id; int tf; int offset; const char *name; } juno_bind;

static const juno_bind BINDINGS[] = {
    { 35, 22, T_ID,  6736, "VCF CUTOFF FREQ" }, /* -> LPF Cutoff  (VERIFIED = 0.6)     */
    { 37, 22, T_ID,  6832, "VCF RESONANCE"   }, /* -> LPF Resonance                    */
    { 38, 41, T_ID, 10240, "HPF CUTOFF FREQ" }, /* -> HPF Cutoff (curve 41, SR-invar.) */
    { 38, 52, T_ID, 10256, "HPF CUTOFF FREQ" }, /* -> HPF Switch  (2nd coeff)          */
    { 38, 10, T_ID, 10272, "HPF CUTOFF FREQ" }, /* -> Boost LPF Level (3rd coeff)      */
    { 38, 18, T_BIP,10288, "HPF CUTOFF FREQ" }, /* -> Boost Thru Level (4th, bipolar)  */
    { 44, 35, T_ID,  2784, "ENV1 ATTACK"     }, /* -> filter ENV Attack  (96k curve 35)*/
    { 41, 38, T_ID,  2816, "ENV1 DECAY"      }, /* -> filter ENV Decay   (96k curve 38)*/
    { 42, 50, T_ID,  2800, "ENV1 SUSTAIN"    }, /* -> filter ENV Sustain               */
    { 43, 38, T_ID,  2832, "ENV1 RELEASE"    }, /* -> filter ENV Release (96k curve 38)*/
    { 45, 35, T_ID,  3264, "ENV2 ATTACK"     }, /* -> amp ENV Attack                   */
    { 52, 38, T_ID,  3312, "ENV2 RELEASE"    }, /* -> amp ENV Release                  */
    { 48, 24, T_ID,  7408, "VCF KEY FOLLOW"  }, /* -> KCV Level                        */
    { 39, 46, T_ID,  7392, "VCF ENV MOD"     }, /* -> ENV Level (filter env depth)     */
    { 53, 24, T_ID,  9584, "VCA TONE"        }, /* -> AMP TONE                         */
    { 26, 54, T_ID,  4208, "DCO PWM LEVEL"   }, /* -> JU OSC Sqr Lev (see note below)  */
    {  7, 44, T_ID,  1920, "LFO DELAY TIME"  }, /* -> LFO Delay (value tree, 96k c44)  */
    {  7, 52, T_ID,  1936, "LFO DELAY TIME"  }, /* -> LFO Delay Sw (2nd coeff)         */
    {  8, 22, T_ID,  1088, "LFO RATE"        }, /* -> LFO Rate (value tree c22)        */
    {  8, 22, T_ID,  2064, "LFO RATE"        }, /* -> LFO Noise Mix (shared rate coeff)*/
    { 66, 49, T_ID,101072, "VCA LEVEL"       }, /* -> Patch Level (value tree c49)     */
    { 27, 54, T_ID,  4192, "DCO SAW LEVEL"   }, /* -> JU OSC Saw Lev (value tree c54)  */
    { 28, 54, T_ID,  4224, "DCO SUB LEVEL"   }, /* -> JU OSC Sub Lev (value tree c54)  */
    { 29, 54, T_ID,  6528, "DCO NOISE LEVEL" }, /* -> Osc Noise Level (value tree c54) */
    {  9,  0, T_ID,  4032, "DCO LFO MOD"     }, /* -> LFO Level (value tree c0)        */
    { 10, 47, T_ID,  7344, "VCF LFO MOD"     }, /* -> LFO Level (VCF) (value tree c47) */
    { 12, 51, T_ID,  1872, "LFO KEY TRIG"    }, /* -> LFO Trig (value tree c51)        */
    { 14, 45, T_ID,  4144, "DCO PWM DEPTH"   }, /* -> PWM Level (value tree c45)       */
    { 16,  5, T_ID,  3840, "DCO RANGE"       }, /* -> OSC1 Feet (value tree c5)        */
    { 46, 38, T_ID,  3296, "ENV2 DECAY"      }, /* -> amp ENV Decay (96k c38)          */
    { 47, 50, T_ID,  3280, "ENV2 SUSTAIN"    }, /* -> amp ENV Sustain (value tree c50) */
    { 54, 52, T_ID,   592, "PORTAMENTO"      }, /* -> Porta OnOff (value tree c52)     */
    { 54,  7, T_ID,   624, "PORTAMENTO"      }, /* -> Porta Time  (2nd coeff)          */
    { 57, 10, T_ID,  4128, "BEND RANGE"      }, /* -> Bend (value tree c10; +c10@7472) */
    { 57, 10, T_ID,  7472, "BEND RANGE"      }, /* -> Bend Range VCF (2nd coeff)       */
    { 59, 52, T_ID,  1056, "TEMPO SYNC"      }, /* -> LFO Tempo Rate Sw (value tree c52)*/
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

/* DCO PWM SOURCE (blob 15) is a small-integer ENUM, not a curve: the value tree
 * sets one of four boolean/polarity flags (recovered by probing all 256 values on
 * the value-tree dispatch for panel 10):
 *   0 -> Manual=1;  1 -> LFO=1;  2 -> ENV1=+1;  3 -> ENV1=-1;
 *   4 -> ENV2=+1;   5 -> ENV2=-1;  6..255 -> Manual=1 (default/clamp).
 * Engine slots: PWM SW LFO=3888, ENV1=3904, ENV2=3920, Manual=3936. */
static void apply_pwm_source(unsigned char *state, int v)
{
    float lfo = 0.0f, env1 = 0.0f, env2 = 0.0f, man = 0.0f;
    switch (v) {
        case 1:  lfo  =  1.0f; break;
        case 2:  env1 =  1.0f; break;
        case 3:  env1 = -1.0f; break;
        case 4:  env2 =  1.0f; break;
        case 5:  env2 = -1.0f; break;
        default: man  =  1.0f; break;   /* 0 and 6..255 */
    }
    JF(state, 3888) = lfo;
    JF(state, 3904) = env1;
    JF(state, 3920) = env2;
    JF(state, 3936) = man;
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
        JF(state, BINDINGS[i].offset) =
            juno_curve(BINDINGS[i].curve_id, apply_tf(BINDINGS[i].tf, v));
        ++n;
    }
    /* DCO PWM SOURCE — blob 15 enum (4 flag coefficients). */
    {
        int v = ((blob[2 * 15] & 0xF) << 4) | (blob[2 * 15 + 1] & 0xF);
        apply_pwm_source(state, v);
        ++n;
    }
    return n;
}
