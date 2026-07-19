/* juno_driver.c — offline per-sample driver around the exact DSP transcription.
 *
 * This is the clean host glue (NO plugin threading): it renders the voices into
 * the 8 voice buffers the master expects, supplies the chorus-mode selectors
 * the master reads through a host-params pointer, and calls the master process
 * (juno_master_render = sub_180363380) to produce the final stereo sample.
 *
 * POLYPHONY: the master's input is 8 voice samples. voice_render is now
 * parameterised by voice index using the VERIFIED offset classification (diffing
 * the 8 specialised copies sub_180369070..sub_180383F20 proves every state
 * reference is main +v*10512, shared +0, or aux +v*32 — see docs/POLYPHONY.md).
 * All 8 voices are rendered by the one exact transcription each sample. NOTE: the
 * shared analog-noise block (84272..84436) must NOT chain across the 8 voices — the
 * plugin runs 8 ISOLATED engine units (BUILD sub_7FF91E0268D0 = 9x operator
 * new(0xA83010)), each stepping its OWN copy once/sample in lockstep, so every voice
 * reads the same one-step advance. juno_driver_render_voices snapshots the block and
 * restores it before each voice to reproduce that (chaining it, as an earlier version
 * did, stepped the noise 8x too fast). Each voice needs its own copy of the per-voice
 * patch coefficients: juno_bank_apply writes voice 0's block, and
 * juno_driver_seed_voices replicates it to voices 1..7 (call after apply). Global
 * coeffs (e.g. VCA level at 101072) stay single.
 */
#include "juno_engine.h"
#include "juno_driver.h"
#include "delay_recall.h"
#include "effect_modes.h"
#include <string.h>

/* Install the host-params shim into the state block. Call once after init.
 * `shim` must outlive all render calls (the state holds a pointer into it). */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode)
{
    int32_t *p39, *p551;
    void *base;

    shim->mode_v39  = chorus_mode;   /* legacy field; no longer read by the master */
    shim->mode_v551 = chorus_mode;   /* legacy field; slot 2 now follows JUNO_PROG_EFX */
    /* The master reads slot 1 (v39) through params+136 and slot 2 (v551) through
     * params+112 (see src/master_render.c). Point BOTH at the ENGINE cells the
     * per-patch recall writes so each slot follows the loaded patch's own routing:
     *   slot 1 -> state[JUNO_PROG_DLY] = DELAY TYPE  (juno_apply_delay)
     *   slot 2 -> state[JUNO_PROG_EFX] = EFFECT TYPE (juno_apply_effect_modes)
     * Pointer wiring ONLY — the cells' power-on values (DELAY 0, EFFECT 2) are
     * part of the prepared baseline written by juno_engine_prepare, exactly as
     * the plugin's constructor leaves them (poweron_routing proof). Do NOT seed
     * from chorus_mode here: an earlier revision did, and every caller passing 0
     * silently parked slot 2 in the Pan arm instead of the plugin's power-on
     * chorus, so the warm (host-idled) state diverged on every chorus patch. */
    p39  = (int32_t *)(st + JUNO_PROG_DLY);
    p551 = (int32_t *)(st + JUNO_PROG_EFX);
    memcpy(shim->params + 136, &p39,  sizeof(void *));
    memcpy(shim->params + 112, &p551, sizeof(void *));
    /* base = &shim->params, stored at state+136 (the chase's first hop) */
    base = shim->params;
    memcpy(st + 136, &base, sizeof(void *));
}

/* Replicate voice 0's per-voice state block [176,84272) to voices 1..7 so every
 * voice carries the same patch coefficients. Call once after juno_bank_apply (and
 * after juno_engine_init). The 8 blocks tile [176,84272) exactly at stride 10512;
 * the shared/global region (>=84272) and the header (<176) are left untouched. */
void juno_driver_seed_voices(unsigned char *st)
{
    const unsigned block = 176;                 /* per-voice block start          */
    int v;
    for (v = 1; v < JUNO_NUM_VOICES; ++v)
        memcpy(st + block + (unsigned)v * JUNO_VOICE_MAIN_STRIDE,
               st + block, JUNO_VOICE_MAIN_STRIDE);
}

/* Shared analog-noise/LFSR block: a self-contained noise generator + one-pole
 * filter at [84272, 84436) whose evolution reads only its own cells (no per-voice
 * input — voice_render.c:573-631). The plugin BUILDs 9 isolated engine units
 * (sub_7FF91E0268D0: nine operator new(0xA83010)); each of the 8 voice units owns
 * its own copy and steps it exactly ONCE per sample (all units lockstep, so every
 * voice reads the same value). Our single shared state would step it 8x/sample
 * (once per chained voice) and hand each voice a different noise value. */
#define JUNO_NOISE_BLOCK_OFF 84272u
#define JUNO_NOISE_BLOCK_LEN 164u        /* [84272, 84436): 11 cells x 16 - 12 */

void juno_driver_render_voices(unsigned char *st, float *vbuf)
{
    unsigned char nblk[JUNO_NOISE_BLOCK_LEN];
    int v;
    /* snapshot the block, then restore before EACH voice so all 8 step from the
     * same state (nblk) and read the identical one-step advance; after the loop the
     * block is left advanced exactly once (by the last voice) — matching the plugin. */
    memcpy(nblk, st + JUNO_NOISE_BLOCK_OFF, JUNO_NOISE_BLOCK_LEN);
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        float vr = 0.0f;
        vbuf[v] = 0.0f;
        memcpy(st + JUNO_NOISE_BLOCK_OFF, nblk, JUNO_NOISE_BLOCK_LEN);
        juno_voice_render(st, v, &vbuf[v], &vr);
    }
}

/* Render one stereo output sample: 8 voices -> 8 buffers -> master process.
 * Writes the final stereo pair to *outL / *outR. Returns 1 if the full master/
 * chorus path ran, 0 if the dry fallback was used (chorus coeffs not yet loaded). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR)
{
    float vbuf[JUNO_NUM_VOICES];     /* one mono sample per voice */
    float scratch = 0.0f;
    float *a2[16];
    int i;

    for (i = 0; i < 16; ++i) a2[i] = &scratch;        /* default: harmless */

    juno_driver_render_voices(st, vbuf);              /* 8 voices; noise block stepped once */
    for (i = 0; i < JUNO_NUM_VOICES; ++i)
        a2[2 * i] = &vbuf[i];                          /* even slots = voices */

    /* Run the full master/chorus/output stage. Every coefficient it reads is now
     * supplied bit-exactly from the binary (juno_engine_init + juno_engine_prepare
     * for the invariant/prepare state, the per-patch recall for the rest) — no
     * captured baseline — so the master always produces the faithful signal. */
    {
        float *a3[2] = { outL, outR };
        *outL = 0.0f; *outR = 0.0f;
        juno_master_render(st, a2, a3);
        /* Reproduce the x86 plugin's FTZ/DAZ: flush decayed recursive state out
         * of the denormal range so the next sample reads zeros (as it would on
         * the real CPU). Removes the denormal-op load behind the crackle. */
        juno_flush_denormals(st);
        return 1;
    }
}
