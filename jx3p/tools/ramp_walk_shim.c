/* ramp_walk_shim.c -- plumbing only (harness rule: it may never reimplement plugin logic). The walk's case --
 * a pool of the plugin's 40-byte ramp slots, an int32 id vector, the targets -- handed to THE PRODUCT'S sweep
 * (jx3p/gui/jx_bridge.c jxg_ramp_sweep, the plugin's 0x3F40E0 / 0x3F4A40, through jx3p_ramp_sweep_obj): each slot's
 * target pointed into the caller's float array, an object with the slot base at +0x58 and the vector at +0x70 /
 * +0x78. (Until 2026-10-11 the walk graded jx3p/src/jx_ramp.c, a transcription the product no longer built --
 * docs/GATE_PARITY.tsv ramp_smoothing, playbook 212.) Returns the live count. */
#include <stdint.h>
#include <string.h>

void jx_enable_hw_ftz(void);
int jx3p_ramp_sweep_obj(uint8_t *obj);

int jx_walk_case(int n, void *pool_bytes, void *idx_bytes, void *tgt_bytes)
{
    uint8_t *pool = (uint8_t *)pool_bytes, obj[0x80];
    int32_t *idx = (int32_t *)idx_bytes;
    float *tgt = (float *)tgt_bytes;
    uint64_t p;
    int i;

    /* The oracle runs FTZ+DAZ. Match the plugin's FP MODE, or the two sides
     * are not computing the same function on denormal inputs. */
    jx_enable_hw_ftz();

    for (i = 0; i < n; i++) {
        p = (uint64_t)(uintptr_t)&tgt[i];
        memcpy(pool + 40 * i, &p, 8);
    }
    memset(obj, 0, sizeof obj);
    p = (uint64_t)(uintptr_t)pool; memcpy(obj + 0x58, &p, 8);
    p = (uint64_t)(uintptr_t)idx; memcpy(obj + 0x70, &p, 8);
    p = (uint64_t)(uintptr_t)(idx + n); memcpy(obj + 0x78, &p, 8);
    return jx3p_ramp_sweep_obj(obj);
}
