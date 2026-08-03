/* test_sizes.c — the memory budget, reported and enforced.
 *
 * docs/engineb/SCOPE.md sets these, and eb_types.h enforces them with
 * _Static_assert so an over-budget field is a BUILD error. This program prints
 * the numbers so a change is visible while there is still headroom, rather than
 * only when a limit is crossed.
 *
 *   cc -std=c99 -O2 -I.. -o t test_sizes.c && ./t
 */
#include <stdio.h>
#include <stddef.h>
#include "eb_types.h"

#define ROW(name, val, limit)                                                  \
    printf("  %-28s %8zu B   limit %8zu B   %s\n", name, (size_t)(val),        \
           (size_t)(limit), (size_t)(val) <= (size_t)(limit) ? "ok" : "OVER")

int main(void)
{
    size_t fx = sizeof(eb_fx);
    /* The reverb tank is NO LONGER a member of eb_fx: it outgrew its
     * placeholder by 6x and moved to eb_reverb_state in engine_b/eb_reverb.h,
     * with a per-element budget. This file still referenced the old `rev`
     * member and EB_REVERB_LEN, so it had not compiled since that move -- which
     * means `make -C engine_b/tests` was FAILING and, with it, step 2 of
     * `make engineb`. Found 2026-08-02 by running it. */
    size_t bufs = sizeof(((eb_fx *)0)->cho) + sizeof(((eb_fx *)0)->dly);
    int over = 0;

    printf("ENGINE B STRUCT SIZES (host build)\n");
    ROW("eb_env",                 sizeof(eb_env),                 16);
    ROW("eb_voice",               sizeof(eb_voice),               1024);
    ROW("eb_voice x 8",           sizeof(eb_voice) * EB_NUM_VOICES, 8192);
    ROW("eb_params",              sizeof(eb_params),              256);
    ROW("eb_fx (with buffers)",   fx,                             200u*1024u);
    ROW("eb_fx delay lines",      bufs,                           200u*1024u);
    ROW("eb_fx control only",     fx - bufs,                      1024);
    ROW("eb_engine (total)",      sizeof(eb_engine),              200u*1024u);
    printf("\n");
    printf("  per-voice hot state, group 1 (offset of pitch_target):  %zu B\n",
           offsetof(eb_voice, pitch_target));
    printf("  cache lines for one voice's hot state at 32 B/line:     %zu\n",
           (offsetof(eb_voice, pitch_target) + 31) / 32);
    printf("  the sealed port, for comparison:                        10512 B "
           "per voice, 620 cells per sample, each on its own 16 B boundary\n");
    printf("  engine B ratio:                                         %.1fx "
           "smaller per voice\n", 10512.0 / (double)sizeof(eb_voice));
    printf("\n  delay-line budget is COMPILE-TIME (eb_types.h): "
           "EB_CHORUS_LEN=%d EB_FX_DLY_LEN=%d. The reverb's budget is per "
           "element in engine_b/eb_reverb.h (EB_REV_CAP_*), because the four "
           "long loop delays dominate it.\n",
           EB_CHORUS_LEN, EB_FX_DLY_LEN);

    if (sizeof(eb_voice) > 1024) over++;
    if (sizeof(eb_voice) * EB_NUM_VOICES > 8192) over++;
    if (sizeof(eb_engine) > 200u * 1024u) over++;
    printf("\n%s\n", over ? "BUDGET: FAIL" : "BUDGET: PASS");
    return over ? 1 : 0;
}
