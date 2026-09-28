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

    printf("%s: %d failure(s); on=%u off=%u bytes=%u\n",
           fails ? "HOST TEST FAIL" : "HOST TEST PASS", fails, m.n_on, m.n_off, m.n_bytes);
    return fails ? 1 : 0;
}
