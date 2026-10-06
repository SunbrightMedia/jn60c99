/* recall_ramp.c -- the plugin's RECALL RAMPS (CLAIMS B1). See recall_ramp.h.
 *
 * Every arm below is one call of the plugin's ramped setter (rva 0x3C10D0 ->
 * 0x3C2920 -> ramp start 0x3C2E80), in the plugin's order PER CELL. Records
 * are independent (one record per cell), so only the order within a cell
 * matters. The sequences are the dynamic census of every ramped set in 234
 * warm recalls (probes/warm/ramp_census_dyn.py, tagged with the dispatched
 * leaf: 757 = the osc-enable leaf, 795 REVERB LEVEL, 873 EFFECT TYPE, 875
 * DELAY TYPE, 876 REVERB TYPE, 877 REVERB TIME, 1323..1327 reverb fine FX).
 * During a recall nothing else writes these 73 cells (EXECUTED,
 * probes/warm/ramp_cells_writers.py), so every arm starts from the value the
 * cell held before the recall. An arm takes effect only when its target
 * differs from the record's stored target (juno_ramp_start's early-out).
 *
 * Compiled out under EB_DEVCELLS: the device recall stays settled.
 */
#include "recall_ramp.h"

#ifndef EB_DEVCELLS
#include "juno_engine.h"
#include "juno_ramp.h"
#include "delay_recall.h"      /* juno_lfx1_value */
#include "reverb_recall.h"     /* juno_reverb_hplp, juno_reverb_level_on */
#include <string.h>

/* The ramped setter's time table (rva 0x9DEB50, READ): index i -> 4*(i+1) ms;
 * its subdivision is the constant 10 (rva 0x3C2940). */
static const float RR_TIME_MS[9] = { 4.0f, 8.0f, 12.0f, 16.0f, 20.0f, 24.0f, 28.0f, 32.0f, 36.0f };
enum { T4 = 0, T24 = 5, T36 = 8 };
#define RR_SUBDIV 10

#define V(o) (o), (o) + 10512u, (o) + 21024u, (o) + 31536u, (o) + 42048u, (o) + 52560u, (o) + 63072u, (o) + 73584u
/* The 73 recall-ramped cells, ascending (voice cells at stride
 * JUNO_VOICE_MAIN_STRIDE 10512, checked at compile time below). */
static const uint32_t RR_CELLS[] = {
    2848u, 3328u, 6448u,  13360u, 13840u, 16960u,  23872u, 24352u, 27472u,
    34384u, 34864u, 37984u,  44896u, 45376u, 48496u,  55408u, 55888u, 59008u,
    65920u, 66400u, 69520u,  76432u, 76912u, 80032u,
    84560u, 85168u, 85184u, 86320u, 91248u, 91280u, 96384u, 96416u,
    101744u, 102544u, 102592u,
    4297776u, 4297840u,
    6395328u, 6396400u, 6396448u,
    6429488u, 6430736u, 6430784u,
    6497360u, 6497408u,
    10692032u, 10693280u, 10693328u,
    10759376u, 10759392u, 10759408u, 10759424u, 10759488u,
    10759520u, 10759536u, 10759552u, 10759568u, 10759584u, 10759600u, 10759616u, 10759632u,
    10759648u, 10759664u, 10759680u, 10759696u, 10759712u, 10759728u,
    10759744u, 10759760u, 10759776u, 10759792u, 10759808u, 10759824u,
};
#undef V
#define RR_N ((int)(sizeof(RR_CELLS) / sizeof(RR_CELLS[0])))
typedef char rr_n_is_73[(RR_N == 73) ? 1 : -1];
typedef char rr_stride_is_10512[(JUNO_VOICE_MAIN_STRIDE == 10512) ? 1 : -1];

/* The record table, port-owned memory at JUNO_RR_BASE (src/juno_engine.h):
 * a 16-byte header {magic, n_active, revtime, rev_on} and RR_N records. */
typedef struct { float incr, accum, start, target; int32_t active, step; float pre; int32_t pad; } rr_rec;
#define RR_MAGIC 0x31525252
#define HDR(st, k) (*(int32_t *)((st) + JUNO_RR_BASE + 4u * (unsigned)(k)))
enum { H_MAGIC, H_NACT, H_REVTIME, H_REVON };

static rr_rec *rec_at(unsigned char *st, int i)
{
    return (rr_rec *)(st + JUNO_RR_BASE + 16u + 32u * (unsigned)i);
}

static int index_of(uint32_t cell)
{
    int lo = 0, hi = RR_N - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (RR_CELLS[mid] == cell) return mid;
        if (RR_CELLS[mid] < cell) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

/* The plugin's record state after build + setSampleRate + snap: every
 * recall-ramped record is inactive and its stored target equals the cold cell
 * value (MEASURED for all 73 at 44100/48000/96001,
 * probes/warm/ramp_records_cold.py). The processor holds REVERB TIME 128 (the
 * first TYPE arm is the (type, 128) coefficient in all 22 cold census chains)
 * and REVERB LEVEL off (the first recall with a level >= 3 arms "on"). */
static void rr_seed(unsigned char *st)
{
    int i;
    for (i = 0; i < RR_N; ++i) {
        rr_rec *r = rec_at(st, i);
        memset(r, 0, sizeof *r);
        r->target = JF(st, RR_CELLS[i]);
    }
    HDR(st, H_MAGIC) = RR_MAGIC;
    HDR(st, H_NACT) = 0;
    HDR(st, H_REVTIME) = 128;
    HDR(st, H_REVON) = 0;
}

void juno_rr_reset(unsigned char *state) { HDR(state, H_MAGIC) = 0; }

/* One ramped set: the transcribed ramp start (src/juno_ramp.c, gated by
 * tools/verify/ramp_ab_gate.sh) on this cell's record. */
static void arm(unsigned char *st, uint32_t cell, float v, int t)
{
    rr_rec *r = rec_at(st, index_of(cell));
    juno_ramp x;
    x.out = (float *)JCELL(st, cell);
    x.incr = r->incr; x.accum = r->accum; x.start = r->start; x.target = r->target;
    x.rate = JF(st, 16);                   /* the record's session rate: the host rate */
    x.active = r->active; x.subdiv = RR_SUBDIV; x.step_cnt = r->step;
    juno_ramp_start(&x, v, RR_TIME_MS[t], RR_SUBDIV);
    r->incr = x.incr; r->accum = x.accum; r->start = x.start; r->target = x.target;
    r->active = x.active; r->step = x.step_cnt;
}

void juno_rr_begin(unsigned char *state, juno_rr_ctx *c)
{
    int i;
    if (HDR(state, H_MAGIC) != RR_MAGIC) rr_seed(state);
    c->prev_etype = (int)JI(state, JUNO_PREV_EFX);
    c->prev_dtype = (int)JI(state, JUNO_PREV_DLY);
    c->prev_revtime = (int)HDR(state, H_REVTIME);
    c->prev_rev_on = (int)HDR(state, H_REVON);
    for (i = 0; i < RR_N; ++i) rec_at(state, i)->pre = JF(state, RR_CELLS[i]);
}

/* the cells of the slot-1 block that holds DELAY TYPE t: {switch, enable} pairs */
static int dly_block(int t) { return (t == 2 || t == 3) ? 2 : t; }

void juno_rr_end(unsigned char *st, const juno_rr_ctx *c)
{
    static const uint32_t BLK[6][2][2] = {   /* by dly_block(): {switch, enable} x 2 */
        { { 102544u, 102592u },   { 0u, 0u } },
        { { 4297776u, 4297840u }, { 0u, 0u } },
        { { 6396400u, 6396448u }, { 0u, 0u } },
        { { 0u, 0u },             { 0u, 0u } },
        { { 6430736u, 6430784u }, { 0u, 0u } },
        { { 6497360u, 6497408u }, { 10693280u, 10693328u } },
    };
    float fin[RR_N], hplp[4];
    int i, k, v, Hr = (int)JF(st, 16);
    int pE = c->prev_etype, nE = c->new_etype, pD = c->prev_dtype, nD = c->new_dtype;
    int on_new = juno_reverb_level_on(c->new_revlevel);
    float ON, OFF;
    if (Hr <= 0) Hr = 96000;
    ON = juno_lfx1_value(Hr, 1);
    OFF = juno_lfx1_value(Hr, 0);
    (void)pE;

    /* the appliers wrote the settled values; the plugin leaves the cells
     * untouched and arms their records instead */
    for (i = 0; i < RR_N; ++i) {
        fin[i] = JF(st, RR_CELLS[i]);
        JF(st, RR_CELLS[i]) = rec_at(st, i)->pre;
    }
#define FIN(cell) fin[index_of(cell)]

    /* voices: the osc-enable leaf (757) and the DELAY TYPE setter (875) mute
     * and unmute every voice of every unit */
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        uint32_t o = (uint32_t)v * JUNO_VOICE_MAIN_STRIDE;
        arm(st, 2848u + o, 0.0f, T4); arm(st, 2848u + o, 1.0f, T4);
        arm(st, 3328u + o, 0.0f, T4); arm(st, 3328u + o, 1.0f, T4);
        for (k = 0; k < 2; ++k) { arm(st, 6448u + o, 0.0f, T4); arm(st, 6448u + o, 1.0f, T4); }
    }

    /* slot 2: the EFFECT TYPE setter (873) and the DELAY TYPE setter's replay
     * (875) each switch the slot-2 block of the NEW type off and on */
    for (k = 0; k < 2; ++k) {
        arm(st, 84560u, 0.0f, T4); arm(st, 84560u, 1.0f, T4);
        if (nE == 0) { arm(st, 85168u, 1.0f, T24); arm(st, 85184u, 1.0f, T24); }
        if (nE == 1) arm(st, 86320u, 1.0f, T4);
        if (nE >= 2 && nE <= 4) {
            arm(st, 91248u, OFF, T4); arm(st, 91248u, ON, T4);
            arm(st, 91280u, 0.0f, T4); arm(st, 91280u, 1.0f, T4);
        }
        if (nE == 5) {
            arm(st, 96384u, OFF, T4); arm(st, 96384u, ON, T4);
            arm(st, 96416u, 0.0f, T4); arm(st, 96416u, 1.0f, T4);
        }
    }

    /* slot 1: the DELAY TYPE setter (875, rva 0x3B93E0) switches the old
     * type's block off (switch -> OFF, enable -> 0, DLY Mute -> 0), then the new
     * type's block on (switch -> ON, enable -> 1, DLY Mute -> 1), and a
     * type 2/3, 4 or 5 block mutes and unmutes its own input once */
    if (pD >= 0 && pD <= 5) {
        int b = dly_block(pD);
        arm(st, 101744u, 0.0f, T4);
        for (k = 0; k < 2; ++k)
            if (BLK[b][k][0]) { arm(st, BLK[b][k][0], OFF, T4); arm(st, BLK[b][k][1], 0.0f, T4); }
    }
    if (nD >= 0 && nD <= 5) {
        int b = dly_block(nD);
        arm(st, 101744u, 1.0f, T4);
        for (k = 0; k < 2; ++k)
            if (BLK[b][k][0]) { arm(st, BLK[b][k][0], ON, T4); arm(st, BLK[b][k][1], 1.0f, T4); }
        if (b == 2) { arm(st, 6395328u, 0.0f, T4); arm(st, 6395328u, 1.0f, T4); }
        if (b == 4) { arm(st, 6429488u, 0.0f, T4); arm(st, 6429488u, 1.0f, T4); }
        if (b == 5) { arm(st, 10692032u, 0.0f, T4); arm(st, 10692032u, 1.0f, T4); }
    }

    /* reverb: REVERB LEVEL (795) arms the reverb on/off cell when the level
     * crosses zero (setter rva 0x3C1460, READ + EXECUTED); DELAY TYPE (875),
     * REVERB TYPE (876) and PRE DELAY (1323) each mute and unmute it */
    if (on_new != c->prev_rev_on) arm(st, 10759376u, on_new ? 1.0f : 0.0f, T36);
    for (k = 0; k < 3; ++k) { arm(st, 10759376u, 0.0f, T36); arm(st, 10759376u, 1.0f, T36); }
    arm(st, 10759408u, FIN(10759408u), T4);                 /* LEVEL (795)          */
    arm(st, 10759392u, FIN(10759392u), T4);                 /* DENSITY (1326)       */
    arm(st, 10759424u, FIN(10759424u), T4);                 /* DIRECT LEVEL (1327)  */
    for (i = 0; i < 8; ++i) {                               /* LOW / HIGH CUT (1324/1325) */
        uint32_t cell = 10759520u + 16u * (uint32_t)i;
        arm(st, cell, FIN(cell), T4);
    }
    /* the type-only cells: 876 and 1323 */
    for (k = 0; k < 2; ++k) {
        arm(st, 10759488u, FIN(10759488u), T4);
        arm(st, 10759648u, FIN(10759648u), T4); arm(st, 10759696u, FIN(10759696u), T4);
        arm(st, 10759744u, FIN(10759744u), T4); arm(st, 10759792u, FIN(10759792u), T4);
    }
    /* the joint (TYPE, TIME) decay coefficients: 876 computes them with the new
     * TYPE and the TIME the processor still holds (the previous recall's; 212
     * of 212 warm census recalls), then 877 and 1323 with the new TIME */
    juno_reverb_hplp(c->new_revtype, c->prev_revtime, hplp);
    arm(st, 10759664u, hplp[0], T4); arm(st, 10759712u, hplp[0], T4);
    arm(st, 10759680u, hplp[1], T4); arm(st, 10759728u, hplp[1], T4);
    arm(st, 10759760u, hplp[2], T4); arm(st, 10759808u, hplp[2], T4);
    arm(st, 10759776u, hplp[3], T4); arm(st, 10759824u, hplp[3], T4);
    for (k = 0; k < 2; ++k) {
        static const uint32_t CO[8] = { 10759664u, 10759712u, 10759680u, 10759728u,
                                        10759760u, 10759808u, 10759776u, 10759824u };
        for (i = 0; i < 8; ++i) arm(st, CO[i], FIN(CO[i]), T4);
    }
#undef FIN

    HDR(st, H_REVTIME) = c->new_revtime;
    HDR(st, H_REVON) = on_new;
    for (k = 0, i = 0; i < RR_N; ++i) k += rec_at(st, i)->active != 0;
    HDR(st, H_NACT) = k;
}

/* the harness snap (tools/verify/e2e_emu.py snap_all) */
void juno_rr_settle(unsigned char *st)
{
    int i;
    if (HDR(st, H_MAGIC) != RR_MAGIC) return;
    for (i = 0; i < RR_N; ++i) {
        rr_rec *r = rec_at(st, i);
        if (!r->active) continue;
        JF(st, RR_CELLS[i]) = r->target;
        r->accum = 0.0f;
        r->active = 0;
        r->step = 0;
    }
    HDR(st, H_NACT) = 0;
}

/* one sample: the plugin's pump (rva 0x3C24A0) after the DSP of the sample */
void juno_rr_pump(unsigned char *st)
{
    int i;
    if (HDR(st, H_MAGIC) != RR_MAGIC || HDR(st, H_NACT) <= 0) return;
    for (i = 0; i < RR_N; ++i) {
        rr_rec *r = rec_at(st, i);
        juno_ramp x;
        if (!r->active) continue;
        x.out = (float *)JCELL(st, RR_CELLS[i]);
        x.incr = r->incr; x.accum = r->accum; x.start = r->start; x.target = r->target;
        x.rate = JF(st, 16);
        x.active = r->active; x.subdiv = RR_SUBDIV; x.step_cnt = r->step;
        juno_ramp_step(&x);
        r->incr = x.incr; r->accum = x.accum; r->start = x.start; r->target = x.target;
        r->step = x.step_cnt;
        if (!x.active) { r->active = 0; --HDR(st, H_NACT); }
    }
}

int juno_rr_active(const unsigned char *state)
{
    unsigned char *st = (unsigned char *)state;
    return HDR(st, H_MAGIC) == RR_MAGIC ? (int)HDR(st, H_NACT) : 0;
}

#else   /* EB_DEVCELLS: the device recall stays settled */
typedef int juno_rr_compiled_out;
#endif
