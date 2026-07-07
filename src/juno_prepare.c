/* juno_prepare.c — the voice-block coefficients the plugin's own prepare
 * (CWaveGen::setSampleRate, RVA 0x3C7A20) writes, that the constructor
 * transcription juno_engine_init (sub_1803990C0) does NOT.
 *
 * PROVENANCE — binary, not capture. Every value below is the exact 32-bit
 * pattern the plugin's setSampleRate leaves in the CJu60Sim voice-0 block when
 * executed under Unicorn (BUILD @0x3C68D0 + setSampleRate @0x3C7A20 with
 * XMM1=float32(96000)). This is the binary's OWN code producing the value — it
 * is NOT scanned from the running commercial plugin. See
 * scratchpad/oracle/gen_voice_prepare.py for the generator + the A/B proof.
 *
 * WHY A SEPARATE STEP: these 33 offsets are DSP-read at playback but come from
 * the sample-rate prepare, not the constructor, so juno_engine_init leaves them
 * zero. 21 of them are INVARIANT (not among the 79 recallable parameters, so no
 * patch ever changes them) — without this the captured pad was their only
 * source, which is exactly why every patch inherited the pad's dark colour. The
 * other 12 are recall-defaults (a loaded bank overwrites them; this supplies the
 * plugin's genuine power-on default so the UNAPPLIED sound is the real machine's,
 * not a pad snapshot).
 *
 * A/B PROOF (gen_voice_prepare.py): with these applied, my prepared voice-0
 * block [176,10688) matches the binary's setSampleRate output with ZERO
 * mismatches; the only residual diffs are in the object header [0,176) — C++
 * metadata (vtable ptr, heap pointers, descriptor counts) the flat engine never
 * reads.
 *
 * Apply to voice 0 AFTER juno_engine_init; juno_driver_seed_voices replicates
 * the block to voices 1..7 (identical voices), exactly as the plugin prepares
 * all 8. Offsets are absolute (object-relative), matching juno_engine_init's.
 */
#include "juno_engine.h"
#include <stdint.h>

void juno_engine_prepare(unsigned char *st)
{
    /* --- INVARIANT (not recallable; prepare is the ONLY source) ----------- */
    JI(st,   304) = 0x400004f7;  /*  2.000303     master tune / pitch base    */
    JI(st,  1072) = 0x410bc406;  /*  8.735357                                 */
    JI(st,  1888) = 0x3f800000;  /*  1.0          unity gain/scale            */
    JI(st,  1952) = 0x3f800000;  /*  1.0                                      */
    JI(st,  2080) = 0x3f800000;  /*  1.0                                      */
    JI(st,  3872) = 0x3f800000;  /*  1.0                                      */
    JI(st,  3936) = 0x3f800000;  /*  1.0                                      */
    JI(st,  4016) = 0x3f800000;  /*  1.0                                      */
    JI(st,  4048) = 0x3f800000;  /*  1.0                                      */
    JI(st,  5520) = 0x392291e6;  /*  0.0001550388  DCO duty / tune trim       */
    JI(st,  6512) = 0x3f80f154;  /*  1.007365                                 */
    JI(st,  7296) = 0x3f800000;  /*  1.0                                      */
    JI(st,  7440) = 0xbf010204;  /* -0.503937                                 */
    JI(st,  7632) = 0x3f800000;  /*  1.0                                      */
    JI(st,  9056) = 0x3f800000;  /*  1.0                                      */
    JI(st,  9104) = 0x3f800000;  /*  1.0                                      */
    JI(st,  9616) = 0x3f6e147a;  /*  0.9299999                                */
    JI(st,  9824) = 0x3f800000;  /*  1.0                                      */
    JI(st, 10208) = 0x3f800000;  /*  1.0                                      */
    JI(st, 10304) = 0x3f800000;  /*  1.0                                      */
    JI(st, 10320) = 0x3f800000;  /*  1.0                                      */

    /* --- recall-defaults (a loaded bank overwrites these; this is the
     *     plugin's power-on default for the UNAPPLIED sound) --------------- */
    JI(st,   624) = 0x3d01499d;  /*  0.03156434                               */
    JI(st,  1872) = 0x3f800000;  /*  1.0                                      */
    JI(st,  1920) = 0x3c2aaa78;  /*  0.01041662                               */
    JI(st,  2784) = 0x40638f21;  /*  3.555611     ENV1 (filter) attack coeff  */
    JI(st,  2816) = 0x40aaac0b;  /*  5.333501     ENV1 decay coeff            */
    JI(st,  2832) = 0x40aaac0b;  /*  5.333501     ENV1 release coeff          */
    JI(st,  3264) = 0x40638f21;  /*  3.555611     ENV2 (amp) attack coeff     */
    JI(st,  3296) = 0x40aaac0b;  /*  5.333501     ENV2 decay coeff            */
    JI(st,  3312) = 0x40aaac0b;  /*  5.333501     ENV2 release coeff          */
    JI(st,  3840) = 0x3f800000;  /*  1.0                                      */
    JI(st, 10240) = 0x3b0d8c2e;  /*  0.002159845                              */
    JI(st, 10288) = 0x3f800000;  /*  1.0                                      */
}
