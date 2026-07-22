/* finefx_recall.c — per-patch DELAY "fine-FX" filter recall (#116).
 *
 * THE BLIND SPOT THIS CLOSES: the fine delay filter params (DELAY HIGH CUT,
 * LF/HF DAMP, LF/HF DAMP FREQ — dispatch idx 1180/1182..1185) are NOT in the
 * plugin's recall ENUMERATOR (rva 0x3B48A0, real_recall.leaf_table). So the
 * render-A/B ORACLE never applied them either, and BOTH the port and the oracle
 * left the delay's high-cut/damp coefficient cells frozen at the plugin's
 * DEFAULT-byte values (delay_recall.c's FILT[]/put_rate constants). A real host
 * DOES apply them on preset-load (via the controller path), so any patch whose
 * DELAY HIGH CUT / DAMP differs from the default rendered too bright/dark. This
 * was the darkest-bounce signature (factory p2/p6 use DELAY HIGH CUT=3).
 *
 * PROVENANCE (covenant-clean): the DLY_* tables in finefx_tables.h are the exact
 * float32 coefficients the plugin's OWN setter writes for each param byte,
 * captured by executing dispatch 1180/1182..1185 under Unicorn across all 256
 * byte values at every host rate (tools/verify/finefx_delay_rates.py). At the
 * default byte each row EQUALS delay_recall.c's proven FILT[]/put_rate constant
 * (HIGH CUT byte 7, DAMP byte 0, LF/HF DAMP FREQ arms == ARM_LFX2/ARM_HFDMP),
 * so this applier is a strict generalization: identity at the default, correct
 * everywhere else. The render-A/B oracle is extended to dispatch these same
 * leaves (recall_render_ab.py DELAY_FILT_LEAVES), so the gate now covers them.
 *
 * SCOPE: DELAY TYPE 0 only. For TYPE 1/4 the delay uses a different cell
 * signature (DLY1_A) and for TYPE 2/3/5 slot-1 hosts chorus/reverb (which own
 * 102656 as a rate-CONSTANT); those routings leave the delay high-cut cells
 * unread, so applying the delay fine-FX there would be both unnecessary and
 * (for 102656) wrong. delay_recall.c calls this only from the TYPE-0 arm.
 *
 * Record decode mirrors juno_hostparams.c exactly: HIGH CUT is int1x7 (raw byte
 * at roff 3059); the DAMP params are int8x4 (low-byte nibble pair at roff/roff+1,
 * roff 3068/3076/3084/3092). These are the plugin's own serialization offsets.
 */
#include "juno_engine.h"
#include "finefx_recall.h"
#include "finefx_tables.h"
#include <string.h>

static void wr_bits(unsigned char *state, int off, uint32_t bits)
{
    float f; memcpy(&f, &bits, sizeof f); JF(state, off) = f;
}
static int nib(const unsigned char *rec, int roff)   /* int2x4 / int8x4 low byte */
{
    return ((rec[roff] & 0xF) << 4) | (rec[roff + 1] & 0xF);
}
static int clampi(int v, int lo, int hi)
{
    return v < lo ? lo : (v > hi ? hi : v);
}

void juno_apply_delay_finefx(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    int hc  = clampi(rec[3059] & 0x7F, 0, 14);   /* HIGH CUT     (int1x7, raw)  */
    int lfd = clampi(nib(rec, 3068),   0, 81);   /* LF DAMP      (int8x4)       */
    int lff = clampi(nib(rec, 3076),   0, 10);   /* LF DAMP FREQ (int8x4, rate) */
    int hfd = clampi(nib(rec, 3084),   0, 81);   /* HF DAMP      (int8x4)       */
    int hff = clampi(nib(rec, 3092),   0, 13);   /* HF DAMP FREQ (int8x4, rate) */
    int k;
    for (k = 0; k < 7; k++)
        wr_bits(state, DLY_HC_CELLS[k], DLY_HC[hc][k]);
    wr_bits(state, 102640, DLY_LFDMP[lfd]);
    wr_bits(state, 102672, DLY_HFDMP[hfd]);
    wr_bits(state, 102608, DLY_LFDF[arm][lff]);
    wr_bits(state, 102656, DLY_HFDF[arm][hff]);
}

/* DELAY TYPE 1 (dual delay) SECOND-INSTANCE fine-FX. In TYPE 1 the HIGH CUT / DAMP /
 * DIRECT knobs move the SECOND delay instance (cells 4297xxx), NOT the first — proven
 * by dispatch+snap in a DELAY TYPE 1 context (tools/verify/finefx_multictx_probe.py:
 * dispatch 1180-1185 write only 4297xxx there, 102xxx untouched). The per-byte law is
 * IDENTICAL to the TYPE-0 first-instance law (same DLY_* tables; verified law(DT1)==
 * law(DT0) for every leaf), only the target cells differ. Identity at the default
 * byte: every default value equals delay_recall.c's DLY1_B block constant (4297600=
 * 0x3e1b31ce, 4297744/4297936/4297968=1.0, 4297904=ARM_LFX2, 4297952=ARM_HFDMP), so
 * this overwrites the DLY1_B placeholders and is a no-op for default-fine-FX patches.
 * Cell offset from the TYPE-0 cell: +4195232 (HIGH CUT/DIRECT), +4195296 (DAMP).
 * (TYPE 4 writes NO fine-FX cell — proven — so no TYPE-4 applier.) */
static const int DLY_HC_CELLS2[7] = {4297600, 4297616, 4297632, 4297648,
                                     4297664, 4297696, 4297728};
void juno_apply_delay_finefx_2nd(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    int hc  = clampi(rec[3059] & 0x7F, 0, 14);   /* HIGH CUT      (int1x7, raw)  */
    int dl  = clampi(nib(rec, 3060),   0, 255);  /* DIRECT LEVEL  (int2x4)       */
    int lfd = clampi(nib(rec, 3068),   0, 81);   /* LF DAMP       (int8x4)       */
    int lff = clampi(nib(rec, 3076),   0, 10);   /* LF DAMP FREQ  (int8x4, rate) */
    int hfd = clampi(nib(rec, 3084),   0, 81);   /* HF DAMP       (int8x4)       */
    int hff = clampi(nib(rec, 3092),   0, 13);   /* HF DAMP FREQ  (int8x4, rate) */
    int k;
    for (k = 0; k < 7; k++)
        wr_bits(state, DLY_HC_CELLS2[k], DLY_HC[hc][k]);
    JF(state, 4297744) = (float)dl / 255.0f;     /* DIRECT LEVEL = byte/255      */
    wr_bits(state, 4297936, DLY_LFDMP[lfd]);
    wr_bits(state, 4297968, DLY_HFDMP[hfd]);
    wr_bits(state, 4297904, DLY_LFDF[arm][lff]);
    wr_bits(state, 4297952, DLY_HFDF[arm][hff]);
}

/* DELAY TYPE 5 (slot-1 hosts REVERB) SLOT-1-REVERB delay-filter fine-FX. In TYPE 5
 * the HIGH CUT / DAMP / DIRECT knobs move the slot-1 reverb's delay-style filter
 * block (cells 6497xxx), with the per-byte law IDENTICAL to the TYPE-0 first-instance
 * law (proven law-identical, tools/verify (finefx_fullctx_audit.py + dt5_derive.py)).
 * Identity at the default byte (== delay_recall.c's S1REVERB constants:
 * 6497184=0x3e1b31ce, 6497328/6497456/6497488=1.0, 6497424=ARM_LFX2, 6497472=ARM_HFDMP).
 * Called from delay_recall.c's apply_slot1_reverb. */
static const int DLY_HC_CELLS5[7] = {6497184, 6497200, 6497216, 6497232,
                                     6497248, 6497280, 6497312};
void juno_apply_delay_finefx_slot1rev(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    int hc  = clampi(rec[3059] & 0x7F, 0, 14);
    int dl  = clampi(nib(rec, 3060),   0, 255);
    int lfd = clampi(nib(rec, 3068),   0, 81);
    int lff = clampi(nib(rec, 3076),   0, 10);
    int hfd = clampi(nib(rec, 3084),   0, 81);
    int hff = clampi(nib(rec, 3092),   0, 13);
    int k;
    for (k = 0; k < 7; k++)
        wr_bits(state, DLY_HC_CELLS5[k], DLY_HC[hc][k]);
    JF(state, 6497328) = (float)dl / 255.0f;
    wr_bits(state, 6497456, DLY_LFDMP[lfd]);
    wr_bits(state, 6497488, DLY_HFDMP[hfd]);
    wr_bits(state, 6497424, DLY_LFDF[arm][lff]);
    wr_bits(state, 6497472, DLY_HFDF[arm][hff]);
}

/* REVERB fine-FX (LOW CUT 1324 / HIGH CUT 1325 / DENSITY 1326 / DIRECT LEVEL 1327):
 * NOT in the plugin's recall enumerator (blind spot), but a host's preset-load
 * applies them via 0x3B9A30; the coefficient CELL materializes when the reverb
 * smoother settles. The law is the plugin's own smoother TARGET (== the render-
 * materialized coeff), captured by dispatch 0x3B9A30 + snap_all at all 4 rates
 * (tools/verify/reverb_finefx_derive.py). The master always runs the reverb tank,
 * so these apply unconditionally; all cells are master_render-READ. Record decode
 * per juno_hostparams.c: LOW/HIGH CUT/DENSITY int1x7 (raw 7-bit, roff 3948/3949/
 * 3950); DIRECT LEVEL int2x4 (nibble pair, roff 3951). REVERB PRE DELAY (1323) is
 * a joint TYPE x tap-array function (34 cells at 11022208, overlaps
 * juno_write_reverb_taps) and is handled separately (follow-up). */
void juno_apply_reverb_finefx(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    /* Clamp to the plugin's OWN param range (real host maps normalized->[0,1]->
     * plain in [min,max], so out-of-range record bytes are unreachable). The
     * reverb setter does NOT saturate internally past its range (it reads
     * state-dependent garbage), so clamping here is load-bearing for any-preset
     * robustness; proven bit-exact over [0,max] by finefx_pillar3_gate.py. */
    int lc = clampi(rec[3948] & 0x7F, 0, 17);    /* REVERB LOW CUT   (int1x7)     */
    int hc = clampi(rec[3949] & 0x7F, 0, 14);    /* REVERB HIGH CUT  (int1x7)     */
    int dn = clampi(rec[3950] & 0x7F, 0, 10);    /* REVERB DENSITY   (int1x7)     */
    int dl = clampi(nib(rec, 3951),  0, 255);    /* REVERB DIRECT LV (int2x4)     */
    int k;
    for (k = 0; k < 3; k++) wr_bits(state, REV_LC_CELLS[k], REV_LC[arm][lc][k]);
    for (k = 0; k < 5; k++) wr_bits(state, REV_HC_CELLS[k], REV_HC[arm][hc][k]);
    wr_bits(state, REV_DENS_CELL,   REV_DENS[dn]);
    wr_bits(state, REV_DIRECT_CELL, REV_DIRECT[dl]);
}

/* SLOT-1 CHORUS fine-FX (DELAY TYPE 2/3): CHORUS HIGH CUT (1212) / LOW CUT (1211) /
 * PRE DELAY (1210). The slot-2 EFFECT-TYPE chorus has NO fine filters (0 cells,
 * proven); these apply ONLY to the DELAY-TYPE-2/3 slot-1 chorus (cells 6396xxx).
 * Law = the plugin's own smoother target via 0x3B9A30 + snap_all at all 4 rates
 * (chorus_finefx_derive.py). At the default byte (HIGH CUT 13 / LOW CUT 2 / PRE
 * DELAY 20) every value EQUALS delay_recall.c's S1CHORUS/ARM_CHLF/ARM_CHDEP
 * constants -- identity at the default, correct for any value. Called from
 * delay_recall.c apply_slot1_chorus. HIGH CUT rate-indep; LOW CUT/PRE DELAY armed.
 * int1x7 record bytes (HIGH 3288 / LOW 3287 / PRE 3286). */
void juno_apply_chorus_finefx(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    /* Clamp to the plugin's own param range (see reverb note above). The chorus
     * setter DOES saturate internally, so the port matched bit-exact over 0..127
     * before this too; clamping to range is kept for uniformity + robustness. */
    int hc = clampi(rec[3288] & 0x7F, 0, 14);    /* CHORUS HIGH CUT (int1x7)      */
    int lc = clampi(rec[3287] & 0x7F, 0, 17);    /* CHORUS LOW CUT  (int1x7)      */
    int pd = clampi(rec[3286] & 0x7F, 0, 80);    /* CHORUS PRE DELAY(int1x7)      */
    int k;
    for (k = 0; k < 7; k++) wr_bits(state, CHO1_HC_CELLS[k], CHO1_HC[hc][k]);
    for (k = 0; k < 2; k++) wr_bits(state, CHO1_LC_CELLS[k], CHO1_LC[arm][lc][k]);
    wr_bits(state, CHO1_PD_CELL, CHO1_PD[arm][pd]);
}

/* DELAY TYPE 5 (slot-1 reverb) SLOT-1-REVERB chorus-filter fine-FX. In TYPE 5 the
 * CHORUS HIGH CUT / LOW CUT / PRE DELAY knobs move the slot-1 reverb's chorus-style
 * filter block (cells 10693xxx), with the per-byte law IDENTICAL to the DELAY-TYPE-2/3
 * slot-1 chorus law (proven law-identical, dt5_derive.py). Identity at the default
 * byte (== delay_recall.c's S1REVERB constants: 10693072=0x3f03df74, 10693008=ARM_CHDEP,
 * 10693216=ARM_CHLF). Called from delay_recall.c apply_slot1_reverb. */
static const int CHO_HC_CELLS5[7] = {10693072, 10693088, 10693104, 10693120,
                                     10693136, 10693168, 10693200};
static const int CHO_LC_CELLS5[2] = {10693216, 10693232};
void juno_apply_chorus_finefx_slot1rev(unsigned char *state, const unsigned char *rec, int Hr)
{
    int arm = (Hr == 44100) ? 0 : (Hr == 48000) ? 1 : (Hr == 88200) ? 2 : 3;
    int hc = clampi(rec[3288] & 0x7F, 0, 14);
    int lc = clampi(rec[3287] & 0x7F, 0, 17);
    int pd = clampi(rec[3286] & 0x7F, 0, 80);
    int k;
    for (k = 0; k < 7; k++) wr_bits(state, CHO_HC_CELLS5[k], CHO1_HC[hc][k]);
    for (k = 0; k < 2; k++) wr_bits(state, CHO_LC_CELLS5[k], CHO1_LC[arm][lc][k]);
    wr_bits(state, 10693008, CHO1_PD[arm][pd]);
}
