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

/* Per-voice base layout (verified from the 8 identical voice-render copies):
 *   main state block : voice v at  +320  + v*10512
 *   secondary array  : voice v at  +101504 + v*32
 * voice_render is transcribed for voice 0's absolute offsets; the driver selects
 * the per-voice base. (The plugin specialised one routine per voice; we keep one
 * routine parameterised by base.) */
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

/* juno_chorus_init — exact transcription of sub_1803A1300, the chorus/master
 * state constructor: zeroes the BBD delay buffers and writes the integer control
 * fields (delay-line lengths, ring indices) the master indexes its circular
 * buffers with. Call BEFORE juno_engine_init. Without it the master's buffer
 * masks are -1 and it reads out of bounds. (Returns the state pointer; unused.) */
void *juno_chorus_init(unsigned char *st);

/* juno_chorus_coeffs_apply — write the 241 chorus/output coefficients the master
 * reads but no static init sets (the plugin applies them at runtime from the
 * parameter system). Values are captured from the live plugin via
 * tools/capture_chorus_coeffs.js into src/chorus_coeffs_data.c. Call after
 * juno_chorus_init + juno_engine_init. No-op until the capture is pasted in. */
void juno_chorus_coeffs_apply(unsigned char *st);

/* voice_render — exact transcription of sub_180369070. Produces one mono sample
 * for one voice from its state block `st`; writes it to *outL and *outR (the
 * plugin duplicates the mono voice to both channels; stereo comes from chorus).
 * Returns the sample as a bit pattern (the decompile returns it in eax). */
uint32_t juno_voice_render(unsigned char *st, float *outL, float *outR);

/* juno_master_render — exact transcription of sub_180363380. The master process:
 * sums the 8 voice samples, runs the stereo BBD chorus, and writes the final
 * true-stereo output. Per-sample.
 *   a1 : engine state.
 *   a2 : array of 8 voice-sample pointers at EVEN indices a2[0,2,..,14] (the
 *        plugin's voice-buffer layout; odd slots are unused).
 *   a3 : {float* L, float* R} — receives 2*state[101264] (L), 2*state[101280] (R).
 * Returns a3[1] (the decompile returns the R pointer in rax); unused by callers.
 *
 * The chorus reads ~250 coefficient fields produced by sub_180388170, which is
 * not yet captured (Hex-Rays returns None on it). Until those exist the fields
 * are zero and the chorus is inert. See docs/MASTER_RENDER_MAP.md. */
float *juno_master_render(unsigned char *a1, float **a2, float **a3);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_ENGINE_H */
