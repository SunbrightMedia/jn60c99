/* test_multi_instance.c -- two plugin instances on two threads must render what each
 * renders alone (task #41). The driver's record buffers were static: shared by every
 * context, so two contexts processing at once (a DAW's instances, the Pi kernel's worker
 * cores calling juno_gui_tick) overwrote each other's pending MIDI records. Each instance
 * gets dense MIDI (notes and CCs in every block, so records are always pending) through
 * juno_gui_process_ex (drv_block) and through juno_gui_tick; the concurrent runs, repeated,
 * must equal the sequential ones bit for bit. */
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef struct { int offset, type, channel, pitch; float velocity; } juno_host_note;
typedef struct { uint32_t id; int offset; double value; } juno_host_param;
void *juno_gui_create(float sample_rate, int chorus_mode);
int   juno_gui_plugin_init(void *c);
void  juno_gui_destroy(void *c);
int   juno_gui_process_ex(void *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                          int tempo_valid, double tempo, float *outL, float *outR, int n);
void  juno_gui_tick(void *c);
void  juno_gui_midi_note_on(void *c, int midi_note, int velocity);
void  juno_gui_midi_note_off(void *c, int midi_note);
void  juno_enable_hw_ftz(void);

#define N 64
#define NB 120
#define NEV 48
#define NPAR 40
#define TICKS 6000

typedef struct { int seed; float *L, *R; void *c; } job;

static uint32_t rng(uint32_t *s) { *s = *s * 1664525u + 1013904223u; return *s >> 8; }

static void *run_blocks(void *a)
{
    job *j = a;
    uint32_t s = (uint32_t)j->seed;
    int b, i;
    juno_enable_hw_ftz();
    for (b = 0; b < NB; ++b) {
        juno_host_note ev[NEV];
        juno_host_param par[NPAR];
        for (i = 0; i < NEV; ++i) {
            ev[i].offset = (int)(rng(&s) % N);
            ev[i].type = (int)(rng(&s) & 1);
            ev[i].channel = 0;
            ev[i].pitch = 36 + (int)(rng(&s) % 48);
            ev[i].velocity = (float)(rng(&s) % 128) / 127.0f;
        }
        for (i = 0; i < NPAR; ++i) {
            par[i].id = 0x0FFFC100u + (uint32_t)(i == 0 ? 3 : 12 + i);   /* CCs: one queue each */
            par[i].offset = (int)(rng(&s) % N);
            par[i].value = (double)(rng(&s) % 1000) / 999.0;
        }
        juno_gui_process_ex(j->c, ev, NEV, par, NPAR, 1, 120.0, j->L + b * N, j->R + b * N, N);
    }
    return 0;
}

static void *run_ticks(void *a)
{
    job *j = a;
    uint32_t s = (uint32_t)j->seed;
    int t;
    juno_enable_hw_ftz();
    for (t = 0; t < TICKS; ++t) {
        int k;
        for (k = 0; k < 8; ++k) {                     /* records pending at every tick */
            int note = 36 + (int)(rng(&s) % 48);
            if (rng(&s) & 1) juno_gui_midi_note_on(j->c, note, 1 + (int)(rng(&s) % 126));
            else juno_gui_midi_note_off(j->c, note);
        }
        juno_gui_tick(j->c);
    }
    for (t = 0; t < NB; ++t)                         /* the state the ticks left, as sound: the */
        juno_gui_process_ex(j->c, 0, 0, 0, 0, 1, 120.0, j->L + t * N, j->R + t * N, N);   /* state */
    return 0;                                        /* holds pointers into its own instance */
}

static job make(int seed)
{
    job j;
    j.seed = seed;
    j.L = calloc(NB * N, sizeof(float));
    j.R = calloc(NB * N, sizeof(float));
    j.c = juno_gui_create(48000.0f, 0);
    juno_gui_plugin_init(j.c);
    return j;
}

static void drop(job *j) { juno_gui_destroy(j->c); free(j->L); free(j->R); }

int main(void)
{
    job ref[2], cur[2];
    pthread_t th[2];
    int r, k, bad = 0, w;
    for (w = 0; w < 2; ++w) {                          /* 0: process blocks, 1: ticks */
        void *(*fn)(void *) = w ? run_ticks : run_blocks;
        for (k = 0; k < 2; ++k) { ref[k] = make(1000 + 77 * k); fn(&ref[k]); }
        for (r = 0; r < 12; ++r) {
            for (k = 0; k < 2; ++k) cur[k] = make(1000 + 77 * k);
            for (k = 0; k < 2; ++k) pthread_create(&th[k], 0, fn, &cur[k]);
            for (k = 0; k < 2; ++k) pthread_join(th[k], 0);
            for (k = 0; k < 2; ++k) {
                int diff = memcmp(cur[k].L, ref[k].L, NB * N * sizeof(float)) != 0 ||
                           memcmp(cur[k].R, ref[k].R, NB * N * sizeof(float)) != 0;
                if (diff) ++bad;
                drop(&cur[k]);
            }
        }
        for (k = 0; k < 2; ++k) drop(&ref[k]);
        printf("  %s: %s\n", w ? "juno_gui_tick" : "juno_gui_process_ex", bad ? "CONCURRENT != ALONE" : "equal");
        if (bad) break;
    }
    if (bad) { printf("FAIL: two instances on two threads disturb each other (%d runs differ)\n", bad); return 1; }
    printf("OK: two instances on two threads render what each renders alone (blocks + ticks, 12 runs each)\n");
    return 0;
}
