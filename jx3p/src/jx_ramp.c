/* jx_ramp.c -- the JX-3P parameter-smoothing RAMP STEPPER, transcribed from
 * sub_1803F4A40. STATUS: READ (static transcription); UNPROVEN until a gate
 * drives it (see the note at the bottom).
 *
 * WHY THIS EXISTS
 * The plugin's per-voice step is not just the DSP arm. VOICE_WRAP (0x377080)
 * calls the arm and then TAIL-CALLS sub_1803F40E0, which walks a list of ramp
 * records, steps each one, and retires the finished ones. That tail is how a
 * parameter change reaches the engine SMOOTHLY instead of instantly.
 *
 * `jx_voice_render` transcribes the arm only, so the port does not step ramps
 * at all. That went unnoticed because the one voice cell a ramp visibly moves
 * (+0xA6BFD0) lies ABOVE the A/B's compared window (SNAP_V = 0x60000) --
 * exactly the shape jx3p/docs/SCOPE_AUDIT.md row 2 exists to catch.
 *
 * RECORD LAYOUT (derived from the machine code, byte offsets):
 *   +0x00  float *target   where the ramped value is written
 *   +0x08  float  step     per-tick increment (negative for a falling ramp)
 *   +0x0C  float  acc      running accumulator
 *   +0x10  float  offset   added to acc when writing the target
 *   +0x14  float  limit    end value; the ramp clamps to it and retires
 *   +0x1C  uint8  enabled  0 = inert
 *   +0x20  int32  period   tick divider
 *   +0x24  int32  counter  ticks since the last step
 *
 * NaN SEMANTICS (playbook 81 -- do NOT "simplify" these comparisons):
 *   0x3F4A84 is `comiss xmm0, [rcx+8] ; jae` with xmm0 = 0.0, i.e. "is
 *   0.0 >= step". `jae` is NOT taken when unordered, so a NaN step takes the
 *   ASCENDING path. Written below as !(0.0f >= step) inverted to match.
 *   0x3F4A89 / 0x3F4A91 are `jae` / `ja` on (*target vs limit), also not taken
 *   on unordered, so a NaN target FALLS THROUGH INTO THE CLAMP.
 */
#include <stdint.h>
#include <string.h>
#include "jx_ramp.h"

/* sub_1803F4A40. Returns 1 while the ramp is still running, 0 once retired. */
int jx_ramp_step(jx_ramp *r)
{
    float acc, out;

    if (!r->enabled)                       /* 3F4A40: cmp byte [rcx+0x1c], 0 */
        return 0;                          /* 3F4A9D: xor al, al ; ret       */

    if (++r->counter < r->period)          /* 3F4A46..4F                     */
        return 1;                          /* 3F4A8B: mov al, 1 ; ret        */

    acc = r->step + r->acc;                /* 3F4A51/58                      */
    r->counter = 0;                        /* 3F4A60                         */
    r->acc = acc;                          /* 3F4A63                         */
    out = acc + r->offset;                 /* 3F4A68                         */
    *r->target = out;                      /* 3F4A6D: movss [rax], xmm0      */

    /* 3F4A74: comiss 0.0, step ; 3F4A84: jae -> the step<=0 (falling) path.
     * jae is NOT taken on unordered, so NaN goes the RISING way. */
    if (!(0.0f >= r->step)) {              /* rising                          */
        /* 3F4A86: comiss *target, limit ; jae -> finish. Not taken on NaN,
         * so a NaN target falls into the clamp below. */
        if (!(*r->target >= r->limit))
            return 1;                      /* 3F4A8B                          */
    } else {                               /* falling: 3F4A8E                 */
        /* 3F4A91: ja -> still running. Not taken on NaN. */
        if (*r->target > r->limit)
            return 1;
    }

    *r->target = r->limit;                 /* 3F4A93                          */
    r->acc = 0.0f;                         /* 3F4A97                          */
    r->enabled = 0;                        /* 3F4A9A                          */
    return 0;                              /* 3F4A9D                          */
}

/* sub_1803F4AA0 -- force a ramp to its end value and retire it. The plugin
 * copies the limit as a 32-bit WORD (mov eax, [rcx+0x14] ; mov [rdx], eax),
 * i.e. a bit copy, not an FP move: identical for every value including NaN. */
void jx_ramp_finish(jx_ramp *r)
{
    uint32_t bits;
    memcpy(&bits, &r->limit, 4);           /* 3F4AA0                          */
    memcpy(r->target, &bits, 4);           /* 3F4AA6                          */
    r->counter = 0;                        /* 3F4AAA                          */
    r->acc = 0.0f;                         /* 3F4AAD                          */
    r->enabled = 0;                        /* 3F4AB0                          */
}

/* NOT YET PORTED, and deliberately not faked here: the WALKER, sub_1803F40E0.
 * It holds the live ramps in a pointer list ([obj+0x70] begin, [obj+0x78] end,
 * array at [obj+0x58]), steps each via the function above, and COMPACTS the
 * list when one retires (memmove through 0x6E4010, then end -= 4). A C port
 * needs its own container for that list; the pointer arithmetic is not
 * transcribable one-to-one. Sizing it, and gating this stepper, is the open
 * work recorded in jx3p/docs/SCOPE_AUDIT.md row 2. */
