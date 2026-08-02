/* test_render_guard.c — eb_engine_render() must REFUSE to run until it is
 * complete, and must say so rather than producing audio.
 *
 * WHY THIS TEST EXISTS. The function calls all thirteen gated modules in the
 * port's order, so it will produce plausible-sounding output the moment anyone
 * wires it up. It is NOT a complete engine: eb_render.h lists eight inputs it
 * cannot yet compute, and none of its three gates has been run. A
 * half-finished render that quietly makes noise is how a project ships
 * something it never compared to anything.
 *
 * So the guard is behaviour, not a comment, and this test holds it to that.
 */
#include <stdio.h>
#include <string.h>
#include "eb_render.h"

int main(void)
{
    static eb_engine E;
    static eb_render_state S;
    static eb_render_coefs C;
    eb_render_needs N;
    float l = 12345.0f, r = 12345.0f;
    int rc, bad = 0;

    memset(&E, 0, sizeof E);
    memset(&S, 0, sizeof S);
    memset(&C, 0, sizeof C);
    memset(&N, 0, sizeof N);

    /* render_ok is 0, as it is everywhere in the tree today. */
    rc = eb_engine_render(&E, &S, &C, &N, &l, &r);

    if (rc != EB_RENDER_INCOMPLETE) {
        fprintf(stderr, "  FAIL: expected EB_RENDER_INCOMPLETE (%d), got %d\n",
                EB_RENDER_INCOMPLETE, rc);
        ++bad;
    }
    if (l != 0.0f || r != 0.0f) {
        fprintf(stderr, "  FAIL: refused but still wrote audio: %g %g\n",
                (double)l, (double)r);
        ++bad;
    }

    /* And the guard must be the ONLY thing standing in the way -- if someone
     * sets render_ok the function must actually run, so that the day the gates
     * pass, removing the guard is a one-line change and not a rewrite. */
    E.render_ok = 1;
    l = r = 12345.0f;
    rc = eb_engine_render(&E, &S, &C, &N, &l, &r);
    if (rc != EB_RENDER_OK) {
        fprintf(stderr, "  FAIL: render_ok set but still refused (%d)\n", rc);
        ++bad;
    }

    printf("RENDER GUARD: %s\n", bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}
