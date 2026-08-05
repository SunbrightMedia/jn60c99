/* test_standalone_link.c — THE TRUNK MUST LINK WITHOUT THE PORT.
 *
 * Engine B is the splitting point for every microcontroller target, so it must
 * be buildable on its own. Until 2026-08-05 it was not: four modules called
 * juno_pitch_poly / juno_triangle / juno_wrap_unit / juno_wrap_hi out of
 * src/juno_dsp.c. NO NULL GATE COULD SEE THAT, because every null build links
 * the whole port by construction -- the dependency was found by linking engine
 * B outside the harness, by hand, once.
 *
 * A defect found by hand once is a defect that comes back. This test is that
 * hand check made permanent: its Makefile rule links ONLY engine_b/eb_*.c, so
 * any new call into the port fails here with an undefined reference and names
 * the symbol. It deliberately does not render anything -- the nulls do that.
 * Its whole content is the link.
 *
 * Note it still COMPILES against src/*.h. Constant tables (juno_tables.h) are
 * proven port DATA that a target ships; that is a different thing from linking
 * port CODE, and conflating the two is what left this open for so long.
 */
#include "eb_render.h"
#include "eb_master.h"
#include <stdio.h>

int main(void)
{
    /* Reference the two entry points so the linker must resolve their whole
     * call graphs. Taking their addresses is enough and runs nothing. */
    const void *p[2];
    p[0] = (const void *)&eb_engine_render;
    p[1] = (const void *)&eb_master_render;
    printf("STANDALONE LINK: %s\n", (p[0] && p[1]) ? "PASS" : "FAIL");
    return (p[0] && p[1]) ? 0 : 1;
}
