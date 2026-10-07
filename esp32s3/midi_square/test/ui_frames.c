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
    for (uint32_t t = 0; t <= UI_INTRO_MS + 100; t += 150) {
        int running = ui_intro(&f, t);
        snprintf(lab, sizeof lab, "intro t=%u ms", t); dump(&f, lab);
        if (t >= UI_INTRO_MS) CHECK(!running, "intro still running at %u ms", t);
    }
    msq_t m; msq_init(&m, 48000);     /* laws only */
    float k[5] = { 0.5f, 0.40f, 0.30f, 0.55f, 0.1f };   /* VOL, WAVE, ATK, CHOR, free */
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
    panel_knob(&pn, 0, 0.2f, now); panel_knob(&pn, 0, 0.75f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus VOLUME 75%");
    CHECK(pn.val[P_VOLUME] == 0.75f && a.focus_knob == 0, "knob 1 did not drive VOLUME (%.2f, focus %d)", pn.val[P_VOLUME], a.focus_knob);
    now += 1700; ui_render(&f, &pn, &lv, &a, now); now += 90; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus leaving (90 ms)");
    now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "back to overview");
    CHECK(a.focus_knob < 0, "focus did not leave after the hold");
    /* SHIFT to bank B */
    panel_shift(&pn, 1, now); now += 70; ui_render(&f, &pn, &lv, &a, now); dump(&f, "SHIFT: bank slide (70 ms)");
    now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "overview bank B (not caught: dotted)");
    CHECK(pn.bank == 1, "shift did not switch to bank B");
    float before = pn.val[P_RELEASE];
    /* param knob 2 sits at 0.30 (ATTACK's value); RELEASE holds 0.642 */
    panel_knob(&pn, 2, 0.45f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "RELEASE not caught: TURN hint");
    CHECK(pn.val[P_RELEASE] == before, "pick-up failed: RELEASE jumped from %.3f", before);
    panel_knob(&pn, 2, 0.70f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "RELEASE caught (crossed 0.642)");
    CHECK(pn.caught[P_RELEASE] && pn.val[P_RELEASE] == 0.70f, "pick-up did not catch on crossing");
    panel_knob(&pn, 1, 0.8f, now); now += 400;
    panel_knob(&pn, 1, 0.8f, now);
    /* unison: catch it (default 0) by passing 0 */
    panel_knob(&pn, 1, 0.0f, now); panel_knob(&pn, 1, 0.7f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus UNISON 0.70");
    panel_knob(&pn, 3, 0.25f, now); now += 400; ui_render(&f, &pn, &lv, &a, now); dump(&f, "focus REVERB");
    /* KNOB NOISE: WAVE (param knob 1) has the screen; every other knob jitters
     * +-3 % (the v6 board log) for 300 polls (VOLUME and the free param knob 4
     * too). The screen must not move. Then a real 10 % turn of param knob 3 must take it. */
    {
        panel_t q; float kk[5] = { 0.5f, 0.40f, 0.30f, 0.55f, 0.1f };
        panel_init(&q, kk, 0);
        uint32_t t = 100;
        panel_knob(&q, 1, 0.45f, t);
        unsigned r = 12345u; int moved = 0;
        for (int i = 0; i < 300; ++i) {
            t += 10;
            for (int k = 0; k <= 4; ++k) {
                if (k == 1) continue;                          /* WAVE: the focused knob, still */
                r = r * 1103515245u + 12345u;
                float j = ((int)((r >> 16) % 61) - 30) * 0.001f;
                panel_knob(&q, k, kk[k] + j, t);
            }
            if (q.last_knob != 1) moved++;
        }
        CHECK(moved == 0, "knob noise stole the screen on %d of 300 polls", moved);
        panel_knob(&q, 3, kk[3] + 0.10f, t + 10);
        CHECK(q.last_knob == 3, "a real 10%% turn of param knob 3 did not take the screen (last_knob %d)", q.last_knob);
    }
    /* INTRO TIMING (user, 2026-10-01: "the title comes in too early, then its
     * animation restarts; the line under it plays twice"). Causes: unsigned
     * time arithmetic (before a letter's start, t - start wrapped and drew the
     * letter finished), and the flat wave line was removed at 1500 ms and a
     * second line grown from the centre. Rules: no letter shows before its own
     * start time (checked every 10 ms, per letter); from the moment the wave
     * is flat (1350 ms) to the wipe, the underline is row 19 across all 128
     * columns -- it never moves, shrinks or regrows; the complete logo is held
     * still >= 500 ms (user 2026-10-01). */
    {
        gfx_fb g;
        static const char *TITLE = "Sunbright.";        /* = ui.c; the whole text appears at UI_TITLE_T0 */
        int lx[16], lw[16], nl = (int)strlen(TITLE), xc = (128 - gfx_text2_w(TITLE)) / 2;
        for (int i = 0; i < nl; ++i) { char c[2] = { TITLE[i], 0 }; lx[i] = xc; lw[i] = gfx_text2_w(c); xc += lw[i] + 2; }
        int early = 0, gaps = 0;
        for (uint32_t t = 1100; t <= UI_INTRO_WIPE; t += 2) {
            ui_intro(&g, t);
            for (int i = 0; i < nl; ++i)                   /* rows 0..7: the wave is below row 8 after 1100 ms */
                if (t < (uint32_t)UI_TITLE_T0 && lit(&g, lx[i], lx[i] + lw[i] - 1, 0, 7)) early++;
            if (t >= 1350) {                                /* the underline: row 19, every column */
                int run = 0;
                for (int x = 0; x < 128; ++x) run += gfx_get(&g, x, 19) != 0;
                if (run < 128) gaps++;
            }
        }
        /* THE HOLD: the complete logo stays still for >= 750 ms before the wipe,
         * and it is complete within 250 ms of the wave going flat ("almost
         * instantly", user 2026-10-01 v2) */
        gfx_fb h0; ui_intro(&h0, UI_INTRO_LOGO_MS);
        int moved = 0;
        CHECK(UI_INTRO_LOGO_MS == 1350, "intro: the text must appear instantly when the wave is flat (1350), not at %d", UI_INTRO_LOGO_MS);
        /* THE LAST CREST: the rightmost wave crest appears at 454 ms -- exactly
         * 150 ms earlier than v2 (604 ms with the 1000 ms reveal; user v3).
         * Measured as the last rightward jump of the rightmost lit pixel in
         * the crest rows (0..8) before the wave starts to flatten. */
        {
            int prevx = -1, last_t = -1;
            for (uint32_t t = 0; t < 900; ++t) {
                ui_intro(&g, t);
                int rx = -1;
                for (int x = 0; x < 128; ++x) for (int y = 0; y <= 8; ++y) if (gfx_get(&g, x, y)) rx = x;
                if (rx > prevx + 3) last_t = (int)t;
                prevx = rx;
            }
            CHECK(last_t == 454, "intro: the last wave crest appears at %d ms, want 454 (v2 604 - 150)", last_t);
            printf("INTRO: last crest at %d ms, text at %d ms, held %d ms, wipe ends %d ms\n",
                   last_t, UI_INTRO_LOGO_MS, UI_INTRO_HOLD_MS, UI_INTRO_MS);
        }
        for (uint32_t t = UI_INTRO_LOGO_MS; t <= UI_INTRO_LOGO_MS + 750; t += 10) {
            ui_intro(&g, t); if (memcmp(&g, &h0, sizeof g)) moved++;
        }
        ui_intro(&g, UI_INTRO_LOGO_MS - 50);
        CHECK(moved == 0 && memcmp(&g, &h0, sizeof g),
              "intro: the full logo is not held still for 750 ms (%d changed frames), or UI_INTRO_LOGO_MS is not when it completes", moved);
        CHECK(early == 0, "intro: %d letter-frames drawn before the letter's own start (it shows, then restarts)", early);
        CHECK(gaps == 0, "intro: the underline (row 19, full width) was not complete in %d of the 10 ms steps after the wave went flat", gaps);
    }
    /* BATTERY: the gauge, the four states in the 5th column, the low warning. */
    {
        int mono = 1, prev = -1;
        for (float v = 3.0f; v <= 4.3f; v += 0.005f) { int q = ui_bat_pct(v); if (q < prev) mono = 0; prev = q; }
        CHECK(mono && ui_bat_pct(4.20f) == 100 && ui_bat_pct(3.27f) == 0 && ui_bat_pct(3.84f) == 50 &&
              ui_bat_pct(3.70f) > 5 && ui_bat_pct(3.70f) < 20,
              "battery gauge: mono %d, 4.20 V %d%%, 3.27 V %d%%, 3.84 V %d%%, 3.70 V %d%%", mono,
              ui_bat_pct(4.20f), ui_bat_pct(3.27f), ui_bat_pct(3.84f), ui_bat_pct(3.70f));
        panel_t q; float kk[5] = { 0.1f, 0.5f, 0.5f, 0.5f, 0.5f };
        panel_init(&q, kk, 0);
        ui_anim b; ui_anim_init(&b, &q);
        static const struct { int st; float v; uint32_t t; const char *lab; } B[] = {
            { UI_BAT_NONE, 0, 20000, "battery: no sense wire (USB)" },
            { UI_BAT_ON, 3.92f, 21000, "battery: on battery, percent" },
            { UI_BAT_ON, 3.92f, 24000, "battery: on battery, volts" },
            { UI_BAT_CHG, 4.10f, 25000, "battery: charging" },
            { UI_BAT_FULL, 4.20f, 26000, "battery: full" },
            { UI_BAT_ON, 3.40f, 40500, "battery: LOW warning" },
        };
        for (unsigned i = 0; i < sizeof B / sizeof B[0]; ++i) {
            ui_live L = { -1, 0, {0}, B[i].st, B[i].v, ui_bat_pct(B[i].v) };
            ui_render(&f, &q, &L, &b, B[i].t); dump(&f, B[i].lab);
            if (i < 5) CHECK(lit(&f, 96, 127, 10, 31) > 20, "battery slot empty in '%s'", B[i].lab);
        }
        CHECK(lit(&f, 0, 127, 10, 31) > 60, "LOW BATT warning not drawn");
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
