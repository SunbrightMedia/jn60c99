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
static void set_rate_gate(carp *e, int rate, int gate);   /* fwd: rva 0x3BF3D0's indices */

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

/* Key-on into the arp: rva 0x3C3440 (sets the clock flag +197, then jumps to
 * 0x3BF190), non-polyphonic (a1+3489 == 0) branch. The press count (+208, 15
 * bits) saturates at 0x7FFF; +200 counts presses, +204 keys with a count; a new
 * key goes into the ascending list by insertion (every entry >= the note moves
 * up one) and becomes +3452, the last note. A re-press only bumps its count. */
void carp_add_key(carp *e, int note, int velocity)
{
    uint16_t was;
    int v7, v8;
    if (note < 0 || note > 127) return;
    e->clk_on = 1;                                   /* +197 = 1             */
    was = e->hold_count[note];
    if ((was & 0x7FFF) == 0x7FFF) return;
    e->hold_count[note] = (uint16_t)((was & 0x7FFF) + 1);
    e->presses++;                                    /* ++*(a1+200)          */
    if (!was) e->keys204++;                          /* ++*(a1+204)          */
    e->per_note_vel[note] = (uint8_t)velocity;       /* a1+464[note]         */
    if (e->note_active[note]) return;                /* a1+3192[note]        */
    v7 = e->count;
    v8 = v7;
    if (v7 > 0) {
        do {
            int v9 = e->sorted[v8 - 1];
            if (v9 < note) break;
            e->sorted[v8] = (int8_t)v9;
            v7--; v8--;
        } while (v8 > 0);
    }
    e->sorted[v7] = (int8_t)note;
    e->note_active[note] = 1;
    e->count++;                                      /* ++*(a1+3320)         */
    e->last_note = note;                             /* a1+3452              */
}

/* all-notes-off, rva 0x3BD3A0: every slot still sounding gets a note-off at
 * velocity 64 and is freed (slots in order 0..15). */
static int all_off(carp *e, carp_event *ev, int cap)
{
    int s, n = 0;
    for (s = 0; s < 16; ++s) {
        if (e->slot_pitch[s] >= 0) {
            if (n < cap) { ev[n].kind = 0; ev[n].note = e->slot_pitch[s]; ev[n].velocity = 64; n++; }
            e->note_slot[e->slot_noteidx[s] & 0x7F] = -1;
            e->slot_pitch[s] = -1;
        }
    }
    return n;
}

/* Key-off from the arp: rva 0x3BF110 (the press count, OR-ed with the sustain
 * word +592) then, when the count reaches 0, rva 0x3BF2A0 (non-poly branch): the
 * key leaves the ascending list (entries above it move down), +3452 becomes the
 * top note, and when no key is left the selector resets (+3464, +3472, +3468)
 * and -- with no sustain and the arp running (+44 in 1..3) -- the arp goes idle
 * and every sounding arp note is turned off (rva 0x3BD3A0), synchronously. */
int carp_key_off(carp *e, int note, carp_event *ev, int cap)
{
    int n = 0, cnt;
    uint16_t r;
    if (note < 0 || note > 127) return 0;
    r = (uint16_t)(e->hold_count[note] & 0x7FFF);
    if (!r) return 0;
    e->hold_count[note] = (uint16_t)(e->sustain | (r - 1));
    e->presses--;
    if (e->hold_count[note]) return 0;
    if (e->keys204) e->keys204--;
    if (!e->note_active[note]) return 0;
    cnt = e->count - 1;                              /* *(a1+3320) = v3 - 1   */
    e->count = cnt;
    if (cnt >= 0) {
        int k = cnt, v4 = -1;
        do {
            int v6 = e->sorted[k];
            e->sorted[k] = (int8_t)v4;
            v4 = v6;
            if (v6 == note) break;
            --k;
        } while (k >= 0);
    }
    e->note_active[note] = 0;
    e->last_note = cnt <= 0 ? -1 : e->sorted[cnt - 1];
    if (cnt <= 0) {
        e->sel_step = 0; e->oct_shift = 0; e->oct_adv_flag = 0;
        if (!cnt && !e->sustain && !e->keys204 && e->state >= 1 && e->state <= 3) {
            e->state = 0;
            n += all_off(e, ev + n, cap - n);
        }
    }
    return n;
}

/* The arp's reset, rva 0x3BDAA0: while running, idle + all notes off; then the
 * press counts, the list and the slot map cleared. */
static int arp_reset(carp *e, carp_event *ev, int cap)
{
    int n = 0, i;
    if (e->state >= 1 && e->state <= 3) { e->state = 0; n += all_off(e, ev, cap); }
    for (i = 0; i < 128; ++i) { e->hold_count[i] = 0; e->note_active[i] = 0; e->note_slot[i] = -1; }
    for (i = 0; i < 129; ++i) e->sorted[i] = -1;
    e->presses = 0; e->keys204 = 0;                  /* *(qword*)(a1+200) = 0 */
    e->sustain = 0;                                  /* *(dword*)(a1+592) = 0 */
    e->count = 0;                                    /* a1+3320               */
    e->last_note = -1;                               /* a1+3452               */
    return n;
}

/* The arp's switch, rva 0x3BE3B0: only a change acts; off goes idle (all
 * notes off while running) and resets (rva 0x3BDAA0); on only sets +10. */
int carp_disable(carp *e, carp_event *ev, int cap)
{
    int n = 0;
    if (!e->enabled) return 0;
    if (e->state >= 1 && e->state <= 3) { e->state = 0; n += all_off(e, ev, cap); }
    n += arp_reset(e, ev + n, cap - n);
    e->enabled = 0;
    return n;
}

void carp_enable(carp *e) { e->enabled = 1; }

/* Bare list removal for the recall model's toggle (note < 0 releases every
 * key): no events; the recall flushes the voices itself. */
void carp_remove_key(carp *e, int note)
{
    carp_event dummy[16];
    if (note < 0) { arp_reset(e, dummy, 0); e->state = 0; return; }
    carp_key_off(e, note, dummy, 0);
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
    if (e->field56 > count - e->pat_nslots) e->field56 = 0; /* a1+56 clamp vs (char)+3054 */
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
    int nslots = e->pat_nslots;                  /* v1 = (char)+3054 */
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
    int nslots = e->pat_nslots;                  /* v2 = (char)+3054 */
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
    int nslots = e->pat_nslots;                  /* v3 = (char)+3054 */
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

static const uint8_t *pattern_block(int slab, int sub)
{
    return carp_pattern_table + (unsigned)CARP_PAT_SLAB_STRIDE * (unsigned)slab
                              + (unsigned)CARP_PAT_SUB_STRIDE  * (unsigned)sub;
}

/* The expand, rva 0x3BF9F0, of the block (slab, sub): the slot table reset first
 * (rva 0x3BDD80: every slot's base note and sounding pitch to 0x80, the grid
 * cleared; the note map, the slots' raw notes and off ticks stay), the length
 * (header[5] >> 2, at most 32; every block of the table holds 1..31), the slots
 * up to the first base note >= 0x80, then the prune and sort (rva 0x3BD540). */
static void pattern_expand(carp *e, int slab, int sub)
{
    const uint8_t *blk = pattern_block(slab, sub);
    int patLen = blk[5] >> 2;
    int term = 16, s, k, gi;
    static const int GAPS[4] = { 8, 4, 2, 1 };
    if (patLen > 32) patLen = 32;

    e->scatter_type = slab; e->scatter_sub = sub;
    e->pat_len = patLen;    e->pat_sens = blk[3] >> 1;
    for (s = 0; s < 16; ++s) e->slot_pitch[s] = -1;

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
}

/* An immediate pattern load (carp_init, tests): the expand, the gate fill and a
 * clean slot table. The plugin's own loads go through the apply's request and
 * the reload at the next step (carp_ctl_config). */
void carp_set_scatter(carp *e, int type, int depth)
{
    int slab = type  < 0 ? 0 : (type  > 9 ? 9 : type);
    int d    = depth < -7 ? -7 : (depth > 7 ? 7 : depth);
    int s, k;
    pattern_expand(e, slab, d + 7);                /* SCATTER DEPTH+7 -> sub */
    for (s = 0; s < 16; ++s) { e->slot_noteidx[s] = 0; e->slot_offtick[s] = -1; }
    for (k = 0; k < 128; ++k) e->note_slot[k] = -1;
    e->pat_step  = -1;
    e->vel_sens  = (uint8_t)e->pat_sens;
    rebuild_gates(e);
}

/* ===================================================================== *
 *  Configuration
 * ===================================================================== */
/* The arp as the build leaves it: the constructor (rva 0x3BD270: the selector
 * index 0, "started" 0, UP&DOWN direction up, the octave state 0) and the init
 * (rva 0x3BE2F0: the reset, the counters 0, the CLOCK FLAG +197 SET, +600 = 1,
 * no pattern -- length 1, every slot empty (rva 0x3BF8B0 with no block) --, the
 * step table for rate 5 / gate 2, the UP selector). PROVEN in the booted plugin
 * (probes/host_render/diag_driver.py: +197 = 1 and +20 counting before any key).
 * Nothing plays before the first switch-on: its config requests the pattern,
 * sets rate 4 / gate 7 / sensitivity 100 and arms the beat re-latch. */
void carp_init(carp *e)
{
    int s, k;
    for (int i = 0; i < 129; i++) e->sorted[i] = -1;
    e->count = 0;
    for (int i = 0; i < 128; i++) { e->note_active[i]=0; e->hold_count[i]=0; e->per_note_vel[i]=100; }
    e->field52 = 0;  e->field56 = 0;
    e->sel_step = 0; e->started = 0; e->ud_dir = 1;
    e->oct_adv_flag = 0; e->oct_shift = 0; e->range = 0;
    e->type = 0; e->selector = CARP_TYPE_SELECTOR[0];
    e->vel_fixed = 0; e->vel_sens = 0;
    /* the step clock: RATE_TABLE[rate_index] ticks per step (the step trigger,
     * rva 0x3C0260: +3048 += the step table's length); the init's table is rate 5,
     * gate 2 (rva 0x3BF3D0 with 5, 2); the first config makes it rate 4 (mode 2:
     * {0,2,4,1,3,5}[2]), gate 7 (every pattern header: 0x1C >> 2) */
    e->division = 0;
    set_rate_gate(e, 5, 2);
    e->use_rate_table = 1;
    e->kb_ctr = 0; e->beat_requant_armed = 0; e->clk_on = 1;
    e->clk20 = 0; e->tick_counter = 0; e->next_step_tick = 0; e->state = 0;
    e->presses = 0; e->keys204 = 0; e->last_note = -1; e->sustain = 0;
    e->countdown48 = 0; e->field52 = 0; e->field60 = -1; e->field64 = -1;
    e->tail600 = 1; e->tail604 = 0; e->flag608 = 0;
    /* no pattern: length 1, no slot, the step index 0 */
    e->scatter_type = 0; e->scatter_sub = 0;
    e->pat_len = 1; e->pat_nslots = 0; e->pat_step = 0; e->pat_sens = 0;
    for (s = 0; s < 16; ++s) {
        e->slot_note[s] = 0x80; e->slot_pitch[s] = -1; e->slot_noteidx[s] = 0; e->slot_offtick[s] = 0;
        for (k = 0; k < 32; ++k) { e->grid_vel[s][k] = 0; e->grid_gate[s][k] = 0; }
    }
    for (k = 0; k < 128; ++k) e->note_slot[k] = -1;
    /* the controller and its apply object as the build leaves them (PROVEN) */
    e->ctl_on = 0; e->ctl_type = 0; e->ctl_step = 0; e->ctl_depth = 0; e->ctl_stype = 0;
    e->ap_type = -1; e->ap_mode = -1; e->ap_slab = 0; e->ap_sub = 7;
    e->enabled = 0;
    e->step4076 = 0; e->range4050 = 0; e->rate4047 = 0; e->gate4049 = 0;
    e->pat_reload = 0; e->pend_slab = 0; e->pend_sub = 7;
}

/* The selector for a TYPE (rva 0x3BFCB0 with the type record's byte 2): the
 * selector function only. The selector's index, its "started" flag and the
 * UP&DOWN direction stay (PROVEN, probes/host_render/arp_cfg_probe.py). */
void carp_set_mode(carp *e, int type)
{
    if (type < 0) type = 0;
    if (type > 5) type = 5;
    e->type = type;
    e->selector = CARP_TYPE_SELECTOR[type];      /* word_9C4458[type].byte2 */
}

/* ARPEGGIO STEP param (0..5) -> octave range (octaves-1), as rva 0x3BFE60 sets it:
 * the octave offset cleared, the range stored. The config (rva 0x3C4F40) clamps
 * the STEP to 2 first, so {0,1,2,2,2,2} == min(step,2). */
void carp_set_range(carp *e, int step)
{
    static const int MAP[6] = { 0, 1, 2, 2, 2, 2 };
    if (step < 0) step = 0;
    if (step > 5) step = 5;
    e->oct_shift = 0;
    e->range = MAP[step];
}

/* ===================================================================== *
 *  The controller's apply (rva 0x3C0EC0) and its CArpeggio setters
 * ===================================================================== */

/* rva 0x3BF3D0's indices: the rate (+12) and the gate (+16), each clamped to
 * 0..9. Its per-step table feeds the step length (read at every step) and the
 * grid's gate lengths (the fill at the next reload, rebuild_gates). */
static void set_rate_gate(carp *e, int rate, int gate)
{
    e->rate_index = rate < 0 ? 0 : (rate >= 10 ? 9 : rate);
    e->gate_index = gate < 0 ? 0 : (gate >= 10 ? 9 : gate);
}

/* The pattern request, rva 0x3C3010 (with rva 0x3BF9C0): the block (slab, sub)
 * becomes the one the next step expands (+32, +40 = 1), and a step index at or
 * past the OLD length is taken modulo it; the rate (+4047) and the block's gate
 * (header[1] >> 2) into the step table; the selector of the type record; the
 * octave offset cleared and the range set from +4076 (rva 0x3BFE60); then the
 * record's fixed velocity (byte 5: 0 in every record) and the block's velocity
 * sensitivity (header[3] >> 1). */
static void pattern_request(carp *e, int type, int slab, int sub)
{
    const uint8_t *blk = pattern_block(slab, sub);
    int gate = blk[1] >> 2;
    e->pend_slab = slab; e->pend_sub = sub;
    e->pat_reload = 1;
    if (e->pat_step >= e->pat_len) e->pat_step %= e->pat_len;
    set_rate_gate(e, e->rate4047, gate);
    carp_set_mode(e, type);
    e->oct_shift = 0;
    e->range = e->step4076;
    e->gate4049 = gate;
    e->range4050 = e->step4076 & 0xFF;
    e->vel_fixed = 0;
    e->vel_sens = (uint8_t)(blk[3] >> 1);
}

/* The apply, rva 0x3C0EC0: nothing until TYPE, rate mode, SCATTER TYPE and
 * DEPTH are all set (-1, -1, -1, -8 from the constructor); then the pattern
 * request, the rate mode (rva 0x3C34F0: {0,2,4,1,3,5}[mode] plus the table's
 * rate delta, not below 0), the range delta (rva 0x3C34C0: +4050 += the delta
 * clamped to -4..4, the octave offset cleared and the range = (signed) +4050),
 * the seven values for dispatch 312..318 (the engine's side: src/host_edit.c),
 * the keyboard's beat (+5, rva 0x3C4590: {0,0,0,1,1,1}[mode]), and, when
 * `arm`, the beat re-latch (+6). Table: [150 * slab + 15 * k + sub]. */
static void ctl_apply(carp *e, int arm)
{
    static const uint8_t RATE_OF_MODE[6] = { 0, 2, 4, 1, 3, 5 };
    static const uint8_t BEAT_OF_MODE[6] = { 0, 0, 0, 1, 1, 1 };
    const int32_t *t;
    int m, r, d;
    if (e->ap_type == -1 || e->ap_mode == -1 || e->ap_slab == -1 || e->ap_sub == -8) return;
    t = carp_apply_table + 150 * e->ap_slab + e->ap_sub;
    pattern_request(e, e->ap_type, e->ap_slab, e->ap_sub);
    m = e->ap_mode < 0 ? 0 : (e->ap_mode >= 6 ? 5 : e->ap_mode);
    r = RATE_OF_MODE[m] + t[105];
    e->rate4047 = r < 0 ? 0 : (r & 0xFF);
    set_rate_gate(e, e->rate4047, e->gate4049);
    d = t[135];
    if (d > 4) d = 4;
    if (d < -4) d = -4;
    e->range4050 = (e->range4050 + d) & 0xFF;
    e->oct_shift = 0;
    e->range = (int8_t)e->range4050;
    e->division = BEAT_OF_MODE[m];
    if (arm) e->beat_requant_armed = 1;
}

void carp_ctl_config(carp *e)
{
    int ty = e->ctl_type < 2 ? e->ctl_type : 2;
    int st = e->ctl_step < 2 ? e->ctl_step : 2;
    e->ctl_type = ty;
    e->ctl_step = st;
    if (e->ap_type != (ty & 0xFF)) { e->ap_type = ty & 0xFF; ctl_apply(e, 0); }
    e->step4076 = st & 0xFF;
    ctl_apply(e, 0);
    if (e->ap_mode != 2) { e->ap_mode = 2; ctl_apply(e, 1); }
    e->division = 0;                                 /* rva 0x3C4590 with mode 2 */
}

void carp_ctl_scatter_type(carp *e, int v, int force)
{
    if ((unsigned)v > 9 || (e->ctl_stype == v && !force)) return;
    e->ctl_stype = v;
    if (e->ap_slab != (v & 0xFF)) { e->ap_slab = v & 0xFF; ctl_apply(e, 0); }
}

void carp_ctl_scatter_depth(carp *e, int v, int force)
{
    int sub;
    if ((unsigned)(v + 7) > 14u || (e->ctl_depth == v && !force)) return;
    e->ctl_depth = v;
    sub = (int8_t)v + 7;
    if (e->ap_sub != sub) { e->ap_sub = sub; ctl_apply(e, 0); }
}

/* Arm the one-shot beat-quantize re-latch (called when the arp is ENABLED, i.e.
 * the plugin controller SW method sets router+6). The next beat boundary consumes
 * it; see the re-latch block in carp_tick. */
void carp_arm_beat_requant(carp *e)              { e->beat_requant_armed = 1; }

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

/* The step trigger, rva 0x3C0260: one pattern step -- the selector once per
 * active grid cell, steals and self-offs first, then the note-on. */
static int step_trigger(carp *e, carp_event *ev, int cap)
{
    int n = 0;
    {
            int dur = step_ticks(e);
            int s;
            e->pat_step += 1;
            if (e->pat_step >= e->pat_len) {             /* a pattern pass: +52 and +56 count it */
                e->pat_step = 0;
                e->field52++;
                e->field56++;
            }
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
    return n;
}

/* The keyboard object's beat re-latch, rva 0x3C3C50, when it fires: every key
 * the arp holds is released (rva 0x3C3A20: each key off through 0x3BF110, the
 * last one's synchronous release turning the sounding notes off, then the reset
 * 0x3BDAA0), handed back in again with the keyboard's velocity (rva 0x3C3440),
 * and the selector index taken before is restored with "started" set (rva
 * 0x3C34B0). No engine path latches keys (+532), so only the held keys return. */
static int relatch(carp *e, const uint8_t *kb_vel, carp_event *ev, int cap)
{
    int n = 0, k, nk = 0;
    int keys[128];
    unsigned char sel = (unsigned char)e->sel_step;  /* rva 0x3C3000: a byte  */
    for (k = 0; k < e->count; ++k) keys[nk++] = e->sorted[k];
    for (k = 0; k < nk; ++k)                         /* rva 0x3C3A20: one key-off each, ascending */
        n += carp_key_off(e, keys[k], ev + n, cap - n);
    n += arp_reset(e, ev + n, cap - n);
    for (k = 0; k < nk; ++k) carp_add_key(e, keys[k], kb_vel ? kb_vel[keys[k]] : e->per_note_vel[keys[k]]);
    e->sel_step = sel;                               /* rva 0x3C34B0          */
    e->started = 1;
    return n;
}

/* One engine tick (CWaveGen vt+184, rva 0x3C6750) for one unit. */
int carp_engine_tick(carp *e, const uint8_t *kb_vel, carp_event *ev, int cap)
{
    int n = 0;
    /* the keyboard object: its counter, then its beat re-latch (rva 0x3C3C50):
     * armed (+6) and the counter on a beat of 24 / (2 - (+5 != 0)) ticks */
    e->kb_ctr++;
    if (e->beat_requant_armed && e->kb_ctr % (unsigned)(24 / (2 - (e->division != 0))) == 0) {
        e->beat_requant_armed = 0;
        n += relatch(e, kb_vel, ev + n, cap - n);
    }
    /* the arp, rva 0x3BDEA0, transcribed whole: +48 counts down; idle with keys
     * starts (LABEL_27: the first step at the next tick, +3048 = +24 + 1, the
     * octave pass and the pattern step reset); states 1 and 3 and the no-key
     * branch of 2 need the sustain word or the hold count, which no engine path
     * sets (+592, and +204 above the key count) */
    {
        int keys = e->count || e->sustain || e->keys204;
        int v1 = e->countdown48;
        int start = 0;
        if (v1) e->countdown48 = --v1;
        switch (e->state) {
        case 0:
            start = keys;
            break;
        case 1:
            if (!keys) { e->state = 0; n += all_off(e, ev + n, cap - n); }
            else if (!v1) start = 1;
            break;
        case 2:
            if (!keys) {
                e->tail604 = e->tail600;
                if (!e->flag608) n += all_off(e, ev + n, cap - n);
                e->state = 3;
            }
            break;
        case 3:
            if (!keys) {
                if (!e->tail604) e->tail604 = -1;
                else { e->state = 0; n += all_off(e, ev + n, cap - n); }
            } else {
                e->state = 2;
            }
            break;
        default:
            break;
        }
        if (start) {
            e->next_step_tick = e->tick_counter + 1;
            e->field52 = 0; e->field56 = 0;          /* *(qword*)(a1+52) = 0  */
            e->field60 = -1; e->field64 = -1;        /* *(qword*)(a1+60) = -1 */
            e->pat_step = -1;                        /* a1+3056               */
            e->state = 2;
        }
    }
    /* +197: the counters run; while running, +24 walks up to +20 one tick at a
     * time -- the slots whose note-off falls on it first, then the step */
    if (e->clk_on) {
        e->clk20++;
        if (e->state < 2) {
            e->tick_counter = e->clk20;
        } else {
            while (e->tick_counter != e->clk20) {
                int s;
                e->tick_counter++;
                for (s = 0; s < e->pat_nslots; ++s) {
                    if (e->slot_pitch[s] >= 0 && e->slot_offtick[s] == e->tick_counter) {
                        if (n < cap) { ev[n].kind = 0; ev[n].note = e->slot_pitch[s]; ev[n].velocity = 64; n++; }
                        e->note_slot[e->slot_noteidx[s] & 0x7F] = -1;
                        e->slot_pitch[s] = -1;
                    }
                }
                if (e->tick_counter == e->next_step_tick) {
                    /* a pending pattern reload first (rva 0x3C07E0): while
                     * running, every slot's note off (the state 0 meanwhile,
                     * then back), the expand and the gate fill (rva 0x3BFED0) */
                    if (e->pat_reload) {
                        int st = e->state;
                        if (st >= 1 && st <= 3) { e->state = 0; n += all_off(e, ev + n, cap - n); }
                        e->state = st;
                        pattern_expand(e, e->pend_slab, e->pend_sub);
                        rebuild_gates(e);
                        e->pat_reload = 0;
                    }
                    n += step_trigger(e, ev + n, cap - n);
                }
            }
        }
    }
    return n;
}
