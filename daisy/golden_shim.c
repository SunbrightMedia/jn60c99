/* golden_shim.c — make tests/test_teensy_golden.c callable as a subroutine,
 * with the renames scoped to THIS FILE ONLY.
 *
 * WHY A SHIM AND NOT -Dmain=... ON THE COMMAND LINE. The obvious approach is to
 * put -Dmain=juno_golden_main in the project's C_DEFS. That is a trap, and it
 * built cleanly while being catastrophically wrong:
 *
 *   libDaisy's core/Makefile:53 adds its own core/startup_stm32h750xx.c to
 *   C_SOURCES, so the startup code is compiled with the PROJECT's flags. A
 *   global -Dmain=juno_golden_main therefore rewrites the startup's own call to
 *   main(), and Reset_Handler branches straight into the golden-corpus driver.
 *   The firmware's real main() is then unreferenced, --gc-sections deletes it
 *   along with everything it touched (the SDRAM pool sizing, the benchmark
 *   buffers, the reporting helpers), and the link SUCCEEDS with exit 0.
 *
 *   On hardware that boots with no hw.Init() -- so no SDRAM clock, no codec, no
 *   logger -- and dies silently. Verified by disassembling Reset_Handler:
 *   `bl <juno_golden_main>` instead of `bl <main>`. Nothing in the build output
 *   hinted at it. `make verify-entry` now checks this on every build.
 *
 * Including the .c file directly keeps the driver byte-identical to what the
 * host gate runs -- no second copy to drift out of sync -- while confining the
 * macros to this translation unit.
 */

/* Rename the driver's entry point so the firmware can call it. */
#define main juno_golden_main

/* Route the driver's printf to the Daisy logger (juno60_daisy.cpp). Under
 * --specs=nosys.specs a real printf has nowhere to write. No engine source uses
 * printf, so nothing else is affected. stdio.h's own declaration is rewritten by
 * this macro, which is where jd_printf's prototype comes from. */
#define printf jd_printf

#include "test_teensy_golden.c"
