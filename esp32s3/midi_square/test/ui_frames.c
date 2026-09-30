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
    ui_live lv = { 60, 0.6f };
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
    fclose(out);
    printf("%s: %d frames, %d failure(s)\n", fails ? "UI FRAMES FAIL" : "UI FRAMES PASS", nframes, fails);
    return fails != 0;
}
