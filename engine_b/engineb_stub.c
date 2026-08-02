/* engineb_stub.c — engine B build identity.
 *
 * The whole of engine B at this commit. It computes no audio: with no module
 * substituted, the library the harness builds is the PORT, and the null against
 * the oracle must therefore be EXACTLY 0. That zero is the harness's self-test,
 * not an engine B result.
 */
#include "engineb.h"

#ifndef ENGINEB_MODULE
#define ENGINEB_MODULE "none"
#endif

const char *engineb_build_id(void) { return "engine_b/" __DATE__ " " __TIME__; }
const char *engineb_modules(void) { return ENGINEB_MODULE; }
