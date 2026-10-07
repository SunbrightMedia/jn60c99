/* panel -- five knobs, two banks, pick-up. Portable C (host-tested).
 * Since 2026-10-07 (the user's final build): knob 1 = VOLUME in both banks (no
 * pick-up needed: the same parameter in both), knob 2 = free, knobs 3-5 = the
 * bank's three parameters, SHIFT = the PB86 button (panel_shift). After a bank change
 * a knob does not jump the parameter: it PICKS UP when it crosses (or comes
 * within 1.5 % of) the stored value. All values are normalised 0..1.
 * SCREEN FOCUS is separate from value: a knob takes the screen only when it
 * moves PANEL_FOCUS_MOVE (4 %) away from where it last had focus, so ADC noise
 * on the other knobs cannot flip the display. The focused knob tracks every
 * move. */
/* 4 %: the v6 board log showed +-3 % raw jitter on an idle pot (RELEASE). */
#define PANEL_FOCUS_MOVE 0.04f
#ifndef MSQ_PANEL_H
#define MSQ_PANEL_H
#include <stdint.h>

#define PANEL_KNOBS 5
enum { P_WAVE, P_ATTACK, P_CHORUS, P_UNISON, P_RELEASE, P_REVERB, P_VOLUME, P_NPARAM };

typedef struct {
    float    val[P_NPARAM];
    uint8_t  caught[P_NPARAM];
    float    knob[PANEL_KNOBS];
    float    anchor[PANEL_KNOBS];   /* where each knob was when it last took the screen */
    int      bank;              /* 0 = A (main), 1 = B (shift) */
    int      last_knob;         /* -1 none; the knob (0..4) that moved last */
    uint32_t last_ms, bank_ms;  /* when it moved; when the bank changed */
    uint32_t changed;           /* bit per parameter, set on a value change */
} panel_t;

/* -1 when knob k (0..4) has no parameter in that bank (knob 2 = free). */
int  panel_param_of(int bank, int k);
const char *panel_name(int p);          /* short label, e.g. "WAVE" */
void panel_init(panel_t *pn, const float knob[PANEL_KNOBS], uint32_t now_ms);
void panel_knob(panel_t *pn, int k, float pos, uint32_t now_ms);
/* SHIFT (the button): 1 = bank B while held. */
void panel_shift(panel_t *pn, int on, uint32_t now_ms);
#endif
