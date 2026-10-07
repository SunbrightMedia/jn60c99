#include "panel.h"
#include <math.h>
#include <string.h>

static const int8_t MAP[2][PANEL_KNOBS] = {
    /* knob 1 = VOLUME (both banks), knob 2 = free, knobs 3-5 = the bank's three
     * parameters; SHIFT is the PB86 button (panel_shift), 2026-10-07 */
    { P_VOLUME, -1, P_WAVE,   P_ATTACK,  P_CHORUS },
    { P_VOLUME, -1, P_UNISON, P_RELEASE, P_REVERB },
};
static const char *NAME[P_NPARAM] = { "WAVE", "ATTACK", "CHORUS", "UNISON", "RELEASE", "REVERB", "VOLUME" };

int panel_param_of(int bank, int k)
{ return (bank < 0 || bank > 1 || k < 0 || k >= PANEL_KNOBS) ? -1 : MAP[bank][k]; }
const char *panel_name(int p) { return (p >= 0 && p < P_NPARAM) ? NAME[p] : "---"; }

#define CATCH 0.015f

static void rearm(panel_t *pn)
{
    for (int k = 0; k < PANEL_KNOBS; ++k) {
        int p = MAP[pn->bank][k];
        if (p >= 0) pn->caught[p] = fabsf(pn->knob[k] - pn->val[p]) < CATCH;
    }
}

void panel_init(panel_t *pn, const float knob[PANEL_KNOBS], uint32_t now_ms)
{
    memset(pn, 0, sizeof *pn);
    memcpy(pn->knob, knob, sizeof pn->knob);
    memcpy(pn->anchor, knob, sizeof pn->anchor);
    /* shift-bank defaults: no unison, 0.3 s release, a little reverb */
    pn->val[P_UNISON] = 0.0f;
    pn->val[P_RELEASE] = 0.642f;                     /* msq_knob_to_release -> ~0.30 s */
    /* 0 since v8: the HALL tail is dark (85 % of its energy at the
     * fundamental, measured on the host), and at 25 % the user heard it as "a
     * sine in the background of each note". The knob adds it. */
    pn->val[P_REVERB] = 0.0f;
    pn->val[P_WAVE] = 1.0f; pn->val[P_ATTACK] = 0.1f; pn->val[P_CHORUS] = 0.0f;
    pn->bank = 0;                                     /* the button sets the bank (panel_shift) */
    for (int k = 0; k < PANEL_KNOBS; ++k) {           /* the live bank follows the knobs now */
        int p = MAP[pn->bank][k];
        if (p >= 0) { pn->val[p] = knob[k]; pn->caught[p] = 1; }
    }
    pn->last_knob = -1;
    pn->bank_ms = now_ms;
    pn->changed = (1u << P_NPARAM) - 1;
}

void panel_shift(panel_t *pn, int on, uint32_t now_ms)
{
    int b = on ? 1 : 0;
    if (b == pn->bank) return;
    pn->bank = b; pn->bank_ms = now_ms; rearm(pn);
    pn->last_knob = -1;                               /* a new bank starts on its overview */
    memcpy(pn->anchor, pn->knob, sizeof pn->anchor);
}

void panel_knob(panel_t *pn, int k, float pos, uint32_t now_ms)
{
    if (k < 0 || k >= PANEL_KNOBS) return;
    if (pos < 0.0f) pos = 0.0f;
    if (pos > 1.0f) pos = 1.0f;
    float prev = pn->knob[k];
    pn->knob[k] = pos;
    int p = MAP[pn->bank][k];
    if (p < 0) return;
#ifdef MSQ_TOOTH_NO_FOCUS_DEADBAND
    const float fm = 0.0f;                            /* TOOTH: any wiggle steals the screen */
#else
    const float fm = PANEL_FOCUS_MOVE;
#endif
    if (k == pn->last_knob || fabsf(pos - pn->anchor[k]) > fm) {
        pn->anchor[k] = pos;
        pn->last_ms = now_ms;
        pn->last_knob = k;
    }
    if (!pn->caught[p]) {
        float v = pn->val[p];
        if (fabsf(pos - v) < CATCH || (prev - v) * (pos - v) <= 0.0f) pn->caught[p] = 1;
        else return;
    }
    if (pn->val[p] != pos) { pn->val[p] = pos; pn->changed |= 1u << p; }
}
