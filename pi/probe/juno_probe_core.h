/* juno_probe_core.h — the ONE render+hash used by BOTH the x86 host reference
 * and the bare-metal kernel probe. Same source, same proven bit-exact compile
 * flags on both sides, so an identical hash means bit-identical samples.
 *
 * The x86 host build is already proven EXACTLY 0 vs the plugin (make verify).
 * So: metal hash == host hash  ==>  metal == plugin, bit for bit. */
#ifndef JUNO_PROBE_CORE_H
#define JUNO_PROBE_CORE_H
#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Render one factory patch (note_on at note/vel), then FNV-1a-64 over the raw
 * stereo float output bytes. buf must hold 2*nframes floats. peak_out (may be
 * NULL) returns the max |sample| for a human sanity read. Returns 0 and sets
 * *peak_out=0 if the engine could not allocate. */
uint64_t juno_probe_render_hash(const unsigned char *bank, int banklen,
                                int patch, float sr, int note, int vel,
                                int nframes, float *buf, float *peak_out);

#ifdef __cplusplus
}
#endif
#endif
