/* recall_ramp.h -- the plugin's RECALL RAMPS (CLAIMS B1).
 *
 * A patch recall does not set every engine cell at once. 73 cells (the slot-1
 * and slot-2 block switches, the per-voice mute pairs, the reverb send and the
 * master reverb-tone coefficients) are set through the plugin's ramped setter
 * (rva 0x3C10D0 -> 0x3C2920 -> ramp start 0x3C2E80): each such set arms the
 * cell's ramp record, and the record glides the cell to its target over 4 ms
 * (24 ms / 36 ms for three cells), one step every 10 samples, stepped after
 * the DSP of every sample (the render wrappers rva 0x398EC0/0x398F30 tail-jump
 * to the pump rva 0x3C24A0). PROVEN by execution (probes/warm/): during a
 * recall nothing else writes these cells, so a recall leaves each one at its
 * old value with its record armed.
 *
 * The port reproduces that per cell: juno_rr_begin() captures the cells before
 * the appliers run; juno_rr_end() restores them and replays the plugin's arm
 * sequence for each cell (the census of every set, probes/warm/
 * ramp_census_dyn.py), using the transcribed ramp start (src/juno_ramp.c), so
 * the record state -- stored target, early-outs, increments -- is the plugin's.
 * An arm takes effect only when its target differs from the record's stored
 * target, so the sequence decides whether a cell glides.
 *
 * juno_rr_settle() is the harness snap (tools/verify/e2e_emu.py snap_all): the
 * settled recall every gate compares. juno_bank_apply settles; juno_bank_apply_live
 * does not, and the render steps the ramps (juno_rr_pump).
 *
 * The record table is port-owned memory past the compared object (see
 * src/juno_engine.h). Compiled out under EB_DEVCELLS: the device recall stays
 * settled and its cell map need not carry the table.
 */
#ifndef JUNO_RECALL_RAMP_H
#define JUNO_RECALL_RAMP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* What the arm sequences depend on: the prev_* fields are captured by
 * juno_rr_begin BEFORE the appliers run; the caller fills the new_* fields
 * (the record's raw leaves) before juno_rr_end. */
typedef struct {
    int prev_etype, prev_dtype;     /* types in force before the recall (raw leaves) */
    int prev_revtime;               /* REVERB TIME byte the processor holds          */
    int prev_rev_on;                /* REVERB LEVEL on-state the processor holds     */
    int new_etype, new_dtype;       /* EFFECT TYPE (rec 634), DELAY TYPE (rec 650)   */
    int new_revtype, new_revtime;   /* REVERB TYPE (rec 658), REVERB TIME (rec 666)  */
    int new_revlevel;               /* REVERB LEVEL byte (blob 51)                   */
    int new_cutoff;                 /* VCF CUTOFF FREQ byte (blob 35)                */
} juno_rr_ctx;

void juno_rr_reset(unsigned char *state);   /* juno_engine_prepare: records re-seed at the next recall */
void juno_rr_begin(unsigned char *state, juno_rr_ctx *ctx);
void juno_rr_end(unsigned char *state, const juno_rr_ctx *ctx);
void juno_rr_settle(unsigned char *state);
void juno_rr_pump(unsigned char *state);
int  juno_rr_active(const unsigned char *state);
/* One host-role ramped set (CLAIMS B7, src/host_edit.c): arm the record of a
 * ramped cell toward v over time index t (4..96 ms, rva 0x9DEB50). Returns -1
 * when the cell is not a ramped cell (src/ramp_cells.h). */
int  juno_rr_arm(unsigned char *state, uint32_t cell, float v, int t);
int  juno_rr_is_ramped(uint32_t cell);
/* processor state the host-role edits read (src/host_edit.c) */
void     juno_rr_note_tap2(unsigned char *state, float v);
uint32_t juno_rr_tap2_bits(unsigned char *state);
int      juno_rr_rev_on(unsigned char *state);
int      juno_rr_arp_on(unsigned char *state);
void     juno_rr_set_arp_on(unsigned char *state, int on);
int      juno_rr_cut_last(unsigned char *state);
void     juno_rr_set_cut_last(unsigned char *state, int v);
void     juno_rr_copy_proc(unsigned char *dst, const unsigned char *src);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_RECALL_RAMP_H */
