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
 * COVERAGE (honest, and now COMPLETE for recalled DSP coefficients): 49 logical
 * parameters (front-panel synthesis block + the extended DSP leaves: VCA mode, LFO
 * env-trigger, HPF type, velocity sensitivity, cutoff high-res) plus per-patch
 * delay / reverb / arpeggiator. VERIFIED TWO INDEPENDENT WAYS (no shared code):
 *   (a) 120 golden coefficient bit-patterns (40 x 3 real patches, test_apply_golden.c);
 *   (b) a FULL-INSTANCE Unicorn emulation that builds the real engine graph
 *       (operator new(0xA83010) 11MB state -> sub_7FF91DFE80F0 init -> wrapper ->
 *       CPrmDSPJu60Plugin ctor sub_7FF91E013320) and drives the param dispatch
 *       sub_7FF91E019A30, recovering (curve_id, engine offset) per setter from the
 *       descriptor writer 0x3C2750 (paramIdx in edx). 28/30 anchors reproduced
 *       independently; the 2 residuals are emulation mis-attributions on anchors
 *       already pinned by the golden bits (4128 BEND, 10240 HPF).
 * This is the complete set the recall writes: a param is recalled IFF it has a byte
 * in the patch record, and cross-checking the 64-patch factory bank for per-patch
 * variation against this applier's full read-set leaves only NON-coefficient panel
 * controls unbound (see docs/RECALL_COMPLETE.md for the full accounting):
 *   - bend/mod-wheel SENS (inert at rest; transform not emulation-verified -> not
 *     shipped, per the no-guess rule);
 *   - LEGATO / ASSIGN MODE (voice-allocation flags, not DSP coefficients);
 *   - CONDITION / EFFECT TONE / EFFECT TYPE modes 1&5 (route through the
 *     un-decompiled master/FX path fed by an external schema absent from the binary);
 *   - JU-06A-only controls the JUNO-60 disables (2nd/3rd osc, ring, sync, ...);
 *   - internal/derived state with no record byte (LFO waveform one-hots, filter
 *     taps, tune, off 1072 LFO Tempo Rate = host-BPM runtime state, off 608 keyboard
 *     mode) — leaving these at their init value IS the bit-exact behaviour.
 * The front-panel bytes live in the 222-byte window (record byte = 2*pool + 12 for
 * pool 2..112; blob_pos = pool - 2).
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
#include "hpf_type_lut.h"
#include "delay_recall.h"
#include "reverb_recall.h"
#include "chorus_recall.h"
#include "effect_modes.h"

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
    { 40, 35, T_ID,  2784, "ENV1 ATTACK"     }, /* -> filter ENV Attack  (96k curve 35)
                                                  * blob 40, NOT 44: the record stores ENV1
                                                  * as natural A,D,S,R at 40,41,42,43 (D/S/R
                                                  * coincide with the old D,S,R,A guess; only
                                                  * A differs). Confirmed from the plugin's
                                                  * own parser under emulation + the raw bank:
                                                  * patch13 "Rip Lead" blob40=13 (fast attack,
                                                  * == panel value), blob44=128 (a bipolar knob
                                                  * that is never <70 across all 64 patches). */
    { 41, 38, T_ID,  2816, "ENV1 DECAY"      }, /* -> filter ENV Decay   (96k curve 38)*/
    { 42, 50, T_ID,  2800, "ENV1 SUSTAIN"    }, /* -> filter ENV Sustain               */
    { 43, 38, T_ID,  2832, "ENV1 RELEASE"    }, /* -> filter ENV Release (96k curve 38)*/
    { 45, 35, T_ID,  3264, "ENV2 ATTACK"     }, /* -> amp ENV Attack                   */
    { 48, 38, T_ID,  3312, "ENV2 RELEASE"    }, /* -> amp ENV Release  (blob 48, NOT 52:
                                                  * dispatch=blob+744 holds for all 26 other
                                                  * bindings; 792-744=48. Was reading a DELAY
                                                  * byte. Same +4 address-sort bug as ATTACK.)*/
    { 44, 24, T_ID,  7408, "VCF KEY FOLLOW"  }, /* -> KCV Level  (blob 44, NOT 48: 788-744=44.
                                                  * curve 24 is BIPOLAR; blob48 gave sign-
                                                  * flipped tracking, e.g. patch13 -1.0 (dark)
                                                  * vs correct 0.0 (neutral) -> brightness.)  */
    { 39, 46, T_ID,  7392, "VCF ENV MOD"     }, /* -> ENV Level (filter env depth)     */
    { 49, 24, T_ID,  9584, "VCA TONE"        }, /* -> AMP TONE  (blob 49, NOT 53: 793-744=49.
                                                  * blob53 is the DELAY TIME leaf; curve 24
                                                  * bipolar sign-flipped, e.g. patch40 +0.197
                                                  * vs correct -0.331. Same +4 bug as ATTACK.) */
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

/* Read one logical byte (a nibble pair) from an EXTENDED record position. The
 * record body past the 16-char name is nibble-packed: logical byte at record
 * offset `roff` = ((rec[roff]&0xF)<<4) | (rec[roff+1]&0xF); the `blob` pointer is
 * record+16 so the blob-relative index is roff-16. Extended-param positions come
 * from the in-binary leaf-order table (VA 0x180C46000) + the deterministic
 * value-tree serialization (raw = 490 + 8*(leaf-113) for the NAME1/2/3 block);
 * each recall is verified bit-for-bit against the plugin's own value-tree dispatch
 * (Unicorn oracle) across all 64 patches. */
static int record_byte(const unsigned char *blob, int roff)
{
    int b = roff - BANK_BLOB_OFF;
    return ((blob[b] & 0xF) << 4) | (blob[b + 1] & 0xF);
}

/* VCA MODE (extended leaf 113, record byte 490): the amp-source selector. Recalls
 * to the ENV1/ENV2/Gate switch flags exactly as the plugin's value-tree dispatch
 * (leaf 113 -> engine 10176/10192/10208) does:
 *   0 -> ENV1 (10192=1);  1 -> ENV2 (10208=1);  2 -> GATE (10176=1).
 * Verified vs the oracle across all 64 patches (distribution 12/45/7). GATE mode
 * makes the amp organ-like (level while the note is held, no ADSR contour) — an
 * audibly distinct behaviour from the enveloped ENV1/ENV2 modes. */
static void apply_vca_mode(unsigned char *state, int v)
{
    float gate = 0.0f, env1 = 0.0f, env2 = 0.0f;
    switch (v) {
        case 1:  env2 = 1.0f; break;
        case 2:  gate = 1.0f; break;
        default: env1 = 1.0f; break;   /* 0, 3, and any clamp -> ENV1 */
    }
    JF(state, 10176) = gate;   /* Gate SW */
    JF(state, 10192) = env1;   /* ENV1 SW */
    JF(state, 10208) = env2;   /* ENV2 SW */
}

/* (F ENV VARIATION) (extended leaf 112, record byte 482 — the leaf immediately
 * before VCA MODE in the NAME2 block): the VCF ENVELOPE-SOURCE selector. This is
 * the switch that decides which envelope opens the filter, and it was the cause of
 * the "pluck has a slow attack" bug: unrecalled, it stayed 0 (=ENV1) for every
 * patch, so a pluck whose filter should snap open on the FAST amp envelope (ENV2)
 * instead crawled open on the slow filter envelope (ENV1).
 *
 * Derived entirely from the decompiled voice render (src/voice_render.c 1151-1157,
 * a byte-identical transcription of sub_180369070) plus the two settable param
 * descriptors idx 74 "Env1/2" (offset 7008) and idx 75 "Int/Env" (offset 7024):
 *     7040 = 7008;                                  // bit-copy (int), read as float
 *     v210 = 2752 + 7040 * (3232 - 2752);           // lerp(ENV1, ENV2, 7008)
 *     7072 = v210 + 7024 * (6640 - v210);           // lerp(selected-env, Int, 7024)
 * so 7008 is a FLOAT lerp factor (0.0 -> ENV1-derived state 2752, 1.0 -> ENV2-
 * derived state 3232) and 7024 mixes the chosen envelope with the internal source
 * 6640. It must be written as float 1.0f (not int 1): the render reads JF(7040), and
 * an integer 1 would read back as a ~1.4e-45 denormal (i.e. still ENV1). Mapping:
 *   0 -> ENV1  (7008=0, 7024=0) — the power-on default init/prepare already leave;
 *   1 -> ENV2  (7008=1, 7024=0);
 *   2 -> INT   (7024=1)         — the "Int" position feeding source 6640.
 * The 0 and 1 cases are fully grounded: value 0 must reproduce the power-on state
 * (verified 57/64 patches sit here) and value 1 = ENV2 is the fix that makes the 7
 * plucky/percussive patches (incl. patch 10 "PL The Square") snap. Value 2 does not
 * occur in the factory bank, so its Int mapping is derived from the descriptor name
 * + the render math but is not exercised by any patch (flagged honestly). */
static void apply_fenv_variation(unsigned char *state, int v)
{
    float env12 = 0.0f, intenv = 0.0f;
    switch (v) {
        case 1:  env12  = 1.0f; break;   /* ENV2 drives the filter */
        case 2:  intenv = 1.0f; break;   /* Int source (unexercised by this bank) */
        default: break;                  /* 0 (and clamp) -> ENV1, the default state */
    }
    JF(state, 7008) = env12;    /* Env1/2 selector (lerp ENV1<->ENV2) */
    JF(state, 7024) = intenv;   /* Int/Env mix                       */
}

/* Read a big-endian IEEE-754 float stored as 8 nibbles in the record starting at
 * record byte offset `roff` (the `blob` pointer is record+16, i.e. blob-relative
 * index = roff-16). The plugin stores full-resolution companions of some params
 * this way and its recall applies them ON TOP OF the coarse front-panel byte.
 * Proven against the plugin's own recall (Unicorn oracle, tools/build_oracle.py):
 * VCF CUTOFF FREQ H at record byte 1870 equals engine off 6736 for all 64 patches
 * — bit-identical to the coarse juno_curve(22,byte) for 53, and the correct FINER
 * value for 11 (e.g. patch 47: 0.1424 vs the coarse 0.2078). */
static float record_befloat(const unsigned char *blob, int roff)
{
    int b = roff - BANK_BLOB_OFF;                 /* blob-relative byte index */
    unsigned int bits =
        ((unsigned)(((blob[b+0] & 0xF) << 4) | (blob[b+1] & 0xF)) << 24) |
        ((unsigned)(((blob[b+2] & 0xF) << 4) | (blob[b+3] & 0xF)) << 16) |
        ((unsigned)(((blob[b+4] & 0xF) << 4) | (blob[b+5] & 0xF)) <<  8) |
        ((unsigned)(((blob[b+6] & 0xF) << 4) | (blob[b+7] & 0xF)));
    float f;
    unsigned int t = bits;
    { unsigned char *dst = (unsigned char *)&f, *src = (unsigned char *)&t;
      dst[0]=src[0]; dst[1]=src[1]; dst[2]=src[2]; dst[3]=src[3]; }
    return f;
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
    /* VCF CUTOFF FREQ high-resolution override (see record_befloat): the plugin
     * recalls the full-precision cutoff float and it supersedes the coarse byte. */
    JF(state, 6736) = record_befloat(blob, 1870);

    /* Extended engine parameters stored PAST the 222-byte front-panel blob. Their
     * record byte positions come from the in-binary leaf-order table + value-tree
     * serialization (see record_byte); each mapping below is transcribed from the
     * plugin's own dispatch and verified bit-for-bit vs the Unicorn oracle over all
     * 64 patches. These write per-voice offsets (<84272), so juno_driver_seed_voices
     * replicates them to all 8 voices. */
    apply_vca_mode(state, record_byte(blob, 490));      /* VCA MODE  (leaf 113) */
    apply_fenv_variation(state, record_byte(blob, 482)); /* F ENV VARIATION (leaf 112) */
    {
        int t = record_byte(blob, 554);                  /* LFO TRIG ENV (leaf 121) */
        JF(state, 2560) = t ? 1.0f : 0.0f;               /* both env-trigger switches */
        JF(state, 3040) = t ? 1.0f : 0.0f;
    }
    /* VCF / VCA VELOCITY SENS (leaves 286 / 316): linear v/255 into the sens
     * coefficients the voice scales its velocity response by. */
    JF(state, 7424) = (float)record_byte(blob, 1862) / 255.0f;   /* VCF VEL SENS */
    JF(state, 9600) = (float)record_byte(blob, 2102) / 255.0f;   /* VCA VEL SENS */
    n += 4;

    /* HPF TYPE (record 618, leaf 129): the HPF coefficients (10240/10256/10272/
     * 10288) are a JOINT function of HPF CUTOFF FREQ (blob 38) and HPF TYPE, and
     * HPF TYPE is applied LAST in the value tree. The front-panel bindings above
     * already produce the TYPE=0 result; for TYPE!=0 the plugin recomputes them
     * (low-cut + boost) — see hpf_type_lut.c. Fixes the 10 TYPE=1 patches. */
    {
        int hpf_cut  = ((blob[2 * 38] & 0xF) << 4) | (blob[2 * 38 + 1] & 0xF);
        int hpf_type = record_byte(blob, 618);
        juno_apply_hpf_type(state, hpf_cut, hpf_type);
        ++n;
    }

    /* Per-patch DELAY effect recall (slot-1 / v39). Sets the DELAY TYPE selector
     * and, for DELAY TYPE == 0, the slot-1 delay coefficient block (Wet/Feedback/
     * Time/Dry/On-Off + filter), all transcribed from the value-tree oracle. The
     * host shim points the master's v39 pointer chase at state[JUNO_PROG_DLY], so
     * this makes the ~15 delay-on patches audibly play delay instead of the forced
     * chorus. Slot-2 (v551 = EFFECT TYPE) stays on the chorus block (see driver).
     * `blob` is record + 16, so the record start is blob - BANK_BLOB_OFF. */
    juno_apply_delay(state, blob - BANK_BLOB_OFF);
    ++n;

    /* Per-patch global REVERB recall. The reverb is a global send in the master
     * output stage (always active); REVERB LEVEL -> 10759408 (send/wet) and
     * REVERB TIME -> 10759680 (decay) are recalled from the plugin's own value
     * tree (see reverb_recall.c). These are global coefficients (>84272), single
     * write, not seeded per-voice. */
    juno_apply_reverb(state, blob - BANK_BLOB_OFF);
    ++n;

    /* Per-patch CHORUS level recall (slot-2 chorus block): EFFECT DEPTH -> Wet,
     * EFFECT TONE -> Noise, Dry const 1.3, all bit-exact from the value-tree
     * dispatch (see chorus_recall.c). Replaces the captured pad's chorus depth
     * with each patch's own for the patches whose EFFECT TYPE selects the chorus.
     * Global master cells (>84272), single write. */
    juno_apply_chorus(state, blob - BANK_BLOB_OFF);
    ++n;

    /* Per-patch EFFECT TYPE routing + modes 1 (distortion+pan) and 5 (chorus/ensemble
     * variant): writes the slot-2 selector cell (state[JUNO_PROG_EFX]) so the master
     * follows the patch's EFFECT TYPE, the shared slot-2 "Effect SW" wet level, and —
     * for a mode-1 or mode-5 patch — that mode's structural block + recalled cells,
     * all bit-exact from the binary (see src/effect_modes.c). */
    juno_apply_effect_modes(state, blob - BANK_BLOB_OFF);
    ++n;
    return n;
}

/* Per-patch ARPEGGIATOR recall. The arp SW/TYPE/STEP live in the NAME1 value-tree
 * block (leaves 89/90/91). Their record positions (298/306/314) are derived from
 * the SAME contiguous leaf enumeration that lands all five oracle-anchored NAME2/3
 * leaves (VCA MODE@490, LFO TRIG@554, HPF TYPE@618, DELAY TYPE@650, REVERB TIME@666)
 * exactly on record_byte = 8*leaf - 414, with a perfectly consistent offset across
 * all five (verified by enumerating the Script.xml value leaves). So these are
 * derived to the same standard as the anchors, not guessed.
 *   ARPEGGIO TYPE (leaf 90): 0=UP, 1=UP&DOWN, 2..5=DOWN.
 *   ARPEGGIO STEP (leaf 91): octave range, 0=1 oct, 1=2 oct, 2..5=3 oct.
 * The plugin's arp rate is host-tempo-synced (24-PPQN), with no per-patch rate, so
 * the standalone preview keeps its own rate; only on/mode/range recall per patch. */
int juno_bank_arp(const unsigned char *bank, int idx, int *mode, int *oct)
{
    const unsigned char *blob;
    int sw, type, step;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    sw   = record_byte(blob, 298);   /* ARPEGGIO SW   (leaf 89) */
    type = record_byte(blob, 306);   /* ARPEGGIO TYPE (leaf 90) */
    step = record_byte(blob, 314);   /* ARPEGGIO STEP (leaf 91) */
    if (mode) *mode = (type == 0) ? 0 : (type == 1) ? 2 : 1;  /* up / up&down / down */
    if (oct)  *oct  = (step == 0) ? 1 : (step == 1) ? 2 : 3;
    return sw ? 1 : 0;
}

/* Decode LEGATO (CTRL leaf 57, front-panel blob_pos 55) and ASSIGN MODE (CTRL
 * leaf 58, blob_pos 56). These are front-panel nibble-pair bytes (stride-2:
 * blob byte = 2*blob_pos), the same decode the BINDINGS loop uses. Verified by the
 * per-leaf variance audit (scratchpad/oracle/leaf_variance_audit.py): LEGATO takes
 * value 1 in 4 patches, ASSIGN MODE 1 in 14 and 2 in 2 patches — all in range. */
int juno_bank_voice_modes(const unsigned char *bank, int idx,
                          int *legato, int *assign, int *porta)
{
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    if (legato) *legato = ((blob[2 * 55] & 0xF) << 4) | (blob[2 * 55 + 1] & 0xF);
    if (assign) *assign = ((blob[2 * 56] & 0xF) << 4) | (blob[2 * 56 + 1] & 0xF);
    if (porta)  *porta  = ((blob[2 * 54] & 0xF) << 4) | (blob[2 * 54 + 1] & 0xF);
    return 1;
}
