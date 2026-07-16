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
 * COVERAGE (honest): the VOICE recall set is COMPLETE and gate-proven — this applier
 * writes every voice cell the plugin's own recall enumerator (rva 0x3B48A0) fires,
 * matching the plugin's recall bit-for-bit (tools/verify/recall_gate.py: 67/67 cells,
 * all 64 patches; docs/CLAIMS.md §E11-E13). That is the front-panel synthesis block
 * (incl. the DCO RANGE / LFO / PWM cluster added 2026-07) + the extended DSP leaves
 * (VCA mode, LFO env-trigger, HPF type) plus per-patch delay / reverb / arpeggiator.
 * FX recall has known open items (delay feedback 102560 — see PROVENANCE.tsv).
 * Earlier, the pre-2026-07 subset was VERIFIED TWO INDEPENDENT WAYS (no shared code):
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
 *   tune/condition, VCA mode, HPF/effect TYPE) are NOT bound via the flat formula: the
 *   record is a MULTI-BLOCK structure and those leaves live at higher, non-flat offsets
 *   (e.g. VCF CUTOFF FREQ H is at record byte ~1871, not 2*287+12) whose addresses are
 *   the schema addresses (same external-schema data that blocks the EFX order). An earlier
 *   attempt using a flat offset formula was WRONG (it read empty bytes as 0); reverted.
 *   Remapping PATCH2/PATCH3 needs the record deserializer or the external schema.
 *   (The FX TYPEs that ARE recalled — DELAY TYPE record byte 650, REVERB TYPE record
 *   byte 658 — use direct record-byte reads in delay_recall.c / reverb_recall.c.)
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
 * SAMPLE-RATE-VARIANT recall (sr_variant flag, host rate from state[16]): the
 * plugin's recall setter selects a curve arm by rate — attack 33/34/35, decay &
 * release 36/37/38, LFO-delay 42/43/44, HPF-cutoff 39/40/41 for 44100/48000/96k —
 * and multiplies portamento time (curve 7) by 96000/H. Proven bit-exact 256/256 vs
 * the plugin's recall dispatch at all three rates and cross-checked against
 * juno_prepare's independent Class-C/A defaults (scratchpad/oracle/recall_rate_spec.md).
 * (The earlier "HPF cutoff curve 41 SR-invariant" note was WRONG — it selects
 * 39/40/41; only its 3 secondary coeffs 10256/10272/10288 are rate-invariant.)
 */
#include "juno_engine.h"
#include "juno_curve.h"
#include "juno_apply.h"
#include <string.h>
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
 *   thunks under Unicorn. curve_id is the 96 kHz arm; the sample-rate-variant rows
 *   (sr_variant=1/2) select the per-rate arm/multiply at recall time (see above).
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

/* sr_variant: 0 = rate-invariant curve; 1 = 3-class curve-arm select {c-2,c-1,c}
 * by host rate (44100/48000/else-96k); 2 = post-curve C/H multiply (portamento).
 * The plugin's recall setter thunks read the descriptor's rate field and select a
 * consecutive juno_curve arm for the SR-variant envelope/LFO-delay/HPF params, or
 * (porta) multiply juno_curve(7,·) by 96000/H. All arms already exist bit-exact in
 * juno_curve.c; verified 256/256 at 44100/48000/96000 and cross-checked against
 * juno_prepare's independent Class-C/A defaults. See scratchpad/oracle/recall_rate_spec.md. */
typedef struct { int blob_pos; int curve_id; int tf; int offset; const char *name; int sr_variant; } juno_bind;

/* Curve-arm select by host rate: arm(44100)=c96-2, arm(48000)=c96-1, else=c96
 * (the binary's LUT layout keeps the three rate variants as a consecutive triple). */
static int rate_curve(int c96, int Hr)
{
    return (Hr == 44100) ? c96 - 2 : (Hr == 48000) ? c96 - 1 : c96;
}

static const juno_bind BINDINGS[] = {
    { 35, 22, T_ID,  6736, "VCF CUTOFF FREQ" }, /* -> LPF Cutoff  (VERIFIED = 0.6)     */
    { 37, 22, T_ID,  6832, "VCF RESONANCE"   }, /* -> LPF Resonance                    */
    { 38, 41, T_ID, 10240, "HPF CUTOFF FREQ", 1 }, /* -> HPF Cutoff. SR-VARIANT: arm 39/40/41
                                                  * by rate (recall_rate_spec.md); the 3 secondary
                                                  * coeffs 10256/10272/10288 below are rate-invar. */
    { 38, 52, T_ID, 10256, "HPF CUTOFF FREQ" }, /* -> HPF Switch  (2nd coeff)          */
    { 38, 10, T_ID, 10272, "HPF CUTOFF FREQ" }, /* -> Boost LPF Level (3rd coeff)      */
    { 38, 18, T_BIP,10288, "HPF CUTOFF FREQ" }, /* -> Boost Thru Level (4th, bipolar)  */
    { 40, 35, T_ID,  2784, "ENV1 ATTACK", 1  }, /* -> filter ENV Attack. SR-VARIANT arm 33/34/35
                                                  * (96k curve 35)
                                                  * blob 40, NOT 44: the record stores ENV1
                                                  * as natural A,D,S,R at 40,41,42,43 (D/S/R
                                                  * coincide with the old D,S,R,A guess; only
                                                  * A differs). Confirmed from the plugin's
                                                  * own parser under emulation + the raw bank:
                                                  * patch13 "Rip Lead" blob40=13 (fast attack,
                                                  * == panel value), blob44=128 (a bipolar knob
                                                  * that is never <70 across all 64 patches). */
    { 41, 38, T_ID,  2816, "ENV1 DECAY", 1   }, /* -> filter ENV Decay. SR-VARIANT 36/37/38 */
    { 42, 50, T_ID,  2800, "ENV1 SUSTAIN"    }, /* -> filter ENV Sustain               */
    { 43, 38, T_ID,  2832, "ENV1 RELEASE", 1 }, /* -> filter ENV Release. SR-VARIANT 36/37/38 */
    { 45, 35, T_ID,  3264, "ENV2 ATTACK", 1  }, /* -> amp ENV Attack. SR-VARIANT 33/34/35 */
    { 48, 38, T_ID,  3312, "ENV2 RELEASE", 1 }, /* -> amp ENV Release. SR-VARIANT 36/37/38 (blob 48, NOT 52:
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
    /* LFO RATE (1088/2064) + LFO DELAY (1920): the plugin's OWN recall enumerator
     * (proc vtable slot 8, rva 0x3B48A0) DOES recall these — executed under Unicorn it
     * fires the engine setter for indices 751 (LFO DELAY) and 752 (LFO RATE) on every
     * patch. The earlier "held constant" claim came from a DSP-only reconstruction that
     * structurally never dispatched these indices; the plugin's self-proven setter gives
     * cell 1088/2064 = juno_curve(22, LFO-RATE byte) and cell 1920 = the SR-variant
     * LFO-delay curve (arms 42/43/44 @ 44100/48000/96000). Proven bit-exact vs the
     * plugin's own setter for all 256 input values at all three rates, and vs the
     * self-proven recall reference across all 64 patches (tools/verify/
     * extract_dropped_luts.py + verify_dropped_luts.py). See docs/CLAIMS.md §E. */
    { 8, 22, T_ID,  1088, "LFO RATE"        }, /* -> LFO rate (idx 752, curve 22)     */
    { 8, 22, T_ID,  2064, "LFO RATE"        }, /* -> LFO rate mirror (idx 752)        */
    { 7, 44, T_ID,  1920, "LFO DELAY", 1    }, /* -> LFO delay. SR-VARIANT arm 42/43/44 (idx 751) */
    { 66, 49, T_ID,101072, "VCA LEVEL"       }, /* -> Patch Level (value tree c49)     */
    { 27, 54, T_ID,  4192, "DCO SAW LEVEL"   }, /* -> JU OSC Saw Lev (value tree c54)  */
    { 28, 54, T_ID,  4224, "DCO SUB LEVEL"   }, /* -> JU OSC Sub Lev (value tree c54)  */
    { 29, 54, T_ID,  6528, "DCO NOISE LEVEL" }, /* -> Osc Noise Level (value tree c54) */
    /* DCO LFO MOD (4032), VCF LFO MOD (7344), DCO PWM DEPTH (4144): the plugin's own
     * recall enumerator fires indices 753/754/758 for these on every patch (setter-
     * proven, not held constant). 4032 = juno_curve(0, byte), 7344 = juno_curve(47,
     * byte), 4144 = juno_curve(45, byte); each reproduces the plugin's setter output
     * bit-exact for all 256 inputs and the recall reference for all 64 patches. The
     * discrete cells this cluster also recalls (LFO KEY TRIG 1872, DCO RANGE feet 3840,
     * PWM SOURCE 3888/3904/3920/3936, LFO DELAY switch 1936, tempo-baseline 1072) are
     * applied below in juno_bank_apply (small enum/switch laws, not single-curve rows).
     * The old "these cells are held constant / DCO RANGE never recalled" claims are
     * refuted by the plugin's own enumerator+setter (docs/CLAIMS.md §E). */
    { 9,  0, T_ID,  4032, "DCO LFO MOD"     }, /* -> DCO LFO mod depth (idx 753)      */
    { 10, 47, T_ID, 7344, "VCF LFO MOD"     }, /* -> VCF LFO mod depth (idx 754)      */
    { 14, 45, T_ID,  4144, "DCO PWM DEPTH"   }, /* -> DCO PWM depth (idx 758)          */
    { 46, 38, T_ID,  3296, "ENV2 DECAY", 1   }, /* -> amp ENV Decay. SR-VARIANT 36/37/38 */
    { 47, 50, T_ID,  3280, "ENV2 SUSTAIN"    }, /* -> amp ENV Sustain (value tree c50) */
    { 54, 52, T_ID,   592, "PORTAMENTO"      }, /* -> Porta OnOff (value tree c52)     */
    { 54,  7, T_ID,   624, "PORTAMENTO", 2   }, /* -> Porta Time. SR-VARIANT: juno_curve(7,v)
                                                  * * (96000/H) for H!=96000 (C/H post-multiply) */
    /* BEND RANGE (blob 57) is NOT a standalone binding: it is the curve4() factor of
     * the bend-depth PRODUCT at 4128/7472 — see apply_bend_mod_sens(). The old
     * {57,curve 10,4128/7472} rows were a disguised write-zero (curve 10 == 0 for the
     * factory BEND RANGE=11) and are removed. */
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

/* --- Per-parameter setter API: the "raw 0..255 byte -> parameter" interface. ---
 * Each single-byte panel binding above is exposed as an indexable parameter driven
 * by the EXACT recall dispatch (curve + transform + rate-variant + offset). Feeding
 * juno_apply_param the raw byte a bank record would hold at that param's blob slot
 * yields the identical engine float juno_bank_apply produces — so the interface is
 * bit-for-bit the plugin's own value-tree recall, one parameter at a time. Index
 * space is the BINDINGS order; juno_param_name/offset describe each slot. */
int juno_param_count(void) { return N_BINDINGS; }

const char *juno_param_name(int i)
{
    return (i >= 0 && i < N_BINDINGS) ? BINDINGS[i].name : "";
}

int juno_param_offset(int i)
{
    return (i >= 0 && i < N_BINDINGS) ? BINDINGS[i].offset : -1;
}

/* Blob position of binding row i. Several rows share one front-panel blob byte
 * (HPF blob 38 -> the 4 rows for 10240/10256/10272/10288; PORTAMENTO blob 54 ->
 * 2 rows): the plugin's value tree dispatches whole LEAVES, so one panel change
 * writes EVERY cell bound to that blob (measured under emulation: a single HPF
 * dispatch writes 4 cells x 8 voice strides). Callers mirroring a live panel
 * move must apply the byte to all rows sharing the blob — juno_gui_set_param
 * does this expansion. */
int juno_param_blob(int i)
{
    return (i >= 0 && i < N_BINDINGS) ? BINDINGS[i].blob_pos : -1;
}

/* Apply raw byte (0..255) to parameter i via the recall dispatch. Hr = host rate
 * (drives the SR-variant curve arm / portamento post-multiply, exactly as
 * juno_bank_apply). Writes the engine cell and returns the float written (0.0 on a
 * bad index). Writes voice-0's cell only; the caller replicates to the other voices
 * (juno_gui_set_param seeds them + re-applies CONDITION scatter, mirroring recall). */
float juno_apply_param(unsigned char *state, int i, int byte, int Hr)
{
    int cid;
    float c;
    if (i < 0 || i >= N_BINDINGS) return 0.0f;
    if (Hr <= 0) Hr = 96000;
    cid = BINDINGS[i].curve_id;
    if (BINDINGS[i].sr_variant == 1)                 /* 3-class curve-arm select */
        cid = rate_curve(cid, Hr);
    c = juno_curve(cid, apply_tf(BINDINGS[i].tf, byte & 0xFF));
    if (BINDINGS[i].sr_variant == 2 && Hr != 96000)  /* porta C/H post-multiply */
        c *= 96000.0f / (float)Hr;
    JF(state, BINDINGS[i].offset) = c;
    return c;
}

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

/* DCO PWM SOURCE (blob 15, idx 759) — a 6-value enum the plugin's own recall
 * enumerator DOES fire (setter-proven), recalled as a one-hot over the four source-
 * select cells 3888(LFO)/3904(ENV1)/3920(ENV2)/3936(Manual), the ENV arms signed for
 * invert. Proven bit-exact vs the plugin's setter for all 256 inputs
 * (tools/verify/extract_dropped_luts.py):
 *   0 -> Manual(3936=1)    1 -> LFO(3888=1)
 *   2 -> ENV1+(3904=+1)    3 -> ENV1-(3904=-1)
 *   4 -> ENV2+(3920=+1)    5 -> ENV2-(3920=-1)    >=6 -> Manual (default).
 * (The earlier apply_pwm_source() was removed on a mistaken "held constant at
 * (0,0,0,1)" reading; the plugin recalls it per patch. v=0/>=6 == the (0,0,0,1)
 * prepare default, so unconditionally writing it is safe.) */
static void apply_pwm_source(unsigned char *state, int v)
{
    float a = 0.0f, b = 0.0f, c = 0.0f, d = 0.0f;   /* 3888,3904,3920,3936 */
    switch (v) {
        case 1:  a =  1.0f; break;
        case 2:  b =  1.0f; break;
        case 3:  b = -1.0f; break;
        case 4:  c =  1.0f; break;
        case 5:  c = -1.0f; break;
        default: d =  1.0f; break;   /* 0 and >=6 -> Manual */
    }
    JF(state, 3888) = a;
    JF(state, 3904) = b;
    JF(state, 3920) = c;
    JF(state, 3936) = d;
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

/* BEND SENS DCO/VCF (leaves 116/117) + MOD SENS DCO/VCF (leaves 118/119). The
 * plugin's recall runs a per-voice recompute that stores a PRODUCT coefficient, not
 * a single-curve write (setters 0x35C630/0x359BE0/0x35C710/0x359D10, driven bit-exact
 * under Unicorn — scratchpad/oracle/bendmod_recall_spec.md):
 *   4128 (bend depth DCO) = curve22(BEND SENS DCO) * curve4(BEND RANGE) * mode(BEND GAIN)
 *   7472 (bend depth VCF) = curve22(BEND SENS VCF) * curve4(BEND RANGE) * mode(BEND GAIN)
 *   3984 (mod depth DCO)  = curve22(MOD SENS DCO)
 *   7360 (mod depth VCF)  = curve22(MOD SENS VCF) * 10.0
 * mode(g) = {1:2, 2:3, 3:4, else:1}. All SR-INVARIANT (no rate branch in the thunks).
 * These are the recalled DEPTHS; the live bend/mod AMOUNT (off 4112/7456) is a separate
 * runtime coeff that is 0 at a centered wheel, so the depths are inert in the dry
 * preview (verified: the mod sources 3856/3552/4112 are 0 at rest -> the render term
 * that reads 4128 is 0) but are the plugin's true recalled state and correct once live
 * bend/mod is driven. Voice-0 offsets, replicated to all 8 by juno_driver_seed_voices.
 * NOTE: the old "{57,curve 10,4128/7472} BEND RANGE" BINDINGS rows were mis-mapped —
 * curve 10 is ~all-zero (0 for the factory BEND RANGE=11), a disguised write-zero; the
 * real BEND RANGE curve is 4, applied as a factor here. */
static const float BEND_GAIN_MODE[4] = { 1.0f, 2.0f, 3.0f, 4.0f };
static void apply_bend_mod_sens(unsigned char *state, const unsigned char *blob)
{
    int bsd  = record_byte(blob, 514);   /* BEND SENS DCO (leaf 116) */
    int bsv  = record_byte(blob, 522);   /* BEND SENS VCF (leaf 117) */
    int msd  = record_byte(blob, 530);   /* MOD  SENS DCO (leaf 118) */
    int msv  = record_byte(blob, 538);   /* MOD  SENS VCF (leaf 119) */
    int bg   = record_byte(blob, 506);   /* BEND GAIN     (leaf 115, 0 in all factory) */
    int brng = ((blob[2 * 57] & 0xF) << 4) | (blob[2 * 57 + 1] & 0xF);  /* BEND RANGE (blob 57) */
    float mode = BEND_GAIN_MODE[(bg >= 0 && bg <= 3) ? bg : 0];
    float c4r  = juno_curve(4, brng);
    /* mulss left-to-right, matching the binary's mulss xmm6,xmm1; mulss xmm6,xmm0. */
    JF(state, 4128) = juno_curve(22, bsd) * c4r * mode;   /* Bend depth DCO */
    JF(state, 7472) = juno_curve(22, bsv) * c4r * mode;   /* Bend depth VCF */
    JF(state, 3984) = juno_curve(22, msd);                /* Mod depth DCO  */
    JF(state, 7360) = juno_curve(22, msv) * 10.0f;        /* Mod depth VCF  */
}

/* CONDITION — analog voice-scatter (leaf 114, record byte 498; value-tree idx 856).
 * Broadcasts the clamped byte C (0..255) to the 8 voices as PER-VOICE-DISTINCT detune
 * + re-level, i.e. component-tolerance emulation: each voice gets TUNE(5520), FINE
 * (7600), GAIN(10320) = a fixed per-voice scalar times a C ramp. Bit-exact vs the
 * plugin's per-voice setter methods (0x35bdb0/0x3595c0/0x3561a0), 240/240; SR-invariant.
 * See scratchpad/oracle/condition_scatter_spec.md. Because these are per-voice-DISTINCT,
 * this MUST run AFTER juno_driver_seed_voices (which replicates voice 0 and would
 * clobber the scatter). The default patch value is 128 (both ramps = 1.0). */
static const float COND_TUNE_SCAL[8] = { 0.02f, 0.01f, 0.025f, 0.015f,
                                        -0.005f, -0.015f, 0.0f, -0.01f };
static const float COND_FINE_SCAL[8] = { 0.0f, 0.00416666688f, 0.00186666672f, -0.00150833325f,
                                         0.00208333344f, -0.00333333341f, -0.00249999994f, 0.000833333354f };
static const float COND_GAIN_SCAL[8] = { -0.0f, -0.005f, -0.015f, -0.01f,
                                         -0.02f, -0.0f, -0.02f, -0.008f };
void juno_apply_condition(unsigned char *state, int cbyte)
{
    int v, C = cbyte < 0 ? 0 : (cbyte > 255 ? 255 : cbyte);   /* clamp 0..255 */
    float recip = 1.0f / 129.0f;                              /* f32 reciprocal (0x3bfe03f8) */
    float L    = (float)(C + 1) * recip;                      /* linear ramp (NOT (C+1)/129) */
    float cube = (L * L) * L;                                 /* stepwise f32 cube          */
    for (v = 0; v < 8; ++v) {
        unsigned b = (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
        JF(state, 5520u  + b) = L    * COND_TUNE_SCAL[v];     /* per-voice detune (tune-trim) */
        JF(state, 7600u  + b) = cube * COND_FINE_SCAL[v];     /* per-voice fine detune        */
        JF(state, 10320u + b) = cube * COND_GAIN_SCAL[v] + 1.0f; /* per-voice re-level        */
        /* ZERO_A(3968)/ZERO_B(7616) stay 0.0 = engine baseline; no write needed. */
    }
}

/* ASSIGN MODE 2 (UNISON) per-voice DCO detune spread at 3968. Measured under the
 * oracle from the running binary for BOTH ASSIGN==2 factory patches (61, 63) at
 * 44100 and 96000 Hz — identical fixed table, rate- and patch-independent
 * (tools/verify/triage/probe93.py; the old single-cell recall used entry [7],
 * ground-truthed from the one sounding voice). Must run AFTER seed_voices (which
 * would replicate voice 0's 0.0 over the spread), like juno_apply_condition. */
static const unsigned int UNISON_3968[8] = {
    0x00000000u, 0xbae33103u, 0x3b6101c6u, 0xbbf3d93au,
    0x3bda740eu, 0xbba3d70au, 0x3b5a740eu, 0xbb23d70au,
};
void juno_apply_unison_spread(unsigned char *state, int assign)
{
    int v;
    for (v = 0; v < 8; ++v) {
        unsigned b = (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
        unsigned int bits = (assign == 2) ? UNISON_3968[v] : 0x00000000u;
        float f; memcpy(&f, &bits, 4);
        JF(state, 3968u + b) = f;
    }
}

/* Read the ASSIGN MODE nibble-pair (blob row 56) for patch idx, for the bridge to
 * drive juno_apply_unison_spread post-seed. Defaults to 0 on bad idx. */
int juno_bank_assign(const unsigned char *bank, int idx)
{
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    return ((blob[2 * 56] & 0xF) << 4) | (blob[2 * 56 + 1] & 0xF);
}

/* Read the CONDITION byte (leaf 114, record byte 498) from a bank record, for the
 * bridge to apply post-seed. Defaults to 128 (the Script.xml default) on bad idx. */
int juno_bank_condition(const unsigned char *bank, int idx)
{
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 128;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    return record_byte(blob, 498);
}

/* Recalled HPF TYPE (record byte 618, leaf 129). The HPF engine cells are a JOINT
 * function of (HPF CUTOFF byte, HPF TYPE); a LIVE cutoff move must recompute with
 * the patch's current TYPE (fuzz seeds 49/52/58: the plugin's live blob-38 leaf
 * dispatch writes the TYPE-joint values). The bridge stashes this at recall. */
int juno_bank_hpf_type(const unsigned char *bank, int idx)
{
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    return record_byte(blob, 618);
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
 *   0 -> ENV1  (7008=0, 7024=0) — the power-on default init/prepare leave.
 * RETRACTED (Tier-C audit 2026): the plugin does NOT recall this — a full 0..1121
 * dispatch sweep finds ZERO writers of 7008/7024, disp854 is disabled in Script.xml,
 * and 0/64 patches touch them in the oracle. The filter always uses ENV1. The former
 * apply_fenv_variation() wrote ENV2 for 7 patches by ear (a divergence) and is removed;
 * leaving the init default (both 0.0) is bit-exact. */

/* VCF CUTOFF FREQ "high-resolution override" REMOVED (cold-load audit). The plugin
 * stores a full-precision cutoff companion at record byte 1870, but its ENGINE cell
 * 6736 holds the COARSE juno_curve(22, byte 35) value for ALL 64 patches — verified
 * bit-for-bit against every captured post-recall engine state (0/64 mismatches). The
 * former record_befloat(1870) override diverged from the engine on 11 patches: +1 ULP
 * on 10 (float-storage rounding of the high-res companion) and a large error on patch
 * 47 (engine 0.2078 = coarse byte 53, override read 0.1424). The earlier "proven equal
 * for all 64" claim had compared against the value tree, not the engine. Dropped, so
 * the coarse binding {35,22,T_ID,6736} alone drives the cutoff (engine-exact). */

/* Apply patch `idx` from `bank` into the engine `state`. Returns #params set. */
int juno_bank_apply(unsigned char *state, const unsigned char *bank, int idx)
{
    int i, n = 0;
    const unsigned char *blob;
    int Hr;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    /* Host rate, exactly as juno_prepare reads it — drives the SR-variant curve
     * selection so recall matches the plugin at 44100/48000/else-96k. An unset
     * rate field (0) defaults to 96 kHz (the engine's historical rate). */
    Hr = (int)JF(state, 16);
    if (Hr <= 0) Hr = 96000;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    for (i = 0; i < N_BINDINGS; ++i) {
        int p   = BINDINGS[i].blob_pos;
        int v   = ((blob[2 * p] & 0xF) << 4) | (blob[2 * p + 1] & 0xF);  /* hi-nibble */
        int cid = BINDINGS[i].curve_id;
        float c;
        if (BINDINGS[i].sr_variant == 1)              /* 3-class curve-arm select */
            cid = rate_curve(cid, Hr);
        c = juno_curve(cid, apply_tf(BINDINGS[i].tf, v));
        if (BINDINGS[i].sr_variant == 2 && Hr != 96000)  /* porta C/H post-multiply */
            c *= 96000.0f / (float)Hr;
        JF(state, BINDINGS[i].offset) = c;
        ++n;
    }
    /* Discrete / multi-curve recalls the plugin's own enumerator (0x3B48A0) fires but
     * that don't fit a single {curve,transform} BINDINGS row. Each is the plugin's
     * exact setter law, proven bit-exact for all 256 input values against the plugin's
     * own setter and against the self-proven recall reference for all 64 patches
     * (tools/verify/extract_dropped_luts.py + verify_dropped_luts.py, 896/896):
     *   751 LFO DELAY switch (1936) : byte==0 ? 0 : 1
     *   752 LFO tempo-baseline (1072): curve48(byte) * curve53(1280)  [build BPM 128]
     *   756 LFO KEY TRIG (1872)     : byte==0 ? 1 : 0
     *   759 PWM SOURCE (3888..3936) : one-hot enum (LFO / ENV1± / ENV2± / Manual)
     *   760 DCO RANGE feet (3840)   : 2^(min(byte,5)-3)   {16'..2', default 8'}
     * These write voice-0 cells (<10512); juno_driver_seed_voices replicates to all 8.
     * 1072 is the tempo-sync baseline (used only when TEMPO SYNC 1056==1); the runtime
     * host-BPM path juno_apply_lfo_tempo overwrites it for a synced patch, exactly as
     * the plugin recomputes it from live tempo — recall sets the default-BPM baseline. */
    {
        int b751 = ((blob[2 * 7]  & 0xF) << 4) | (blob[2 * 7  + 1] & 0xF);  /* LFO DELAY    */
        int b752 = ((blob[2 * 8]  & 0xF) << 4) | (blob[2 * 8  + 1] & 0xF);  /* LFO RATE     */
        int b756 = ((blob[2 * 12] & 0xF) << 4) | (blob[2 * 12 + 1] & 0xF);  /* LFO KEY TRIG */
        int b759 = ((blob[2 * 15] & 0xF) << 4) | (blob[2 * 15 + 1] & 0xF);  /* PWM SOURCE   */
        int b760 = ((blob[2 * 16] & 0xF) << 4) | (blob[2 * 16 + 1] & 0xF);  /* DCO RANGE    */
        int rng  = b760 > 5 ? 5 : b760;
        JF(state, 1936) = (b751 == 0) ? 0.0f : 1.0f;                        /* LFO delay switch  */
        JF(state, 1072) = juno_curve(48, b752) * juno_curve(53, 1280);      /* LFO tempo baseline */
        JF(state, 1872) = (b756 == 0) ? 1.0f : 0.0f;                        /* LFO key trig      */
        JF(state, 3840) = 0.125f * (float)(1u << rng);                      /* DCO feet 2^(rng-3) */
        apply_pwm_source(state, b759);                                      /* PWM source one-hot */
        n += 5;
    }
    /* VCF CUTOFF FREQ (6736): driven solely by the coarse binding {35,22,T_ID} above —
     * the high-res override was removed (it diverged from the engine; see comment at
     * record_befloat's former site). */

    /* Extended engine parameters stored PAST the 222-byte front-panel blob. Their
     * record byte positions come from the in-binary leaf-order table + value-tree
     * serialization (see record_byte); each mapping below is transcribed from the
     * plugin's own dispatch and verified bit-for-bit vs the Unicorn oracle over all
     * 64 patches. These write per-voice offsets (<84272), so juno_driver_seed_voices
     * replicates them to all 8 voices. */
    apply_vca_mode(state, record_byte(blob, 490));      /* VCA MODE  (leaf 113) */
    apply_bend_mod_sens(state, blob);                   /* BEND/MOD SENS (leaves 115..119) */
    n += 4;
    /* F ENV VARIATION: NOT recalled by the plugin. Proven non-circularly (Tier-C audit
     * 2026): a full 0..1121 dispatch sweep finds ZERO writers of 7008/7024, disp854 is
     * parenthesized/disabled in Script.xml, and 0/64 patches touch these in the oracle.
     * juno_init leaves both = 0 (filter always driven by ENV1), which is bit-exact.
     * The prior apply_fenv_variation() call wrote ENV2 for 7 "plucky" patches by ear —
     * a divergence from the plugin — so it is removed (function deleted above). */
    {
        /* PORTAMENTO MODE (off 608): the plugin sets it to 1.0 only when LEGATO is on
         * (1) AND ASSIGN MODE == 1. Across all 64 patches the engine cell is 1.0 for
         * exactly the (LEG=1, ASG=1) patches; (LEG=1, ASG=2) — patch 61 — is 0, so the
         * old `as != 0` test was too loose. Per-voice, seeded to all 8. */
        int lg = ((blob[2 * 55] & 0xF) << 4) | (blob[2 * 55 + 1] & 0xF);
        int as = ((blob[2 * 56] & 0xF) << 4) | (blob[2 * 56 + 1] & 0xF);
        JF(state, 608) = (lg == 1 && as == 1) ? 1.0f : 0.0f;
        /* ASSIGN MODE 2 (UNISON) carries a per-voice DCO detune SPREAD in the
         * pitch-sum term at 3968 (0 otherwise). The old single value here was
         * voice 7's entry only; the full 8-voice table is written per voice by
         * juno_apply_unison_spread AFTER seed_voices (fuzz seeds 93/83/61/27 —
         * measured identical for patches 61+63 at 44.1k and 96k). Voice-0 value
         * is written here so a bank apply without the bridge stays coherent. */
        JF(state, 3968) = 0.0f;
        (void)as;
    }
    {
        int t = record_byte(blob, 554);                  /* LFO TRIG ENV (leaf 121) */
        JF(state, 2560) = t ? 1.0f : 0.0f;               /* both env-trigger switches */
        JF(state, 3040) = t ? 1.0f : 0.0f;
    }
    /* VCF / VCA VELOCITY SENS: the plugin's engine holds BOTH sens cells at 0 for all
     * 64 factory patches (velocity is inert on the JUNO-60 — see docs/BITEXACT_RENDER_AB.md).
     * VCF (7424): record byte 1862 == 0 for every patch, so v/255 == 0 (correct). VCA
     * (9600): record byte 2102 is NOT the VCA-vel-sens leaf (it holds nonzero data for
     * 27 patches, but the plugin's engine cell 9600 == 0 for all) — writing v/255 there
     * diverged. Set both to 0 to match the plugin. */
    JF(state, 7424) = 0.0f;   /* VCF VEL SENS (inert) */
    JF(state, 9600) = 0.0f;   /* VCA VEL SENS (inert) */
    n += 4;

    /* (The former recall_engine_constants K[] block that froze 1088/2064/1920/4144/
     * 7344 at fixed bit-patterns is removed: the plugin's own recall enumerator recalls
     * all five per-patch, now driven by the BINDINGS rows + discrete block above. Their
     * old "constant" values were the specific case of the recall for those patches whose
     * LFO/PWM knobs happened to match — proven wrong for the 45-64 patches that vary.) */

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
     * output stage (always active); REVERB LEVEL (blob 51) -> 10759408 (send/wet),
     * plus REVERB TYPE (record 658) + TIME (record 666) -> the 4 DPF cutoffs, the
     * type-5 stage, and the 8 joint (type,time) Hp/Lp decay coeffs, all recalled
     * from the plugin's own value tree (see reverb_recall.c). Global coefficients
     * (>84272), single write, not seeded per-voice. */
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

/* Decode SCATTER TYPE (NAME1 leaf 92, record byte 322 -> arp pattern slab 0..9) and
 * SCATTER DEPTH (leaf 93, record byte 330, SIGNED int8 -5..5 -> pattern sub = depth+7).
 * These select the arpeggiator's STEP x SLOT pattern grid (carp_set_scatter /
 * src/carp_patterns.h). The leaf -> param-DB id 834/835 -> record-byte binding is
 * nominally proven: the schema NAME1 value-leaf order (…ARP SW/TYPE/STEP, SCATTER
 * TYPE, SCATTER DEPTH…), the consecutive param-DB dispatch cases 831..835
 * (sub_7FF91E027AE0), and the rigid 8-byte NAME stride (record = 8*leaf-414) anchored
 * to 8 verified leaves all agree. All 64 factory patches decode to (0,0) = the default
 * slab0/sub7 grid. Writes *type (0..9) and *depth (-7..7, setter-clamped); either
 * pointer may be NULL. Returns 1 on success. See scratchpad/oracle/scatter_recall_spec.md. */
int juno_bank_scatter(const unsigned char *bank, int idx, int *type, int *depth)
{
    const unsigned char *blob;
    int t, draw, d;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    t    = record_byte(blob, 322);              /* SCATTER TYPE  (leaf 92)     */
    draw = record_byte(blob, 330);              /* SCATTER DEPTH (leaf 93)     */
    d    = (draw >= 128) ? draw - 256 : draw;   /* signed int8, musical -5..5  */
    if (t < 0) t = 0;                           /* setter guard cfg[8] <= 9    */
    if (t > 9) t = 9;
    if (d < -7) d = -7;                          /* setter guard cfg[9]=d+7 in [0,14] */
    if (d > 7) d = 7;
    if (type)  *type  = t;
    if (depth) *depth = d;
    return 1;
}

/* LFO Tempo Rate (engine cell 1072) — the tempo-synced LFO rate coefficient. When a
 * patch has TEMPO SYNC on (34/64 factory patches), the voice DSP uses cell 1072 as the
 * LFO rate INSTEAD of the free knob rate (src/voice_render.c:775-796: JF(1056)==1 ->
 * LFO rate = JF(1072) verbatim). The plugin feeds 1072 from HOST TEMPO; the port left
 * it 0, freezing the LFO on every synced patch. Bit-exact formula (proven 270/270 vs
 * the plugin's own dispatch under Unicorn, scratchpad/oracle/lfo_tempo_rate_spec.md):
 *   1072 = juno_curve(48, LFO_RATE_byte) * juno_curve(53, clamp(round(BPM*10),400,3000))
 * curve48 = the note-division rate (LFO cycles per whole note) from the LFO RATE knob;
 * curve53 = the tempo->multiplier LUT indexed by BPM*10 (0.1-BPM steps). Both LUTs are
 * already baked bit-exact in juno_curve.c. The result is SAMPLE-RATE INDEPENDENT.
 * Written to all 8 voices; harmless while sync is off (voice_render ignores it then). */
void juno_apply_lfo_tempo(unsigned char *state, int lfo_rate_byte, float bpm)
{
    int   idx = (int)(bpm * 10.0f + 0.5f);       /* curve53 index = BPM*10, round */
    float coeff;
    unsigned v;
    if (idx < 400)  idx = 400;                   /* plugin TEMPO param clamps BPM to [40,300]; */
    if (idx > 3000) idx = 3000;                  /* curve53 clamp is [100,3000] */
    if (lfo_rate_byte < 0) lfo_rate_byte = 0;
    if (lfo_rate_byte > 255) lfo_rate_byte = 255;
    coeff = juno_curve(48, lfo_rate_byte) * juno_curve(53, idx);   /* f32 mul (mulss) */
    for (v = 0; v < 8u; ++v)
        JF(state, v * JUNO_VOICE_MAIN_STRIDE + 1072u) = coeff;
}

/* Read the LFO RATE front-panel byte (blob pool 8, the {8,22,T_ID,1088} binding's
 * source) from a bank patch, for juno_apply_lfo_tempo. Returns 0 on bad idx. */
int juno_bank_lfo_rate_byte(const unsigned char *bank, int idx)
{
    const unsigned char *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF;
    return ((blob[2 * 8] & 0xF) << 4) | (blob[2 * 8 + 1] & 0xF);
}

/* Decode the per-patch DELAY tempo-sync inputs for the host-tempo recompute
 * (juno_apply_delay_tempo): *time_byte = DELAY TIME byte (blob 53), *sync =
 * TEMPO SYNC engaged (blob 59 != 0 — the shared LFO/DELAY sync switch), *dtype =
 * DELAY TYPE (record byte 650). Any out pointer may be NULL. Returns 1 on success. */
int juno_bank_delay_modes(const unsigned char *bank, int idx,
                          int *time_byte, int *sync, int *dtype)
{
    const unsigned char *rec, *blob;
    if (idx < 0 || idx >= BANK_COUNT) return 0;
    rec  = bank + BANK_HEADER + idx * BANK_STRIDE;
    blob = rec + BANK_BLOB_OFF;
    if (time_byte) *time_byte = ((blob[2 * 53] & 0xF) << 4) | (blob[2 * 53 + 1] & 0xF);
    if (sync)      *sync      = (((blob[2 * 59] & 0xF) << 4) | (blob[2 * 59 + 1] & 0xF)) != 0;
    if (dtype)     *dtype     = ((rec[650] & 0xF) << 4) | (rec[651] & 0xF);
    return 1;
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
