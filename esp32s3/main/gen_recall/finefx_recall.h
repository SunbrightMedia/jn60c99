/* finefx_recall.h — per-patch "fine-FX" filter recall (the leaves the plugin's
 * value-tree recall ENUMERATOR (0x3B48A0) does NOT fire, but a real host's
 * preset-load DOES apply via the controller path). See finefx_recall.c. */
#ifndef JUNO_FINEFX_RECALL_H
#define JUNO_FINEFX_RECALL_H

/* Apply the DELAY fine-FX filter params (HIGH CUT / LF+HF DAMP / LF+HF DAMP FREQ)
 * for a DELAY TYPE-0 patch: overwrites the delay slot-1 high-cut/damp coefficient
 * cells (102368..102672) with the per-byte law the plugin's own setter produces.
 * `rec` = patch record start; `Hr` = host sample rate (for the two rate-armed
 * cells). Reduces to delay_recall.c's frozen FILT[]/put_rate defaults at the
 * default byte, so it is a no-op for default-fine-FX patches. */
void juno_apply_delay_finefx(unsigned char *state, const unsigned char *rec, int Hr);

/* DELAY TYPE 1 (dual delay) second-instance fine-FX: the HIGH CUT / DAMP / DIRECT
 * knobs move the SECOND delay instance (cells 4297xxx) in TYPE 1, with the SAME
 * per-byte law as TYPE 0's first instance (proven, identity at the default byte ==
 * the DLY1_B constants). Called from delay_recall.c's TYPE-1 arm. */
void juno_apply_delay_finefx_2nd(unsigned char *state, const unsigned char *rec, int Hr);

/* DELAY TYPE 5 (slot-1 reverb) slot-1-reverb fine-FX: the DELAY fine-FX knobs move the
 * slot-1 reverb's delay-filter block (6497xxx) and the CHORUS fine-FX knobs move its
 * chorus-filter block (10693xxx), both with the SAME laws as TYPE 0 / DELAY TYPE 2,3.
 * Identity at the default byte (== the S1REVERB constants). Called from the TYPE-5 arm. */
void juno_apply_delay_finefx_slot1rev(unsigned char *state, const unsigned char *rec, int Hr);
void juno_apply_chorus_finefx_slot1rev(unsigned char *state, const unsigned char *rec, int Hr);

/* Apply the REVERB fine-FX filter/gain params (LOW/HIGH CUT / DENSITY / DIRECT
 * LEVEL) — the plugin's own smoother-target coefficients (see finefx_recall.c).
 * Unconditional (the master always runs the reverb tank). PRE DELAY excluded
 * (joint TYPE x tap-array, handled in reverb_recall.c). */
void juno_apply_reverb_finefx(unsigned char *state, const unsigned char *rec, int Hr);

/* Apply the SLOT-1 chorus fine-FX (CHORUS HIGH/LOW CUT / PRE DELAY) for a DELAY
 * TYPE 2/3 patch (the slot-1 chorus; the slot-2 EFFECT-TYPE chorus has none).
 * Identity at the default byte. Called from delay_recall.c apply_slot1_chorus. */
void juno_apply_chorus_finefx(unsigned char *state, const unsigned char *rec, int Hr);

#endif
