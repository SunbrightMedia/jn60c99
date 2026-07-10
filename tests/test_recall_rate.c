/* test_recall_rate.c — regression guard for sample-rate-variant patch recall.
 *
 * The plugin selects a different envelope/LFO-delay/HPF curve arm by host rate,
 * and multiplies the portamento-time curve by 96000/H. juno_bank_apply reads the
 * host rate from state[16] and must reproduce that: at 96 kHz the historical
 * (c96) arms, at 48 kHz the c96-1 arms, at 44.1 kHz the c96-2 arms; portamento a
 * C/H multiply. All arms proven bit-exact 256/256 vs the plugin's recall dispatch
 * and cross-checked against juno_prepare's Class-C/A defaults
 * (scratchpad/oracle/recall_rate_spec.md). A VCF-cutoff negative control (arm 22,
 * rate-invariant) must be identical across rates.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../src/juno_engine.h"
#include "../src/juno_apply.h"
#include "../src/juno_curve.h"

#define HDR 23
#define STRIDE 20223
static void put_blob(unsigned char *rec, int bp, int v)
{ unsigned char *b = rec + 16; b[2*bp] = (v>>4)&0xF; b[2*bp+1] = v&0xF; }
static unsigned u32(unsigned char *st, int off)
{ float f = JF(st, off); unsigned b; memcpy(&b,&f,4); return b; }
static unsigned cbits(int id, int v) { float f = juno_curve(id, v); unsigned b; memcpy(&b,&f,4); return b; }

static int fails;
static void expect(unsigned char *st, int off, unsigned want, const char *tag)
{ unsigned g = u32(st, off); if (g != want) { printf("  %s: off %d %08x != %08x\n", tag, off, g, want); ++fails; } }

int main(void)
{
    unsigned char *bank = calloc(1, HDR + STRIDE);
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;

    /* representative non-trivial knob values */
    int atk = 37, dec = 91, lfod = 200, hpf = 150, porta = 173, cutoff = 153;
    put_blob(rec, 40, atk);     /* ENV1 ATTACK  (2784, curve 35 @96k) */
    put_blob(rec, 41, dec);     /* ENV1 DECAY   (2816, curve 38 @96k) */
    put_blob(rec,  7, lfod);    /* LFO DELAY    (1920, curve 44 @96k) */
    put_blob(rec, 38, hpf);     /* HPF CUTOFF   (10240, curve 41 @96k) */
    put_blob(rec, 54, porta);   /* PORTAMENTO   (624, curve 7 @96k, C/H mult) */
    put_blob(rec, 35, cutoff);  /* VCF CUTOFF   (6736, curve 22, INVARIANT) */

    struct { int rate, atk_arm, dec_arm, lfo_arm, hpf_arm; } R[3] = {
        { 96000, 35, 38, 44, 41 },
        { 48000, 34, 37, 43, 40 },
        { 44100, 33, 36, 42, 39 },
    };
    unsigned cutoff96 = 0;
    for (int i = 0; i < 3; ++i) {
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = (float)R[i].rate;
        juno_bank_apply(st, bank, 0);
        char tag[32];
        snprintf(tag, sizeof tag, "%dHz ATK", R[i].rate); expect(st, 2784, cbits(R[i].atk_arm, atk), tag);
        snprintf(tag, sizeof tag, "%dHz DEC", R[i].rate); expect(st, 2816, cbits(R[i].dec_arm, dec), tag);
        snprintf(tag, sizeof tag, "%dHz LFOd", R[i].rate); expect(st, 1920, cbits(R[i].lfo_arm, lfod), tag);
        snprintf(tag, sizeof tag, "%dHz HPF", R[i].rate); expect(st, 10240, cbits(R[i].hpf_arm, hpf), tag);
        /* portamento: juno_curve(7,porta) * (96000/rate) */
        float p = juno_curve(7, porta);
        if (R[i].rate != 96000) p *= 96000.0f / (float)R[i].rate;
        unsigned pb; memcpy(&pb, &p, 4);
        snprintf(tag, sizeof tag, "%dHz PORTA", R[i].rate); expect(st, 624, pb, tag);
        /* negative control: VCF cutoff (arm 22) must be identical at every rate */
        unsigned c = u32(st, 6736);
        if (i == 0) cutoff96 = c;
        else if (c != cutoff96) { printf("  %dHz VCF CUTOFF changed with rate (%08x != %08x) — should be invariant\n", R[i].rate, c, cutoff96); ++fails; }
    }

    free(st); free(bank);
    if (fails) { printf("FAIL: %d recall-rate check(s) drifted\n", fails); return 1; }
    printf("OK: SR-variant recall (ENV/LFO/HPF arm-select + porta C/H) bit-exact at 44100/48000/96000\n");
    return 0;
}
