/* voice_render_itcm.c — a SECOND COMPILATION of src/voice_render.c, identical in
 * every respect except its NAME and therefore its PLACEMENT.
 *
 * juno_itcm.lds puts *voice_render_itcm.o(.text*) in ITCMRAM (load address in
 * QSPI, copied by itcm_install()), while the original voice_render.o stays in
 * QSPI and executes XIP. Assigning juno_voice_render_fn then selects which copy
 * runs, so ONE BOOT measures both placements. That removes an entire flash, and
 * flashing is the scarce resource in this project.
 *
 * SAME SOURCE, SAME FLAGS, SAME ARITHMETIC. This file adds no code of its own —
 * it is a rename plus an include. Anything else here would break the claim that
 * the two arms differ only in placement.
 *
 * The rename must be a macro, not a linker alias, because the definition and
 * its prototype in juno_engine.h must agree; the macro rewrites both. */
#define juno_voice_render juno_voice_render_itcm
#include "../src/voice_render.c"
