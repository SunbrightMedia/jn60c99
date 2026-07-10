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
    e->tick_phase = 0.0; e->tick_counter = 0; e->next_step_tick = 0;
    e->off_tick = -1; e->running = 0; e->cur_note = -1; e->gate_closed = 0;
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

void carp_set_bpm(carp *e, double bpm)           { if (bpm > 0.0) e->bpm = bpm; }
void carp_set_division(carp *e, int rate_sw)     { e->division = rate_sw; }
void carp_set_rate_index(carp *e, int idx)       { if(idx<0)idx=0; if(idx>9)idx=9; e->rate_index=idx; }
void carp_set_gate_index(carp *e, int idx)       { if(idx<0)idx=0; if(idx>9)idx=9; e->gate_index=idx; }
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

    const double spp = sample_rate * 60.0 / (e->bpm * 24.0);   /* samples/tick */

    /* --- arp start: empty -> held (mirror sub_7FF91E01D810 LABEL_27) --------
     * schedule the first step at +3048 = +24 + 1 (the next whole tick). patStep
     * is implicitly -1: the first run_selector() call below is step 0. */
    if (e->count > 0 && !e->running) {
        e->running = 1;
        e->next_step_tick = e->tick_counter + 1;
    }

    /* --- all keys released (mirror sub_7FF91E01F2A0 / state 2->0) -----------
     * emit the trailing note-off, drop running; the tick grid keeps advancing
     * below so the next phrase re-quantizes to tick_counter+1. Zero sel_step,
     * oct_shift, oct_adv_flag — but NOT started / ud_dir (kept), so 2nd-and-later
     * phrases resume DOWN / UP&DOWN ordering exactly as the binary. */
    if (e->count == 0) {
        if (e->cur_note >= 0 && n < cap) {
            ev[n].kind = 0; ev[n].note = e->cur_note; ev[n].velocity = 0; n++;
        }
        e->cur_note = -1; e->off_tick = -1; e->running = 0;
        e->sel_step = 0; e->oct_shift = 0; e->oct_adv_flag = 0;
    }

    /* --- advance the free-running 24-PPQN tick clock by one sample ---------- */
    e->tick_phase += 1.0;
    if (e->tick_phase >= spp) {
        e->tick_phase -= spp;
        e->tick_counter++;

        /* (1) scheduled note-off first (plugin fires offs before step trigger) */
        if (e->cur_note >= 0 && !e->gate_closed &&
            e->off_tick >= 0 && e->tick_counter == e->off_tick) {
            if (n < cap) { ev[n].kind=0; ev[n].note=e->cur_note; ev[n].velocity=0; n++; }
            e->gate_closed = 1;
        }

        /* (2) step trigger: +24 == +3048 -> sub_7FF91E020260 */
        if (e->running && e->count > 0 && e->tick_counter == e->next_step_tick) {
            if (e->cur_note >= 0 && !e->gate_closed) {   /* gate>=step: force close */
                if (n < cap) { ev[n].kind=0; ev[n].note=e->cur_note; ev[n].velocity=0; n++; }
            }
            e->nslots = e->count;                        /* chord size            */
            int dur        = step_ticks(e);
            int gate_ticks = (dur * CARP_GATE_TABLE[e->gate_index]) / 100; /* as F3D0 */
            int base   = run_selector(e);                /* sorted note value     */
            int in_v   = e->per_note_vel[(unsigned)base & 0x7F]; /* a1+464[note]  */
            int pitch  = apply_octave_and_fold(e, base);
            int vel    = velocity_calc(e, in_v, in_v);
            e->cur_note = pitch; e->gate_closed = 0;
            e->off_tick = e->tick_counter + gate_ticks;  /* offTick = curTick+gateLen */
            e->next_step_tick += dur;                    /* +3048 += dur          */
            if (n < cap) { ev[n].kind=1; ev[n].note=pitch; ev[n].velocity=vel; n++; }
        }
    }
    return n;
}
