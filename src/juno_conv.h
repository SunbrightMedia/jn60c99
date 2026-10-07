/* juno_conv.h -- the plugin's render object: the step between its render driver and
 * the engine (CLAIMS B13, docs/HOST_RENDER_LAYER.md).
 *
 * The core keeps one object (core +96) for the pair (engine rate, host rate). Its
 * lookup (rva 0x343A80) takes the pair's entry from the table at rva 0xC43C30
 * (src/conv_tables.h, read from the booted plugin) and with it one of three render
 * functions: IDENTITY (rva 0x344270, the engine renders the host block itself),
 * CONVERTER (rva 0x343E30, the engine renders into the object's buffers, a polyphase
 * FIR makes the host samples) and SILENCE (rva 0x344280: zeros, no engine render --
 * host 11025 / 22050, and every pair the table does not hold). */
#ifndef JUNO_CONV_H
#define JUNO_CONV_H

#include <stdint.h>

/* the render function of a table entry (src/conv_tables.h kind) */
enum { JUNO_RO_IDENTITY = 0, JUNO_RO_CONVERTER = 1, JUNO_RO_SILENCE = 2 };

typedef struct {
    int    engine;      /* +8   the engine rate                                    */
    int    host;        /* +12  the host rate                                      */
    int    entry;       /* +0   the table entry (JUNO_CONV_N: the terminator)      */
    int    delay;       /* +16  L x ceil(coefficients / L)                         */
    int    acc42;       /* +168 the engine-sample counter (x L)                    */
    int    acc43;       /* +172 the host-sample counter (x M)                      */
    int    size;        /* the size of both buffers (std::vector<float> at +120)   */
    int    cap;         /* their allocated capacity                                */
    float *buf[2];
} juno_ro;

/* The engine render the converter calls (CWaveGen vt+56): `count` samples of
 * `nch` channels into ptrs[ch][0..count). */
typedef void (*juno_ro_render_fn)(void *user, float *const *ptrs, int nch, int count);

void juno_ro_init(juno_ro *ro, int engine, int host);   /* no lookup: entry -1 */
void juno_ro_free(juno_ro *ro);

/* The lookup, rva 0x343A80: the entry of (ro->engine, ro->host). Found: the
 * buffers reserved (4096) and set to 2 x ceil(n / L) zeros, the counters to
 * 2 x delay and delay; returns 1. Not found: the terminator (SILENCE), delay
 * and both counters 0, the buffers as they were; returns 0. Returns -1 when a
 * buffer cannot be allocated (the object is then left on SILENCE). */
int  juno_ro_lookup(juno_ro *ro);

/* JUNO_RO_IDENTITY / _CONVERTER / _SILENCE; -1 before any lookup. */
int  juno_ro_kind(const juno_ro *ro);

/* The converter, rva 0x343E30: n host samples into out[ch][0..n), ch < nch
 * (1 or 2), rendering the engine through `render` when it needs samples (once,
 * ceil-ahead, before the filter). Returns -1 when a buffer cannot grow. */
int  juno_ro_convert(juno_ro *ro, float *const *out, int nch, int n,
                     juno_ro_render_fn render, void *user);

/* The engine rate the setting vm.vs.sampleRate selects (rva 0x3222F0): the
 * value & 0x7F indexes the table at rva 0x94AB80 (0..4: 96000, 88200, 48000,
 * 44100, 32000; above 5 the bytes that follow it); 5 is the automatic setting
 * (*automatic = 1), which takes the engine's current rate (rva 0x34B260). */
int  juno_ro_setting_rate(int value, int engine_rate, int *automatic);

#endif /* JUNO_CONV_H */
