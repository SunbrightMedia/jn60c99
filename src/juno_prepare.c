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
 * Two regions:
 *   - VOICE-0 block [176,10688): 33 offsets. Apply to voice 0 AFTER
 *     juno_engine_init; juno_driver_seed_voices replicates them to voices 1..7.
 *   - SHARED / master-FX region (>=84272): 57 offsets, written once (NOT
 *     voice-replicated). These are the master's per-voice output gains, the
 *     chorus/delay/reverb algorithm constants (vtable[10] @0x3990C0) and the FX
 *     parameter power-on defaults (incl. the SR-derived High-Cut / damp filter
 *     coefficients and the reverb tap-index table). Without the Voice-Output
 *     gains (=1.0, were 0) the master attenuates every voice — a second reason
 *     the captured baseline was masking the true signal.
 *
 * FULL-STATE A/B PROOF (tools/oracle/full_ab.py): with both regions applied and
 * NO capture, the compiled C engine matches the binary's BUILD+setSampleRate
 * state on 1572/1573 DSP-read offsets; the single residual is offset 136 (the
 * params-vector pointer), which juno_driver_attach_host installs at runtime.
 *
 * Offsets are absolute (object-relative), matching juno_engine_init's.
 */
#include "juno_engine.h"
#include <stdint.h>

void juno_engine_prepare(unsigned char *st)
{
    /* --- INVARIANT (not recallable; prepare is the ONLY source) ----------- */
    JI(st,   304) = 0x400004f7;  /*  2.000303     master tune / pitch base    */
    JI(st,  1072) = 0x410bc406;  /*  8.735357                                 */
    /* envelope-smoother / osc-enable inits: snap-all sub_7FF91E0229B0 sets these
     * to 1.0 for every voice; invariant (no patch data). voice_render uses 2848/
     * 3328 as one-pole lerp coefficients, 6448 as an osc enable. */
    JI(st,  2848) = 0x3f800000;  /*  1.0          ENV1 smoother init          */
    JI(st,  3328) = 0x3f800000;  /*  1.0          ENV2 smoother init          */
    JI(st,  6448) = 0x3f800000;  /*  1.0          osc enable                  */
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

    /* --- SHARED / master-FX region (written once; NOT voice-replicated) --- */
    /* master per-voice-pair output gains — unity; were 0 => voices attenuated */
    JI(st,     84448) = 0x3f800000;  /*  1.0          Voice01 Output          */
    JI(st,     84464) = 0x3f800000;  /*  1.0          Voice23 Output          */
    JI(st,     84480) = 0x3f800000;  /*  1.0          Voice45 Output          */
    JI(st,     84496) = 0x3f800000;  /*  1.0          Voice67 Output          */
    /* chorus block FX param defaults (91xxx) */
    JI(st,     91120) = 0x3c0e0000;  /*  0.008666992  Delay Time              */
    JI(st,     91136) = 0x3f77b282;  /*  0.9675683    Error Depth             */
    JI(st,     91152) = 0x3727c5ac;  /*  1e-05        LFO Rate    (SR-derived)*/
    JI(st,     91168) = 0x3f800000;  /*  1.0          LFO Phase               */
    JI(st,     91184) = 0x3b83126f;  /*  0.004        LFO Depth               */
    JI(st,     91264) = 0x3f800000;  /*  1.0          On/Off                  */
    JI(st,     96336) = 0x3c1abc15;  /*  0.009444263  Delay Time              */
    JI(st,     96368) = 0x3b442984;  /*  0.0029932    LFO Depth               */
    JI(st,    101152) = 0x3e77a5b3;  /*  0.2418432    Volume                  */
    /* output-stage High-Cut / damp filter coefficients (SR-derived @96k) */
    JI(st,    102352) = 0x3f96bc00;  /*  1.177612     Delay Time              */
    JI(st,    102368) = 0x3e1b31ce;  /*  0.1515571    High Cut C0 (SR-derived)*/
    JI(st,    102416) = 0x3fb07de6;  /*  1.378843     High Cut B0 (SR-derived)*/
    JI(st,    102432) = 0xbf07c840;  /* -0.5303986    High Cut B2 (SR-derived)*/
    JI(st,    102464) = 0x3e52bdc7;  /*  0.2058022    High Cut Fc (SR-derived)*/
    JI(st,    102480) = 0x3fb50bf3;  /*  1.414430     High Cut Qc             */
    JI(st,    102608) = 0x3bab929a;  /*  0.005235980  LF Damp Fc  (SR-derived)*/
    JI(st,    102656) = 0x3f4ba5b0;  /*  0.7954972    HF Damp Fc  (SR-derived)*/
    /* reverb-ECF */
    JI(st,  10759504) = 0x37ae2650;  /*  2.07603e-05  Rev Ecf Rate (SR-derived)*/
    JI(st,  10759872) = 0x00000100;  /*  int 256      reverb algo const        */
    /* effect ENABLE / output-stage constants — the per-mode effect setActive step
     * (container setSampleRate sub_7FF91E01C980 @0x3BC980 + snap-all) writes these;
     * without them the master output stage stays muted. All binary-derived (see
     * scratchpad/oracle/chorus_structural_findings.md / cs_effect_merged.json),
     * bit-exact vs the runtime baseline. Invariant (not per-patch). */
    JI(st,     84560) = 0x3f800000;  /*  1.0          Mute SW (OD/DS block)   */
    JI(st,     85152) = 0x41008081;  /*  8.03137      DS Level                */
    JI(st,     91248) = 0x37ffd974;  /*  3.04996e-05  chorus Ip Fc            */
    JI(st,     91280) = 0x3f800000;  /*  1.0          chorus Mute/enable      */
    JI(st,    101136) = 0x3f800000;  /*  1.0          Expression (output)     */
    JI(st,    101744) = 0x3f800000;  /*  1.0          DLY Mute                */
    JI(st,    102496) = 0x3f800000;  /*  1.0          High Cut Sw             */
    JI(st,    102624) = 0x3f800000;  /*  1.0          LF Damp Hp              */
    JI(st,    102640) = 0x3f800000;  /*  1.0          LF Damp Lp              */
    JI(st,    102672) = 0x3f800000;  /*  1.0          HF Damp Hp              */
    JI(st,    102688) = 0x3f800000;  /*  1.0          HF Damp Lp              */
    /* reverb-ECF tank — the reverb ALGORITHM constants (density, dir/global
     * level, and the HPF/LPF/DPF filter cascade). Global send, always read by the
     * master output stage; without these the reverb produces no tail. Binary-
     * derived (BUILD -> snap-all -> setSampleRate); the SR-dependent filter coeffs
     * are the 96 kHz values. REVERB LEVEL (10759408) + TIME (10759680) stay
     * per-patch (reverb_recall.c). */
    JI(st,  10759376) = 0x3f800000;  /*  1.0          Rev Ecf On              */
    JI(st,  10759392) = 0x3f000000;  /*  0.5          Rev Ecf Density         */
    JI(st,  10759424) = 0x3f800000;  /*  1.0          Rev Ecf Dir Lev         */
    JI(st,  10759440) = 0x3efefeff;  /*  0.498039     Rev Ecf Glb Lev         */
    JI(st,  10759520) = 0x3f7f8b7e;  /*  0.998222     Rev Ecf HPF C0          */
    JI(st,  10759536) = 0xbf7f8b7e;  /* -0.998222     Rev Ecf HPF A0          */
    JI(st,  10759552) = 0x3f7f16fb;  /*  0.996444     Rev Ecf HPF B0          */
    JI(st,  10759568) = 0x3d434c95;  /*  0.0476805    Rev Ecf LPF C0          */
    JI(st,  10759584) = 0x3dc34c95;  /*  0.0953609    Rev Ecf LPF A0          */
    JI(st,  10759600) = 0x3d434c95;  /*  0.0476805    Rev Ecf LPF A1          */
    JI(st,  10759616) = 0x3fa5addf;  /*  1.29437      Rev Ecf LPF B0          */
    JI(st,  10759632) = 0xbef85dc7;  /* -0.48509      Rev Ecf LPF B1          */
    JI(st,  10759648) = 0x3e0566f8;  /*  0.130276     Rev Ecf DPF0 Fc         */
    JI(st,  10759664) = 0x3ebd52a3;  /*  0.369771     Rev Ecf DPF0 Hp         */
    JI(st,  10759696) = 0x3e0566f8;  /*  0.130276     Rev Ecf DPF1 Fc         */
    JI(st,  10759712) = 0x3ebd52a3;  /*  0.369771     Rev Ecf DPF1 Hp         */
    JI(st,  10759728) = 0xbf16c2f3;  /* -0.588912     Rev Ecf DPF1 Lp         */
    JI(st,  10759744) = 0x3e0566f8;  /*  0.130276     Rev Ecf DPF2 Fc         */
    JI(st,  10759760) = 0x3e8f487e;  /*  0.27985      Rev Ecf DPF2 Hp         */
    JI(st,  10759776) = 0xbf044337;  /* -0.516651     Rev Ecf DPF2 Lp         */
    JI(st,  10759792) = 0x3e0566f8;  /*  0.130276     Rev Ecf DPF3 Fc         */
    JI(st,  10759808) = 0x3e8f487e;  /*  0.27985      Rev Ecf DPF3 Hp         */
    JI(st,  10759824) = 0xbf044337;  /* -0.516651     Rev Ecf DPF3 Lp         */
    /* reverb tap-index table (integers) — vtable[10] algorithm constants */
    JI(st,  11022208) = 0x00000001;  JI(st,  11022212) = 0x0000077f;
    JI(st,  11022216) = 0x00000b41;  JI(st,  11022220) = 0x000012b8;
    JI(st,  11022224) = 0x000012ba;  JI(st,  11022228) = 0x000018a7;
    JI(st,  11022232) = 0x000018a9;  JI(st,  11022236) = 0x00001c34;
    JI(st,  11022240) = 0x00001c36;  JI(st,  11022244) = 0x00001d9f;
    JI(st,  11022248) = 0x00001da1;  JI(st,  11022252) = 0x000022e4;
    JI(st,  11022256) = 0x000022e6;  JI(st,  11022260) = 0x00002823;
    JI(st,  11022264) = 0x00002825;  JI(st,  11022268) = 0x00002d6c;
    JI(st,  11022272) = 0x00002d6e;  JI(st,  11022276) = 0x000032b1;
    JI(st,  11022280) = 0x000032b3;  JI(st,  11022284) = 0x00004310;
    JI(st,  11022288) = 0x00004e38;  JI(st,  11022292) = 0x00004eb0;
    JI(st,  11022296) = 0x00004eb2;  JI(st,  11022300) = 0x00005e1f;
    JI(st,  11022304) = 0x00006b83;  JI(st,  11022308) = 0x00006c71;
    JI(st,  11022312) = 0x00006c73;  JI(st,  11022316) = 0x000079ee;
    JI(st,  11022320) = 0x00008c84;  JI(st,  11022324) = 0x0000928e;
    JI(st,  11022328) = 0x00009290;  JI(st,  11022332) = 0x0000a0f9;
    JI(st,  11022336) = 0x0000b38f;  JI(st,  11022340) = 0x0000b997;
}
