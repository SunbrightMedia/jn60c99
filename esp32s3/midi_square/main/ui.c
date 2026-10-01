#include "ui.h"
#include "msq_core.h"
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAIN_Y   10               /* rows 10..31 are the main area */
#define MAIN_H   (GFX_H - MAIN_Y)
#define FOCUS_HOLD_MS 1600
#define SLIDE_MS 180

static float clampf(float x, float a, float b) { return x < a ? a : (x > b ? b : x); }
static float ease_out(float t) { t = clampf(t, 0, 1); return 1.0f - (1.0f - t) * (1.0f - t) * (1.0f - t); }
static float ease_io(float t)  { t = clampf(t, 0, 1); return t < 0.5f ? 4*t*t*t : 1.0f - powf(-2*t + 2, 3) / 2; }

/* one sample of the morphing oscillator picture, t in 0..1, w in 0..3 */
static float shape(float t, float w)
{
    float s[4];
    s[0] = sinf(6.2831853f * t);
    float u = t + 0.25f; if (u >= 1.0f) u -= 1.0f;
    s[1] = 1.0f - 4.0f * fabsf(u - 0.5f);
    s[2] = 1.0f - 2.0f * t;
    s[3] = t < 0.5f ? 1.0f : -1.0f;
    int k = (int)w; if (k > 2) k = 2;
    float f = w - k;
    return s[k] + (s[k + 1] - s[k]) * f;
}

static void draw_wave(gfx_fb *f, int x, int y, int w, int h, float wv, float cycles, float amp)
{
    int py = 0;
    for (int i = 0; i < w; ++i) {
        float t = fmodf(i * cycles / (float)w, 1.0f);
        int yy = y + h / 2 - (int)lroundf(shape(t, wv) * amp * (h / 2 - 1));
        if (i) gfx_line(f, x + i - 1, py, x + i, yy, 1); else gfx_pixel(f, x, yy, 1);
        py = yy;
    }
}

void ui_value_text(int p, float v, char *buf, int n)
{
    static const char *W[4] = { "SIN", "TRI", "SAW", "SQR" };
    switch (p) {
    case P_WAVE: {
        float w = v * 3.0f; int k = (int)lroundf(w);
        if (fabsf(w - k) < 0.12f) snprintf(buf, n, "%s", W[k]);
        else { int a = (int)w; snprintf(buf, n, "%s>%s", W[a], W[a + 1 > 3 ? 3 : a + 1]); }
        break;
    }
    case P_ATTACK: case P_RELEASE: {
        float s = p == P_ATTACK ? msq_knob_to_attack(v) : msq_knob_to_release(v);
        if (s < 1.0f) snprintf(buf, n, "%dMS", (int)lroundf(s * 1000.0f));
        else snprintf(buf, n, "%.2fS", s);
        break;
    }
    case P_UNISON: {
        int nv = msq_unison_voices(v);
        if (nv == 1) snprintf(buf, n, "OFF");
        else snprintf(buf, n, "%dX", nv);
        break;
    }
    default: snprintf(buf, n, "%d%%", (int)lroundf(v * 100.0f)); break;
    }
}

/* ---------------------------------------------------------------- intro */
#define UL_Y 19                   /* the underline row = the wave's centre */
int ui_intro(gfx_fb *f, uint32_t t)
{
    static const char *TITLE = "Sunbright.";
    gfx_clear(f);
    float amp = 1.0f;
    if (t > 900) amp = 1.0f - ease_io((t - 900) / 450.0f);            /* wave flattens */
    /* ALL INTRO TIMES ARE SIGNED. t is unsigned: "t - start" before a start
     * wrapped to ~4e9 and drew a letter FINISHED before its drop began (user
     * 2026-10-01: "the title comes in too early, then restarts"). */
    const int ti = (int)t;
    if (ti < 1350) {                                                   /* the morph trace */
        int reveal = (int)(ease_out(t / (float)UI_WAVE_REVEAL_MS) * GFX_W);
        int py = UL_Y;
        for (int x = 0; x < reveal; ++x) {
            float w = 3.0f * x / (GFX_W - 1);
            float ph = fmodf(x / 32.0f + t / 2000.0f, 1.0f);
            int yy = UL_Y - (int)lroundf(shape(ph, w) * 12.0f * amp);
            if (x) gfx_line(f, x - 1, py, x, yy, 1); else gfx_pixel(f, 0, yy, 1);
            py = yy;
        }
    }
    if (ti >= UI_TITLE_T0) {                                           /* the text: instantly, no slide */
        gfx_text2(f, (GFX_W - gfx_text2_w(TITLE)) / 2, 2, TITLE, 1);
        gfx_text(f, (GFX_W - gfx_text_w("Minisynth")) / 2, 23, "Minisynth", 1);
    }
    /* ONE LINE, NOT TWO, AND IT NEVER MOVES: the wave is centred on the
     * underline row, so when it flattens (1350 ms) it already IS the
     * underline, full width (user 2026-10-01). v9 removed the flat wave and
     * grew a second line; the first fix slid it down and inwards. */
    if (ti >= 1350) gfx_hline(f, 0, GFX_W - 1, UL_Y, 1);
    if (ti > UI_INTRO_WIPE) {                                          /* iris-out wipe */
        int r = (int)(ease_io((ti - UI_INTRO_WIPE) / (float)(UI_INTRO_MS - UI_INTRO_WIPE - 50)) * 70);
        for (int x = 0; x < GFX_W; ++x)
            if (abs(x - 64) < r) gfx_vline(f, x, 0, GFX_H - 1, 0);
    }
    return t < UI_INTRO_MS;
}

/* ------------------------------------------------------------ dimming
 * Full brightness while anything is touched; after UI_DIM_AFTER_MS of no knob
 * or key, a smooth fade over UI_DIM_FADE_MS. v7 used CONTRAST alone (143 ->
 * 14) and the board showed it "only very slightly" dimmer: on the SSD1306 the
 * contrast register is a weak lever. v8 walks three registers in one fade:
 *   d 0.00-0.50  contrast 143 -> 14 (geometric: the v7 range)
 *   d 0.50-0.75  contrast 14 -> 0
 *   d 0.50-1.00  pre-charge phase 2: 15 -> 1 clocks (0xF1 -> 0x11)
 *   d 0.75-1.00  VCOMH 0x40 -> 0x30 -> 0x20 -> 0x00
 * Every register only moves one way and in small steps (host-tested). */
uint8_t ui_dim(uint32_t idle_ms)
{
#ifdef MSQ_TOOTH_NO_DIM
    return 0;                                                          /* TOOTH: never dims */
#endif
    if (idle_ms <= UI_DIM_AFTER_MS) return 0;
    float t = clampf((idle_ms - UI_DIM_AFTER_MS) / (float)UI_DIM_FADE_MS, 0, 1);
    float e = t * t * (3.0f - 2.0f * t);          /* smoothstep: max slope 1.5, gentler than ease_io's 3 */
    return (uint8_t)lroundf(e * 255.0f);
}

void ui_dim_regs(uint8_t level, uint8_t *contrast, uint8_t *precharge, uint8_t *vcomh)
{
    float d = level / 255.0f;
    float c = d <= 0.5f ? UI_CONTRAST_FULL * powf(0.10f, d / 0.5f)
                        : (d < 0.75f ? UI_CONTRAST_FULL * 0.10f * (0.75f - d) / 0.25f : 0.0f);
    *contrast = (uint8_t)lroundf(c);
    int p2 = d <= 0.5f ? 15 : 15 - (int)lroundf(14.0f * (d - 0.5f) / 0.5f);
    *precharge = (uint8_t)((p2 << 4) | 1);
    *vcomh = d < 0.75f ? 0x40 : (d < 0.85f ? 0x30 : (d < 0.95f ? 0x20 : 0x00));
}

/* ---------------------------------------------------------------- pieces */
static void header(gfx_fb *f, const panel_t *pn, const ui_live *lv, int bank, float slide, const char *title)
{
    /* bank pill: the letter slides vertically on a change */
    gfx_rfill(f, 0, 0, 13, 9, 1);
    int dy = (int)lroundf(slide * 9);
    char a[2] = { bank ? 'B' : 'A', 0 }, b[2] = { bank ? 'A' : 'B', 0 };
    gfx_fb tmp; gfx_clear(&tmp);
    gfx_text(&tmp, 4, 1 + dy, a, 1);
    if (dy) gfx_text(&tmp, 4, 1 + dy - 9, b, 1);
    for (int x = 1; x < 12; ++x) for (int y = 1; y < 8; ++y) if (gfx_get(&tmp, x, y)) gfx_pixel(f, x, y, 0);
    gfx_text(f, 17, 1, title ? title : (bank ? "SHIFT" : "MAIN"), 1);
    /* note + meter on the right */
    if (lv && lv->note >= 0) {
        static const char *N[12] = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"};
        char s[16]; snprintf(s, sizeof s, "%s%d", N[lv->note % 12], lv->note / 12 - 1);
        gfx_text(f, 112 - gfx_text_w(s), 1, s, 1);
    }
    if (lv) for (int k = 0; k < 6; ++k) {                 /* six voice lamps */
        int x = 66 + k * 4;
        if (lv->vstate[k] == 2) gfx_fill(f, x, 2, 3, 5, 1);
        else if (lv->vstate[k] == 1) gfx_rect(f, x, 2, 3, 5, 1);
        else gfx_pixel(f, x + 1, 6, 1);
    }
    int m = lv ? (int)lroundf(clampf(lv->meter, 0, 1) * 7) : 0;
    gfx_rect(f, 116, 0, 12, 9, 1);
    for (int i = 0; i < m; ++i) gfx_vline(f, 118 + i, 7 - i, 7, 1);
    (void)pn;
    gfx_hline(f, 0, GFX_W - 1, 9, 2);                     /* dotted separator */
    for (int x = 0; x < GFX_W; x += 2) gfx_pixel(f, x, 9, 0);
}

static void bar(gfx_fb *f, int x, int y, int w, int h, float v, int caught, float knob)
{
    if (caught) gfx_rect(f, x, y, w, h, 1);
    else for (int i = 0; i < w; i += 2) { gfx_pixel(f, x + i, y, 1); gfx_pixel(f, x + i, y + h - 1, 1); }
    int fw = (int)lroundf(clampf(v, 0, 1) * (w - 4));
    gfx_fill(f, x + 2, y + 2, fw, h - 4, 1);
    if (!caught) {                                        /* where the knob is now */
        int kx = x + 2 + (int)lroundf(clampf(knob, 0, 1) * (w - 5));
        gfx_vline(f, kx, y - 1, y + h, 2);
    }
}

/* ------------------------------------------------------------ battery */
int ui_bat_pct(float v)
{
#ifdef MSQ_TOOTH_BAT_FLAT
    (void)v; return 50;                                                /* TOOTH: the gauge never moves */
#endif
    static const float V[] = { 3.27f, 3.61f, 3.69f, 3.71f, 3.73f, 3.75f, 3.77f, 3.79f, 3.80f, 3.82f, 3.84f,
                               3.85f, 3.87f, 3.91f, 3.95f, 3.98f, 4.02f, 4.08f, 4.11f, 4.15f, 4.20f };
    if (v <= V[0]) return 0;
    if (v >= V[20]) return 100;
    int i = 0;
    while (v > V[i + 1]) i++;
    return (int)lroundf(5.0f * i + 5.0f * (v - V[i]) / (V[i + 1] - V[i]));
}

/* The empty 5th column of the overview: percent / volts (alternating every
 * 3 s), CHG, FULL or USB, over a battery icon. Below 15 % the outline blinks. */
static void battery_slot(gfx_fb *f, int x, const ui_live *lv, uint32_t now)
{
    int st = lv ? lv->bat_state : UI_BAT_NONE, pct = lv ? lv->bat_pct : 0;
    char s[12];
    if (st == UI_BAT_NONE)      snprintf(s, sizeof s, "USB");
    else if (st == UI_BAT_CHG)  snprintf(s, sizeof s, "CHG");
    else if (st == UI_BAT_FULL) snprintf(s, sizeof s, "FULL");
    else if ((now / 3000) & 1)  snprintf(s, sizeof s, "%.2fV", lv->bat_v);
    else                        snprintf(s, sizeof s, "%d%%", pct);
    gfx_text(f, x + (31 - gfx_text_w(s)) / 2, MAIN_Y + 2, s, 1);
    int bx = x + 2, by = MAIN_Y + 12, bw = 25, bh = 8;
    int low = st == UI_BAT_ON && pct <= 15, show = !low || ((now / 400) & 1);
    if (st == UI_BAT_NONE) {
        for (int i = 0; i < bw; i += 2) { gfx_pixel(f, bx + i, by, 1); gfx_pixel(f, bx + i, by + bh - 1, 1); }
        gfx_vline(f, bx, by, by + bh - 1, 1); gfx_vline(f, bx + bw - 1, by, by + bh - 1, 1);
    } else if (show) gfx_rect(f, bx, by, bw, bh, 1);
    gfx_fill(f, bx + bw, by + 2, 2, bh - 4, 1);                        /* the nub */
    int full = bw - 4, fw = 0;
    if (st == UI_BAT_ON) fw = (pct * full + 50) / 100;
    else if (st == UI_BAT_FULL) fw = full;
    else if (st == UI_BAT_CHG) fw = (int)((now / 120) % (full + 1));   /* filling sweep */
    gfx_fill(f, bx + 2, by + 2, fw, bh - 4, 1);
}

static void overview(gfx_fb *f, const panel_t *pn, int bank, const ui_live *lv, uint32_t now)
{
    for (int k = 1; k < PANEL_KNOBS; ++k) {
        int x = (k - 1) * 32, p = panel_param_of(bank, k);
        static const char *SHORT[P_NPARAM] = { "WAVE", "ATK", "CHOR", "UNI", "REL", "VERB", "VOL" };
        if (k == PANEL_KNOBS - 1) { battery_slot(f, x, lv, now); continue; }   /* knob 5 = VOLUME: its column shows the battery */
        const char *lab = p >= 0 ? SHORT[p] : "----";
        gfx_text(f, x + (31 - gfx_text_w(lab)) / 2, MAIN_Y + 2, lab, 1);
        if (p >= 0) bar(f, x + 2, MAIN_Y + 12, 28, 8, pn->val[p], pn->caught[p], pn->knob[k]);
        else for (int i = 0; i < 28; i += 3) gfx_pixel(f, x + 2 + i, MAIN_Y + 16, 1);
    }
}

static void envelope_pic(gfx_fb *f, int x, int y, int w, int h, float v, int rel)
{
    int k = 4 + (int)lroundf(clampf(v, 0, 1) * (w / 2 - 4));
    int top = y + 1, bot = y + h - 1;
    if (!rel) { gfx_line(f, x, bot, x + k, top, 1); gfx_hline(f, x + k, x + w - 1, top, 1); }
    else      { gfx_hline(f, x, x + w - 1 - k, top, 1); gfx_line(f, x + w - 1 - k, top, x + w - 1, bot, 1); }
    gfx_hline(f, x, x + w - 1, bot, 1);
}

static void focus(gfx_fb *f, const panel_t *pn, int bank, int knob, uint32_t now)
{
    int p = panel_param_of(bank, knob);
    char val[16];
    if (p < 0) {
        char s[24]; snprintf(s, sizeof s, "KNOB %d", knob + 1);
        (void)s;
        gfx_text2(f, 2, MAIN_Y + 4, "FREE", 1);
        return;
    }
    ui_value_text(p, pn->val[p], val, sizeof val);        /* the name is in the header */
    if (gfx_text2_w(val) <= 64) gfx_text2(f, 2, MAIN_Y + 4, val, 1);   /* rows 14..27 */
    else gfx_text(f, 2, MAIN_Y + 8, val, 1);
    int gx = 68, gy = MAIN_Y + 1, gw = 58, gh = MAIN_H - 2;
    if (!pn->caught[p]) {                                 /* pick-up hint */
        int right = pn->knob[knob] < pn->val[p];
        gfx_text(f, gx + 4, gy + 1, right ? "TURN >" : "< TURN", (now / 300) & 1 ? 1 : 1);
        bar(f, gx, gy + 11, gw, 8, pn->val[p], 0, pn->knob[knob]);
        return;
    }
    switch (p) {
    case P_WAVE: gfx_rect(f, gx, gy, gw, gh, 1); draw_wave(f, gx + 2, gy + 2, gw - 4, gh - 4, pn->val[p] * 3.0f, 2.0f, 1.0f); break;
    case P_ATTACK: envelope_pic(f, gx, gy + 2, gw, gh - 3, pn->val[p], 0); break;
    case P_RELEASE: envelope_pic(f, gx, gy + 2, gw, gh - 3, pn->val[p], 1); break;
    case P_UNISON: {
        int nv = msq_unison_voices(pn->val[p]);
        float c = msq_unison_cents(pn->val[p]);
        for (int i = 0; i < nv; ++i) {
            float off = nv > 1 ? (i - (nv - 1) / 2.0f) / ((nv - 1) / 2.0f) : 0.0f;
            int cx = gx + gw / 2 + (int)lroundf(off * c / 25.0f * (gw / 2 - 3));
            gfx_vline(f, cx, gy + 3, gy + gh - 3, 1);
        }
        gfx_hline(f, gx, gx + gw - 1, gy + gh - 1, 1);
        break;
    }
    case P_VOLUME: {                                      /* a speaker and a wedge filled to the level */
        int cx = gx + 2, cy = gy + gh / 2;
        gfx_fill(f, cx, cy - 2, 3, 5, 1);
        for (int i = 0; i < 4; ++i) gfx_vline(f, cx + 3 + i, cy - 2 - i, cy + 2 + i, 1);
        int wx = gx + 12, ww = gw - 14, fillw = (int)lroundf(clampf(pn->val[p], 0, 1) * ww);
        for (int i = 0; i < ww; ++i) {
            int h = 1 + i * (gh - 3) / ww;
            if (i < fillw) gfx_vline(f, wx + i, gy + gh - 1 - h, gy + gh - 1, 1);
            else gfx_pixel(f, wx + i, gy + gh - 1 - h, 1);
        }
        gfx_hline(f, wx, wx + ww - 1, gy + gh - 1, 1);
        break;
    }
    default: {                                            /* chorus / reverb: amount bars */
        int nb = 9;
        for (int i = 0; i < nb; ++i) {
            float lvl = p == P_REVERB ? expf(-i * 0.35f) : 0.6f + 0.4f * sinf(i * 1.3f + now / 180.0f);
            int hh = (int)lroundf(lvl * pn->val[p] * (gh - 2));
            gfx_fill(f, gx + i * 6, gy + gh - 1 - hh, 4, hh, 1);
        }
        gfx_hline(f, gx, gx + gw - 1, gy + gh - 1, 1);
        break;
    }
    }
}

void ui_anim_init(ui_anim *a, const panel_t *pn)
{
    memset(a, 0, sizeof *a);
    a->prev_bank = pn->bank;
    a->seen_bank_ms = pn->bank_ms;
    a->focus_knob = -1;
    a->seen_last_ms = pn->last_ms;
}

/* compose the main area of `b` into `f`, shifted: dx > 0 moves it right */
static void blit_main(gfx_fb *f, const gfx_fb *b, int dx, int dy)
{
    for (int y = MAIN_Y; y < GFX_H; ++y) for (int x = 0; x < GFX_W; ++x) {
        int sx = x - dx, sy = y - dy;
        if (sx < 0 || sx >= GFX_W || sy < MAIN_Y || sy >= GFX_H) continue;
        if (gfx_get(b, sx, sy)) gfx_pixel(f, x, y, 1);
    }
}

void ui_render(gfx_fb *f, const panel_t *pn, const ui_live *lv, ui_anim *a, uint32_t now)
{
    /* bookkeeping: new touches, bank changes, focus timeout */
    if (pn->bank_ms != a->seen_bank_ms) { a->seen_bank_ms = pn->bank_ms; a->focus_knob = -1; a->focus_out_ms = 0; }
    if (pn->last_ms != a->seen_last_ms && pn->last_knob >= 0) {
        a->seen_last_ms = pn->last_ms;
        if (a->focus_knob < 0 || a->focus_out_ms) a->focus_in_ms = now;
        a->focus_knob = pn->last_knob;
        a->focus_out_ms = 0;
    }
    if (a->focus_knob >= 0 && !a->focus_out_ms && now - pn->last_ms > FOCUS_HOLD_MS) a->focus_out_ms = now;
    if (a->focus_out_ms && now - a->focus_out_ms > SLIDE_MS) { a->focus_knob = -1; a->focus_out_ms = 0; }

    float bs = 1.0f - ease_out((now - pn->bank_ms) / (float)SLIDE_MS);   /* 1 -> 0 */
    if (now - pn->bank_ms > SLIDE_MS) { bs = 0; a->prev_bank = pn->bank; }

    gfx_clear(f);
    const char *title = NULL;
    if (a->focus_knob >= 0 && !(bs > 0 && a->prev_bank != pn->bank)) {
        int fp = panel_param_of(pn->bank, a->focus_knob);
        static char kn[24];
        if (fp >= 0) title = panel_name(fp); else { snprintf(kn, sizeof kn, "KNOB %d", a->focus_knob + 1); title = kn; }
    }
    header(f, pn, lv, pn->bank, bs, title);

    gfx_fb ov, fo;
    gfx_clear(&ov); overview(&ov, pn, pn->bank, lv, now);
    if (bs > 0 && a->prev_bank != pn->bank) {                          /* bank change: vertical slide */
        gfx_fb old; gfx_clear(&old); overview(&old, pn, a->prev_bank, lv, now);
        int d = (int)lroundf(bs * MAIN_H), dir = pn->bank ? 1 : -1;
        blit_main(f, &old, 0, -dir * (MAIN_H - d));
        blit_main(f, &ov, 0, dir * d);
        return;
    }
    /* LOW BATTERY: at 5 % or less (on battery), 2.5 s of every 20 s */
    if (lv && lv->bat_state == UI_BAT_ON && lv->bat_pct <= 5 && now % 20000 < 2500) {
        const char *t = "LOW BATT", *u = "CHARGE NOW";
        gfx_text2(f, (GFX_W - gfx_text2_w(t)) / 2, MAIN_Y, t, 1);
        gfx_text(f, (GFX_W - gfx_text_w(u)) / 2, MAIN_Y + 15, u, 1);
        return;
    }
    if (a->focus_knob < 0) { blit_main(f, &ov, 0, 0); return; }
    gfx_clear(&fo); focus(&fo, pn, pn->bank, a->focus_knob, now);
    float s;                                                            /* 0 = overview, 1 = focus */
    if (a->focus_out_ms) s = 1.0f - ease_out((now - a->focus_out_ms) / (float)SLIDE_MS);
    else s = ease_out((now - a->focus_in_ms) / (float)SLIDE_MS);
    int off = (int)lroundf(s * GFX_W);
    blit_main(f, &ov, -off, 0);
    blit_main(f, &fo, GFX_W - off, 0);
}
