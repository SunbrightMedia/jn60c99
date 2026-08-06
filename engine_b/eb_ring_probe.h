/* eb_ring_probe.h — HOW DEEP DO THE DELAY RINGS REALLY GO?
 *
 * WHY THIS EXISTS. The nine FX rings are allocated at the port's own length
 * cells and total 6.10 MB, three of them 2 MB each. 2 MB of floats at 44,100
 * Hz is 11.9 seconds of delay. No JUNO-60 delay is 11.9 seconds long, so the
 * ALLOCATED length and the USED depth are almost certainly different numbers,
 * and only the used depth decides whether a ring can live in the S3's
 * internal RAM instead of PSRAM. The FX chain measures c/i 2.36 against the
 * voice chain's 1.56 because it waits for PSRAM, so this is not a memory
 * question -- it is the largest single speed lever left.
 *
 * The depth is NOT readable from a coefficient. The read index is a smoothed,
 * modulated value (eb_delay_t1.c:184 reads at `write - (int)(v433*-16384)`,
 * where v433 is itself the output of a one-pole chased toward the recalled
 * time). So it is MEASURED: every read records its lag behind that ring's
 * write pointer, and the maximum survives.
 *
 * Build with -DEB_RING_PROBE=1. It writes to file-scope counters and nothing
 * else; no gate run may use a build that defines it.
 */
#ifndef ENGINEB_EB_RING_PROBE_H
#define ENGINEB_EB_RING_PROBE_H

#if EB_RING_PROBE

enum { EB_RP_T1 = 0, EB_RP_T23, EB_RP_T5_0, EB_RP_T5_1, EB_RP_T5_2,
       EB_RP_T5_3, EB_RP_E5, EB_RP_T4_0, EB_RP_T4_1, EB_RP_N };

extern int eb_rp_maxlag[EB_RP_N];   /* deepest read, in samples */
extern int eb_rp_len[EB_RP_N];      /* the allocated length, for the ratio */

/* THE LAG, not the index, and the write pointer is passed IN rather than
 * cached. The rings run BACKWARD -- the write pointer DECREMENTS
 * (eb_delay_t1.c:236) -- and every read happens BEFORE that decrement, so the
 * write index in scope at the read is the right reference. Caching it in the
 * probe would sample it one step late on the first read of every sample. */
static int eb_rp_hit(int id, int len, int idx, int w)
{
    int r = idx & (len - 1);
    int lag = (r - (w & (len - 1))) & (len - 1);
    eb_rp_len[id] = len;
    if (lag > eb_rp_maxlag[id]) eb_rp_maxlag[id] = lag;
    return r;
}

#define EB_RP_R(id, len, idx, w)  eb_rp_hit((id), (len), (int)(idx), (int)(w))

#else
#define EB_RP_R(id, len, idx, w)  (((int)(idx)) & ((len) - 1))
#endif

#endif
