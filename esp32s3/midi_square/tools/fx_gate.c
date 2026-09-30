/* fx_gate.c -- THE FIRMWARE'S FX PATH (main/fx.c + main/gen/msq_fx.h) MUST BE
 * BIT-IDENTICAL TO THE PROVEN RECALL PATH. Reference: the port's recall with
 * the EFFECT DEPTH / REVERB LEVEL bytes really set, eb_master_state_seed, then
 * eb_master_render. Candidate: fx_init + fx_set_* + fx_process_f. Same input
 * (the minisynth voice: a unison saw note, then silence for the tail).
 * Mid-stream knob moves are compared against a mid-stream coefficient rebuild
 * (state continues), which is what the firmware does.
 * Build with -DMSQ_FX_TOOTH: fx_set_reverb(200) is one LSB off -> MUST FAIL. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "fx_recall.h"
#include "fx.h"
#include "msq_core.h"
#include "gen/msq_fx.h"

#define N 96000                       /* 2 s: 0.8 s note, then the tail */
static float VOICE[N], RL[N], RR[N], CL[N], CR[N];

static void make_voice(void)
{
    msq_t m; msq_init(&m, 48000);
    msq_set_wave(&m, 2.0f); msq_set_unison(&m, 0.8f); msq_set_release(&m, 0.2f);
    const uint8_t on[3] = {0x90, 57, 100}, off[3] = {0x80, 57, 0};
    for (int i = 0; i < 3; ++i) msq_byte(&m, on[i]);
    msq_render_f(&m, VOICE, 38400);
    for (int i = 0; i < 3; ++i) msq_byte(&m, off[i]);
    msq_render_f(&m, VOICE + 38400, N - 38400);
}

static int scenario(int d0, int l0, int d1, int l1, int at)
{
    int p = MSQ_FX_BASE_PATCH;
    static eb_master_coef mc; static eb_master_state ms;
    static unsigned char *mem;
    if (!mem) mem = malloc(msq_fx_state_bytes);
    /* reference */
    setp(p, R_EFX_TYPE, 3); setp(p, R_EFX_TONE, 0); setp(p, R_REV_TYPE, 2);
    setp(p, R_EFX_DEPTH, d0); setp(p, R_REV_LEVEL, l0);
    boot(48000); recall(p, &mc, &ms);
    const eb_master_rings rings = {0};
    float v[8] = {0};
    for (int i = 0; i < N; ++i) {
        if (i == at) { setp(p, R_EFX_DEPTH, d1); setp(p, R_REV_LEVEL, l1); boot(48000); recall(p, &mc, NULL); }
        v[0] = VOICE[i] * FX_IN_GAIN;
        eb_master_render(&ms, &mc, &rings, v, &RL[i], &RR[i]);
    }
    /* candidate */
    fx_init(mem); fx_set_chorus(d0); fx_set_reverb(l0);
    fx_process_f(VOICE, CL, CR, at);
    fx_set_chorus(d1); fx_set_reverb(l1);
    fx_process_f(VOICE + at, CL + at, CR + at, N - at);
    int diff = 0, first = -1; float pk = 0, tail = 0;
    for (int i = 0; i < N; ++i) {
        if (memcmp(&RL[i], &CL[i], 4) || memcmp(&RR[i], &CR[i], 4)) { if (first < 0) first = i; diff++; }
        pk = fmaxf(pk, fmaxf(fabsf(RL[i]), fabsf(RR[i])));
        if (i > N - 4800) tail = fmaxf(tail, fmaxf(fabsf(RL[i]), fabsf(RR[i])));
        if (!isfinite(CL[i]) || !isfinite(CR[i])) { printf("  non-finite output at %d\n", i); return 1; }
    }
    printf("  depth %3d->%3d level %3d->%3d at %5d: %s (%d diffs, first %d)  peak %.4f  last-0.1s %.2e  overrun %d\n",
           d0, d1, l0, l1, at, diff ? "DIFF" : "EXACTLY 0", diff, first, pk, tail, fx_overrun());
    return diff != 0 || fx_overrun() != 0;
}

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "usage: %s <bank.bin>\n", argv[0]); return 2; }
    FILE *f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long bl = ftell(f); fseek(f, 0, SEEK_SET);
    BANK = malloc((size_t)bl); if (fread(BANK, 1, (size_t)bl, f) != (size_t)bl) return 2; fclose(f);
    ST = malloc(JUNO_STATE_BYTES);
    make_voice();
    int bad = 0;
    bad |= scenario(0, 0, 0, 0, N);
    bad |= scenario(255, 0, 255, 0, N);
    bad |= scenario(0, 255, 0, 255, N);
    bad |= scenario(128, 128, 128, 128, N);
    bad |= scenario(37, 201, 37, 201, N);
    bad |= scenario(0, 0, 200, 200, 20000);          /* knobs move mid-note */
    bad |= scenario(255, 90, 1, 0, 50000);           /* and in the tail */
    printf("%s\n", bad ? "FX GATE FAIL" : "FX GATE PASS: firmware FX path == proven recall path, bit for bit");
    return bad;
}
