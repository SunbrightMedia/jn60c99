/* Host frame dump: renders the real ui.c / panel.c / gfx.c into raw 128x32
 * frames (one byte per pixel, 0/1) for test/frames_png.py. Checks too:
 * the intro ends, the focus view appears on a turn and leaves after the hold,
 * pick-up blocks a jump after a bank change. */
#include "ui.h"
#include "msq_core.h"
#include <stdio.h>
#include <string.h>

static FILE *out;
static int nframes, fails;
static void dump(const gfx_fb *f, const char *label)
{
    fprintf(out, "%s\n", label);
    for (int y = 0; y < GFX_H; ++y) { for (int x = 0; x < GFX_W; ++x) fputc(gfx_get(f, x, y) ? '#' : '.', out); fputc('\n', out); }
    nframes++;
}
#define CHECK(c, ...) do { if (!(c)) { printf("FAIL: " __VA_ARGS__); printf("\n"); fails++; } } while (0)
static int lit(const gfx_fb *f, int x0, int x1, int y0, int y1)
{ int n = 0; for (int y = y0; y <= y1; ++y) for (int x = x0; x <= x1; ++x) n += gfx_get(f, x, y); return n; }

int main(int argc, char **argv)
{
    out = fopen(argc > 1 ? argv[1] : "frames.txt", "w");
    gfx_fb f; char lab[64];
    for (uint32_t t = 0; t <= 2700; t += 150) {
        int running = ui_intro(&f, t);
        snprintf(lab, sizeof lab, "intro t=%u ms", t); dump(&f, lab);
        if (t >= 2700) CHECK(!running, "intro still running at %u ms", t);
    }
    msq_t m; msq_init(&m, 48000);     /* laws only */
    float k[5] = { 0.1f, 0.40f, 0.30f, 0.55f, 0.5f };
    panel_t pn; panel_init(&pn, k, 0);
    ui_anim a; ui_anim_init(&a, &pn);
    ui_live lv = { 60, 0.6f, {2, 2, 1, 0, 0, 0} };
    uint32_t now = 5000;
    ui_render(&f, &pn, &lv, &a, now); dump(&f, "overview bank A (WAVE 0.40, ATTACK, CHORUS)");
    CHECK(lit(&f, 0, 127, 10, 31) > 60, "overview empty");
    panel_knob(&pn, 1, 0.45f, now); now += 60; ui_render(&f, &pn, &lv, &a, now); dump(&f, "turn WAVE: slide-in (60 ms)");
    now += 300; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus WAVE");
    CHECK(lit(&f, 68, 127, 10, 31) > 40, "focus WAVE picture missing");
    uint32_t tt = now;
    for (float v = 0.0f; v <= 1.001f; v += 0.25f) {
        panel_knob(&pn, 1, v, now); now += 200; ui_render(&f, &pn, &lv, &a, now);
        snprintf(lab, sizeof lab, "focus WAVE = %.2f", v); dump(&f, lab);
    }
    (void)tt;
    panel_knob(&pn, 2, 0.6f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus ATTACK");
    panel_knob(&pn, 3, 0.7f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus CHORUS");
    panel_knob(&pn, 4, 0.2f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus knob 5 (free)");
    now += 1700; ui_render(&f, &pn, &lv, &a, now); now += 90; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus leaving (90 ms)");
    now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "back to overview");
    CHECK(a.focus_knob < 0, "focus did not leave after the hold");
    /* SHIFT to bank B */
    panel_knob(&pn, 0, 0.9f, now); now += 70; ui_render(&f, &pn, &lv, &a, now); dump(&f, "SHIFT: bank slide (70 ms)");
    now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "overview bank B (not caught: dotted)");
    CHECK(pn.bank == 1, "shift did not switch to bank B");
    float before = pn.val[P_RELEASE];
    /* knob 3 sits at 0.30 (ATTACK's value); RELEASE holds 0.642 */
    panel_knob(&pn, 2, 0.45f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "RELEASE not caught: TURN hint");
    CHECK(pn.val[P_RELEASE] == before, "pick-up failed: RELEASE jumped from %.3f", before);
    panel_knob(&pn, 2, 0.70f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "RELEASE caught (crossed 0.642)");
    CHECK(pn.caught[P_RELEASE] && pn.val[P_RELEASE] == 0.70f, "pick-up did not catch on crossing");
    panel_knob(&pn, 1, 0.8f, now); now += 400;
    panel_knob(&pn, 1, 0.8f, now);
    /* unison: catch it (default 0) by passing 0 */
    panel_knob(&pn, 1, 0.0f, now); panel_knob(&pn, 1, 0.7f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus UNISON 0.70");
    panel_knob(&pn, 3, 0.25f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus REVERB");
    /* KNOB NOISE: WAVE has the screen; every other knob jitters +-3 % (the v6 board log) for
     * 300 polls and knob 5 floats full-range. The screen must not move. Then a
     * real 10 % turn of knob 4 must take it. */
    {
        panel_t q; float kk[5] = { 0.1f, 0.40f, 0.30f, 0.55f, 0.5f };
        panel_init(&q, kk, 0);
        uint32_t t = 100;
        panel_knob(&q, 1, 0.45f, t);
        unsigned r = 12345u; int moved = 0;
        for (int i = 0; i < 300; ++i) {
            t += 10;
            for (int k = 2; k <= 3; ++k) {
                r = r * 1103515245u + 12345u;
                float j = ((int)((r >> 16) % 61) - 30) * 0.001f;
                panel_knob(&q, k, kk[k] + j, t);
            }
            r = r * 1103515245u + 12345u;
            panel_knob(&q, 4, (r >> 16) % 1000 / 1000.0f, t);
            if (q.last_knob != 1) moved++;
        }
        CHECK(moved == 0, "knob noise stole the screen on %d of 300 polls", moved);
        panel_knob(&q, 3, kk[3] + 0.10f, t + 10);
        CHECK(q.last_knob == 3, "a real 10%% turn of knob 4 did not take the screen (last_knob %d)", q.last_knob);
    }
    /* DIMMING: full for 10 s idle, then a smooth fade to the deepest dim
     * (contrast 0, pre-charge 0x11, VCOMH 0x00); every register moves one way
     * in small steps per 30 ms frame. */
    {
        uint8_t c, p, v, pc, pp, pv;
        ui_dim_regs(ui_dim(0), &pc, &pp, &pv);
        CHECK(pc == UI_CONTRAST_FULL && pp == 0xF1 && pv == 0x40, "not full at 0 idle: %d %02x %02x", pc, pp, pv);
        CHECK(ui_dim(UI_DIM_AFTER_MS) == 0, "screen dims before %d ms idle", UI_DIM_AFTER_MS);
        int mono = 1, wc = 0, wp = 0, wv = 0;
        for (uint32_t t = 0; t < 20000; t += 30) {
            ui_dim_regs(ui_dim(t), &c, &p, &v);
            if (c > pc || p > pp || v > pv) mono = 0;
            if (pc - c > wc) wc = pc - c;
            if ((pp >> 4) - (p >> 4) > wp) wp = (pp >> 4) - (p >> 4);
            if (pv != v) wv++;
            pc = c; pp = p; pv = v;
        }
        CHECK(pc == 0 && pp == 0x11 && pv == 0x00, "deepest dim is %d %02x %02x, want 0 11 00", pc, pp, pv);
        CHECK(mono && wc <= 8 && wp <= 1 && wv == 3, "dim fade not smooth: monotonic %d, worst contrast step %d, "
              "pre-charge step %d, VCOMH changes %d (want 3)", mono, wc, wp, wv);
        printf("DIM: contrast %d->0, pre-charge F1->11, VCOMH 40->00 over %d ms after %d ms idle; "
               "worst step per frame: contrast %d, pre-charge %d\n", UI_CONTRAST_FULL, UI_DIM_FADE_MS,
               UI_DIM_AFTER_MS, wc, wp);
    }
    fclose(out);
    printf("%s: %d frames, %d failure(s)\n", fails ? "UI FRAMES FAIL" : "UI FRAMES PASS", nframes, fails);
    return fails != 0;
}
