/* juno_ftz.c — flush-to-zero shim for the recursive DSP state.
 *
 * WHY THIS EXISTS (portability, not a guess): the original plugin runs on x86
 * with the SSE FTZ (flush-to-zero) + DAZ (denormals-are-zero) MXCSR bits set —
 * the standard mode every audio host uses — so a denormal float result is
 * silently written as 0 and a denormal operand is read as 0. WebAssembly (and
 * strict IEEE C) has no such mode, so as a note's envelope, filter and amp
 * feedback tails decay toward zero they settle into the DENORMAL range
 * (|x| < 1.18e-38) and STAY there. Every subsequent multiply/add that touches a
 * denormal costs ~2 orders of magnitude more on most CPUs; with ~100 such slots
 * alive per sample the audio callback intermittently blows its deadline → the
 * "crackle when playing notes". Flushing these slots to zero each sample
 * reproduces the plugin's FTZ/DAZ behaviour EXACTLY (denormal→0), so it is
 * bit-faithful, and it removes the denormal load that causes the crackle.
 *
 * The slot list is the per-voice recursive DSP state, recovered by decaying
 * notes across many patch configs and unioning every offset that settled
 * denormal. Two classes of offset are deliberately EXCLUDED because their bit
 * patterns only *look* denormal:
 *   - the header/shared region [0,176): holds the host-shim base POINTER at
 *     st+136 (8 bytes) + captured header constants;
 *   - the effect region's delay/chorus/reverb line METADATA (buffer lengths and
 *     read/write indices, e.g. 0x00080000 = 524288): these are used as INTEGERS,
 *     never in float arithmetic, so they cause no denormal slowdown, but zeroing
 *     them corrupts the delay geometry → out-of-bounds write → crash.
 * Flushing either class corrupts a pointer/index the master's parameter chase or
 * a delay line dereferences (master_render.c:853) and crashes.
 *
 * Slots flushed (per-voice, replicated to all 8 voices at stride 10512, all
 * >= 176): the ENV1/ENV2 integrators (2720/2736, 3200/3216) and the amp/output
 * filter state (9904/9920/9936/10160/10416..10496).
 */
#include "juno_engine.h"
#include <math.h>
#include <float.h>

/* Enable the CPU's hardware flush-to-zero / denormals-are-zero mode, matching the
 * exact SSE MXCSR state the plugin (and every x86 audio host) runs in. On x86 this
 * makes the ENTIRE engine compute in the plugin's floating-point mode — the most
 * faithful reproduction possible — so denormals never even form. WebAssembly and
 * targets without SSE have no such mode; there this is a no-op and the per-sample
 * juno_flush_denormals() below is the fallback. Call once after engine init. */
#if defined(__SSE__) && !defined(__EMSCRIPTEN__)
#include <xmmintrin.h>
#include <pmmintrin.h>   /* _MM_SET_DENORMALS_ZERO_MODE (DAZ) */
void juno_enable_hw_ftz(void)
{
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);        /* FTZ: denormal result -> 0 */
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON); /* DAZ: denormal operand -> 0 */
}
int juno_hw_ftz_available(void) { return 1; }
#else
void juno_enable_hw_ftz(void) { /* no hardware FTZ (WASM/other): explicit flush used */ }
int juno_hw_ftz_available(void) { return 0; }
#endif

/* structural per-voice recursive-state offsets (relative to the voice block,
 * all >= 176 so they never touch the header/shim-pointer region). */
static const int VOICE_OFF[] = {
    2720, 2736, 3200, 3216,
    9904, 9920, 9936, 10160,
    10416, 10432, 10448, 10480, 10496
};
#define N_VOICE ((int)(sizeof(VOICE_OFF)/sizeof(VOICE_OFF[0])))

static inline void ftz(unsigned char *st, unsigned off)
{
    float f = JF(st, off);
    /* denormal (nonzero, sub-FLT_MIN magnitude) -> 0, matching x86 FTZ/DAZ */
    if (f != 0.0f && fabsf(f) < FLT_MIN) JF(st, off) = 0.0f;
}

/* Flush the engine's recursive DSP state. Call once per rendered sample, after
 * the voice + master render, so the NEXT sample reads zeros where the plugin's
 * FTZ/DAZ would. Cheap: 13*8 slot checks per sample. */
void juno_flush_denormals(unsigned char *st)
{
    int v, i;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        unsigned base = (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
        for (i = 0; i < N_VOICE; ++i) ftz(st, base + (unsigned)VOICE_OFF[i]);
    }
}
