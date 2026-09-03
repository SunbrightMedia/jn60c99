/* s3_chain.h -- CHAIN4: the 4-board chain as pure functions (no hardware).
 *
 * Design: docs/engineb/CHAIN4.md (binding). The chain is 4->3->2->1, chip 1
 * owns the DAC; each hop is one instance of the PROVEN pairwise link. This
 * header holds everything a host gate can execute: the per-position config,
 * the wire-slot merge law, chip 1's injection map, and the per-hop window
 * check. tools/engineb/chain_gate.sh proves the merge+inject law nulls
 * EXACTLY 0 against the single-engine render, and that every check here has
 * been SEEN TO FAIL.
 *
 * THE BIT-EXACT LAW (READ eb_master_in.c:20-23): the master consumes voice
 * slots as four pair sums (v8=1+0, v13=3+2, v18=5+4, v24=7+6), one float add
 * each. A chord of six occupies slots 2..7 (three complete pairs) and slot
 * IS global identity at base 0 -- so a chip that owns a complete pair may
 * send the pre-added pair, and a chip that owns half a pair must send the
 * raw voice. All four chips run EB_DEVSEQ_VOICE_BASE = 0 and share the one
 * plain chord-6 answer key.
 *
 * ±0 EDGE, stated: chip 1 re-adds 0.0f to a received pre-add, so a -0.0
 * pre-add lands as +0.0 -- numerically equal everywhere downstream, PCM
 * null 0. chain_gate counts how often it fires.
 */
#ifndef JUNO_S3_CHAIN_H
#define JUNO_S3_CHAIN_H

/* wire format: 4 slots x 32-bit, one TDM frame per sample, every hop */
#define S3_CHAIN_SLOTS 4
#define S3_CHAIN_NPOS  4

/* the six sounding voices of a chord-6 build (devchord.h: 8-k..7) */
#define S3_CHAIN_V_LO  2
#define S3_CHAIN_V_HI  8

typedef struct {
    int pos;        /* 1..4; 1 = the DAC end                                */
    int has_up;     /* a hop exists AWAY from the DAC (this chip is A on it)*/
    int has_down;   /* a hop exists TOWARD the DAC (this chip is B on it)   */
    int v_lo, v_hi; /* local render window [lo, hi)                         */
    /* what this chip's DOWN-hop frames advertise: its own window PLUS
     * everything it forwards (up-cumulative). The downstream side checks
     * disjointness against its own down-cumulative window. */
    int adv_lo, adv_hi;
    int uses_dac;   /* pos 1 only */
    int has_fx;     /* chorus + master run on pos 1 only                    */
} s3_chain_cfg;

static s3_chain_cfg s3_chain_config(int pos)
{
    s3_chain_cfg c;
    static const int lo[5] = { 0, 7, 6, 4, 2 };   /* [pos] */
    static const int hi[5] = { 0, 8, 7, 6, 4 };
    if (pos < 1 || pos > S3_CHAIN_NPOS) pos = 1;  /* fail SAFE: the DAC end */
    c.pos      = pos;
    c.has_up   = (pos < S3_CHAIN_NPOS);
    c.has_down = (pos > 1);
    c.v_lo     = lo[pos];
    c.v_hi     = hi[pos];
    c.adv_lo   = S3_CHAIN_V_LO;                   /* up-cumulative: 2..hi   */
    c.adv_hi   = hi[pos];
    c.uses_dac = (pos == 1);
    c.has_fx   = (pos == 1);
    return c;
}

/* this chip's DOWN-cumulative window (its own + everything nearer the DAC):
 * what the A-side of its UP hop presents for the disjointness check. */
static void s3_chain_down_window(int pos, int *lo, int *hi)
{
    s3_chain_cfg c = s3_chain_config(pos);
    *lo = c.v_lo;
    *hi = S3_CHAIN_V_HI;
}

/* per-hop window check, run by BOTH ends: the A-side's down-cumulative
 * window and the B-side's up-cumulative advert must be DISJOINT and must
 * TILE [2,8) exactly -- overlap duplicates a voice, a gap silences one.
 * Returns 0 = OK, nonzero = refuse (mix stays closed). */
static int s3_chain_hop_check(int a_lo, int a_hi, int b_lo, int b_hi)
{
    if (b_hi != a_lo) return 1;                       /* gap or overlap     */
    if (b_lo != S3_CHAIN_V_LO) return 2;              /* upstream not 2..   */
    if (a_hi != S3_CHAIN_V_HI) return 3;              /* downstream not ..8 */
    if (a_lo <= b_lo || a_lo >= a_hi) return 4;       /* degenerate window  */
    return 0;
}

/* ---- THE MERGE LAW: what this chip writes on its DOWN hop ----------------
 * v[8]     = the chunk of voice samples this chip rendered (its window; the
 *            rest are 0).
 * up[4]    = the slots received on its UP hop, CRC-proven, or NULL/invalid
 *            (mix closed / no upstream) -- zeros then, and the chain
 *            degrades one pair at a time instead of breaking (INVARIANT).
 * out[4]   = the slots to transmit.
 * Slot map on EVERY hop: 0 = v13 pre-add (slots 3+2), 1 = v18 pre-add
 * (slots 5+4), 2 = raw voice slot 6, 3 = spare (0). */
static void s3_chain_merge(const s3_chain_cfg *c, const float v[8],
                           const float up[4], int up_valid, float out[4])
{
    float u0 = (up_valid && up) ? up[0] : 0.0f;
    float u1 = (up_valid && up) ? up[1] : 0.0f;
    float u2 = (up_valid && up) ? up[2] : 0.0f;
    out[0] = (c->pos == 4) ? (v[3] + v[2]) : u0;   /* the v13 pre-add      */
    out[1] = (c->pos == 3) ? (v[5] + v[4]) : u1;   /* the v18 pre-add      */
    out[2] = (c->pos == 2) ? v[6]          : u2;   /* raw half of v24      */
    out[3] = 0.0f;
    (void)up;
}

/* ---- CHIP 1'S INJECTION: build the 8-slot master input -------------------
 * m[3] carries the v13 pre-add (m[2]=0 -> v13 = pre-add + 0.0f), m[5] the
 * v18 pre-add likewise; m[6] is the RAW remote voice so v24 = local + remote
 * is the port's own association, unchanged. */
static void s3_chain_inject(const float v[8], const float up[4], int up_valid,
                            float m[8])
{
    int i;
    for (i = 0; i < 8; ++i) m[i] = 0.0f;
    if (up_valid && up) {
        m[3] = up[0];
        m[5] = up[1];
        m[6] = up[2];
    }
    m[7] = v[7];
}

#endif /* JUNO_S3_CHAIN_H */
