/* panel -- five knobs, two banks, pick-up. Portable C (host-tested).
 * Knob 1 is SHIFT: a pot used as a two-position switch (hysteresis). Knobs 2-4
 * each drive one parameter per bank; knob 5 is unassigned. After a bank change
 * a knob does not jump the parameter: it PICKS UP when it crosses (or comes
 * within 1.5 % of) the stored value. All values are normalised 0..1.
 * SCREEN FOCUS is separate from value: a knob takes the screen only when it
 * moves PANEL_FOCUS_MOVE (2 %) away from where it last had focus, so ADC noise
 * on the other knobs cannot flip the display. The focused knob tracks every
 * move. Knob 5 (no parameter) never takes the screen: unwired, it floats. */
#define PANEL_FOCUS_MOVE 0.02f
#ifndef MSQ_PANEL_H
#define MSQ_PANEL_H
#include <stdint.h>

#define PANEL_KNOBS 5
enum { P_WAVE, P_ATTACK, P_CHORUS, P_UNISON, P_RELEASE, P_REVERB, P_NPARAM };

typedef struct {
    float    val[P_NPARAM];
    uint8_t  caught[P_NPARAM];
    float    knob[PANEL_KNOBS];
    float    anchor[PANEL_KNOBS];   /* where each knob was when it last took the screen */
    int      bank;              /* 0 = A (main), 1 = B (shift) */
    int      last_knob;         /* -1 none; the knob (0..4) that moved last, SHIFT excluded */
    uint32_t last_ms, bank_ms;  /* when it moved; when the bank changed */
    uint32_t changed;           /* bit per parameter, set on a value change */
} panel_t;

/* -1 when knob k (0..4) has no parameter in that bank (knob 1 = SHIFT, knob 5). */
int  panel_param_of(int bank, int k);
const char *panel_name(int p);          /* short label, e.g. "WAVE" */
void panel_init(panel_t *pn, const float knob[PANEL_KNOBS], uint32_t now_ms);
void panel_knob(panel_t *pn, int k, float pos, uint32_t now_ms);
#endif
