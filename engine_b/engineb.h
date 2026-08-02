/* engineb.h — engine B, the fast rewrite (docs/engineb/SCOPE.md).
 *
 * Nothing here is DSP yet. This header exists so that engine_b/ is a real,
 * compilable unit from the first commit, and so the null harness
 * (tools/engineb/null_b.py) has something to link and prove EXACTLY 0 against
 * before any module is written.
 *
 * Target: ESP32-S3, one core, 240 MHz, 48 kHz -> 3,500 cycles/sample.
 * Rules: plain C99, no assembly, no processor-specific intrinsics, one core,
 * same source builds for ESP32-S3 / Daisy Seed / host.
 */
#ifndef ENGINEB_H
#define ENGINEB_H

/* Build identity. The harness calls this to prove the engine B objects were
 * really linked into the library under test — a passthrough build that failed
 * to link engine_b/ would otherwise score a perfect (and meaningless) 0. */
const char *engineb_build_id(void);

/* Which modules this build has substituted for the port's own code.
 * Set at compile time by -DENGINEB_MODULE="<name>" from the harness. */
const char *engineb_modules(void);

#endif /* ENGINEB_H */
