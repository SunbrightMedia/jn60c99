/* carp.h - Bit-exact C99 transcription of the Roland JUNO-60 (JU-06A) VST3
 * keyboard arpeggiator (CKbdArp / CArpeggio).
 *
 * Ground truth: the decompiled plugin binary only. Every field carries its
 * source RVA / object offset. See docs/ARP_PROVENANCE.md for the full derivation and
 * for the parts that remain genuinely ambiguous in the decompile.
 *
 * Binary: aea4b19d-JUNO60VST3_64bit.vst3  (PE ImageBase 0x180000000)
 * Decompile rebase: 0x7FF91DC60000  (so symbol sub_7FF91E0xxxxx has
 *                   RVA = 0x7FF91E0xxxxx - 0x7FF91DC60000).
 */
#ifndef CARP_H
#define CARP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- arpeggio TYPE (ARPEGGIO TYPE param, stored 0..5) -------------------
 * Value -> selector, via table word_9C4458[type].byte2 (extracted, see .c):
 *   0        -> selector 0  = sub_7FF91E01EFC0  (UP, ascending)
 *   1        -> selector 20 = sub_7FF91E01E5C0  (UP&DOWN, bouncing)
 *   2,3,4,5  -> selector 19 = sub_7FF91E01E850  (DOWN across octaves)
 */
enum {
    CARP_TYPE_UP      = 0,
    CARP_TYPE_UPDOWN  = 1,
    CARP_TYPE_DOWN    = 2   /* 2..5 all map to selector 19 */
};

/* Event returned by carp_tick(). */
typedef struct {
    int kind;      /* 0 = note-off, 1 = note-on            */
    int note;      /* MIDI note 0..127                     */
    int velocity;  /* 1..127 (note-on); 0 for note-off     */
} carp_event;

/* Full engine state. All fields annotated with the CArpeggio object offset
 * (a1 + N) they transcribe, or the RVA of the table/formula they come from. */
typedef struct {
    /* ---- held-note pitch-sorted-ascending list (insertion sort
     *      sub_7FF91E023440 / removal sub_7FF91E01F2A0) --------------- */
    int8_t  sorted[129];        /* a1+3064 : notes, ascending; [count-1] top */
    int     count;              /* a1+3320 : number of held notes            */
    uint8_t note_active[128];   /* a1+3192 : 1 while a note is held           */
    uint16_t hold_count[128];   /* a1+208  : press ref-count per note         */
    uint8_t per_note_vel[128];  /* a1+464  : velocity a note was pressed with */

    /* ---- selector / octave state ------------------------------------ */
    int     field56;            /* a1+56   : octave-pass counter (clamped)    */
    int     nslots;             /* a1+3054 : active slot count (chord size)   */
    int     sel_step;           /* a1+3464 : selector running index           */
    int     started;           /* a1+3460 : selector "has started" flag       */
    int     ud_dir;             /* a1+3461 : UP&DOWN direction (1=up,0=down)  */
    int     oct_adv_flag;       /* a1+3468 : request octave advance (UP mode) */
    int     oct_shift;          /* a1+3472 : current octave offset (semitone
                                 *           multiples = 12*oct)              */
    int     range;              /* a1+3476 : octaves-1 (set by 0x3BFE60)      */

    int     type;               /* ARPEGGIO TYPE 0..5                         */
    int     selector;           /* resolved selector id (0,19,20,...)         */

    /* ---- velocity params (note-on override sub_7FF91E0235A0) --------- */
    uint8_t vel_fixed;          /* a1+4052 : fixed velocity (0 = use input)   */
    uint8_t vel_sens;           /* a1+4051 : sensitivity 0..100               */

    /* ---- timing (clock handler sub_7FF91E023C50 + rate/gate tables) -- */
    double  bpm;                /* host tempo                                 */
    int     division;           /* rate switch: 0 -> 12 PPQN/step (8ths),
                                 *              !=0 -> 24 PPQN/step (quarters) */
    int     rate_index;         /* 0..9 into RATE table word_9C43B8 (optional
                                 *  fine subdivision; see PROVENANCE)         */
    int     gate_index;         /* 0..9 into GATE table word_9C43F8 (gate %)  */
    int     use_rate_table;     /* 0: step = division (12/24 PPQN, decoded
                                 *    clock);  1: step = RATE[rate_index]      */

    /* ---- runtime step clock (free-running 24-PPQN tick grid) --------------
     * Mirrors CArpeggio's transport clock: +20/+24 free-run every sample on the
     * host transport (NOT reset on key-down), and the first step is scheduled at
     * +3048 = +24 + 1, i.e. the next whole tick strictly after the key press —
     * never at pos 0. See scratchpad/oracle/arp_finish_findings.md (a). */
    long long  tick_acc;        /* +20/+24 : tick-phase accumulator, 1e-9-sample units */
    long long  tick_period;     /* integer tick period (60e9*SR/round(BPM)/24), 1e-9 units */
    long long  tick_counter;    /* +24     : running 24-PPQN tick index         */
    long long  next_step_tick;  /* +3048   : tick at which the next step fires  */
    int        running;         /* +44>=2  : arp has been started (has notes)   */

    /* ---- SCATTER pattern grid (STEP x SLOT) --------------------------------
     * The plugin's arp is not one-note-per-step: it walks a runtime slot table
     * (built from the .rdata pattern block by expand sub_7FF91E01F9F0, then
     * prune-all-rest + shell-sort-by-base-note sub_7FF91E01D540) and calls the
     * selector once per ACTIVE grid cell. The default slab0/sub7 collapses to
     * 1 slot / 1 step / velocity 127, i.e. carp's original single-note-per-step
     * behaviour, bit-for-bit. See scratchpad/oracle/arp_pattern_grid_spec.md
     * (verified 330/330 vs the plugin under Unicorn). */
    int      scatter_type;      /* SCATTER TYPE 0..9   -> pattern slab           */
    int      scatter_sub;       /* SCATTER DEPTH+7 (2..12) -> pattern sub         */
    int      pat_len;           /* pattern length in steps (a1+3055, 1..32)       */
    int      pat_nslots;        /* active slots after prune/sort (a1+3054)        */
    int      pat_step;          /* current step index (a1+3056, -1 before start)  */
    int      pat_sens;          /* velocity sensitivity, header[3]>>1 (=100)      */
    uint8_t  grid_vel [16][32]; /* runtime cell velocity(bit0-6)|tie(bit7) [slot][step] */
    uint16_t grid_gate[16][32]; /* runtime per-cell gate length in ticks (FED0)   */
    uint8_t  slot_note[16];     /* runtime slot base note (0x80=none), sorted asc */
    int      slot_pitch[16];    /* current sounding pitch per slot, -1 = silent   */
    int      slot_noteidx[16];  /* raw selector note owning the slot (a1+804 +3)   */
    long long slot_offtick[16]; /* scheduled note-off tick per slot (-1 = none)   */
    int8_t   note_slot[128];    /* a1+3324 raw-note -> slot map, -1 = free         */
} carp;

/* Reset to power-on defaults (empty keyboard, UP, 1 octave, 120 BPM). */
void carp_init(carp *e);

/* Held-key input. Velocity 1..127; a re-press of a held note only bumps its
 * ref-count (matches sub_7FF91E023440). */
void carp_add_key(carp *e, int note, int velocity);
void carp_remove_key(carp *e, int note);      /* note < 0 => release all      */

/* Configuration. */
void carp_set_mode(carp *e, int type);        /* ARPEGGIO TYPE 0..5           */
void carp_set_range(carp *e, int step);       /* ARPEGGIO STEP 0..5 -> octaves*/
void carp_set_bpm(carp *e, double bpm);
void carp_set_division(carp *e, int rate_sw); /* 0 => 12 PPQN, !=0 => 24 PPQN */
void carp_set_rate_index(carp *e, int idx);   /* 0..9 fine rate (opt-in)      */
void carp_set_gate_index(carp *e, int idx);   /* 0..9 gate %                  */
void carp_set_velocity(carp *e, int fixed, int sens); /* fixed 0..127, sens 0..100 */

/* Select the SCATTER pattern grid. type = SCATTER TYPE (0..9 -> slab), depth =
 * SCATTER DEPTH (-5..5 -> sub = depth+7). Rebuilds the runtime slot/grid tables
 * (expand -> prune -> shell-sort -> gate-fill) and sets velocity sensitivity from
 * the pattern header. Defaults (0,0) -> slab0/sub7 = the proven power-on pattern,
 * which reproduces the single-note-per-step path bit-for-bit. Called by carp_init;
 * call again to change patterns. See scratchpad/oracle/arp_pattern_grid_spec.md. */
void carp_set_scatter(carp *e, int type, int depth);

/* Advance the arp by exactly one output sample. Writes up to `cap` events
 * into `ev` (note-offs before note-ons) and returns how many were produced.
 * Call once per rendered sample; supply the current sample rate. */
int  carp_tick(carp *e, double sample_rate, carp_event *ev, int cap);

/* Exposed extracted tables (see docs/ARP_PROVENANCE.md). */
extern const uint16_t CARP_RATE_TABLE[10][3];   /* {evenDur,oddDur,accentMod} */
extern const uint16_t CARP_GATE_TABLE[10];      /* gate percent               */
extern const uint8_t  CARP_TYPE_SELECTOR[6];    /* type -> selector id        */

#ifdef __cplusplus
}
#endif
#endif /* CARP_H */
