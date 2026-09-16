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

/* A deterministic seeded SCENARIO: note-on / note-off / patch-change events on
 * an absolute SAMPLE grid (from `seed`), rendered across `total_frames`. The
 * event times do not depend on `chunk`; only how the render is sliced does. So
 * the same seed rendered at chunk = total_frames (one continuous call, what the
 * plugin does) and at chunk = a small DMA block (what the I2S callback does)
 * MUST return the same hash. That equality is the proof that the real-time
 * block callback adds no boundary tick — the exact defect the S3 chain had.
 *
 * buf must hold 2*total_frames floats. Returns the FNV-1a-64 of the whole run. */
uint64_t juno_probe_timeline_hash(const unsigned char *bank, int banklen,
                                  float sr, uint32_t seed, int total_frames,
                                  int chunk, float *buf, float *peak_out);

/* THE INVARIANT gate (robustness, not bit-exact): drive the WHOLE control
 * surface with out-of-range values too, and verify every rendered sample is
 * finite and within |bound|. Returns 0 if clean, 1 if any bad sample, -1 on
 * alloc failure. buf must hold 2*total_frames floats. */
int juno_probe_fuzz(const unsigned char *bank, int banklen, float sr,
                    uint32_t seed, int total_frames, float bound, float *buf,
                    float *worst_peak, long *nbad_finite, long *nbad_bound);

#ifdef __cplusplus
}
#endif
#endif
