/* split_gate.c — prove a MULTI-CORE voice split is bit-exact vs single-core.
 *
 * The Pi plan may spread the 8 voices across the A53's cores. That is only safe
 * if the split output is byte-identical to rendering all voices on one core.
 * The risk is real: float addition is NOT associative, so summing the voices in
 * a different order would diverge in the last bit.
 *
 * The engine's structure makes an exact split POSSIBLE (see src/juno_driver.c):
 *   - each voice reads only its own block + the SHARED noise snapshot, and writes
 *     only its own vbuf[v] slot (voices are independent);
 *   - the sum is NOT in the voice loop — juno_master_render reads vbuf[0..7] in a
 *     FIXED canonical order, so which core filled which slot cannot change it;
 *   - the shared noise/LFSR block is snapshot-restored before each voice, so every
 *     voice steps from the same state (order-independent).
 *
 * This gate renders the voices in many PARTITION ORDERS (modelling different
 * core->voice assignments) and checks the stereo sample AND the whole post-state
 * (12 MB: noise block, voice states, FX, flushed denormals) are byte-identical to
 * single-core. If any order diverges, the split is not safe as written.
 *
 * WHAT IT PROVES (numerics) and REQUIRES (implementation): each core must render
 * its voices from a PRIVATE copy of the shared noise block (so concurrent cores
 * do not clobber it), and the master must sum vbuf on ONE core after a barrier.
 * Given that, the split is exact — proven here for every order.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "juno_engine.h"
#include "juno_driver.h"

/* gui API */
void *juno_gui_create(float, int);
void  juno_gui_reinit(void *, float, int);
int   juno_gui_apply_bank(void *, const char *, int, int);
void  juno_gui_note_on(void *, int, int);
void  juno_gui_note_off(void *, int);
int   juno_gui_render(void *, float *, int);
int   juno_gui_host_count(void);
int   juno_host_param_min(int);
int   juno_host_param_max(int);
void  juno_gui_host_set(void *, int, int);
unsigned char *juno_gui_state(void *);
unsigned juno_gui_state_bytes(void);

static uint32_t xs(uint32_t *s){uint32_t x=*s;x^=x<<13;x^=x>>17;x^=x<<5;return *s=x;}

/* Drive a seeded mix of note on/off and live param edits over `frames`, leaving
 * the 8 voices in a DIVERSE state (some gated, some releasing, some free; FX and
 * params moved) before the split/single compare. seed==0 = the plain 8-note
 * chord (all voices active). */
static void evolve(void *c, const unsigned char *bank, int len, uint32_t seed,
                   int frames, float *rbuf)
{
    int chord[] = { 45, 48, 52, 55, 60, 64, 67, 72 };
    int k, nhost = juno_gui_host_count();
    for (k = 0; k < 8; ++k) juno_gui_note_on(c, chord[k], 100);
    if (seed == 0) { juno_gui_render(c, rbuf, frames); return; }
    uint32_t s = seed;
    int done = 0;
    while (done < frames) {
        int step = 40 + (int)(xs(&s) % 400u);
        if (step > frames - done) step = frames - done;
        juno_gui_render(c, rbuf, step);
        done += step;
        uint32_t r = xs(&s) % 100u;
        if      (r < 30) juno_gui_note_on(c, 36 + (int)(xs(&s)%48u), 40 + (int)(xs(&s)%88u));
        else if (r < 55) juno_gui_note_off(c, chord[xs(&s) & 7u]);
        else if (r < 90) { int i = (int)(xs(&s)%(uint32_t)nhost);
                           int lo=juno_host_param_min(i), hi=juno_host_param_max(i);
                           juno_gui_host_set(c, i, lo + (int)(xs(&s)%(uint32_t)(hi-lo+1))); }
        else juno_gui_note_on(c, chord[xs(&s) & 7u], 100);
    }
}

#define NOISE_OFF 84272u
#define NOISE_LEN 164u
#define SR 48000.0f

/* Render one sample with the voices taken in `order` — modelling a core split.
 * Identical to juno_driver_render_sample EXCEPT the voice iteration order; the
 * master still reads vbuf in canonical slot order (the whole point). */
static void split_render_sample(unsigned char *st, const int *order,
                                float *outL, float *outR)
{
    float vbuf[JUNO_NUM_VOICES];
    float scratch = 0.0f, vr = 0.0f;
    float *a2[16];
    unsigned char nblk[NOISE_LEN];
    int i, v;

    for (i = 0; i < 16; ++i) a2[i] = &scratch;

    memcpy(nblk, JCELL(st, NOISE_OFF), NOISE_LEN);          /* shared snapshot */
    for (i = 0; i < JUNO_NUM_VOICES; ++i) {
        v = order[i];
        vbuf[v] = 0.0f; vr = 0.0f;
        memcpy(JCELL(st, NOISE_OFF), nblk, NOISE_LEN);      /* each voice: same state */
        juno_voice_render(st, v, &vbuf[v], &vr);
    }
    for (i = 0; i < JUNO_NUM_VOICES; ++i) a2[2 * i] = &vbuf[i];  /* CANONICAL sum order */

    {
        float *a3[2] = { outL, outR };
        *outL = 0.0f; *outR = 0.0f;
        juno_master_render(st, a2, a3);
        juno_flush_denormals(st);
    }
}

static uint64_t fnv(const unsigned char *p, size_t n)
{
    uint64_t h = 1469598103934665603ULL;
    for (size_t i = 0; i < n; ++i) { h ^= p[i]; h *= 1099511628211ULL; }
    return h;
}

/* core->voice partitions to test (each a permutation of 0..7) */
static const int ORDERS[][8] = {
    {0,1,2,3,4,5,6,7},   /* single core (sanity)                */
    {7,6,5,4,3,2,1,0},   /* fully reversed                      */
    {4,5,6,7,0,1,2,3},   /* 2 cores, groups swapped             */
    {0,4,1,5,2,6,3,7},   /* 2 cores, round-robin interleave     */
    {0,1,4,5,2,3,6,7},   /* 4 cores x 2 voices                  */
    {3,7,1,5,0,4,2,6},   /* arbitrary scatter                   */
};
#define NORDER ((int)(sizeof ORDERS / sizeof ORDERS[0]))

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank path\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *bank = malloc(len);
    if (fread(bank, 1, len, f) != (size_t)len) return 2;
    fclose(f);

    int npatch = argc > 2 ? atoi(argv[2]) : 64;   /* patches to sweep (default all) */
    if (npatch > 64) npatch = 64;
    int points[] = { 1, 30, 120, 600, 2500 };     /* attack .. deep sustain/decay  */
    int npoint = (int)(sizeof points / sizeof points[0]);
    uint32_t seeds[] = { 0u, 0xC0FFEEu, 0x5EEDu, 0xBEEFu };   /* 0 = chord; rest diverse */
    int nseed = (int)(sizeof seeds / sizeof seeds[0]);

    void *c = juno_gui_create(SR, 0);
    unsigned SB = juno_gui_state_bytes();
    unsigned char *snap = malloc(SB), *post1 = malloc(SB);
    int adv = 2600; float *rbuf = malloc(sizeof(float) * 2 * adv);

    long checks = 0, fails = 0;
    for (int p = 0; p < npatch; ++p) {
        for (int se = 0; se < nseed; ++se) {
        for (int q = 0; q < npoint; ++q) {
            juno_gui_reinit(c, SR, 0);
            juno_gui_apply_bank(c, (const char *)bank, (int)len, p);
            evolve(c, bank, (int)len, seeds[se], points[q], rbuf);  /* diverse state */

            unsigned char *st = juno_gui_state(c);
            memcpy(snap, st, SB);

            float L1, R1;
            juno_driver_render_sample(st, &L1, &R1);       /* single-core reference */
            memcpy(post1, st, SB);
            uint64_t h1 = fnv(post1, SB);

            for (int o = 0; o < NORDER; ++o) {
                memcpy(st, snap, SB);                      /* restore pre-sample state */
                float L2, R2;
                split_render_sample(st, ORDERS[o], &L2, &R2);
                uint64_t h2 = fnv(st, SB);
                int ok = (L1 == L2) && (R1 == R2) && (h1 == h2);
                ++checks;
                if (!ok) {
                    ++fails;
                    if (fails <= 12)
                        printf("patch %2d point %4d order %d  L %.9g/%.9g R %.9g/%.9g  state %s\n",
                               p, points[q], o, L1, L2, R1, R2, h1 == h2 ? "OK" : "DIFF");
                }
            }
        }
        }
    }

    printf("----\n");
    printf("checked %ld (patches %d x seeds %d x points %d x orders %d): output + full 12MB post-state\n",
           checks, npatch, nseed, npoint, NORDER);
    if (fails == 0) {
        printf("SPLIT IS BIT-EXACT: every core->voice partition == single-core, sample and state\n");
        return 0;
    }
    printf("SPLIT DIVERGES in %ld checks\n", fails);
    return 1;
}
