/* fx_chorus_probe.c — FX-isolation probe for the ENGINE B chorus specification.
 *
 * Drives the SEALED port's master stage (juno_master_render) directly with
 * synthetic voice inputs, so the chorus block can be observed with a known
 * signal instead of a note. Reads back state cells per sample so the BBD ring,
 * the tap indices, the interpolation fraction and the LFO phase can be measured
 * rather than read off the decompile.
 *
 * This probe NEVER writes an engine cell that the DSP reads (except through the
 * bridge's own setters) — it only supplies the master's input argument and
 * copies cells out.
 *
 * Build: cc -O2 -shared -fPIC -o fx_chorus_probe.so fx_chorus_probe.c -L. -ljuno
 */
#include <string.h>
#include <stdint.h>

extern float *juno_master_render(unsigned char *, float **, float **);

/* juno_ctx's first member is `unsigned char *st` (gui/juno_bridge.c). */
unsigned char *pb_state(void *ctx) { return *(unsigned char **)ctx; }

uint32_t pb_peek32(unsigned char *st, int off)
{
    uint32_t u; memcpy(&u, st + off, 4); return u;
}

/* Render n samples of the MASTER stage only. in[i] is fed to voice 0; the other
 * seven voice slots are zero. outL/outR receive the final master output.
 * If offs != 0, trace[i*noff + k] receives cell offs[k] (as float bits reread as
 * float) AFTER the sample was rendered. */
void pb_fx(unsigned char *st, const float *in, int n, float *outL, float *outR,
           const int *offs, int noff, float *trace)
{
    float vb[8], scratch;
    float *a2[16], *a3[2];
    int i, k;
    for (k = 0; k < 16; ++k) a2[k] = &scratch;
    for (k = 0; k < 8; ++k)  a2[2 * k] = &vb[k];
    for (i = 0; i < n; ++i) {
        scratch = 0.0f;
        for (k = 0; k < 8; ++k) vb[k] = 0.0f;
        vb[0] = in[i];
        outL[i] = 0.0f; outR[i] = 0.0f;
        a3[0] = &outL[i]; a3[1] = &outR[i];
        juno_master_render(st, a2, a3);
        for (k = 0; k < noff; ++k)
            memcpy(&trace[(size_t)i * noff + k], st + offs[k], 4);
    }
}

/* Copy the BBD ring buffer out: nsamp floats starting at byte offset base. */
void pb_copy(unsigned char *st, int base, int nbytes, void *dst)
{
    memcpy(dst, st + base, (size_t)nbytes);
}
