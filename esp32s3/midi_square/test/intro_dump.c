/* Dumps the shipped intro (ui_intro) and the first overview frames at the
 * firmware's own frame clock (30 ms: pdMS_TO_TICKS(33) at 100 Hz = 3 ticks). */
#include <stdio.h>
#include "ui.h"
#include "panel.h"
int main(void)
{
    static gfx_fb f; panel_t pn; ui_anim a;
    float kk[5] = { 0.1f, 0.4f, 0.3f, 0.55f, 0.5f };
    panel_init(&pn, kk, 0); ui_anim_init(&a, &pn);
    ui_live lv = { -1, 0, {0}, UI_BAT_ON, 3.95f, 70 };
    for (unsigned t = 0; t <= UI_INTRO_MS + 1200; t += 30) {
        if (t < UI_INTRO_MS) ui_intro(&f, t); else ui_render(&f, &pn, &lv, &a, t);
        printf("%u\n", t);
        for (int y = 0; y < 32; ++y) { for (int x = 0; x < 128; ++x) putchar(gfx_get(&f, x, y) ? '#' : '.'); putchar('\n'); }
    }
    return 0;
}
