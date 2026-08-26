/* ramp_walk_shim.c -- plumbing only (harness rule: it may never reimplement
 * plugin logic). Rebuilds the walker's object from flat buffers, patches each
 * record's target pointer to point into the caller's float array, calls the
 * ported walker, and returns the live count. */
#include <stdint.h>
#include "../src/jx_ramp.h"

void jx_enable_hw_ftz(void);
int jx_hw_ftz_available(void);

int jx_walk_case(int n, void *pool_bytes, void *idx_bytes, void *tgt_bytes)
{
    jx_ramp *pool = (jx_ramp *)pool_bytes;
    int32_t *idx = (int32_t *)idx_bytes;
    float *tgt = (float *)tgt_bytes;
    jx_ramp_list L;
    int i;

    /* The oracle runs FTZ+DAZ. Match the plugin's FP MODE, or the two sides
     * are not computing the same function on denormal inputs. */
    jx_enable_hw_ftz();

    for (i = 0; i < n; i++)
        pool[i].target = &tgt[i];

    L.pool = pool;
    L.begin = idx;
    L.end = idx + n;
    jx_ramp_walk(&L);
    return (int)(L.end - L.begin);
}
