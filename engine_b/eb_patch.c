/* eb_patch.c — the compact patch (127 bytes, MEASURED), decoded into eb_params.
 *
 * PROVENANCE OF THE POSITIONS. Every `roff` in TAB below is transcribed from the
 * sealed port's own recall (src/juno_apply.c), which is itself gated bit-for-bit
 * against the plugin's recall enumerator under Unicorn. That makes each position
 * READ (from proven port source), not INFERRED, and certainly not guessed.
 * A parameter whose position is not in that source is entered with roff = -1 and
 * counted as UNRESOLVED. It is never given a plausible-looking number.
 *
 * The distinction the two counters draw is the point of this file:
 *
 *   UNRESOLVED  engine B does not yet know where the parameter lives.
 *   MISSING     engine B knows where it lives, and the 118-byte compact format
 *               does not carry it.
 *
 * MISSING is a defect in the format. UNRESOLVED is work not yet done. Collapsing
 * them into one "not available" number is how a format gets shipped with a hole
 * in it.
 */
#include "eb_patch.h"
#include <string.h>

/* docs/preset/compact_bytes.json (118) + the nine this session MEASURED it to be
 * missing: 112 (ASSIGN MODE high nibble), 282/283 290/291 298/299 (ARPEGGIO
 * SW / TYPE / STEP), 466/467 (F ENV VARIATION). Ascending. */
const uint16_t eb_patch_offsets[EB_PATCH_BYTES] = {
      14,   15,   16,   17,   18,   19,   20,   21,   24,   25,   28,   29,
      30,   31,   32,   33,   52,   53,   54,   55,   56,   57,   58,   59,
      70,   71,   74,   75,   76,   77,   78,   79,   80,   81,   82,   83,
      84,   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,   95,
      96,   97,   98,   99,  100,  101,  102,  103,  104,  105,  106,  107,
     108,  109,  111,  112,  113,  114,  115,  118,  119,  132,  133,  282,
     283,  290,  291,  298,  299,  466,  467,  474,  475,  482,  483,  490,
     491,  498,  499,  506,  507,  514,  515,  522,  523,  538,  539,  602,
     603,  618,  619,  626,  627,  634,  635,  642,  643,  650,  651, 1852,
    1853, 2086, 2087, 3041, 3042, 3043, 3044, 3045, 3052, 3053, 3060, 3061,
    3068, 3069, 3076, 3077, 3270, 3271, 3272, 3931, 3932, 3933, 3934, 3935,
    3936,
};

/* Front-panel parameter p sits at record offset 16 + 2p (src/juno_apply.c). */
#define PANEL(p) (16 + 2 * (p))

/* A parameter is read from the record in ONE of two ways, and getting it wrong
 * silently decodes garbage:
 *   EB_NIB  nibble pair, ((rec[roff]&0xF)<<4)|(rec[roff+1]&0xF) -- the front
 *           panel and the value-tree leaves (src/juno_apply.c record_byte).
 *   EB_RAW  a single byte, rec[roff] & 0x7F -- the int1x7 fine-FX leaves
 *           (src/finefx_recall.c:147-151, :173-175). ONE byte, not two.
 * The 2026-08-11 design missed this distinction and would have decoded CHORUS
 * HIGH CUT out of two bytes that are two DIFFERENT parameters. */
enum { EB_NIB = 0, EB_RAW = 1 };
typedef struct { int roff; size_t field; const char *name; int kind; } eb_bind;

#define F(x) offsetof(eb_params, x)
static const eb_bind TAB[] = {
    /* ---- front panel, position = the port's own blob index ---------------- */
    { PANEL( 7), F(lfo_delay),     "LFO DELAY"        , EB_NIB },
    { PANEL( 8), F(lfo_rate),      "LFO RATE"         , EB_NIB },
    { PANEL( 9), F(dco_lfo),       "DCO LFO MOD"      , EB_NIB },
    { PANEL(10), F(vcf_lfo),       "VCF LFO MOD"      , EB_NIB },
    { PANEL(14), F(dco_pwm_depth), "DCO PWM DEPTH"    , EB_NIB },
    { PANEL(15), F(dco_pwm_src),   "PWM SOURCE"       , EB_NIB },
    { PANEL(16), F(dco_range),     "DCO RANGE"        , EB_NIB },
    { PANEL(26), F(dco_pulse),     "DCO PWM LEVEL"    , EB_NIB },
    { PANEL(27), F(dco_saw),       "DCO SAW LEVEL"    , EB_NIB },
    { PANEL(28), F(dco_sub),       "DCO SUB LEVEL"    , EB_NIB },
    { PANEL(29), F(dco_noise),     "DCO NOISE LEVEL"  , EB_NIB },
    { PANEL(35), F(vcf_freq),      "VCF CUTOFF FREQ"  , EB_NIB },
    { PANEL(37), F(vcf_res),       "VCF RESONANCE"    , EB_NIB },
    { PANEL(38), F(hpf),           "HPF CUTOFF FREQ"  , EB_NIB },
    { PANEL(39), F(vcf_env),       "VCF ENV MOD"      , EB_NIB },
    { PANEL(40), F(env1_a),        "ENV1 ATTACK"      , EB_NIB },
    { PANEL(41), F(env1_d),        "ENV1 DECAY"       , EB_NIB },
    { PANEL(42), F(env1_s),        "ENV1 SUSTAIN"     , EB_NIB },
    { PANEL(43), F(env1_r),        "ENV1 RELEASE"     , EB_NIB },
    { PANEL(44), F(vcf_kbd),       "VCF KEY FOLLOW"   , EB_NIB },
    { PANEL(45), F(env2_a),        "ENV2 ATTACK"      , EB_NIB },
    { PANEL(46), F(env2_d),        "ENV2 DECAY"       , EB_NIB },
    { PANEL(47), F(env2_s),        "ENV2 SUSTAIN"     , EB_NIB },
    { PANEL(48), F(env2_r),        "ENV2 RELEASE"     , EB_NIB },
    { PANEL(50), F(chorus_mode),   "CHORUS"           , EB_NIB },
    { PANEL(51), F(reverb_level),  "REVERB LEVEL"     , EB_NIB },
    { PANEL(52), F(delay_level),   "DELAY LEVEL"      , EB_NIB },
    { PANEL(53), F(delay_time),    "DELAY TIME"       , EB_NIB },
    { PANEL(54), F(portamento),    "PORTAMENTO"       , EB_NIB },
    { PANEL(56), F(assign_mode),   "ASSIGN MODE"      , EB_NIB },
    { PANEL(57), F(bend_range),    "BEND RANGE"       , EB_NIB },
    { PANEL(59), F(delay_sync),    "TEMPO SYNC"       , EB_NIB },
    { PANEL(66), F(vca_level),     "VCA LEVEL"        , EB_NIB },
    /* ---- extended leaves, record offsets straight from juno_apply.c ------- */
    {        482, F(vcf_env_src),  "F ENV VARIATION"  , EB_NIB },   /* leaf 112 */
    {        490, F(vca_mode),     "VCA MODE"         , EB_NIB },   /* leaf 113 */
    {        498, F(condition),    "CONDITION"        , EB_NIB },   /* leaf 114 */
    {        618, F(hpf_type),     "HPF TYPE"         , EB_NIB },   /* leaf 129 */
    {        650, F(delay_type),   "DELAY TYPE"       , EB_NIB },
    {        298, F(arp_sw),       "ARPEGGIO SW"      , EB_NIB },   /* leaf 89  */
    {        306, F(arp_type),     "ARPEGGIO TYPE"    , EB_NIB },   /* leaf 90  */
    {        314, F(arp_step),     "ARPEGGIO STEP"    , EB_NIB },   /* leaf 91  */
    /* ---- UNRESOLVED: position not derived. Never guessed. ----------------- */
    { -1, F(effect_type),   "EFFECT TYPE"     , EB_NIB },
    { -1, F(effect_depth),  "EFFECT DEPTH"    , EB_NIB },
    { -1, F(delay_fb),      "DELAY FEEDBACK"  , EB_NIB },
    { -1, F(reverb_type),   "REVERB TYPE"     , EB_NIB },
    { -1, F(reverb_time),   "REVERB TIME"     , EB_NIB },
    { -1, F(legato),        "LEGATO"          , EB_NIB },
    { -1, F(transpose),     "TRANSPOSE"       , EB_NIB },
    { -1, F(dly_hicut),     "DELAY HIGH CUT"  , EB_NIB },
    { -1, F(dly_locut),     "DELAY LOW CUT"   , EB_NIB },
    { -1, F(dly_lfdamp),    "DELAY LF DAMP"   , EB_NIB },
    { -1, F(dly_hfdamp),    "DELAY HF DAMP"   , EB_NIB },
    /* ---- LOCATED 2026-08-12, int1x7 single-byte reads --------------------- */
    {       3288, F(cho_hicut),     "CHORUS HIGH CUT" , EB_RAW },
    {       3287, F(cho_locut),     "CHORUS LOW CUT"  , EB_RAW },
    {       3286, F(cho_predelay),  "CHORUS PRE DELAY", EB_RAW },
    { -1, F(rev_predelay),  "REVERB PRE DELAY", EB_NIB },
    { -1, F(rev_locut),     "REVERB LOW CUT"  , EB_NIB },
    { -1, F(rev_hicut),     "REVERB HIGH CUT" , EB_NIB },
    {       3950, F(rev_density),   "REVERB DENSITY"  , EB_RAW },
};
#undef F
#define NTAB ((int)(sizeof(TAB) / sizeof(TAB[0])))

/* WHY 127 AND NOT THE DOCUMENTED 118: see eb_patch.h. Short version, MEASURED
 * against the oracle this session -- the 118-byte set drops ARPEGGIO SW/TYPE/STEP
 * and 7 of the 64 factory patches do not reproduce; with the six arp bytes added,
 * all 64 render BIT-EXACTLY. Three further bytes (ASSIGN MODE's high nibble and
 * F ENV VARIATION) are added because they are parameters that are not stored,
 * which the byte scan could not see precisely because they are constant or inert
 * in the factory bank.
 */

/* ---------------------------------------------------------------- lookup */
static int index_of(int blob_off)
{
    int lo = 0, hi = EB_PATCH_BYTES - 1;
    if (blob_off < 0) return -1;
    while (lo <= hi) {
        int mid = (lo + hi) >> 1;
        int v = (int)eb_patch_offsets[mid];
        if (v == blob_off) return mid;
        if (v < blob_off) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

int eb_patch_byte(const eb_patch *p, int blob_off)
{
    int i = index_of(blob_off);
    return i < 0 ? -1 : (int)p->b[i];
}

/* ONE byte, int1x7: the fine-FX leaves read the record byte directly and mask
 * to 7 bits (src/finefx_recall.c). Reading them as a nibble pair would fold in
 * the NEXT parameter's byte. */
int eb_patch_param_raw(const eb_patch *p, int roff)
{
    int b = eb_patch_byte(p, roff - EB_BANK_BLOB_OFF);
    return b < 0 ? -1 : (b & 0x7F);
}

int eb_patch_param(const eb_patch *p, int roff)
{
    int hi = eb_patch_byte(p, roff - EB_BANK_BLOB_OFF);
    int lo = eb_patch_byte(p, roff - EB_BANK_BLOB_OFF + 1);
    if (hi < 0 || lo < 0) return -1;
    return ((hi & 0xF) << 4) | (lo & 0xF);      /* the plugin's own packing */
}

/* ---------------------------------------------------------------- extract */
int eb_patch_extract(const uint8_t *bank, size_t len, int idx, eb_patch *out)
{
    size_t blob;
    int i;
    if (!bank || !out || idx < 0 || idx >= EB_BANK_COUNT) return 1;
    if (len < (size_t)EB_BANK_HEADER + (size_t)EB_RECORD_BYTES * EB_BANK_COUNT)
        return 2;
    blob = (size_t)EB_BANK_HEADER + (size_t)EB_RECORD_BYTES * (size_t)idx
         + (size_t)EB_BANK_BLOB_OFF;
    for (i = 0; i < EB_PATCH_BYTES; ++i)
        out->b[i] = bank[blob + eb_patch_offsets[i]];
    return 0;
}

int eb_patch_install(uint8_t *record, const eb_patch *p)
{
    int i;
    if (!record || !p) return 1;
    for (i = 0; i < EB_PATCH_BYTES; ++i)
        record[EB_BANK_BLOB_OFF + eb_patch_offsets[i]] = p->b[i];
    return 0;
}

/* ---------------------------------------------------------------- decode */
int eb_patch_decode(const eb_patch *p, eb_params *out, int *missing, int nmiss)
{
    int i, nm = 0;
    if (!p || !out) return -1;
    memset(out, 0, sizeof(*out));
    for (i = 0; i < NTAB; ++i) {
        int v;
        if (TAB[i].roff < 0) continue;                  /* UNRESOLVED, not MISSING */
        v = (TAB[i].kind == EB_RAW) ? eb_patch_param_raw(p, TAB[i].roff)
                                    : eb_patch_param(p, TAB[i].roff);
        if (v < 0) {                                    /* located, not carried    */
            if (missing && nm < nmiss) missing[nm] = TAB[i].roff;
            nm++;
            continue;                                   /* left at 0, and COUNTED  */
        }
        *((uint8_t *)out + TAB[i].field) = (uint8_t)v;
    }
    return nm;
}

/* ------------------------------------------------- record-position coverage
 *
 * MEASURED, PROVEN by execution: every record position in [16,4096) whose
 * perturbation moves eb_render_coefs or eb_master_coef. Probe = four values
 * {0x00,0x03,0x0C,0x7F} over six base patches, three factory and three with
 * every nibble randomised (tools/engineb/devrecall_gate.py --patch-scan,
 * gate.c scan_section). Regenerate with that flag; do not edit by hand.
 *
 * juno_bank_apply reads record 30..3952, so [16,4096) brackets it. */
static const short EB_RECALL_POS[] = {
      30,   31,   32,   33,   34,   35,   36,   37,   40,   41,   44,   45,
      46,   47,   48,   49,   68,   69,   70,   71,   72,   73,   74,   75,
      86,   87,   90,   91,   92,   93,   94,   95,   96,   97,   98,   99,
     100,  101,  102,  103,  104,  105,  106,  107,  108,  109,  110,  111,
     112,  113,  114,  115,  116,  117,  118,  119,  120,  121,  122,  123,
     124,  125,  135,  148,  149,  490,  491,  498,  499,  530,  531,  538,
     539,  554,  555,  618,  619,  634,  635,  642,  643,  650,  651,  658,
     659,  666,  667, 1868, 1869, 2102, 2103, 3057, 3058, 3059, 3060, 3061,
    3068, 3069, 3076, 3077, 3084, 3085, 3092, 3093, 3286, 3287, 3288, 3948,
    3949, 3950, 3951, 3952,
};

/* READ, not measured. Positions the recall path reads that the scan above
 * CANNOT see, with the reason. A single-byte perturbation scan is blind to a
 * parameter that is one factor of a product of several: with any other factor
 * at a zeroing value the product stays 0 whatever this byte does.
 *
 *   506, 507   BEND GAIN, src/juno_apply.c:447. Multiplied by juno_curve(4,
 *              BEND RANGE) and juno_curve(22, BEND SENS DCO/VCF) at :452-453.
 *              The scan reports the WHOLE bend family inert -- 130, 131 (BEND
 *              RANGE), 514, 515, 522, 523 (BEND SENS) all come back as
 *              non-affecting, which is the control that shows the blindness is
 *              the probe's and not the parameter's. Those six are carried
 *              already; these two were not.
 *
 * If a future reader wants to delete this list, the thing to do is not to
 * argue about it: drive two of the factors to non-zero and re-run the scan. */
static const short EB_READ_POS[] = { 506, 507 };

int eb_patch_record_coverage(int *missing, int nmiss)
{
    int i, nm = 0;
    for (i = 0; i < (int)(sizeof EB_RECALL_POS / sizeof EB_RECALL_POS[0]); ++i)
        if (index_of((int)EB_RECALL_POS[i] - EB_BANK_BLOB_OFF) < 0) {
            if (missing && nm < nmiss) missing[nm] = EB_RECALL_POS[i];
            nm++;
        }
    for (i = 0; i < (int)(sizeof EB_READ_POS / sizeof EB_READ_POS[0]); ++i)
        if (index_of((int)EB_READ_POS[i] - EB_BANK_BLOB_OFF) < 0) {
            if (missing && nm < nmiss) missing[nm] = EB_READ_POS[i];
            nm++;
        }
    return nm;
}

int eb_patch_coverage(int *missing, int nmiss)
{
    int i, nm = 0;
    for (i = 0; i < NTAB; ++i) {
        int b;
        if (TAB[i].roff < 0) continue;
        b = TAB[i].roff - EB_BANK_BLOB_OFF;
        if (index_of(b) < 0 || (TAB[i].kind == EB_NIB && index_of(b + 1) < 0)) {
            if (missing && nm < nmiss) missing[nm] = TAB[i].roff;
            nm++;
        }
    }
    return nm;
}

int eb_patch_unresolved(const char **names, int n)
{
    int i, c = 0;
    for (i = 0; i < NTAB; ++i)
        if (TAB[i].roff < 0) { if (names && c < n) names[c] = TAB[i].name; c++; }
    return c;
}

const char *eb_patch_name_of(int roff)
{
    int i;
    for (i = 0; i < NTAB; ++i) if (TAB[i].roff == roff) return TAB[i].name;
    return "?";
}

int eb_patch_selftest(void)
{
    int i, bad = 0;
    for (i = 1; i < EB_PATCH_BYTES; ++i)
        if (eb_patch_offsets[i] <= eb_patch_offsets[i - 1]) bad++;  /* ordering */
    for (i = 0; i < EB_PATCH_BYTES; ++i)
        if (index_of((int)eb_patch_offsets[i]) != i) bad++;         /* lookup   */
    if (index_of(13) >= 0 || index_of(3937) >= 0) bad++;            /* rejects  */
    /* THE NET. A format that does not carry a byte the recall reacts to is a
     * format that cannot store the instrument, and END_GOAL item 5 says every
     * parameter. This is what stops it shipping short again. */
    bad += eb_patch_record_coverage((int *)0, 0);
    return bad;
}
