/* juno_prepare.c — the voice-block + master-FX coefficients the plugin's own
 * prepare (CWaveGen::setSampleRate, RVA 0x3C7A20) writes, that the constructor
 * transcription juno_engine_init (sub_1803990C0) does NOT.
 *
 * RATE-PARAMETERIZED. The plugin runs its DSP natively at the HOST sample rate
 * (no oversampling, no decimator — proven three independent ways in
 * scratchpad/oracle/samplerate_findings.md). setSampleRate recomputes the
 * rate-dependent coefficients from the host rate H every time. This function
 * reproduces that computation BIT-EXACTLY at any host rate, reading H from the
 * engine's SR field JF(st,16) (set before juno_engine_init, exactly as the
 * plugin's ctor reads it for its ==44100 table select).
 *
 * PROVENANCE — binary, not capture. Every constant and every rate-law below was
 * located by instruction-level tracing of setSampleRate under Unicorn (write-hook
 * -> ring-buffer disassembly -> rip-relative constant extraction), then verified
 * bit-for-bit against the binary's OWN BUILD+setSampleRate output at 44100 /
 * 48000 / 88200 / 96000. See scratchpad/oracle/prepare_rate_spec.md for the full
 * derivation, the negative controls, and the per-offset disassembly sites. No
 * capture files were opened.
 *
 * FIVE rate mechanisms (only 3 offsets are true C/H — the audit's "everything is
 * C/H" assumption was DISPROVEN by tracing the binary):
 *   A. true C/H (continuous float divide): 624, 91152, 102608.
 *   B. affine delay-time  ((float)H*T - 2.0f)*(1/16384f): 91120, 96336, 102352.
 *   C. 3-class rate-selected curve {44100 / 48000 / else-96k}: the ENV1/ENV2
 *      attack/decay/release + DCO/LFO voice coeffs 1920, 2784, 2816, 2832, 3264,
 *      3296, 3312, 10240. The plugin picks a curve INDEX by rate (disasm @0x358540:
 *      cmp rate,0xAC44 / cmp rate,0xBB80; setne; +0x22); 88200==96000 (clamped).
 *   D. 2-class rate-selected {44100 / else}: 102448, 102656.
 *   E. reverb tap-index generator (34 ints): a continuous predelay
 *      (floor(T1*H)) plus a rate-CLASS integer stage table (TAP44 for 44100,
 *      TAP96 shifted by predelay-1919 otherwise). Naive floor(tap96*H/96000)
 *      is DISPROVEN (33/34 taps wrong at 48000).
 *
 * At exactly 96 kHz every class reproduces the previously-hardcoded 96 kHz value
 * byte-for-byte (Class A: 96000/H==1; Class B: verified; Class C/D: the else
 * branch; Class E: shift 0) — so behavior at the engine's old fixed 96 kHz rate
 * is UNCHANGED (regression-safe), while 48000 / 44100 now get the plugin's genuine
 * per-rate coefficients. Note (faithful vintage quirk): the class-C/D coeffs only
 * differ at exactly 44100 and 48000; any other rate gets the 96 kHz value — this
 * is the plugin's own two-table design, so envelope/reverb TIMING at non-44.1/48k
 * rates matches the plugin's (frozen-96k) behavior, not a continuous scaling.
 *
 * The 21 INVARIANT voice coeffs and all the rate-INDEPENDENT master-FX constants
 * (High-Cut biquad, reverb ECF HPF/LPF/DPF cascade, effect enables) are byte-
 * identical across all four rates in the binary and are kept as literal hardcodes.
 *
 * Offsets are absolute (object-relative), matching juno_engine_init's. Voice-0
 * block [176,10688) is replicated to voices 1..7 by juno_driver_seed_voices.
 */
#include "juno_engine.h"
#include "delay_recall.h"    /* JUNO_PROG_DLY/EFX (power-on slot routing)   */
#include "reverb_recall.h"   /* juno_write_reverb_taps (Class E tap tables) */
#include <stdint.h>
#include <string.h>

/* reinterpret a float32 bit pattern as a float (the plugin's .rdata constants). */
static float f32(uint32_t b) { float f; memcpy(&f, &b, sizeof f); return f; }

void juno_engine_prepare(unsigned char *st)
{
    /* Host rate: the plugin's setSampleRate arg, stored verbatim at obj+8 / our
     * SR field [16]. Float for the continuous laws, int for the class selects. */
    const float Hf = JF(st, 16);
    const int   Hr = (int)Hf;

    /* --- INVARIANT (not recallable, rate-independent; prepare is the ONLY source) */
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

    /* --- recall-defaults: rate-INDEPENDENT unity slots (bank overwrites) ---- */
    JI(st,  1872) = 0x3f800000;  /*  1.0                                      */
    JI(st,  3840) = 0x3f800000;  /*  1.0                                      */
    JI(st, 10288) = 0x3f800000;  /*  1.0                                      */

    /* --- Class A: true C/H (continuous float divide) ----------------------- */
    /* base96 * (96000.0f/(float)H) — one divss then one mulss, exactly as the
     * binary (const 96000.0f @RVA 0x98802C). At H==96000 the ratio is 1.0f so the
     * result is base96 verbatim. Recall-default (bank overwrites 624). */
    {
        const float r96 = 96000.0f / Hf;
        JF(st,    624) = f32(0x3d01499d) * r96;  /* Porta/env time base (3030.177/H) */
        JF(st, 102608) = f32(0x3bab929a) * r96;  /* LF-Damp Fc      (502.6543/H)     */
        /* 91152 MUST divide 0.96f directly (a base96*96000/H form is 1 ULP wrong —
         * the 1e-5 base lost precision). Single divss of 0.96f (0x3f75c28f). */
        JF(st,  91152) = 0.96f / Hf;             /* chorus LFO rate (0.96/H)         */
    }

    /* --- Class B: affine delay-time ((float)H*T - 2.0f) * (1/16384f) -------- */
    /* mulss H,T -> subss ,2.0f -> mulss ,1/16384 (disasm @0x357c2e; K1=2, K2=1/16384). */
    {
        const float K2 = 1.0f / 16384.0f;        /* 0x38800000, exact */
        JF(st,  91120) = (Hf * f32(0x3ac49ba6) - 2.0f) * K2;  /* T=0.0015    (1.5 ms) */
        JF(st,  96336) = (Hf * f32(0x3ad5febf) - 2.0f) * K2;  /* T=0.00163265        */
        JF(st, 102352) = (Hf * f32(0x3e4dd2f2) - 2.0f) * K2;  /* T=0.201     (201 ms)*/
    }

    /* --- Class C: 3-class rate-selected voice coeffs (44100 / 48000 / else) - */
    /* ENV1/ENV2 attack/decay/release + DCO/LFO. Bit-exact hardcode of the three
     * curve outputs the plugin selects by rate. Recall may overwrite the
     * recallable ones per-patch; this is the rate-correct UNAPPLIED default. */
    #define SELC(v44, v48, v96) (Hr == 44100 ? (v44) : (Hr == 48000 ? (v48) : (v96)))
    JI(st,  1920) = SELC(0x3cb9c172, 0x3caaa9e0, 0x3c2aaa78); /* LFO delay        */
    JI(st,  2784) = SELC(0x40f7ad09, 0x40e38db9, 0x40638f21); /* ENV1 attack      */
    JI(st,  2816) = SELC(0x4139c0c1, 0x412aa9ad, 0x40aaac0b); /* ENV1 decay       */
    JI(st,  2832) = SELC(0x4139c0c1, 0x412aa9ad, 0x40aaac0b); /* ENV1 release     */
    JI(st,  3264) = SELC(0x40f7ad09, 0x40e38db9, 0x40638f21); /* ENV2 attack      */
    JI(st,  3296) = SELC(0x4139c0c1, 0x412aa9ad, 0x40aaac0b); /* ENV2 decay       */
    JI(st,  3312) = SELC(0x4139c0c1, 0x412aa9ad, 0x40aaac0b); /* ENV2 release     */
    JI(st, 10240) = SELC(0x3b9a10b5, 0x3b8d8c28, 0x3b0d8c2e); /* HPF cutoff dflt  */
    #undef SELC

    /* --- SHARED / master-FX region (written once; NOT voice-replicated) ----- */
    /* master per-voice-pair output gains — unity; were 0 => voices attenuated */
    JI(st,     84448) = 0x3f800000;  /*  1.0          Voice01 Output          */
    JI(st,     84464) = 0x3f800000;  /*  1.0          Voice23 Output          */
    JI(st,     84480) = 0x3f800000;  /*  1.0          Voice45 Output          */
    JI(st,     84496) = 0x3f800000;  /*  1.0          Voice67 Output          */
    /* chorus block FX param defaults (91xxx) — rate-independent members */
    JI(st,     91136) = 0x3f77b282;  /*  0.9675683    Error Depth             */
    JI(st,     91168) = 0x3f800000;  /*  1.0          LFO Phase               */
    JI(st,     91184) = 0x3b83126f;  /*  0.004        LFO Depth               */
    JI(st,     91264) = 0x3f800000;  /*  1.0          On/Off                  */
    JI(st,     96368) = 0x3b442984;  /*  0.0029932    LFO Depth               */
    JI(st,    101152) = 0x3e77a5b3;  /*  0.2418432    Volume                  */
    /* output-stage High-Cut biquad coefficients — rate-INDEPENDENT (identical
     * bytes at 44100/48000/88200/96000; frozen-96k design) */
    JI(st,    102368) = 0x3e1b31ce;  /*  0.1515571    High Cut C0             */
    JI(st,    102416) = 0x3fb07de6;  /*  1.378843     High Cut B0             */
    JI(st,    102432) = 0xbf07c840;  /* -0.5303986    High Cut B2             */
    JI(st,    102464) = 0x3e52bdc7;  /*  0.2058022    High Cut Fc             */
    JI(st,    102480) = 0x3fb50bf3;  /*  1.414430     High Cut Qc             */
    /* --- Class D: 2-class rate-selected {44100 / else} --------------------- */
    JI(st,    102448) = (Hr == 44100) ? 0x3f800000 : 0x00000000; /* High-Cut Sw   */
    /* HF-Damp Fc: rate-INDEPENDENT (0x3f4ba5b0 at 44100/48000/88200/96000/192000 —
     * measured from the plugin's own build+setSampleRate cold state, coldstate_ab).
     * The former (Hr==44100)?1.0 arm was a reconstruction guess never checked at
     * 44100; the plugin holds 0x3f4ba5b0 there too. */
    JI(st,    102656) = 0x3f4ba5b0;                              /* HF-Damp Fc    */
    /* reverb-ECF rate — rate-INDEPENDENT (identical across the 4 rates) */
    JI(st,  10759504) = 0x37ae2650;  /*  2.07603e-05  Rev Ecf Rate            */
    JI(st,  10759872) = 0x00000100;  /*  int 256      reverb algo const        */
    /* effect ENABLE / output-stage constants — the per-mode effect setActive step
     * (container setSampleRate sub_7FF91E01C980 @0x3BC980 + snap-all) writes these;
     * without them the master output stage stays muted. All binary-derived (see
     * scratchpad/oracle/chorus_structural_findings.md / cs_effect_merged.json),
     * bit-exact vs the runtime baseline. Invariant (not per-patch, rate-indep). */
    JI(st,     84560) = 0x3f800000;  /*  1.0          Mute SW (OD/DS block)   */
    JI(st,     85152) = 0x41008081;  /*  8.03137      DS Level                */
    /* chorus Ip Fc — SR-dependent (input high-pass ~2.93 Hz; effect-setActive wrapper
     * picks from an .rdata SR table, verified in mode5_gates_spec.md). 3-class select. */
    JI(st,     91248) = (Hr == 44100) ? 0x388b3cdf : (Hr == 48000) ? 0x387fd974 : 0x37ffd974;
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
     * derived (BUILD -> snap-all -> setSampleRate); rate-INDEPENDENT (identical at
     * all four rates). REVERB LEVEL (10759408) + TIME (10759680) stay per-patch
     * (reverb_recall.c). */
    JI(st,  10759376) = 0x3f800000;  /*  1.0          Rev Ecf On              */
    JI(st,  10759392) = 0x3f000000;  /*  0.5          Rev Ecf Density         */
    JI(st,  10759424) = 0x3f800000;  /*  1.0          Rev Ecf Dir Lev         */
    JI(st,  10759440) = 0x3efefeff;  /*  0.498039     Rev Ecf Glb Lev         */
    /* Rev Ecf HPF/LPF cascade — RATE-DEPENDENT, 2-class {44100 / else} (48000 ==
     * 88200 == 96000 share the else arm; both arms measured bit-for-bit from the
     * plugin's own cold state at 44100/48000/88200/96000, identical across every
     * patch — build defaults, never recalled. scratchpad/oracle/rate_fullscan.py +
     * rate88_dump.py. The former single 48k arm was one seed of the 44.1 kHz
     * cold-render drift.) */
    JI(st,  10759520) = (Hr == 44100) ? 0x3f7f02e7 : 0x3f7f8b7e; /* Rev Ecf HPF C0 */
    JI(st,  10759536) = (Hr == 44100) ? 0xbf7f02e7 : 0xbf7f8b7e; /* Rev Ecf HPF A0 */
    JI(st,  10759552) = (Hr == 44100) ? 0x3f7e05cf : 0x3f7f16fb; /* Rev Ecf HPF B0 */
    JI(st,  10759568) = (Hr == 44100) ? 0x3e1ca4f3 : 0x3d434c95; /* Rev Ecf LPF C0 */
    JI(st,  10759584) = (Hr == 44100) ? 0x3e9ca4f3 : 0x3dc34c95; /* Rev Ecf LPF A0 */
    JI(st,  10759600) = (Hr == 44100) ? 0x3e1ca4f3 : 0x3d434c95; /* Rev Ecf LPF A1 */
    JI(st,  10759616) = (Hr == 44100) ? 0x3f2180e3 : 0x3fa5addf; /* Rev Ecf LPF B0 */
    JI(st,  10759632) = (Hr == 44100) ? 0xbe789759 : 0xbef85dc7; /* Rev Ecf LPF B1 */
    /* Rev Ecf DPF Fc (all 4 diffusers): RATE-DEPENDENT, 2-class {44100 / else},
     * like the HPF/LPF cascade above — 48000 == 88200 == 96000 == 192000 share the
     * else arm; 44100 uses 0x3e90d0c2 (0.2828427). Both arms measured bit-for-bit
     * from the plugin's own cold state (coldstate_ab). The former single-arm
     * 0x3e0566f8 was a reconstruction that never checked 44100 — a residual seed of
     * the 44.1 kHz cold-render drift, in the same family as the HPF/LPF fix above. */
    JI(st,  10759648) = (Hr == 44100) ? 0x3e90d0c2 : 0x3e0566f8; /* Rev Ecf DPF0 Fc */
    JI(st,  10759664) = 0x3ebd52a3;  /*  0.369771     Rev Ecf DPF0 Hp         */
    JI(st,  10759696) = (Hr == 44100) ? 0x3e90d0c2 : 0x3e0566f8; /* Rev Ecf DPF1 Fc */
    JI(st,  10759712) = 0x3ebd52a3;  /*  0.369771     Rev Ecf DPF1 Hp         */
    JI(st,  10759728) = 0xbf16c2f3;  /* -0.588912     Rev Ecf DPF1 Lp         */
    JI(st,  10759744) = (Hr == 44100) ? 0x3e90d0c2 : 0x3e0566f8; /* Rev Ecf DPF2 Fc */
    JI(st,  10759760) = 0x3e8f487e;  /*  0.27985      Rev Ecf DPF2 Hp         */
    JI(st,  10759776) = 0xbf044337;  /* -0.516651     Rev Ecf DPF2 Lp         */
    JI(st,  10759792) = (Hr == 44100) ? 0x3e90d0c2 : 0x3e0566f8; /* Rev Ecf DPF3 Fc */
    JI(st,  10759808) = 0x3e8f487e;  /*  0.27985      Rev Ecf DPF3 Hp         */
    JI(st,  10759824) = 0xbf044337;  /* -0.516651     Rev Ecf DPF3 Lp         */

    /* --- SETTLED override: cells the plugin's activation SNAP settles to a
     * rate-INDEPENDENT target that this prepare baseline otherwise leaves at the
     * pre-snap value (or 0). The plugin RUNS with the settled state (setActive's
     * snap completes before any audio), so idle / factory-default / warm-recall
     * must match it. Proven by a full voice-window + master sweep vs the plugin's
     * own post-snap state at 48000 == 44100 (rate-independent). The voice-window
     * cells (<10672) are replicated to voices 1..7 by juno_driver_seed_voices.
     * These feed the DCO/LFO phase accumulators (1536 etc.); leaving them at the
     * pre-snap value made the free-running idle phase — and thus the warm first
     * note — diverge from the plugin. Recall overwrites the recallable ones; this
     * is the correct UNAPPLIED default. See docs/PHASE1_WARM_RECALL.md. */
    JI(st,    624) = 0x3d01499d;  /* 0.031564344   Porta/env time base          */
    JI(st,   1088) = 0x3f119192;  /* 0.56862748                                 */
    JI(st,   1920) = 0x3c2aaa78;  /* 0.010416619   LFO delay                    */
    JI(st,   2064) = 0x3f119192;  /* 0.56862748                                 */
    JI(st,   2784) = 0x40638f21;  /* 3.5556109     ENV1 attack                  */
    JI(st,   2800) = 0x3f800000;  /* 1.0           ENV1 stage gate              */
    JI(st,   2816) = 0x40aaac0b;  /* 5.3335013     ENV1 decay                   */
    JI(st,   2832) = 0x40aaac0b;  /* 5.3335013     ENV1 release                 */
    JI(st,   3264) = 0x40638f21;  /* 3.5556109     ENV2 attack                  */
    JI(st,   3280) = 0x3f800000;  /* 1.0           ENV2 stage gate              */
    JI(st,   3296) = 0x40aaac0b;  /* 5.3335013     ENV2 decay                   */
    JI(st,   3312) = 0x40aaac0b;  /* 5.3335013     ENV2 release                 */
    JI(st,   3984) = 0x3db0b0b1;  /* 0.086274512                                */
    JI(st,   4128) = 0x3e2cacad;  /* 0.16862746                                 */
    JI(st,   4144) = 0x15a931da;  /* 6.8337208e-26                              */
    JI(st,   4208) = 0x3f000000;  /* 0.5                                        */
    JI(st,   6736) = 0x3f800000;  /* 1.0           VCF cutoff default           */
    JI(st,   7344) = 0x1203efe4;  /* 4.1631999e-28                              */
    JI(st,   7360) = 0x3f5cdcdd;  /* 0.86274511                                 */
    JI(st,   7472) = 0x3e2cacad;  /* 0.16862746                                 */
    JI(st,  10240) = 0x3b0d8c2e;  /* 0.0021598446  HPF cutoff default           */
    JI(st,  91200) = 0x3b247b86;  /* 0.002509804   (master FX)                  */
    JI(st,  91216) = 0x3fa66666;  /* 1.3           (master FX)                  */
    JI(st, 101072) = 0x3f800000;  /* 1.0           (master FX)                  */
    JI(st, 102512) = 0x3f800000;  /* 1.0           (output)                     */
    JI(st, 102560) = 0x3ed8d8d9;  /* 0.42352942    (output)                     */
    JI(st, 102592) = 0x3f800000;  /* 1.0           (output)                     */
    JI(st, 102608) = 0x3bab929a;  /* 0.0052359821  LF-Damp Fc                   */
    JI(st, 10759680) = 0xbf16c2f3; /* -0.58891219  Rev Ecf DPF0 Lp              */

    /* Power-on effect-slot routing (the master's v39/v551 program selectors).
     * PROVEN by executing the plugin's constructor + setSampleRate under Unicorn
     * (scratchpad poweron_routing.py 2026-07-19): slot 1 (DELAY) = 0, slot 2
     * (EFFECT) = 2 (chorus I) — read both from the plugin's own params pointer
     * table (state+136 -> +136/+112) and from its state cells 11022056/11022052.
     * Slot 2 = 2 is LOAD-BEARING for warm fidelity: from power-on the plugin's
     * master free-runs the v551==2..4 chorus arm (LFO phase 90624.., BBD ring
     * 95824..) during host idle; seeding 0 here parked the port in the Pan arm
     * until the first patch apply, so a DAW-warmed instance and the port
     * diverged on every chorus patch (found via the BS Solid user report). */
    JI(st, JUNO_PROG_DLY) = 0;
    JI(st, JUNO_PROG_EFX) = 2;

    /* PORT-OWNED SHADOWS of the two raw type leaves, same provenance as the
     * two routing cells above: the power-on EFFECT TYPE is 2 and the power-on
     * DELAY TYPE is 0. Seeding them here is what makes the state-resident form
     * work — every legitimate caller of juno_bank_apply already runs prepare,
     * so every caller gets the seed with ZERO plumbing. A harness that skips
     * prepare reads 0 (= EFFECT TYPE 0), not the plugin's power-on 2; do NOT
     * paper over that with a fallback in the reader, it would hide a missing
     * prepare (see src/juno_engine.h JUNO_PREV_EFX). */
    JI(st, JUNO_PREV_EFX) = 2;
    JI(st, JUNO_PREV_DLY) = 0;

    /* --- Class E: reverb tap-index table (34 ints, 11022208..11022340) ------ */
    /* Generator sub_0x3C1AC0: tap[0]=1; a continuous predelay = floor(T1*H) (T1 in
     * [0.01998958,0.02), ~19.99 ms) plus rate-class integer stage lengths. At
     * H==44100 the whole stage table is the 44.1k set; otherwise it is the 96k set
     * shifted uniformly by (predelay-1919). Reproduces all 34 taps at 44100/48000/
     * 88200/96000 (naive floor(tap96*H/96000) is DISPROVEN). The table is REVERB-
     * TYPE-dependent; prepare seeds the build default (type 2) and the per-patch
     * recall (juno_apply_reverb) rewrites it. Tables + writer: src/reverb_recall.c. */
    juno_write_reverb_taps(st, 2, Hr);
}
