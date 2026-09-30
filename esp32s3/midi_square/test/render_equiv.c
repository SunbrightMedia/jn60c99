/* RENDER EQUIVALENCE: the shipped voice renderer (main/msq_core.c) against the
 * FROZEN v6 renderer (test/ref_render.c), BIT FOR BIT, per voice and summed,
 * over random notes, waves, morphs, unison moves (gain ramps), attack and
 * release. The tooth build (-DMSQ_TOOTH_RENDER, the ramp gain is never
 * written back) MUST fail. */
#include <stdio.h>
#include <string.h>
#include "msq_core.h"
void ref_init(void);
void ref_render_voices(msq_t *m, int v0, int v1, float *out, int n);

static uint32_t rs = 12345;
static uint32_t rnd(void) { rs ^= rs << 13; rs ^= rs >> 17; rs ^= rs << 5; return rs; }
static void both(msq_t *a, msq_t *b, uint8_t x) { msq_byte(a, x); msq_byte(b, x); }

int main(void)
{
    static msq_t mn, mr, sn, sr;
    msq_init(&mn, 48000); msq_init(&mr, 48000); msq_init(&sn, 48000); msq_init(&sr, 48000);
    ref_init();
    static const float waves[] = { 0, 0.5f, 1, 1.3f, 2, 2.5f, 2.99f, 3 };
    long samples = 0, bad = 0, sum_bad = 0, voiced = 0;
    float a[240], b[240];
    for (int blk = 0; blk < 6000; ++blk) {
        uint32_t r = rnd();
        if (r % 7 == 0) {                                   /* a note event */
            uint8_t note = 36 + rnd() % 48, on = rnd() % 3 != 0;
            uint8_t ev[3] = { (uint8_t)(on ? 0x90 : 0x80), note, (uint8_t)(on ? 1 + rnd() % 127 : 0) };
            for (int i = 0; i < 3; ++i) { both(&mn, &mr, ev[i]); both(&sn, &sr, ev[i]); }
        }
        if (r % 53 == 0) { float w = waves[rnd() % 8]; msq_set_wave(&mn, w); msq_set_wave(&mr, w); msq_set_wave(&sn, w); msq_set_wave(&sr, w); }
        if (r % 41 == 0) { float u = (rnd() % 101) / 100.0f; msq_set_unison(&mn, u); msq_set_unison(&mr, u); msq_set_unison(&sn, u); msq_set_unison(&sr, u); }
        if (r % 97 == 0) { float x = (rnd() % 101) / 100.0f; float at = msq_knob_to_attack(x), rl = msq_knob_to_release(1 - x);
            msq_set_attack(&mn, at); msq_set_attack(&mr, at); msq_set_attack(&sn, at); msq_set_attack(&sr, at);
            msq_set_release(&mn, rl); msq_set_release(&mr, rl); msq_set_release(&sn, rl); msq_set_release(&sr, rl); }
        int n = (blk % 5 == 0) ? 1 + rnd() % 240 : 240;     /* odd lengths too */
        for (int k = 0; k < MSQ_VOICES; ++k) {              /* per voice */
            msq_render_mask(&mn, 1u << k, a, n);
            ref_render_voices(&mr, k, k + 1, b, n);
            for (int i = 0; i < n; ++i) if (a[i] != 0.0f) voiced++;
            if (memcmp(a, b, n * sizeof *a)) bad++;
        }
        msq_render_mask(&sn, (1u << MSQ_VOICES) - 1, a, n); /* summed, all voices */
        ref_render_voices(&sr, 0, MSQ_VOICES, b, n);
        if (memcmp(a, b, n * sizeof *a)) sum_bad++;
        samples += n;
    }
    int ok = bad == 0 && sum_bad == 0 && voiced > samples;   /* and it was not silence */
    printf("RENDER EQUIV vs frozen v6: %ld samples x %d voices, %ld nonzero, per-voice blocks differing %ld, "
           "summed blocks differing %ld  %s\n", samples, MSQ_VOICES, voiced, bad, sum_bad, ok ? "PASS (bit-exact)" : "FAIL");
    return ok ? 0 : 1;
}
