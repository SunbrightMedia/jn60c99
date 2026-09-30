/* ui -- the 128x32 OLED screens: intro animation, overview of the live bank,
 * a focus view of the knob being turned (value, picture, pick-up hint), and
 * animated bank / focus transitions. Pure rendering (host-tested as PNGs). */
#ifndef MSQ_UI_H
#define MSQ_UI_H
#include <stdint.h>
#include "gfx.h"
#include "panel.h"

#define UI_INTRO_MS 2600

typedef struct {
    int   note;        /* sounding MIDI note, -1 none */
    float meter;       /* 0..1 output level */
    uint8_t vstate[6]; /* per voice: 0 idle, 1 releasing, 2 held */
} ui_live;

typedef struct {
    int      prev_bank;     /* bank shown before the last change */
    uint32_t seen_bank_ms;
    int      focus_knob;    /* knob shown in the focus view, -1 none */
    uint32_t focus_in_ms, focus_out_ms;  /* start of slide-in / slide-out, 0 = none */
    uint32_t seen_last_ms;
} ui_anim;

/* Returns 1 while the intro is still running. */
int  ui_intro(gfx_fb *f, uint32_t t_ms);
void ui_anim_init(ui_anim *a, const panel_t *pn);
void ui_render(gfx_fb *f, const panel_t *pn, const ui_live *lv, ui_anim *a, uint32_t now_ms);
/* Value text for a parameter, e.g. "0.25S", "SAW", "5X 18C", "40%". */
void ui_value_text(int p, float v, char *buf, int n);
#endif
