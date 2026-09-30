/* Host gate for msq_core (the SAME file the firmware compiles).
 * Oracle: the MIDI 1.0 spec (running status, vel-0 = off, real-time bytes may
 * land inside a message) and the equal-tempered pitch law, measured on the
 * rendered samples by zero crossings -- not by reading msq's own inc.
 * Tooth: `sh test/run.sh` also builds with -DMSQ_TOOTH_NO_RUNNING_STATUS and
 * REQUIRES this test to FAIL. */
#include "msq_core.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define SR 48000
static int fails;
#define CHECK(c, ...) do { if (!(c)) { printf("FAIL: " __VA_ARGS__); printf("\n"); fails++; } } while (0)

static void feed(msq_t *m, const uint8_t *b, int n) { for (int i = 0; i < n; ++i) msq_byte(m, b[i]); }

/* render `sec` seconds, return measured Hz (rising crossings) and peak |x| */
static double measure(msq_t *m, double sec, int *peak)
{
    int n = (int)(sec * SR), rises = 0, pk = 0, prev = 0;
    int16_t *buf = malloc(sizeof(int16_t) * 2 * n);
    msq_render(m, buf, n);
    for (int i = 0; i < n; ++i) {
        int v = buf[2 * i];
        if (buf[2 * i + 1] != v) { printf("FAIL: L != R\n"); fails++; break; }
        if (abs(v) > pk) pk = abs(v);
        if (prev <= 0 && v > 0 && i > 0) rises++;
        prev = v;
    }
    free(buf);
    *peak = pk;
    return rises / sec;
}

static void expect_note(msq_t *m, int note, const char *what)
{
    int pk;
    measure(m, 0.02, &pk);                           /* past the attack */
    double hz = measure(m, 1.0, &pk), want = 440.0 * pow(2.0, (note - 69) / 12.0);
    CHECK(fabs(hz - want) <= 1.5, "%s: note %d measured %.1f Hz, want %.2f", what, note, hz, want);
    CHECK(pk > 8000, "%s: peak %d, want ~8192", what, pk);
}

static void expect_silent(msq_t *m, const char *what)
{
    int pk;
    measure(m, 0.02, &pk);                           /* past the 10 ms release */
    measure(m, 0.2, &pk);
    CHECK(pk == 0, "%s: peak %d after release, want exactly 0", what, pk);
}

int main(void)
{
    msq_t m;
    msq_init(&m, SR);
    expect_silent(&m, "boot");

    /* 1. plain note on / note off */
    feed(&m, (uint8_t[]){0x90, 69, 100}, 3); expect_note(&m, 69, "A4");
    feed(&m, (uint8_t[]){0x80, 69, 64}, 3);  expect_silent(&m, "A4 off");

    /* 2. running status + note-on velocity 0 as note-off (most keyboards) */
    feed(&m, (uint8_t[]){0x90, 60, 90}, 3);  expect_note(&m, 60, "C4");
    feed(&m, (uint8_t[]){60, 0}, 2);         expect_silent(&m, "C4 vel0 (running status)");
    feed(&m, (uint8_t[]){72, 80}, 2);        expect_note(&m, 72, "C5 (running status)");
    feed(&m, (uint8_t[]){72, 0}, 2);         expect_silent(&m, "C5 off");

    /* 3. real-time bytes (clock 0xF8, active sensing 0xFE) inside a message */
    feed(&m, (uint8_t[]){0x91, 0xF8, 64, 0xFE, 100}, 5); expect_note(&m, 64, "E4 with RT inside");
    feed(&m, (uint8_t[]){0x81, 64, 0xF8, 0}, 4);          expect_silent(&m, "E4 off with RT");

    /* 4. last-note priority, legato fall-back */
    feed(&m, (uint8_t[]){0x90, 48, 100, 55, 100}, 5); expect_note(&m, 55, "G3 over C3");
    feed(&m, (uint8_t[]){0x80, 55, 0}, 3);             expect_note(&m, 48, "back to C3");
    feed(&m, (uint8_t[]){0x80, 48, 0}, 3);             expect_silent(&m, "C3 off");

    /* 5. sysex in the stream does not create notes; CC 123 clears held keys */
    feed(&m, (uint8_t[]){0xF0, 0x7E, 0x10, 0x60, 0xF7}, 5); expect_silent(&m, "sysex");
    feed(&m, (uint8_t[]){0x90, 40, 100, 41, 100}, 5);
    feed(&m, (uint8_t[]){0xB0, 123, 0}, 3);                  expect_silent(&m, "CC123");

    /* 6. range ends */
    feed(&m, (uint8_t[]){0x90, 21, 100}, 3); expect_note(&m, 21, "A0");
    feed(&m, (uint8_t[]){0x90, 21, 0}, 3);   expect_silent(&m, "A0 off");
    feed(&m, (uint8_t[]){0x90, 96, 100}, 3); expect_note(&m, 96, "C7");
    feed(&m, (uint8_t[]){0x90, 96, 0}, 3);   expect_silent(&m, "C7 off");

    /* 7. key-stack overflow (17 keys held) then release all: silent */
    for (int k = 0; k < 17; ++k) feed(&m, (uint8_t[]){0x90, (uint8_t)(50 + k), 100}, 3);
    expect_note(&m, 66, "17 held -> newest");
    for (int k = 0; k < 17; ++k) feed(&m, (uint8_t[]){0x80, (uint8_t)(50 + k), 0}, 3);
    expect_silent(&m, "17 released");

    /* 8. release knob: law endpoints, and a 0.5 s release really takes 0.5 s */
    CHECK(fabsf(msq_knob_to_release(0.0f) - 0.010f) < 1e-4f, "knob 0 -> %.4f s, want 0.010", msq_knob_to_release(0.0f));
    CHECK(fabsf(msq_knob_to_release(1.0f) - 2.0f) < 1e-3f, "knob 1 -> %.4f s, want 2.0", msq_knob_to_release(1.0f));
    CHECK(fabsf(msq_knob_to_release(0.5f) - 0.1414f) < 1e-3f, "knob 0.5 -> %.4f s, want 0.1414", msq_knob_to_release(0.5f));
    {
        int pk;
        msq_set_release(&m, 0.5f);
        feed(&m, (uint8_t[]){0x90, 57, 100}, 3); expect_note(&m, 57, "A3 before long release");
        feed(&m, (uint8_t[]){0x80, 57, 0}, 3);
        measure(&m, 0.200, &pk);                 /* 0.00-0.20 s after off */
        measure(&m, 0.050, &pk);                 /* 0.20-0.25 s: level 0.6 -> 0.5 */
        CHECK(pk >= 4000 && pk <= 5000, "0.5 s release: peak %d at 0.20-0.25 s, want ~4100-4900", pk);
        measure(&m, 0.260, &pk);                 /* to 0.51 s */
        measure(&m, 0.100, &pk);
        CHECK(pk == 0, "0.5 s release: peak %d after 0.51 s, want exactly 0", pk);
        msq_set_release(&m, 0.010f);
    }

    /* 9. waveform morph: every shape and every midpoint keeps the pitch and
     *    the fundamental (phase-aligned shapes never cancel in a crossfade) */
    {
        static const float ws[] = {0.0f, 0.5f, 1.0f, 1.5f, 2.0f, 2.5f, 3.0f};
        for (unsigned k = 0; k < sizeof ws / sizeof ws[0]; ++k) {
            char what[40]; int pk;
            msq_set_wave(&m, ws[k]);
            snprintf(what, sizeof what, "wave %.1f", ws[k]);
            feed(&m, (uint8_t[]){0x90, 64, 100}, 3);
            measure(&m, 0.02, &pk);
            double hz = measure(&m, 1.0, &pk), want = 440.0 * pow(2.0, (64 - 69) / 12.0);
            CHECK(fabs(hz - want) <= 1.5, "%s: %.1f Hz, want %.2f", what, hz, want);
            CHECK(pk > 0.6 * 8192 && pk < 1.15 * 8192, "%s: peak %d, want 0.6..1.15 x 8192", what, pk);
            feed(&m, (uint8_t[]){0x80, 64, 0}, 3); expect_silent(&m, what);
        }
        msq_set_wave(&m, 3.0f);
    }
    /* 10. unison: law endpoints, loudness held, silence exact */
    CHECK(msq_unison_voices(0.0f) == 1 && msq_unison_voices(1.0f) == 7, "unison voices %d..%d, want 1..7",
          msq_unison_voices(0.0f), msq_unison_voices(1.0f));
    {
        int pk1, pk7;
        msq_set_wave(&m, 2.0f);
        feed(&m, (uint8_t[]){0x90, 57, 100}, 3); measure(&m, 0.05, &pk1); measure(&m, 0.5, &pk1);
        msq_set_unison(&m, 1.0f);                measure(&m, 0.05, &pk7); measure(&m, 0.5, &pk7);
        CHECK(pk7 > pk1 / 2 && pk7 < pk1 * 3, "unison 7: peak %d vs single %d (want within 0.5..3x)", pk7, pk1);
        feed(&m, (uint8_t[]){0x80, 57, 0}, 3); expect_silent(&m, "unison off");
        msq_set_unison(&m, 0.0f); msq_set_wave(&m, 3.0f);
        expect_silent(&m, "unison ramps down");
    }
    /* 11. attack knob: law endpoints and a timed 0.5 s attack */
    CHECK(fabsf(msq_knob_to_attack(0.0f) - 0.001f) < 1e-5f && fabsf(msq_knob_to_attack(1.0f) - 2.0f) < 1e-3f,
          "attack law %.4f..%.3f, want 0.001..2", msq_knob_to_attack(0.0f), msq_knob_to_attack(1.0f));
    {
        int pk;
        msq_set_attack(&m, 0.5f);
        feed(&m, (uint8_t[]){0x90, 57, 100}, 3);
        measure(&m, 0.200, &pk);
        measure(&m, 0.050, &pk);                 /* 0.20-0.25 s: level 0.4 -> 0.5 */
        CHECK(pk >= 3200 && pk <= 4300, "0.5 s attack: peak %d at 0.20-0.25 s, want ~3300-4100", pk);
        measure(&m, 0.300, &pk); measure(&m, 0.100, &pk);
        CHECK(pk > 8000, "0.5 s attack: peak %d after 0.55 s, want full", pk);
        feed(&m, (uint8_t[]){0x80, 57, 0}, 3); expect_silent(&m, "after attack test");
        msq_set_attack(&m, 0.002f);
    }

    printf("%s: %d failure(s); on=%u off=%u bytes=%u\n",
           fails ? "HOST TEST FAIL" : "HOST TEST PASS", fails, m.n_on, m.n_off, m.n_bytes);
    return fails ? 1 : 0;
}
