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
#include "ramp_cells.h"
#include <string.h>

/* The ramped setter's time table (rva 0x9DEB50, READ + EXECUTED: 16 floats);
 * its subdivision is the constant 10 (rva 0x3C2940). */
static const float RR_TIME_MS[16] = { 4.0f, 8.0f, 12.0f, 16.0f, 20.0f, 24.0f, 28.0f, 32.0f,
                                      36.0f, 40.0f, 48.0f, 56.0f, 64.0f, 72.0f, 80.0f, 96.0f };
enum { T4 = 0, T24 = 5, T36 = 8 };
#define RR_SUBDIV 10

/* The 73 recall-ramped cells, ascending (voice cells at stride
 * JUNO_VOICE_MAIN_STRIDE 10512, checked at compile time below). Every one is
 * a ramped cell of src/ramp_cells.h. */
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
#define RR_N ((int)(sizeof(RR_CELLS) / sizeof(RR_CELLS[0])))
typedef char rr_n_is_73[(RR_N == 73) ? 1 : -1];
typedef char rr_stride_is_10512[(JUNO_VOICE_MAIN_STRIDE == 10512) ? 1 : -1];
typedef char rr_table_fits[(JUNO_RR_BASE + 32u + 34u * JUNO_RAMP_N <= JUNO_VOICE_COUNT_CELL) ? 1 : -1];

/* The record table, port-owned memory at JUNO_RR_BASE (src/juno_engine.h): a
 * 32-byte header {magic, n_active, revtime, rev_on, tap2, arp_on, cut_last, tempo}, one record
 * per ramped cell (JUNO_RAMP_N, src/ramp_cells.h), then the active list (the
 * indices of the armed records, n_active of them). The records are
 * independent (each steps only its own cell), so the order the list holds
 * them in is free. */
typedef struct { float incr, accum, start, target; int32_t active, step; float pre; int32_t pad; } rr_rec;
#define RR_MAGIC 0x32525252
#define HDR(st, k) (*(int32_t *)((st) + JUNO_RR_BASE + 4u * (unsigned)(k)))
enum { H_MAGIC, H_NACT, H_REVTIME, H_REVON, H_TAP2, H_ARPON, H_CUTLAST, H_TEMPO };

static rr_rec *rec_at(unsigned char *st, int i)
{
    return (rr_rec *)(st + JUNO_RR_BASE + 32u + 32u * (unsigned)i);
}

static int16_t *act_list(unsigned char *st)
{
    return (int16_t *)(st + JUNO_RR_BASE + 32u + 32u * (unsigned)JUNO_RAMP_N);
}

static int index_of(uint32_t cell)
{
    int lo = 0, hi = JUNO_RAMP_N - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (JUNO_RAMP_CELL[mid] == cell) return mid;
        if (JUNO_RAMP_CELL[mid] < cell) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

/* the position of a recall-ramped cell in RR_CELLS */
static int rr_index(uint32_t cell)
{
    int lo = 0, hi = RR_N - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (RR_CELLS[mid] == cell) return mid;
        if (RR_CELLS[mid] < cell) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

/* The plugin's record state after build + setSampleRate + snap (EXECUTED for
 * every unit at five rates, probes/host/ramp_records_units.py): every record
 * inactive; the stored target equals the cell value, except the 86 records
 * the build never armed after its last immediate write, whose target is 0.0
 * (JUNO_RAMP_BUILD0). The recall role writes those cells immediately and
 * leaves the records alone, so a later host-role set early-outs against these
 * targets. The processor holds REVERB TIME 128 (the first TYPE arm is the
 * (type, 128) coefficient in all 22 cold census chains) and REVERB LEVEL off
 * (the first recall with a level >= 3 arms "on"). */
static void rr_seed(unsigned char *st)
{
    int i;
    for (i = 0; i < JUNO_RAMP_N; ++i) {
        rr_rec *r = rec_at(st, i);
        memset(r, 0, sizeof *r);
        r->target = JUNO_RAMP_BUILD0[i] ? 0.0f : JF(st, JUNO_RAMP_CELL[i]);
    }
    HDR(st, H_MAGIC) = RR_MAGIC;
    HDR(st, H_NACT) = 0;
    HDR(st, H_REVTIME) = 128;
    HDR(st, H_REVON) = 0;
    HDR(st, H_TAP2) = 0x3f008081;          /* 128/255: the build's (census job 236) */
    HDR(st, H_ARPON) = 0;
    HDR(st, H_CUTLAST) = 255;              /* the cutoff object's build value; every recall sets it */
    HDR(st, H_TEMPO) = 1280;               /* processor +1056, the tempo x 10 the build stores
                                            * (EXECUTED: probes/host_render/tempo_census.py) */
}

/* The DELAY TYPE 1 second instance's own copy of its tap time (CLAIMS B7):
 * the tap setter acts only at DELAY TYPE 1 (rva 0x3B91E0) and the instance
 * keeps the value; a later host switch of DELAY TYPE to 1 re-arms 4297792
 * twice with that kept value before the current one (EXECUTED: tap 33 at type
 * 1, tap 90 at type 0, switch -> arms 84/255, 84/255, 229/255;
 * scratchpad/probe_tap2.py). The recall writes it where it writes 4297792 by
 * the tap law (src/delay_recall.c). */
void juno_rr_note_tap2(unsigned char *st, float v)
{
    if (HDR(st, H_MAGIC) != RR_MAGIC) rr_seed(st);
    memcpy(&HDR(st, H_TAP2), &v, 4);
}

uint32_t juno_rr_tap2_bits(unsigned char *st) { return (uint32_t)HDR(st, H_TAP2); }

int juno_rr_rev_on(unsigned char *st) { return HDR(st, H_MAGIC) == RR_MAGIC ? (int)HDR(st, H_REVON) : 0; }

/* The processor's arpeggiator on-state (CLAIMS B7): set and cleared only by a
 * host ARPEGGIO SW edit; a patch recall leaves it (EXECUTED: after a host SW 1
 * and a recall of a record with SW 0, a host ARPEGGIO TYPE edit still runs the
 * arp refresh; scratchpad/probe_arp3.py). Build value 0. */
int juno_rr_arp_on(unsigned char *st) { return HDR(st, H_MAGIC) == RR_MAGIC ? (int)HDR(st, H_ARPON) : 0; }

void juno_rr_set_arp_on(unsigned char *st, int on)
{
    if (HDR(st, H_MAGIC) != RR_MAGIC) rr_seed(st);
    HDR(st, H_ARPON) = on != 0;
}

/* The VCF CUTOFF object's last value (+0x14 of the setter's object, rva
 * 0x3597F0): the step its host-role ramp time follows is |new - last|. Every
 * value the object takes stores there -- the recall's byte, a host VCF CUTOFF
 * byte, and a host VCF CUTOFF FREQ H value, whose float bits make the next
 * step "large" (EXECUTED: H 0.25 then 87 -> 90 ramps at index 5, not 6;
 * scratchpad/probe_cutH.py). CLAIMS A20. */
int juno_rr_cut_last(unsigned char *st) { return HDR(st, H_MAGIC) == RR_MAGIC ? (int)HDR(st, H_CUTLAST) : 255; }
/* The engine's tempo x 10 (processor +1056): the tempo entry (rva 0x3C7F10 ->
 * leaf 375, rva 0x3B9710) stores it; the LFO rate and the synced delay times of
 * every later recall and edit read it. */
int juno_rr_tempo(unsigned char *st) { return HDR(st, H_MAGIC) == RR_MAGIC ? (int)HDR(st, H_TEMPO) : 1280; }
void juno_rr_set_tempo(unsigned char *st, int t10)
{
    if (HDR(st, H_MAGIC) != RR_MAGIC) rr_seed(st);
    HDR(st, H_TEMPO) = t10;
}

void juno_rr_set_cut_last(unsigned char *st, int v)
{
    if (HDR(st, H_MAGIC) != RR_MAGIC) rr_seed(st);
    HDR(st, H_CUTLAST) = v;
}

/* The processor state a host-role edit takes from the settled copy (src/
 * host_edit.c): the REVERB TIME and REVERB LEVEL on-state it holds and the
 * tap copy. Records and the active list stay the live engine's. */
void juno_rr_copy_proc(unsigned char *dst, const unsigned char *src)
{
    unsigned char *s = (unsigned char *)src;
    if (HDR(s, H_MAGIC) != RR_MAGIC) return;
    if (HDR(dst, H_MAGIC) != RR_MAGIC) rr_seed(dst);
    HDR(dst, H_REVTIME) = HDR(s, H_REVTIME);
    HDR(dst, H_REVON) = HDR(s, H_REVON);
    HDR(dst, H_TAP2) = HDR(s, H_TAP2);
    HDR(dst, H_TEMPO) = HDR(s, H_TEMPO);
}


void juno_rr_reset(unsigned char *state) { HDR(state, H_MAGIC) = 0; }

/* One ramped set: the transcribed ramp start (src/juno_ramp.c, gated by
 * tools/verify/ramp_ab_gate.sh) on this cell's record; a record it arms
 * joins the active list. */
static void arm_rec(unsigned char *st, int i, float v, int t)
{
    rr_rec *r = rec_at(st, i);
    uint32_t cell = JUNO_RAMP_CELL[i];
    juno_ramp x;
    int was = r->active != 0;
    x.out = (float *)JCELL(st, cell);
    x.incr = r->incr; x.accum = r->accum; x.start = r->start; x.target = r->target;
    x.rate = JF(st, 16);                   /* the record's session rate: the host rate */
    x.active = r->active; x.subdiv = RR_SUBDIV; x.step_cnt = r->step;
    juno_ramp_start(&x, v, RR_TIME_MS[t & 15], RR_SUBDIV);
    r->incr = x.incr; r->accum = x.accum; r->start = x.start; r->target = x.target;
    r->active = x.active; r->step = x.step_cnt;
    if (!was && r->active) act_list(st)[HDR(st, H_NACT)++] = (int16_t)i;
}

static void arm(unsigned char *st, uint32_t cell, float v, int t)
{
    arm_rec(st, index_of(cell), v, t);
}

int juno_rr_arm(unsigned char *st, uint32_t cell, float v, int t)
{
    int i = index_of(cell);
    if (i < 0) return -1;
    if (HDR(st, H_MAGIC) != RR_MAGIC) rr_seed(st);
    arm_rec(st, i, v, t);
    return 0;
}

int juno_rr_is_ramped(uint32_t cell) { return index_of(cell) >= 0; }

void juno_rr_begin(unsigned char *state, juno_rr_ctx *c)
{
    int i;
    if (HDR(state, H_MAGIC) != RR_MAGIC) rr_seed(state);
    c->prev_etype = (int)JI(state, JUNO_PREV_EFX);
    c->prev_dtype = (int)JI(state, JUNO_PREV_DLY);
    c->prev_revtime = (int)HDR(state, H_REVTIME);
    c->prev_rev_on = (int)HDR(state, H_REVON);
    for (i = 0; i < RR_N; ++i) rec_at(state, index_of(RR_CELLS[i]))->pre = JF(state, RR_CELLS[i]);
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
        JF(st, RR_CELLS[i]) = rec_at(st, index_of(RR_CELLS[i]))->pre;
    }
#define FIN(cell) fin[rr_index(cell)]

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
    HDR(st, H_CUTLAST) = c->new_cutoff;
}

/* the harness snap (tools/verify/e2e_emu.py snap_all): every ACTIVE record
 * to its target, inactive records untouched */
void juno_rr_settle(unsigned char *st)
{
    int k, n;
    int16_t *L;
    if (HDR(st, H_MAGIC) != RR_MAGIC) return;
    L = act_list(st);
    n = HDR(st, H_NACT);
    for (k = 0; k < n; ++k) {
        rr_rec *r = rec_at(st, L[k]);
        JF(st, JUNO_RAMP_CELL[L[k]]) = r->target;
        r->accum = 0.0f;
        r->active = 0;
        r->step = 0;
    }
    HDR(st, H_NACT) = 0;
}

/* one sample: the plugin's pump (rva 0x3C24A0) after the DSP of the sample */
/* The engine unit a ramped cell belongs to, as the gates compare it: voice v's
 * main block and aux pair are unit v, everything else the master (unit 8). */
static int rr_unit(uint32_t cell)
{
    if (cell >= 176u && cell < 176u + 8u * JUNO_VOICE_MAIN_STRIDE) return (int)((cell - 176u) / JUNO_VOICE_MAIN_STRIDE);
    if (cell >= 101488u && cell < 101488u + 8u * 32u) return (int)((cell - 101488u) / 32u);
    return 8;
}

void juno_rr_pump(unsigned char *st)
{
    int k, nv;
    int16_t *L;
    if (HDR(st, H_MAGIC) != RR_MAGIC || HDR(st, H_NACT) <= 0) return;
    L = act_list(st);
    nv = juno_voice_count(st);
    for (k = 0; k < HDR(st, H_NACT); ) {
        rr_rec *r = rec_at(st, L[k]);
        juno_ramp x;
        int u = rr_unit(JUNO_RAMP_CELL[L[k]]);
        if (u < 8 && u >= nv) { ++k; continue; }   /* a unit the render does not run steps nothing (rva 0x3C7400) */
        x.out = (float *)JCELL(st, JUNO_RAMP_CELL[L[k]]);
        x.incr = r->incr; x.accum = r->accum; x.start = r->start; x.target = r->target;
        x.rate = JF(st, 16);
        x.active = r->active; x.subdiv = RR_SUBDIV; x.step_cnt = r->step;
        juno_ramp_step(&x);
        r->incr = x.incr; r->accum = x.accum; r->start = x.start; r->target = x.target;
        r->step = x.step_cnt;
        if (!x.active) {                   /* reached: leaves the list */
            r->active = 0;
            L[k] = L[--HDR(st, H_NACT)];
        } else {
            ++k;
        }
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
