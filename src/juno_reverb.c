/* juno_reverb_activate.c — activate the (bit-exact) JUNO-60 plate reverb.
 *
 * Faithful transcription of the retune routine sub_7FF91E021AC0
 *   (rva 0x3C1AC0, allcode/decomp_3C0000.c:1051-1162) which converts a reverb
 *   type index into the 34 tap-offset slots, plus the activation state writes the
 *   per-sample DSP (src/master_render.c:2044-2310) needs to leave the bypass.
 *
 * Integrate by calling juno_reverb_activate(st, 3, decay_step) AFTER
 * juno_chorus_init + juno_engine_init + juno_runtime_coeffs_apply.
 */
#include "juno_engine.h"
#include <string.h>

/* ------------------------------------------------------------------ *
 *  Static .rdata tables (from refs/reverb_tables.json)
 * ------------------------------------------------------------------ */

/* Tap-length table @ rva 0x9DA350 (bound as CDSPRev+56, sub_7FF91E021110:779).
 * 20 rows x 3 SR-variant columns, row-major int32 (samples). */
static const int juno_rev_tap_lengths[20][3] = {
    {  246,  738, 1910 }, {  196,  586, 1516 }, {  116,  350,  906 },
    {   46,  140,  360 }, {  174,  520, 1346 }, {  174,  518, 1340 },
    {  174,  522, 1350 }, {  174,  520, 1346 }, {  540, 1618, 4188 },
    {  906, 2720, 7044 }, {  922, 2766, 7164 }, {  508, 1526, 3948 },
    {  950, 2848, 7376 }, {  980, 2940, 7614 }, {  444, 1332, 3450 },
    { 1056, 3170, 8208 }, { 1256, 3768, 9754 }, {  474, 1424, 3688 },
    { 1088, 3262, 8446 }, { 1286, 3858, 9990 },
};

/* Reverb-type / SR-config table @ rva 0x9DA600 (CDSPRev+64).
 * Rows of 16 int32. col13 = tap-length COLUMN index to use; col0 = DPF Fc bits.
 * (Only HALL2=type3 is verified here; rows 0..3 from refs/reverb_tables.json.) */
static const int juno_rev_type_cfg[6][16] = {
    { 1032165060,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0,0 }, /* type0 */
    { 1040541432,0,0,0,0,0,0,0,0,0,0,0,0, 1, 0,0 }, /* type1 */
    { 1040541432,0,0,0,0,0,0,0,0,0,0,0,0, 2, 0,0 }, /* type2 */
    { 1024003515,0,0,0,0,0,0,0,0,0,0,0,0, 2, 0,0 }, /* type3 = HALL2 */
    { 0 }, { 0 },
};

/* ------------------------------------------------------------------ *
 *  Retune: type -> 34 tap offsets   (transcription of sub_7FF91E021AC0)
 * ------------------------------------------------------------------ *
 *
 * The original walks the type-cfg row, picks the tap COLUMN (v6 = col13) and
 * reads column-v6 of every length row via *(base + 4*v6 + 12*n) (decomp 1092,
 * 1101-1123). It then accumulates running buffer offsets and emits 34 node
 * writes (decomp 1124-1157) through sub_7FF91E021070 -> the source tap table
 * a1+11022208 (slot k -> 11022208 + 4*k; the live copy a1+11022064 is loaded
 * from it by the DSP when the clear-countdown hits 0, master_render.c:2096).
 *
 * `pad` = *(CDSPRev+28)+1 (decomp 1100). It is 0 on a freshly constructed
 * CDSPRev (ctor zeroes the qword at +24, sub_7FF91E021110:776), so pad=0 and
 * v13=1; expose it as a param for completeness.
 *
 * Writes the 34 source slots a1+11022208.. (16-bit values, matching the DSP's
 * uint16 head+tap addressing). Returns the column index used (for verification).
 */
int juno_reverb_build_taps(unsigned char *st, int type, int pad)
{
    const int *cfg;
    int col;                 /* v6 : tap-length column (col13 of type row)     */
    const int *L;            /* column-`col` lengths, indexed L[n] = lengths[n][col] */
    int Lc[20];
    int v13, n;
    unsigned int o[34];      /* the 34 running offsets (slot values)           */

    if (type < 0 || type > 5) return -1;
    cfg = juno_rev_type_cfg[type];
    col = cfg[13];           /* HALL2 -> 2 */

    for (n = 0; n < 20; ++n) Lc[n] = juno_rev_tap_lengths[n][col];
    L   = Lc;
    v13 = pad + 1;           /* decomp 1100 */

    /* decomp 1102-1107 : the seeded offsets (note the +963 / +962 / +1 / +2
     * constants are literal in the asm). */
    {
        unsigned int v6a  = (unsigned int)L[0] + (unsigned int)v13 + 963; /* 1104 */
        unsigned int v3a  = (unsigned int)L[1] + 1;                       /* 1102 */
        unsigned int v14  = (unsigned int)L[2];                           /* 1101 */
        unsigned int v15  = (unsigned int)L[3] + 1;                       /* 1103 */
        unsigned int v3b  = v6a + 2 + v3a;                                /* 1105 */
        unsigned int v16  = v3b + 2 + v14 + 1;                            /* 1106 */
        unsigned int v38  = v16 + 2 + v15;                                /* 1107 */
        unsigned int v19  = v38 + 2 + (unsigned)L[4]  + 1;               /* 1108 */
        unsigned int v20  = v19 + 2 + (unsigned)L[5]  + 1;               /* 1109 */
        unsigned int v21  = v20 + 2 + (unsigned)L[6]  + 1;               /* 1110 */
        unsigned int v22  = v21 + 2 + (unsigned)L[7]  + 1;               /* 1111 */
        unsigned int v23  = v22 + 2 + (unsigned)L[8]  + 1;               /* 1112 */
        unsigned int v24  = v22 + 2 + (unsigned)L[9]  + 1;               /* 1113 */
        unsigned int v25  = v22 + 2 + (unsigned)L[10] + 1;               /* 1114 */
        unsigned int v26  = v25 + 2 + (unsigned)L[11] + 1;               /* 1115 */
        unsigned int v27  = v25 + 2 + (unsigned)L[12] + 1;               /* 1116 */
        unsigned int v28  = v25 + 2 + (unsigned)L[13] + 1;               /* 1117 */
        unsigned int v29  = v28 + 2 + (unsigned)L[14] + 1;               /* 1118 */
        unsigned int v30  = v28 + 2 + (unsigned)L[15] + 1;               /* 1119 */
        unsigned int v31  = v28 + 2 + (unsigned)L[16] + 1;               /* 1120 */
        unsigned int v32  = v31 + 2 + (unsigned)L[17] + 1;               /* 1121 */
        unsigned int v33  = v31 + 2 + (unsigned)L[18] + 1;               /* 1122 */
        unsigned int v34  = v31 + 2 + (unsigned)L[19] + 1;               /* 1123 */

        /* decomp 1124-1157 : the 34 source-table writes, slot order 0..0x21. */
        o[0]  = 1;            o[1]  = (unsigned)v13;  o[2]  = (unsigned)v13 + 962;
        o[3]  = v6a;          o[4]  = v6a + 2;
        o[5]  = v3b;          o[6]  = v3b + 2;
        o[7]  = v16;          o[8]  = v16 + 2;
        o[9]  = v38;          o[10] = v38 + 2;
        o[11] = v19;          o[12] = v19 + 2;
        o[13] = v20;          o[14] = v20 + 2;
        o[15] = v21;          o[16] = v21 + 2;
        o[17] = v22;          o[18] = v22 + 2;
        o[19] = v23;          o[20] = v24;
        o[21] = v25;          o[22] = v25 + 2;
        o[23] = v26;          o[24] = v27;
        o[25] = v28;          o[26] = v28 + 2;
        o[27] = v29;          o[28] = v30;
        o[29] = v31;          o[30] = v31 + 2;
        o[31] = v32;          o[32] = v33;          o[33] = v34;
    }

    /* Write the SOURCE tap table a1+11022208 (slot k -> 11022208 + 4*k).
     * Values are masked to 16 bits to match the DSP's uint16 head addressing
     * (master_render.c:2179 etc). */
    for (n = 0; n < 34; ++n)
        JI(st, 11022208 + 4 * n) = (int)(o[n] & 0xFFFF);

    return col;
}

/* ------------------------------------------------------------------ *
 *  Full activation
 * ------------------------------------------------------------------ *
 *
 * Sets the tap table (above) plus the state the DSP's bypass test reads:
 *   decay  state[10759376]  (>0 required, master_render.c:2049/2074)
 *   fade   state[11022032]  (ramps toward 1; seed mid so it crosses fast)
 *   clear-countdown state[10759872] = 256  (0x100): the DSP zeroes the buffer
 *                   for 256 frames then copies source->live taps (2078-2145)
 *
 * The decay-knob-driven coefficients (allpass g @10759392, the four damping
 * triplets @10759648/696/744/792.., DPF Fc, input/output gains @10759408/
 * 424/440, modulator @10759488/504) are NOT type-derived; they are produced by
 * the Ecf-node param path (sub_7FF91E021290 etc) and are ALREADY supplied for
 * HALL2 by src/runtime_coeffs_data.c (juno_runtime_coeffs_apply): e.g.
 *   10759376 = 1.0  (decay enable)        10759392 = 0.5   (allpass g)
 *   10759648 = 0.0334604 (= HALL2 DPF Fc col0, 0x3d090dbb)
 *   10759872 = 0x100 (clear-countdown)    10759408/424/440/504/520.. set.
 * So with juno_runtime_coeffs_apply already run, the ONLY missing piece is the
 * tap source table — this function fills it. `decay_step` lets the caller
 * override the decay amount; pass <=0 to keep whatever the coeff apply set.
 */
void juno_reverb_activate(unsigned char *st, int type, float decay)
{
    juno_reverb_build_taps(st, type, /*pad=*/0);

    if (decay > 0.0f)
        JF(st, 10759376) = decay;             /* decay/size enable (v463)        */
    else if (JF(st, 10759376) <= 0.0f)
        JF(st, 10759376) = 1.0f;              /* fall back to full if unset      */

    /* Wet fade: leave at 0 to let it ramp up naturally (+0.0004/sample), or seed
     * to 1.0 for instant wet. We seed 0 (faithful: the plugin ramps). */
    if (JF(st, 11022032) < 0.0f || JF(st, 11022032) > 1.0f)
        JF(st, 11022032) = 0.0f;

    /* Kick the clear/retune countdown so the DSP zeroes the tank and copies the
     * source taps into the live table. (juno_runtime_coeffs_apply already sets
     * this to 0x100; set it here too so activation is self-contained.) */
    if (JI(st, 10759872) <= 0)
        JI(st, 10759872) = 0x100;
}
