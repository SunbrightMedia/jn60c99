/* jx_gc.c -- the JX-3P note-expiry GC, transcribed bit-literal.
 *
 *   0x3F4A40  slot tick: advance one ramp slot, say if it is still alive
 *   0x3F40E0  sweep: walk the active-id vector, tick each id's slot,
 *             erase the dead (the plugin memmoves the tail down)
 *
 * Slot layout (40 bytes stride, from the machine code):
 *   +0x00  float *target        (written every fire)
 *   +0x08  float step_sign_probe (compared vs 0 to pick direction)
 *   +0x0C  float accum
 *   +0x10  float base
 *   +0x14  float limit
 *   +0x1C  u8    active
 *   +0x20  i32   period
 *   +0x24  i32   counter
 * Dispatcher fields used by the sweep:
 *   +0x38 (getter base elsewhere) / +0x58 slot array / +0x70 begin / +0x78 end
 * Here the sweep works on plain C arrays the driver owns.
 */
#include <stdint.h>
#include <string.h>

typedef struct {
    float  *target;      /* +0x00 */
    float   pad04;
    float   sign;        /* +0x08 */
    float   accum;       /* +0x0C */
    float   base;        /* +0x10 */
    float   limit;       /* +0x14 */
    uint8_t pad18[4];
    uint8_t active;      /* +0x1C */
    uint8_t pad1d[3];
    int32_t period;      /* +0x20 */
    int32_t counter;     /* +0x24 */
} jx_gc_slot;            /* 40 bytes on the plugin side; padded here */

/* 0x3F4A40 -- returns 1 while the slot stays active */
int jx_gc_tick(jx_gc_slot *s)
{
    if (!s->active) return 0;
    s->counter += 1;
    if (s->counter < s->period) return 1;
    {
        float a = s->sign + s->accum;
        s->counter = 0;
        s->accum = a;
        *s->target = a + s->base;
    }
    {
        float cur = *s->target, lim = s->limit;
        if (!(0.0f >= s->sign)) {              /* comiss 0,sign; jae */
            if (!(cur >= lim)) return 1;       /* rising, below limit */
        } else {
            if (cur > lim) return 1;           /* falling, above limit */
        }
        *s->target = lim;
        s->accum = 0.0f;                       /* mov [rcx+0xC], edx(=0) */
        s->active = 0;
    }
    return 0;
}

/* 0x3F40E0 -- sweep: ids[] of length *n index slots[]; dead ids erased
 * in place exactly as the plugin's vector erase does (tail moves down). */
void jx_gc_sweep(int32_t *ids, int32_t *n, jx_gc_slot *slots)
{
    int32_t i = 0;
    while (i < *n) {
        if (jx_gc_tick(&slots[ids[i]])) {
            ++i;
        } else {
            memmove(&ids[i], &ids[i + 1],
                    (size_t)(*n - i - 1) * sizeof(int32_t));
            *n -= 1;
        }
    }
}
