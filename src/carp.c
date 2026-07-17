/* carp.c - Bit-exact C99 transcription of the JUNO-60 (JU-06A) arpeggiator.
 *
 * Each function below transcribes one decompiled routine; the RVA is given in
 * its header comment. Nothing here is a reconstruction: the note ordering,
 * octave folding, insertion sort, velocity math and rate/gate tables are
 * copied field-for-field from the binary. The only places that are NOT a pure
 * transcription are the top-level step clock (carp_tick) and the choice to run
 * one selector call per step -- both are explained in docs/ARP_PROVENANCE.md, which also
 * lists the parts of the decompile that are genuinely ambiguous.
 */
#include "carp.h"
#include "carp_patterns.h"      /* SCATTER pattern table (generated from the PE .rdata) */

static int step_ticks(const carp *e);   /* fwd: step period in 24-PPQN ticks */

/* ===================================================================== *
 *  Extracted data tables (raw bytes from the binary, .rdata section)
 * ===================================================================== */

/* RATE table  word_7FF91E6243B8  (RVA 0x9C43B8), 10 x 3 uint16:
 *   {even-step duration, odd-step duration, accent modulo}, durations in
 *   24-PPQN ticks. Note even==odd in every row, so the step length is a
 *   single constant per rate index. Read by sub_7FF91E01F3D0. */
const uint16_t CARP_RATE_TABLE[10][3] = {
    {24,24, 1}, {16,16, 1}, {12,12, 2}, { 8, 8, 3}, { 6, 6, 4},
    { 4, 4, 6}, { 3, 3, 8}, { 2, 2,12}, { 1, 1,16}, { 1, 1,24}
};

/* GATE table  word_7FF91E6243F8  (RVA 0x9C43F8), 10 uint16 = gate percent.
 *   Read by sub_7FF91E01F3D0 as v10; gate ticks = dur * v10 / 100.
 *   Index 8 = 120% (legato/overlap), index 9 = 0%. */
const uint16_t CARP_GATE_TABLE[10] = { 30,40,50,60,70,80,90,100,120,0 };

/* TYPE->selector map  word_7FF91E624458  (RVA 0x9C4458), 6 records x 6 bytes.
 *   Only byte[2] is used (it is copied to a1+3498 and passed to the selector
 *   dispatch sub_7FF91E01FCB0). Bytes 0,1 are always {1,2}; 3..5 are 0. */
const uint8_t CARP_TYPE_SELECTOR[6] = { 0, 20, 19, 19, 19, 19 };

/* ===================================================================== *
 *  Held-note list  (insertion sort, ascending)
 * ===================================================================== */

/* Transcribes the non-polyphonic (a1+3489 == 0) branch of
 * sub_7FF91E023440 @ 0x3C3440. On a genuinely new note it shifts every
 * already-sorted entry that is >= the new note up by one slot and inserts,
 * keeping sorted[] ascending. A re-press only bumps the per-note ref count. */
void carp_add_key(carp *e, int note, int velocity)
{
    if (note < 0 || note > 127) return;

    /* a1+208 press ref-count + a1+464 stored velocity (sub_7FF91E023440) */
    if (e->hold_count[note] != 0x7FFF) e->hold_count[note]++;
    e->per_note_vel[note] = (uint8_t)velocity;

    if (e->note_active[note])            /* v6 = (a1+3192[note] == 0) */
        return;                          /* already in list -> no insert */

    /* insertion sort (lines 2071..2088 of the decompile) */
    int v7 = e->count;                   /* v7 = *(a1+3320) */
    int v8 = v7;
    int v10 = 0;
    if (v7 > 0) {
        do {
            int v9 = e->sorted[v8 - 1];  /* *(char*)(a1+v8+3063) = sorted[v8-1] */
            if (v9 < note) break;
            e->sorted[v8] = (int8_t)v9;  /* *(char*)(a1+v8+3064) = sorted[v8] */
            v7--; v8--;
        } while (v8 > 0);
        v10 = v7;
    }
    e->sorted[v10] = (int8_t)note;       /* sorted[v10] = new note */
    e->note_active[note] = 1;            /* a1+3192[note] = 1 */
    e->count++;                          /* ++*(a1+3320) */
}

/* Transcribes sub_7FF91E01F2A0 @ 0x3BF2A0 (non-poly branch): decrement the
 * ref count; when it reaches 0 remove the note from sorted[] (shift down). */
void carp_remove_key(carp *e, int note)
{
    if (note < 0) {                      /* release everything */
        for (int i = 0; i < 128; i++) {
            e->note_active[i] = 0;
            e->hold_count[i] = 0;
        }
        e->count = 0;
        return;
    }
    if (note > 127 || !e->note_active[note]) return;
    if (e->hold_count[note] > 0) e->hold_count[note]--;
    if (e->hold_count[note] != 0) return;   /* still held elsewhere */

    /* find note in sorted[] and shift the tail down (sub_7FF91E01F2A0) */
    int idx = -1;
    for (int i = 0; i < e->count; i++)
        if (e->sorted[i] == note) { idx = i; break; }
    if (idx >= 0) {
        for (int j = idx; j < e->count - 1; j++)
            e->sorted[j] = e->sorted[j + 1];
        e->count--;
    }
    e->note_active[note] = 0;
}

/* ===================================================================== *
 *  Per-step note selectors  (function pointer a1+3480)
 *  Each returns a MIDI note value from sorted[]; UP leaves oct_shift to the
 *  step-trigger octave-advance, the octave-spanning selectors set oct_shift
 *  themselves and clear oct_adv_flag.
 * ===================================================================== */

/* selector 0 : UP  --  sub_7FF91E01EFC0 @ 0x3BEFC0 */
static int sel_up(carp *e)
{
    int count = e->count;                       /* v1 = *(a1+3320) */
    if (e->field56 > count - e->nslots) e->field56 = 0; /* a1+56 clamp */
    int v3 = e->sel_step;                        /* v3 = *(a1+3464) */
    if (v3 > count - 1) { e->sel_step = 0; v3 = 0; e->oct_adv_flag = 1; }
    if (v3 < 0)         { e->sel_step = 0; v3 = 0; }
    int v4 = e->started;                         /* v4 = *(a1+3460) */
    if (!v4)            { e->sel_step = 0; v3 = 0; }
    int result = e->sorted[v3];
    if (result < 0) result = e->sorted[count - 1];
    if (!v4) e->started = 1;
    e->sel_step = v3 + 1;
    return result;
}

/* selector 3 : DOWN (single octave)  --  sub_7FF91E01E6E0 @ 0x3BE6E0
 * (not reached by TYPE 0..5, but transcribed for completeness) */
static int sel_down(carp *e)
{
    int count = e->count;                        /* v3 */
    int nslots = e->nslots;                      /* v1 */
    int v7 = (count - nslots < 0) ? 0 : count - nslots;
    if (e->field56 > v7) e->field56 = 0;
    int v8 = e->sel_step;
    if (v8 > count - 1) { e->sel_step = 0; v8 = 0; e->oct_adv_flag = 1; }
    if (v8 < 0)         { e->sel_step = 0; v8 = 0; }
    int v9 = e->started;
    int v4 = 0;
    if (v9) v4 = count - v8 - 1;
    else    { e->sel_step = 0; v8 = 0; }
    int result = e->sorted[v4];
    if (result < 0) result = e->sorted[count - 1];
    if (!v9) e->started = 1;
    e->sel_step = v8 + 1;
    return result;
}

/* selector 20 : UP&DOWN  --  sub_7FF91E01E5C0 @ 0x3BE5C0
 * A bouncing ramp over indices 0..count*(range+1)-1. note = sorted[i%count],
 * oct_shift = i/count. Endpoints are played once (no doubling). */
static int sel_updown(carp *e)
{
    int count = e->count;                        /* v1 */
    int nslots = e->nslots;                      /* v2 */
    int v3 = count * (e->range + 1) - 1;         /* top index */
    int v6 = (count - nslots < 0) ? 0 : count - nslots;
    if (e->field56 > v6) e->field56 = 0;
    int v7 = e->started;                         /* v7 = *(a1+3460) */
    int v8, v9;
    if (v7) { v8 = e->sel_step; v9 = v8; }
    else    { e->sel_step = 0; v8 = 0; e->ud_dir = 1; v9 = 0; } /* a1+3461=1 */
    if (v8 > v3) { do { v8 = v9 - 1; v9 = v8; } while (v8 > v3); e->sel_step = v8; }
    if (v8 < 0)  { e->sel_step = 0; v8 = 0; }
    int v10 = e->sorted[v8 % count];
    e->oct_shift = v8 / count;                   /* a1+3472 = v8/count */
    if (v10 < 0) v10 = e->sorted[count - 1];
    if (!v7) e->started = 1;
    int dir = e->ud_dir;                         /* v11 = (*(a1+3461)==0) */
    e->oct_adv_flag = 0;                         /* a1+3468 = 0 */
    if (dir == 0) {                              /* going down */
        e->sel_step = v8 - 1;
        if (v8 - 1 <= 0) e->ud_dir = 1;
    } else {                                     /* going up */
        e->sel_step = v8 + 1;
        if (v8 + 1 >= v3) e->ud_dir = 0;
    }
    return v10;
}

/* selector 19 : DOWN across octaves  --  sub_7FF91E01E850 @ 0x3BE850
 * Index v9 descends from count*(range+1)-1 to 0 (wrapping back to the top).
 * note = sorted[v9%count], oct_shift = v9/count. */
static int sel_downoct(carp *e)
{
    int count = e->count;                        /* v1 */
    int nslots = e->nslots;                      /* v3 */
    int v4 = count * (e->range + 1) - 1;         /* top index */
    int v7 = (count - nslots < 0) ? 0 : count - nslots;
    if (e->field56 > v7) e->field56 = 0;
    int v8 = e->started;                         /* v8 = *(a1+3460) */
    int v9, v10;
    if (v8) { v9 = e->sel_step; v10 = v9; }
    else    { e->sel_step = v4; v9 = v4; v10 = v4; }   /* start at top */
    if (v9 > v4) { do { v9 = v10 - 1; v10 = v9; } while (v9 > v4); e->sel_step = v9; }
    if (v9 < 0)  { e->sel_step = 0; v9 = 0; }
    int v11 = e->sorted[v9 % count];
    e->oct_shift = v9 / count;                   /* a1+3472 = v9/count */
    if (v11 < 0) v11 = e->sorted[count - 1];
    if (!v8) e->started = 1;
    int v12 = v9 - 1;
    e->oct_adv_flag = 0;                         /* a1+3468 = 0 */
    if (v9 - 1 < 0) v12 = v4;                    /* wrap to top */
    e->sel_step = v12;
    return v11;
}

/* Dispatch on the resolved selector id (subset actually used by TYPE 0..5). */
static int run_selector(carp *e)
{
    switch (e->selector) {
        case 0:  return sel_up(e);
        case 3:  return sel_down(e);
        case 19: return sel_downoct(e);
        case 20: return sel_updown(e);
        default: return sel_up(e);
    }
}

/* ===================================================================== *
 *  Octave advance + pitch fold  (from step trigger sub_7FF91E020260,
 *  lines 173..204 @ 0x3C0260)
 * ===================================================================== */
static int apply_octave_and_fold(carp *e, int note)
{
    /* octave-advance request (only UP sets oct_adv_flag) */
    if (e->oct_adv_flag) {                        /* a1+3468 */
        int range = e->range;                     /* v20 = *(a1+3476) */
        if (range) {
            int os = e->oct_shift;                /* v21 = *(a1+3472) */
            e->oct_adv_flag = 0;
            if (range < 0) {                      /* negative (down) range */
                int v23 = os - 1;
                if (v23 < range) v23 = 0;
                e->oct_shift = v23;
            } else {                              /* positive range */
                int v22 = os + 1;
                e->oct_shift = v22;
                if (v22 > range) e->oct_shift = 0;
            }
        }
    }

    /* pitch = note + 12*oct_shift, folded back into [0,127] by whole octaves */
    int p = note + 12 * e->oct_shift;             /* v2 */
    if (p > 127) p = p - 12 - 12 * ((p - 128) / 12);
    if (p < 0)   p = p + 12 + 12 * ((~p) / 12);
    return p;
}

/* ===================================================================== *
 *  Velocity  (note-on override sub_7FF91E0235A0 @ 0x3C35A0)
 *    vel = (fixed ? fixed : per_note) * (127 - sens*(127-in)/100) / 127, min 1
 * ===================================================================== */
static int velocity_calc(carp *e, int in_vel, int per_note_vel)
{
    unsigned v4 = e->vel_fixed;                            /* a1+4052 */
    int v6 = (uint8_t)(127 - e->vel_sens * (127 - in_vel) / 100); /* a1+4051 */
    if (!v4) v4 = (unsigned)per_note_vel;                 /* fixed==0 -> a4 */
    unsigned v7 = v4 * (unsigned)v6 / 127;
    int v8 = (uint8_t)v7;
    if ((uint8_t)v7 == 0) v8 = 1;                         /* min 1 */
    return v8;
}

/* ===================================================================== *
 *  SCATTER pattern grid  (static .rdata block -> playable runtime grid)
 *  Ports the loader/expander/prune-sort/gate-fill chain; see
 *  scratchpad/oracle/arp_pattern_grid_spec.md (verified 330/330 vs plugin).
 * ===================================================================== */

/* Gate-length fill for ONE slot's step cells — transcribes sub_7FF91E01FED0.
 * cells[k] = grid velocity(bit0-6)|tie(bit7). Walks steps BACKWARD (wrapping) so
 * each active cell's gate = its base gateLen plus the duration of every following
 * tie-flagged cell before the next non-tie. dur / gateLen are the per-step
 * constants (RATE[rate][0] and GATE[gate]*dur/100, filled identically for every
 * step by F3D0). Faithful port of fed0_gates() in verify_grid.py. */
static void fed0_gates(const uint8_t *cells, int patLen, int dur, int gateLen,
                       uint16_t *gate)
{
    int v6, v8, v11, v12, v13;
    int k;
    for (k = 0; k < 32; ++k) gate[k] = 0;
    if (patLen <= 0) return;
    v6 = 0;
    while (v6 < patLen && (cells[v6] & 0x7F) == 0) ++v6;
    if (v6 >= patLen) return;                 /* LABEL_31: no active cell */
    v8 = v6; v11 = cells[v6]; v12 = 0; v13 = v6;
    for (;;) {
        int v19, v20, v22, v23;
        v13 = (v13 - 1 >= 0) ? v13 - 1 : patLen - 1;   /* decrement with wrap */
        v19 = cells[v13];
        v20 = ((int8_t)v11 >= 0) ? gateLen : dur;      /* prev cell a tie -> full dur */
        v22 = ((v19 & 0x7F) != 0) ? (v12 + v20) : 0;
        gate[v13] = (uint16_t)v22;
        v23 = ((v19 & 0x7F) == 0) ? v12 : 0;
        if (v20) {
            int v24 = v20 + v23; v12 = 0;
            if ((int8_t)v19 < 0) v12 = v24;            /* this cell is a tie -> carry back */
        } else {
            v12 = v23 + dur;
        }
        v11 = v19;
        if (v13 == v8) break;
    }
}

/* Recompute all 16 slots' gate lengths from the current rate/gate index (the
 * plugin re-runs F3D0+FED0 on a rate/gate change). Cheap; called on pattern load
 * and whenever the rate or gate index changes. */
static void rebuild_gates(carp *e)
{
    int dur     = step_ticks(e);
    int gateLen = (dur * (int)CARP_GATE_TABLE[e->gate_index]) / 100;
    int s;
    for (s = 0; s < 16; ++s)
        fed0_gates(e->grid_vel[s], e->pat_len, dur, gateLen, e->grid_gate[s]);
}

void carp_set_scatter(carp *e, int type, int depth)
{
    int slab = type  < 0 ? 0 : (type  > 9 ? 9 : type);
    int d    = depth < -7 ? -7 : (depth > 7 ? 7 : depth);
    int sub  = d + 7;                              /* SCATTER DEPTH+7 -> sub */
    const uint8_t *blk = carp_pattern_table
                       + (unsigned)CARP_PAT_SLAB_STRIDE * (unsigned)slab
                       + (unsigned)CARP_PAT_SUB_STRIDE  * (unsigned)sub;
    int patLen = blk[5] >> 2;                      /* header[5]>>2, clamp 1..32 */
    int sens   = blk[3] >> 1;                      /* header[3]>>1 (=100 for all) */
    int term = 16, s, k, gi;
    static const int GAPS[4] = { 8, 4, 2, 1 };
    if (patLen < 1) patLen = 1;
    if (patLen > 32) patLen = 32;

    e->scatter_type = slab; e->scatter_sub = sub;
    e->pat_len = patLen;    e->pat_sens = sens;

    /* --- expand sub_7FF91E01F9F0: per-slot base note + 32 step cells (transpose),
     *     stopping the slot list at the first base-note terminator (>=0x80). --- */
    for (s = 0; s < 16; ++s) {
        const uint8_t *g = blk + 6 + 34 * s;
        e->slot_note[s] = g[0];
        for (k = 0; k < 32; ++k) e->grid_vel[s][k] = g[1 + k];
    }
    for (s = 0; s < 16; ++s) if (e->slot_note[s] >= 0x80) { term = s; break; }
    for (s = term; s < 16; ++s) { e->slot_note[s] = 0x80; for (k = 0; k < 32; ++k) e->grid_vel[s][k] = 0; }

    /* --- prune+sort sub_7FF91E01D540 part 1: all-rest rows over [0,patLen) -> 0x80 --- */
    for (s = 0; s < 16; ++s) {
        if (e->slot_note[s] < 0x80) {
            int allrest = 1;
            for (k = 0; k < patLen; ++k) if (e->grid_vel[s][k] & 0x7F) { allrest = 0; break; }
            if (allrest) e->slot_note[s] = 0x80;
        }
    }
    /* --- part 2: shell sort (gaps 8,4,2,1) by UNSIGNED base note ascending,
     *     carrying each slot's grid row; deactivated slots (0x80) sink to the end. --- */
    for (gi = 0; gi < 4; ++gi) {
        int gap = GAPS[gi], j;
        for (j = gap; j < 16; ++j) {
            int i = j - gap;
            while (i >= 0) {
                if (e->slot_note[i] <= e->slot_note[i + gap]) break;
                { uint8_t tn = e->slot_note[i]; e->slot_note[i] = e->slot_note[i + gap]; e->slot_note[i + gap] = tn; }
                for (k = 0; k < patLen; ++k) {
                    uint8_t t = e->grid_vel[i][k];
                    e->grid_vel[i][k] = e->grid_vel[i + gap][k];
                    e->grid_vel[i + gap][k] = t;
                }
                i -= gap;
            }
        }
    }
    e->pat_nslots = 0;
    for (s = 0; s < 16; ++s) { if (e->slot_note[s] >= 0x80) break; ++e->pat_nslots; }

    /* reset per-slot voice tracking + pattern step; velocity uses the header sens */
    for (s = 0; s < 16; ++s) { e->slot_pitch[s] = -1; e->slot_noteidx[s] = 0; e->slot_offtick[s] = -1; }
    for (k = 0; k < 128; ++k) e->note_slot[k] = -1;
    e->pat_step  = -1;
    e->vel_sens  = (uint8_t)sens;
    rebuild_gates(e);
}

/* ===================================================================== *
 *  Configuration
 * ===================================================================== */
void carp_init(carp *e)
{
    for (int i = 0; i < 129; i++) e->sorted[i] = -1;
    e->count = 0;
    for (int i = 0; i < 128; i++) { e->note_active[i]=0; e->hold_count[i]=0; e->per_note_vel[i]=100; }
    e->field56 = 0;  e->nslots = 0;
    e->sel_step = 0; e->started = 0; e->ud_dir = 1;
    e->oct_adv_flag = 0; e->oct_shift = 0; e->range = 0;
    e->type = 0; e->selector = CARP_TYPE_SELECTOR[0];
    e->vel_fixed = 0; e->vel_sens = 0;
    /* Step clock: the real plugin ALWAYS steps by RATE_TABLE[rate_index] ticks
     * (step trigger sub_7FF91E020260: +3048 += *(u16*)(a1+6*step+610)); enabling the
     * arp forces rate_index = 4 (sub_7FF91E024F40 hard-codes cfg[7]=2 -> map{0,2,4,1,
     * 3,5}[2] + 0 = 4 -> RATE_TABLE[4] = 6 ticks = 1/16 at 120 BPM). The owner-clock
     * 12/24-tick divisor we previously used is the chord RE-LATCH quantizer, not the
     * step clock (see docs/ARP_PROVENANCE.md / scratchpad/oracle/arp_rate_findings.md).
     * gate_index 7 = 100% is the default sub-pattern header (0x1C>>2). */
    e->bpm = 120.0; e->division = 0; e->rate_index = 4; e->gate_index = 7;
    e->use_rate_table = 1;
    /* Free-running tick grid: phase/counter run on the transport, the first step
     * is scheduled at tick_counter+1 on empty->held (never at pos 0). */
    e->tick_acc = 0; e->tick_period = 1; e->tick_counter = 0; e->next_step_tick = 0;
    e->running = 0; e->beat_requant_armed = 0;
    /* Load the power-on SCATTER pattern (slab0/sub7): 1 slot, 1 step, velocity 127.
     * This is the proven default and collapses the step loop to the original
     * single-note-per-step behaviour. Sets the pattern/grid/slot state and vel_sens
     * (=100). Must come AFTER rate_index/gate_index are set above. */
    carp_set_scatter(e, 0, 0);
}

void carp_set_mode(carp *e, int type)
{
    if (type < 0) type = 0;
    if (type > 5) type = 5;
    e->type = type;
    e->selector = CARP_TYPE_SELECTOR[type];      /* word_9C4458[type].byte2 */
    /* re-arm the selector state so the new mode starts cleanly */
    e->started = 0; e->sel_step = 0; e->ud_dir = 1; e->oct_shift = 0; e->oct_adv_flag = 0;
}

/* ARPEGGIO STEP param (0..5) -> octave range (octaves-1). Binary-proven:
 * dispatch id 833 -> sub_7FF91E024F40 clamps min(step,2) -> CArpeggio+4076 ->
 * sub_7FF91E01FE60 stores it to +3476 (range), consumed by the selectors as octave
 * span. So {0,1,2,2,2,2} == min(step,2) is exact (arp_rate_findings.md §3). */
void carp_set_range(carp *e, int step)
{
    static const int MAP[6] = { 0, 1, 2, 2, 2, 2 };
    if (step < 0) step = 0;
    if (step > 5) step = 5;
    e->range = MAP[step];
}

/* Arm the one-shot beat-quantize re-latch (called when the arp is ENABLED, i.e.
 * the plugin controller SW method sets router+6). The next beat boundary consumes
 * it; see the re-latch block in carp_tick. */
void carp_arm_beat_requant(carp *e)              { e->beat_requant_armed = 1; }

void carp_set_bpm(carp *e, double bpm)           { if (bpm > 0.0) e->bpm = bpm; }
void carp_set_division(carp *e, int rate_sw)     { e->division = rate_sw; rebuild_gates(e); }
void carp_set_rate_index(carp *e, int idx)       { if(idx<0)idx=0; if(idx>9)idx=9; e->rate_index=idx; rebuild_gates(e); }
void carp_set_gate_index(carp *e, int idx)       { if(idx<0)idx=0; if(idx>9)idx=9; e->gate_index=idx; rebuild_gates(e); }
void carp_set_velocity(carp *e, int fixed, int sens)
{
    if (fixed < 0) fixed = 0;
    if (fixed > 127) fixed = 127;
    if (sens  < 0) sens  = 0;
    if (sens  > 100) sens  = 100;
    e->vel_fixed = (uint8_t)fixed; e->vel_sens = (uint8_t)sens;
}

/* ===================================================================== *
 *  Step clock
 *  Step period in 24-PPQN ticks:
 *    - default (use_rate_table==0): the decoded owner-clock divisor
 *        sub_7FF91E023C50 -> 24/(2-(division!=0)) = 12 or 24 ticks/step.
 *    - use_rate_table==1: RATE_TABLE[rate_index] (fine subdivision).
 *  1 tick = sample_rate*60/(bpm*24) samples.
 *  Gate length = dur * GATE_TABLE[gate_index] / 100 ticks (sub_7FF91E01F3D0).
 * ===================================================================== */
static int step_ticks(const carp *e)
{
    if (e->use_rate_table) return CARP_RATE_TABLE[e->rate_index][0];
    return 24 / (2 - (e->division != 0));        /* 12 (division==0) or 24 */
}

int carp_tick(carp *e, double sample_rate, carp_event *ev, int cap)
{
    int n = 0;
    if (sample_rate <= 0.0) sample_rate = 96000.0;

    /* Integer 24-PPQN tick period in 1e-9-sample units, matching the plugin's own
     * process clock (RVA 0x300000 loop, decompile line 27326):
     *   period = 60000000000 * SR / round(BPM) / 24   (integer division)
     * i.e. samples-per-tick x 1e9 truncated to an integer, with the tempo pre-rounded.
     * We accumulate 1e9 units per sample and fire a tick when the accumulator reaches
     * the period — sample-EXACT, unlike a float samples/tick (no sub-sample drift). */
    {
        long long bpmr = (long long)(e->bpm + 0.5);   /* round(BPM), bpm > 0 */
        if (bpmr < 1) bpmr = 1;
        e->tick_period = 60000000000LL * (long long)sample_rate / bpmr / 24LL;
        if (e->tick_period < 1) e->tick_period = 1;
    }

    /* --- arp start: empty -> held (mirror sub_7FF91E01D810 LABEL_27) --------
     * schedule the first step at +3048 = +24 + 1 (the next whole tick). patStep
     * is implicitly -1: the first run_selector() call below is step 0. */
    if (e->count > 0 && !e->running) {
        e->running = 1;
        e->next_step_tick = e->tick_counter + 1;
    }

    /* --- all keys released (mirror sub_7FF91E01F2A0 -> sub_7FF91E01D3A0) -----
     * The plugin handles the LAST key-release (no sustain) SYNCHRONOUSLY: F2A0
     * sets state +44 2->0 immediately and tail-calls the all-notes-off D3A0, which
     * offs only voice slots still SOUNDING (note < 0x80). There is NO tick-spanning
     * release tail in the no-sustain case (the +44=3 / +604 tail is a sustain-pedal-
     * only path; +48 is a dead counter). So emit a trailing off for every slot still
     * open (gate not yet closed); slots whose gate already closed emit nothing (no
     * spurious duplicate). Then go idle; the free clock keeps advancing so the next
     * phrase re-quantizes to tick_counter+1. Zero sel_step/oct_shift/oct_adv_flag;
     * keep started/ud_dir. See scratchpad/oracle/arp_release_fsm_spec.md (§5.1). */
    if (e->count == 0) {
        int s;
        for (s = 0; s < e->pat_nslots; ++s) {
            if (e->slot_pitch[s] >= 0) {
                if (n < cap) { ev[n].kind = 0; ev[n].note = e->slot_pitch[s]; ev[n].velocity = 64; n++; }
                e->note_slot[e->slot_noteidx[s] & 0x7F] = -1;
                e->slot_pitch[s] = -1;
            }
            e->slot_offtick[s] = -1;
        }
        e->running = 0;
        e->sel_step = 0; e->oct_shift = 0; e->oct_adv_flag = 0;
    }

    /* --- advance the free-running 24-PPQN tick clock by one sample ---------- */
    e->tick_acc += 1000000000LL;                     /* +1e9 units (= one sample) */
    if (e->tick_acc >= e->tick_period) {
        e->tick_acc -= e->tick_period;
        e->tick_counter++;

        /* --- beat-quantize re-latch (plugin sub_7FF91E023C50) --------------
         * The plugin arms a "changed" flag (router+6) when the arp is ENABLED,
         * and its per-tick re-latch consumes it exactly ONCE at the first beat
         * boundary (tick_counter % beat_div == 0, beat_div = 24/(2-(router+5!=0))
         * = 12 or 24). Consuming it re-feeds the held notes, which re-quantizes
         * the step grid to that beat: it forces a step to fire ON this tick
         * (next_step_tick = tick_counter) and restarts the pattern step
         * (pat_step = -1) WITHOUT resetting the selector index (the re-fed latch
         * re-selects the current position, so the on-beat step re-fires the
         * current note). One-time per enable; the flag is consumed even if no
         * note is held (then it has no audible effect). Proven bit-exact vs the
         * plugin's own arp under emulation (tools/verify/arp_sched_ab.py):
         * factory arp presets step 1,7,12,18,24... not the free-run 1,7,13,19.
         * NOT re-armed by later held-note changes (only by a fresh arp enable). */
        if (e->beat_requant_armed) {
            int beat_div = (e->division != 0) ? 24 : 12;
            if (e->tick_counter % beat_div == 0) {
                e->beat_requant_armed = 0;
                if (e->running && e->count > 0) {
                    /* Re-quantize the step clock to the beat: force a step to fire ON
                     * this tick with the CURRENT selector state (a normal advancing
                     * step, just one tick early). Proven vs the plugin: at the beat
                     * the selector state == the post-previous-step state, so the
                     * on-beat step advances it normally (UP&DOWN -> next octave note;
                     * UP with one held note -> re-fires the current note because its
                     * selector always wraps). Only the pattern step restarts. */
                    e->next_step_tick = e->tick_counter;   /* fire a step ON the beat */
                    e->pat_step = -1;                      /* restart the pattern step */
                    /* The beat re-latch also restarts the OCTAVE cycle: oct_shift -> 0
                     * (proven vs plugin: patch 1/49 UP arp, t12 entry oct==0 though the
                     * post-t7 value was 1). Harmless for the UP&DOWN / DOWN-octave
                     * selectors, which recompute oct_shift = sel/count each call; only
                     * the UP selector (which carries oct_shift across steps) is affected.
                     * sel_step is NOT reset — the selector index continues. */
                    e->oct_shift = 0; e->oct_adv_flag = 0;
                }
            }
        }

        /* (1) scheduled note-offs first (plugin fires offs before step trigger),
         * one per slot whose offTick == curTick. Plugin arp offs carry MIDI
         * velocity 64 (0x40), not 0 — inert for the JUNO voice path but faithful
         * to the emitted event stream. (per-tick handler body sub_7FF91E020960) */
        {
            int s;
            for (s = 0; s < e->pat_nslots; ++s) {
                if (e->slot_pitch[s] >= 0 && e->slot_offtick[s] >= 0 &&
                    e->tick_counter == e->slot_offtick[s]) {
                    if (n < cap) { ev[n].kind=0; ev[n].note=e->slot_pitch[s]; ev[n].velocity=64; n++; }
                    e->note_slot[e->slot_noteidx[s] & 0x7F] = -1;
                    e->slot_pitch[s] = -1;
                }
            }
        }

        /* (2) step trigger: +24 == +3048 -> sub_7FF91E020260. The step advances the
         * pattern step once, then walks the pruned/sorted slots 0..pat_nslots-1,
         * calling the selector once per ACTIVE cell (grid vel != 0). A note already
         * owned by an EARLIER slot is skipped (no retrigger); one owned by this-or-a-
         * LATER slot is stolen (off'd). The default slab0/sub7 (1 slot, 1 step, vel
         * 127) degenerates to exactly one selector call + one emit per step. */
        if (e->running && e->count > 0 && e->tick_counter == e->next_step_tick) {
            int dur = step_ticks(e);
            int s;
            e->pat_step += 1;
            if (e->pat_step >= e->pat_len) e->pat_step = 0;
            e->nslots = e->count;                        /* chord size (selector field56, inert) */
            e->next_step_tick += dur;                    /* +3048 += dur (constant step period)  */
            for (s = 0; s < e->pat_nslots; ++s) {
                int gv = e->grid_vel[s][e->pat_step] & 0x7F;
                int raw, owner, pitch, per, vel;
                if (gv == 0) continue;                   /* rest cell: selector NOT called */
                if (e->count == 0) continue;
                raw = run_selector(e);                   /* ADVANCES once per active cell */
                if (raw < 0) continue;
                owner = e->note_slot[raw & 0x7F];
                if (owner >= 0 && owner < s) continue;   /* voiced by an earlier slot -> skip */
                if (owner >= 0) {                        /* owner >= s -> steal it */
                    if (e->slot_pitch[owner] >= 0) {
                        if (n < cap) { ev[n].kind=0; ev[n].note=e->slot_pitch[owner]; ev[n].velocity=64; n++; }
                        e->note_slot[e->slot_noteidx[owner] & 0x7F] = -1;
                        e->slot_pitch[owner] = -1;
                    }
                }
                if (e->slot_pitch[s] >= 0) {             /* turn off THIS slot's old note (LABEL_16) */
                    if (n < cap) { ev[n].kind=0; ev[n].note=e->slot_pitch[s]; ev[n].velocity=64; n++; }
                    e->note_slot[e->slot_noteidx[s] & 0x7F] = -1;
                    e->slot_pitch[s] = -1;
                }
                pitch = apply_octave_and_fold(e, raw);   /* octave-advance (UP) + fold, when playing */
                e->note_slot[raw & 0x7F] = (int8_t)s;
                e->slot_noteidx[s] = raw;
                e->slot_pitch[s]   = pitch;
                e->slot_offtick[s] = e->tick_counter + e->grid_gate[s][e->pat_step];
                per = e->per_note_vel[(unsigned)raw & 0x7F];
                vel = velocity_calc(e, gv, per);         /* a3=gridVel, a4=per, sens=pat_sens */
                if (n < cap) { ev[n].kind=1; ev[n].note=pitch; ev[n].velocity=vel; n++; }
            }
        }
    }
    return n;
}
