/* ui -- the 128x32 OLED screens: intro animation, overview of the live bank,
 * a focus view of the knob being turned (value, picture, pick-up hint), and
 * animated bank / focus transitions. Pure rendering (host-tested as PNGs). */
#ifndef MSQ_UI_H
#define MSQ_UI_H
#include <stdint.h>
#include "gfx.h"
#include "panel.h"

#define UI_INTRO_MS 2600
/* Screen dimming: full while in use, then a smooth fade to the dimmest the
 * SSD1306 gives (contrast 0, pre-charge 0x11, VCOMH 0x00). */
#define UI_CONTRAST_FULL 0x8F         /* = OLED_CONTRAST_FULL, the v1-v6 brightness */
#define UI_DIM_AFTER_MS  10000
#define UI_DIM_FADE_MS   2000

enum { UI_BAT_NONE, UI_BAT_ON, UI_BAT_CHG, UI_BAT_FULL };   /* no sense wire / on battery / charging / full */

typedef struct {
    int   note;        /* sounding MIDI note, -1 none */
    float meter;       /* 0..1 output level */
    uint8_t vstate[6]; /* per voice: 0 idle, 1 releasing, 2 held */
    int   bat_state;   /* UI_BAT_* */
    float bat_v;       /* battery volts (smoothed) */
    int   bat_pct;     /* 0..100 */
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
/* Dim level 0 (full) .. 255 (dimmest) for the time since the last knob move
 * or key, and the three SSD1306 registers for a level (see ui.c). */
uint8_t ui_dim(uint32_t idle_ms);
void    ui_dim_regs(uint8_t level, uint8_t *contrast, uint8_t *precharge, uint8_t *vcomh);
/* LiPo state of charge from its voltage, 0..100 (a resting-voltage table;
 * under load it reads a few % low). */
int ui_bat_pct(float volts);
/* Value text for a parameter, e.g. "0.25S", "SAW", "5X 18C", "40%". */
void ui_value_text(int p, float v, char *buf, int n);
#endif
