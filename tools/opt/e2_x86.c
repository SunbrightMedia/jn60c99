/* e2_x86.c — the Daisy firmware's E2 experiment, byte-for-byte the same driving,
 * on x86-64. Purpose: an apples-to-apples x86 cycles/sample number to divide the
 * SILICON M7 number by, plus a callgrind-countable dynamic instruction stream.
 *
 * Driving copied verbatim from daisy/juno60_daisy.cpp measure_cost():
 *   patch = tg_scenarios[0], rate 44100, warmup 1 s, half a second per point,
 *   BLOCK = 48, voice counts 0/1/2/4/8, notes 36 + 5v vel 100.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "teensy_golden.h"

typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode);
void      juno_gui_destroy(juno_ctx *c);
int  juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx);
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity);
void juno_gui_note_off(juno_ctx *c, int midi_note);
void juno_gui_warmup(juno_ctx *c, int n);
int  juno_gui_render(juno_ctx *c, float *out, int nframes);

#define E2_RATE 44100.0f
#define BLOCK   48
#define BK_HEADER 23
#define BK_STRIDE 20223
#define BK_BLOB   16

static inline uint64_t rdtsc(void)
{
    uint32_t lo, hi;
    __asm__ __volatile__("lfence\n\trdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
}

/* callgrind toggle: when run under callgrind with --toggle-collect=cg_region,
 * only the marked region is counted. Without callgrind these are free calls. */
__attribute__((noinline)) void cg_region(juno_ctx *c, float *buf, int N)
{
    for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
}

int main(int argc, char **argv)
{
    int only = (argc > 1) ? atoi(argv[1]) : -1;   /* -1 = all points */
    static float buf[2 * BLOCK];
    const tg_scenario *s = &tg_scenarios[0];
    unsigned char *bank = calloc(1, BK_HEADER + BK_STRIDE);
    memcpy(bank + BK_HEADER + BK_BLOB, s->blob, TG_BLOB_LEN);

    juno_ctx *c = juno_gui_create(E2_RATE, 0);
    if (!c) { fprintf(stderr, "create failed\n"); return 1; }
    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, (int)E2_RATE);

    const int N = (argc > 2) ? atoi(argv[2]) : ((int)E2_RATE / 2);
    const int NV[] = {0, 1, 2, 4, 8};

    for (int k = 0; k < 5; ++k) {
        if (only >= 0 && NV[k] != only) {
            /* still must play/stop notes to keep state identical */
        }
        for (int v = 0; v < NV[k]; ++v) juno_gui_note_on(c, 36 + v * 5, 100);
        uint64_t t0 = rdtsc();
        if (only < 0 || NV[k] == only) cg_region(c, buf, N);
        else { for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK); }
        uint64_t d = rdtsc() - t0;
        printf("  %d voices : %8.1f cyc/sample   (%llu cycles / %d samples)\n",
               NV[k], (double)d / N, (unsigned long long)d, N);
        fflush(stdout);
        for (int v = 0; v < NV[k]; ++v) juno_gui_note_off(c, 36 + v * 5);
        for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    }
    juno_gui_destroy(c);
    free(bank);
    return 0;
}
