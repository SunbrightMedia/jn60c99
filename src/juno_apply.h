/* juno_apply.h — apply a decoded JUNO-60 bank patch to the engine coefficients.
 * See juno_apply.c for the binding provenance + coverage (honest: the confirmed
 * filter + filter-ADSR subset; DCO levels / ENV2 / FX pending binding). */
#ifndef JUNO_APPLY_H
#define JUNO_APPLY_H
#ifdef __cplusplus
extern "C" {
#endif

/* bank = raw KoaBankFile00003 bytes. */
int juno_bank_num_patches(const unsigned char *bank, unsigned long len);
int juno_bank_patch_name(const unsigned char *bank, int idx, char out[17]);
/* Set engine coefficient slots for patch idx. Returns # params applied. */
int juno_bank_apply(unsigned char *state, const unsigned char *bank, int idx);

/* --- Per-parameter "raw 0..255 byte -> parameter" setter ---
 * juno_param_count()  : number of exposed single-byte panel parameters.
 * juno_param_name(i)  : static human name for parameter i ("" if out of range).
 * juno_param_offset(i): engine state offset parameter i writes (-1 if out of range).
 * juno_apply_param(state,i,byte,Hr): apply raw byte 0..255 to parameter i through the
 *   EXACT recall dispatch (curve+transform+rate-variant) at host rate Hr; returns the
 *   float written. Writes voice-0's cell only — replicate to the other voices after.
 * Together these are the plugin's own value-tree recall exposed one parameter at a
 * time (see the BINDINGS table + juno_apply_param in juno_apply.c). */
int         juno_param_count(void);
const char *juno_param_name(int i);
int         juno_param_offset(int i);
int         juno_param_blob(int i);   /* front-panel blob position (leaf id); rows sharing it form one plugin leaf */
float       juno_apply_param(unsigned char *state, int i, int byte, int Hr);
/* juno_apply_param_leaf(state,i,byte,Hr): the LIVE PANEL EDIT -- expands the
 * leaf (every binding row sharing i's blob byte) and replicates a per-voice
 * cell to every voice. The one implementation of that rule; gui/juno_bridge.c
 * and the device-recall gate both call it. See juno_apply.c for why. */
float       juno_apply_param_leaf(unsigned char *state, int i, int byte, int Hr);

/* Decode the per-patch ARPEGGIATOR settings (NAME1 leaves 89/90/91 at record bytes
 * 298/306/314 — derived from the same value-tree leaf enumeration that lands the 5
 * oracle-anchored leaves exactly). Returns 1 if the arp is ON for patch idx; writes
 * *mode (0=up,1=down,2=up&down) and *oct (1..3). Rate is host-tempo-synced in the
 * plugin (no per-patch value), so it is not returned. */
int juno_bank_arp(const unsigned char *bank, int idx, int *mode, int *oct);

/* Decode the per-patch SCATTER TYPE (0..9 -> arp pattern slab) and SCATTER DEPTH
 * (-7..7 -> pattern sub = depth+7), which select the arpeggiator's STEP x SLOT
 * pattern grid (feed to carp_set_scatter). Proven leaf 92/93 -> record byte 322/330;
 * all 64 factory patches decode to (0,0) = the default grid. *type / *depth may be
 * NULL. Returns 1 on success. See scratchpad/oracle/scatter_recall_spec.md. */
int juno_bank_scatter(const unsigned char *bank, int idx, int *type, int *depth);

/* LFO Tempo Rate (cell 1072): write the host-tempo-synced LFO rate to all 8 voices.
 * Required for the 34/64 factory patches with TEMPO SYNC on (else their LFO is frozen).
 * lfo_rate_byte = the LFO RATE front-panel byte (juno_bank_lfo_rate_byte); bpm = host
 * tempo. Bit-exact (juno_curve 48 x 53), SR-independent, inert while sync is off.
 * See scratchpad/oracle/lfo_tempo_rate_spec.md. */
void juno_apply_lfo_tempo(unsigned char *state, int lfo_rate_byte, float bpm);
int  juno_bank_lfo_rate_byte(const unsigned char *bank, int idx);

/* Decode the per-patch DELAY tempo-sync inputs (DELAY TIME byte blob 53, TEMPO SYNC
 * blob 59 != 0, DELAY TYPE record 650) for juno_apply_delay_tempo (delay_recall.h).
 * Any out pointer may be NULL. Returns 1 on success. */
int juno_bank_delay_modes(const unsigned char *bank, int idx,
                          int *time_byte, int *sync, int *dtype);

/* Decode the per-patch VOICE-ASSIGN settings (CTRL leaves at front-panel blob
 * positions): *legato (leaf 57 / bp 55, 0/1), *assign (ASSIGN MODE, leaf 58 / bp 56,
 * 0..3), *porta (PORTAMENTO, leaf 56 / bp 54, 0..255 — the raw byte; the assigner
 * treats "engaged" as porta != 0). Any out pointer may be NULL. Returns 1 on success.
 * The allocation semantics these select are applied in the note driver
 * (gui/juno_bridge.c): 0=POLY, 1=MONO, 2=UNISON, 3=POLY-variant. */
int juno_bank_voice_modes(const unsigned char *bank, int idx,
                          int *legato, int *assign, int *porta);

/* CONDITION analog voice-scatter. juno_apply_condition writes PER-VOICE-DISTINCT
 * detune/level coefficients for the clamped byte cbyte (0..255), so it MUST be called
 * AFTER juno_driver_seed_voices (seed replicates voice 0 and would clobber the scatter).
 * juno_bank_condition reads the CONDITION byte (leaf 114, record 498) for patch idx
 * (default 128). See src/juno_apply.c / scratchpad/oracle/condition_scatter_spec.md. */
void juno_apply_condition(unsigned char *state, int cbyte);
int  juno_bank_condition(const unsigned char *bank, int idx);
/* ASSIGN==2 (UNISON) per-voice 3968 detune spread (fixed measured table); must run
 * after seed_voices. juno_bank_assign reads the ASSIGN MODE nibbles (blob row 56). */
void juno_apply_unison_spread(unsigned char *state, int assign);
int  juno_bank_assign(const unsigned char *bank, int idx);
int juno_bank_hpf_type(const unsigned char *bank, int idx); /* record 618; joint HPF recompute context */

/* Host-visible parameter panel: the ~79 parameters a VST3 host (Ableton) exposes,
 * for the in-browser editor. Generated in src/juno_hostparams.c from Script.xml +
 * the validated record-offset map. roff(i) is the RECORD byte offset of param i's
 * low nibble-pair; editing rec[roff]/rec[roff+1] and re-running juno_bank_apply
 * reproduces the plugin's own recall for that value (render-A/B bit-exact). */
int         juno_host_param_count(void);
const char *juno_host_param_name(int i);
const char *juno_host_param_section(int i);
int         juno_host_param_roff(int i);
int         juno_host_param_type(int i);    /* 0=int1x7 (1 byte), 1=int2x4, 2=int8x4 (nibble-pair low byte) */
int         juno_host_param_min(int i);     /* semantic Script.xml range; min<0 = two's-complement byte */
int         juno_host_param_max(int i);
int         juno_host_param_default(int i);
int         juno_host_param_decode(const unsigned char *rec, int i);
void        juno_host_param_encode(unsigned char *rec, int i, int v); /* type-aware record write */
/* Start of patch idx's record (bank + BANK_HEADER + idx*BANK_STRIDE), or NULL. */
unsigned char *juno_bank_record(unsigned char *bank, int idx);

#ifdef __cplusplus
}
#endif
#endif
