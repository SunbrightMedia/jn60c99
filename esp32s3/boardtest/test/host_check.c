/* host_check.c -- renders the board test's sound with the device's own tone.c,
 * writes a WAV, and grades it: stage lengths, channel isolation, peaks, and the
 * beep pitch by zero crossings. Exit 0 = pass. Usage: host_check OUT.wav */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../main/tone.h"

static int fails;
#define CHECK(c, ...) do { if (!(c)) { printf("FAIL "); printf(__VA_ARGS__); printf("\n"); ++fails; } } while (0)

int main(int argc, char **argv)
{
    enum { LOOP = 400000, N = 2 * LOOP };
    static int16_t lr[2 * N];
    static int stage_of[N];
    bt_tone t; bt_tone_init(&t);
    for (int i = 0; i < N; ++i) {
        int e, p; stage_of[i] = t.stage;
        bt_tone_render(&t, lr + 2 * i, 1, &e, &p);
    }
    long len[BT_NSTAGE] = { 0 }; int pk[BT_NSTAGE][2] = { { 0 } }; long zc[BT_NSTAGE] = { 0 };
    long loop_len = 0;
    for (int i = 0; i < N && !(i > 0 && stage_of[i] == 0 && stage_of[i - 1] == BT_NSTAGE - 1); ++i) {
        int s = stage_of[i]; ++len[s]; ++loop_len;
        for (int c = 0; c < 2; ++c) { int v = abs(lr[2 * i + c]); if (v > pk[s][c]) pk[s][c] = v; }
        int c = s == BT_RIGHT;
        if (i && (lr[2 * (i - 1) + c] < 0) != (lr[2 * i + c] < 0)) ++zc[s];
    }
    for (int s = 0; s < BT_NSTAGE; ++s)
        printf("%-11s %6ld frames  peakL %5d  peakR %5d\n", bt_stage_name[s], len[s], pk[s][0], pk[s][1]);
    CHECK(len[BT_LEFT] == 66150 && len[BT_RIGHT] == 66150, "beep lengths");
    CHECK(pk[BT_LEFT][1] == 0 && pk[BT_RIGHT][0] == 0, "channel isolation");
    CHECK(pk[BT_LEFT][0] > 1000 && pk[BT_LEFT][0] <= BT_PEAK, "left peak %d", pk[BT_LEFT][0]);
    CHECK(pk[BT_RIGHT][1] > 1000 && pk[BT_RIGHT][1] <= BT_PEAK, "right peak %d", pk[BT_RIGHT][1]);
    CHECK(pk[BT_MELODY][0] > 500 && pk[BT_MELODY][0] <= BT_PEAK && pk[BT_MELODY][0] == pk[BT_MELODY][1], "melody peak");
    CHECK(pk[BT_SIL0][0] == 0 && pk[BT_SIL1][1] == 0 && pk[BT_GAP1][0] == 0 && pk[BT_GAP2][1] == 0, "silences");
    double fl = zc[BT_LEFT] / 2.0 / 1.5, fr = zc[BT_RIGHT] / 2.0 / 1.5;
    printf("pitch by zero crossings: left %.1f Hz, right %.1f Hz; loop %.3f s\n", fl, fr, loop_len / (double)BT_SR);
    CHECK(fl > 438 && fl < 442 && fr > 876 && fr < 884, "pitch");
    if (argc > 1) {   /* one loop as a 44.1 kHz stereo WAV */
        FILE *f = fopen(argv[1], "wb"); uint32_t d = (uint32_t)loop_len * 4, v;
        fwrite("RIFF", 1, 4, f); v = 36 + d; fwrite(&v, 4, 1, f); fwrite("WAVEfmt ", 1, 8, f);
        v = 16; fwrite(&v, 4, 1, f); uint16_t h[2] = { 1, 2 }; fwrite(h, 2, 2, f);
        v = BT_SR; fwrite(&v, 4, 1, f); v = BT_SR * 4; fwrite(&v, 4, 1, f);
        h[0] = 4; h[1] = 16; fwrite(h, 2, 2, f); fwrite("data", 1, 4, f); fwrite(&d, 4, 1, f);
        fwrite(lr, 4, loop_len, f); fclose(f);
    }
    printf(fails ? "HOST CHECK FAIL (%d)\n" : "HOST CHECK PASS\n", fails);
    return fails != 0;
}
