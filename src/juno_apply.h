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

/* Decode the per-patch ARPEGGIATOR settings (NAME1 leaves 89/90/91 at record bytes
 * 298/306/314 — derived from the same value-tree leaf enumeration that lands the 5
 * oracle-anchored leaves exactly). Returns 1 if the arp is ON for patch idx; writes
 * *mode (0=up,1=down,2=up&down) and *oct (1..3). Rate is host-tempo-synced in the
 * plugin (no per-patch value), so it is not returned. */
int juno_bank_arp(const unsigned char *bank, int idx, int *mode, int *oct);

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

#ifdef __cplusplus
}
#endif
#endif
