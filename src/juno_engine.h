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

/* voice_render — exact transcription of sub_180369070. Produces one mono sample
 * for one voice from its state block `st`; writes it to *outL and *outR (the
 * plugin duplicates the mono voice to both channels; stereo comes from chorus).
 * Returns the sample as a bit pattern (the decompile returns it in eax). */
uint32_t juno_voice_render(unsigned char *st, float *outL, float *outR);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_ENGINE_H */
