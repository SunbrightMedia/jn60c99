/* juno_engine.h — state model + accessors for the C99 voice-engine transcription.
 *
 * The decompiled engine operates on a large flat state block via byte offsets
 * (e.g. *(float*)(a1 + 320)). We mirror that exactly: the state is a raw byte
 * buffer and stages address it through the F()/I() accessors below. This is a
 * literal transcription choice — it guarantees we reproduce the plugin's memory
 * layout and aliasing precisely; named fields are layered on as offsets are
 * confirmed (see docs/VOICE_RENDER_MAP.md). Build with -fno-strict-aliasing.
 */
#ifndef JUNO_ENGINE_H
#define JUNO_ENGINE_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Per-voice / shared state layout — DERIVED by diffing the offset constants of
 * the 8 specialised voice-render copies (sub_180369070..sub_180383F20); every
 * one of their 1222 state references falls into exactly one of these regions
 * (see docs/POLYPHONY.md):
 *   main per-voice block : offsets [176,10672]   -> +v*10512  (8 blocks tile
 *                          [176,84272) exactly: 176 + 8*10512 == 84272)
 *   shared global block  : offsets [84272,84432] -> +0 (all voices share it)
 *   aux one-shot edge     : offset  101504        -> +v*32
 * voice_render is one routine parameterised by voice index; voice 0 is identical
 * to the original voice-0 function. MAIN_BASE0 (320) is the first field the note
 * driver writes; the block itself starts at 176. */
#define JUNO_VOICE_MAIN_BASE0   320
#define JUNO_VOICE_MAIN_STRIDE  10512
#define JUNO_VOICE_AUX_BASE0    101504
#define JUNO_VOICE_AUX_STRIDE   32
#define JUNO_NUM_VOICES         8

/* Offset accessors into the state block `st` (an unsigned char*). The casts
 * mirror the decompile (float / dword) memory reads exactly. */
#define JF(st, off)  (*(float   *)((unsigned char *)(st) + (off)))   /* float  */
#define JI(st, off)  (*(int32_t *)((unsigned char *)(st) + (off)))   /* int32  */

/* Full engine state size. The initializer (sub_1803990C0) writes up to offset
 * ~10.69 MB (all 8 voices + global blocks); the master reads a counter at
 * +11022344. 12 MB covers the whole block with margin. */
#define JUNO_STATE_BYTES  (12u * 1024u * 1024u)

/* juno_engine_init — exact transcription of sub_1803990C0. Fills the engine
 * state `st` with the real coefficients. Set JF(st,16) to the sample rate first
 * (44100 selects one precomputed coefficient set; any other value the second).
 * Returns the sample rate it used. */
uint32_t juno_engine_init(unsigned char *st);

/* juno_engine_prepare — the coefficients the plugin's sample-rate prepare
 * (CWaveGen::setSampleRate 0x3C7A20 + smoother snap-all 0x3C29B0) writes but the
 * constructor juno_engine_init does not: 33 DSP-read voice-0 offsets (replicated
 * to voices 1..7 by seed_voices) + 57 shared/master-FX offsets (written once).
 * All binary-derived — see src/juno_prepare.c. Call AFTER juno_engine_init.
 * Verified: with these applied the C engine matches the binary's prepared state
 * on 1571/1573 DSP-read offsets (tools/oracle/full_ab.py). */
void juno_engine_prepare(unsigned char *st);

/* juno_chorus_init — exact transcription of sub_1803A1300, the chorus/master
 * state constructor: zeroes the BBD delay buffers and writes the integer control
 * fields (delay-line lengths, ring indices) the master indexes its circular
 * buffers with. Call BEFORE juno_engine_init. Without it the master's buffer
 * masks are -1 and it reads out of bounds. (Returns the state pointer; unused.) */
void *juno_chorus_init(unsigned char *st);

/* NOTE: the former juno_runtime_coeffs_apply / _loaded (a captured one-patch
 * baseline) have been RETIRED. Every coefficient the DSP reads at playback now
 * comes from the binary: juno_engine_init (constructor) + juno_engine_prepare
 * (setSampleRate + snap-all prepared state) + the per-patch recall. See
 * docs/BITEXACT_AUDIT.md. */

/* juno_flush_denormals — flush the engine's recursive DSP state (envelope,
 * filter, delay/chorus/reverb feedback) to zero, reproducing the x86 plugin's
 * SSE FTZ/DAZ behaviour that WebAssembly lacks. Call once per rendered sample;
 * prevents decayed tails from settling into the denormal range (whose ~100x
 * slower ops cause the intermittent audio crackle). See src/juno_ftz.c. */
void juno_flush_denormals(unsigned char *st);

/* juno_enable_hw_ftz — put the CPU into the plugin's SSE flush-to-zero /
 * denormals-are-zero mode (x86 only). On WebAssembly / non-SSE targets this is a
 * no-op and juno_flush_denormals() is the per-sample fallback. Call once after
 * init. juno_hw_ftz_available() returns 1 when the hardware mode was applied. */
void juno_enable_hw_ftz(void);
int  juno_hw_ftz_available(void);

/* voice_render — exact transcription of sub_180369070, parameterised by voice.
 * Produces one mono sample for voice `voice` (0..7) from engine state `base`;
 * writes it to *outL and *outR (the plugin duplicates the mono voice to both
 * channels; stereo comes from chorus). Selects per-voice offsets internally
 * (main +voice*10512, shared +0, aux +voice*32); voice==0 is bit-identical to
 * the original. Render voices in order 0..7 per sample (shared block chains).
 * Returns the sample as a bit pattern (the decompile returns it in eax). */
uint32_t juno_voice_render(unsigned char *base, int voice, float *outL, float *outR);

/* The driver's single call site goes through this pointer. It defaults to
 * juno_voice_render; an embedded harness may point it at an identically
 * compiled copy placed in another memory, to A/B code placement inside one
 * boot. Swapping it changes NO arithmetic. See src/juno_driver.c. */
extern uint32_t (*juno_voice_render_fn)(unsigned char *base, int voice,
                                        float *outL, float *outR);

/* juno_master_render — exact transcription of sub_180363380. The master process:
 * sums the 8 voice samples, runs the stereo BBD chorus, and writes the final
 * true-stereo output. Per-sample.
 *   a1 : engine state.
 *   a2 : array of 8 voice-sample pointers at EVEN indices a2[0,2,..,14] (the
 *        plugin's voice-buffer layout; odd slots are unused).
 *   a3 : {float* L, float* R} — receives 2*state[101264] (L), 2*state[101280] (R).
 * Returns a3[1] (the decompile returns the R pointer in rax); unused by callers.
 *
 * The chorus/reverb/output coefficient fields are all supplied bit-exactly from
 * the binary by juno_engine_prepare (the effect prepare/enable state) + the
 * per-patch recall (delay/reverb/chorus). See docs/MASTER_RENDER_MAP.md. */
float *juno_master_render(unsigned char *a1, float **a2, float **a3);

/* Placement A/B indirection for the master stage — see juno_voice_render_fn. */
extern float *(*juno_master_render_fn)(unsigned char *a1, float **a2, float **a3);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_ENGINE_H */
