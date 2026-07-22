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
