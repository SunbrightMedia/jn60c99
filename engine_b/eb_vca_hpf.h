/* eb_vca_hpf.h — ENGINE B MODULE M-VCA: the VCA + HPF OUTPUT STAGE.
 *
 * SCOPE. This module owns src/voice_render.c:1516-1640 and nothing else: the
 * four latches, the velocity smoother, the mute smoother, the gate ramp, the
 * VCA source combine, the HPF/boost network, the output gain, the DC blocker,
 * the two-filter amp TONE crossfade and the two final gain multiplies that
 * produce the VOICE OUTPUT cell [10672]. It consumes the VCF output [9040],
 * ENV1 [2752], ENV2 [3232], the resonance-compensation source [6848] and the
 * gate [560] as arguments; it produces none of them.
 *
 * PROVENANCE. Every equation is READ from src/voice_render.c:1516-1640 line by
 * line and cross-checked against docs/trackb/CELLMAP.md §V..AB and §"V..AA. VCA
 * + output". On this range the blueprint and the source AGREE — including the
 * two traps CELLMAP calls out and which are honoured here:
 *   * the tone stage is TWO RECURSIVE 1-pole/1-zero filters, not a 3-tap FIR.
 *     The third tap ([10592]/[10640]) multiplies the filter's OWN previous
 *     output, which the shift chain :1615-1617 hides behind cell names.
 *   * the HPF/boost mix at :1591/:1599 really does form the (1-t) complement,
 *     while every other blend in the range is the DISTRIBUTED lerp
 *     `(c*b - c*a) + a`. Those are different floats. Both shapes are kept
 *     exactly where the source has them.
 *
 * TOPOLOGY, as EXTRACTED:
 *   VELOCITY. [9680] is written at NOTE-ON only, as juno_curve(57, velocity)
 *     (src/juno_note.c:195). It is smoothed one-pole by [9744], then blended
 *     against the FIXED-velocity level [9616] by the VEL SENS amount [9600]:
 *         vel = lerp([9616], smoothed, [9600])
 *     and that is smoothed AGAIN by [9808] and clamped at 0 to give the first
 *     output gain [9776]. So with VEL SENS = 0 the played velocity has NO
 *     effect at all, and the wrapper's default (Kbd Vel SW OFF -> every note
 *     forced to velocity 100, CLAUDE.md) only fixes the value fed to curve 57.
 *     Velocity is therefore a per-note SCALAR into a two-stage smoother in this
 *     module and nothing else: it is not a modulation source here.
 *   MUTE. [9824] is 1.0 from note-on and 0 kills the voice; smoothed by [9888],
 *     clamped at 0, and applied LAST as [10672] = [10656] * [9856].
 *   GATE RAMP. A one-pole toward the gate [560] (0 / 1 / 2) whose RATE depends
 *     on which side of the ramp it is on: rising uses the fixed [9968] once
 *     past the threshold [9952] and a linear [9984] step before it; falling
 *     uses a rate that is itself a linear function of the clamped state,
 *     lerp([10032], [10016], clamp(state*[10000], -1, 1)). This is the only
 *     place in the module where a clamp appears, and it clamps a RATE, not the
 *     audio.
 *   VCA SOURCE. env = lerp(ENV1*[10192] + gateramp*[10176] + ENV2*[10208],
 *     extenv [9552], [10224]) — the four VCA MODE switches are gains, not a
 *     branch. lvl = max(0, env*[10304]) * [10320].
 *   HPF. A 1-pole LP state [10096] over the VCF output; the "boost" signal is
 *     (x - lp_prev)*[10352] + lp_new*[10368] (a high-pass plus a shelf tap);
 *     it is crossfaded against the raw x by the HPF SWITCH [10256] and scaled
 *     by (1 + [6848]*[10336]). The result is smoothed by [10384] and the two
 *     boost levels [10272]/[10288] sum the smoothed and unsmoothed paths.
 *   NO OUTPUT CLAMP. There is no saturation and no soft clip in this range.
 *     |[10672]| can exceed 1.0 and engine B does not clamp it, exactly as the
 *     task requires.
 *
 * WHAT ENGINE B CHANGES, and why each change is EXACT:
 *   1. The four latches at :1516-1520 disappear. [9568] is never read at all;
 *      [9632]/[9648]/[9664] are read LATER IN THE SAME SAMPLE, so they are
 *      aliases of [9584]/[9600]/[9616], not one-sample delays. GREPPED across
 *      src/ and gui/: no reader outside this block. Reading the parameter
 *      directly is the same float.
 *   2. The SHADOW stores are dropped: [9568], [9696], [9728], [9760], [9792],
 *      [9840], [9872], [9920], [9936] (only its intra-sample value is used),
 *      [10048], [10064], [10080], [10112], [10144], [10160], [10416], [10448],
 *      [10544] and [10656]. GREPPED: each is either write-only or read only
 *      inside this block. Audio cannot change; per-cell state parity does, so
 *      this is a sonic-identity claim and not a bit-exact-state one — the same
 *      standing modules M7 and M-VCF already carry.
 *   3. The DC blocker's three cells [10416]/[10432]/[10448] become ONE float.
 *      :1607 (`[10432] := [10416]`) is DEAD — :1612 overwrites [10432] in the
 *      same sample — and [10416]/[10448] are re-derived. The recurrence that
 *      survives is acc' = acc + [10464]*(x - acc), y = x - acc.
 *   4. The tone shift chain [10528]<-[10512]<-[10496]<-[10480] becomes three
 *      named floats (x1, yA, yB), which is what the chain actually holds.
 *   There is NO approximation in this module. The null is expected to be
 *   EXACTLY 0; anything else is a defect, not a budget.
 *
 * SIZE. eb_vca_state is 40 bytes (10 floats). The port spends
 * [9552..10672] = 71 cells x 16 bytes = 1,136 bytes on the same information,
 * of which 37 cells are the coefficients (shared, not per voice) and the rest
 * is shadow.
 */
#ifndef ENGINEB_EB_VCA_HPF_H
#define ENGINEB_EB_VCA_HPF_H

/* ---------------------------------------------------------------- state
 * Per voice, 40 bytes. EVERY field here is FREE-RUNNING in the eb_freerun.h
 * sense: the port runs this whole block unconditionally, so a silent voice's
 * smoothers, gate ramp, HPF pole, DC blocker and tone filters keep evolving.
 * Six of the ten (sm, g1, g2, gate_y, lp, lp2) are one-poles with CONSTANT
 * targets while the input is at rest and could in principle be advanced
 * analytically; the other four are driven by the audio and cannot. No skip is
 * offered here, because docs/trackb/ACCURACY_STANDARD.md's rest-stability rule
 * says the decision must be made from the COEFFICIENTS at recall, and this
 * module does not see recall.                                              */
typedef struct {
    float sm;       /* [9712]  velocity smoother stage 1                   */
    float g1;       /* [9776]  velocity gain, clamped >= 0  (output gain A) */
    float g2;       /* [9856]  mute gain,     clamped >= 0  (output gain B) */
    float gate_y;   /* [9904]  gate ramp                                    */
    float lp;       /* [10096] HPF 1-pole LP                                */
    float lp2;      /* [10128] post-HPF smoother                            */
    float dcacc;    /* [10432] DC blocker accumulator                       */
    float x1;       /* [10480] tone filter input, z-1                       */
    float yA;       /* [10496] tone filter A output, z-1                    */
    float yB;       /* [10512] tone filter B output, z-1                    */
} eb_vca_state;

/* ---------------------------------------------------------- coefficients
 * All INPUT-CONST in the port: written by recall / prepare / note-on, never by
 * the render. Named by the port cell so the transcription can be checked
 * against src/voice_render.c without a decoder ring.                        */
typedef struct {
    float c9552;            /* external env input (VCA source D)            */
    float c9584;            /* AMP TONE, bipolar: sign picks filter A / B   */
    float c9600;            /* AMP VELOCITY SENS                            */
    float c9616;            /* AMP FIX VELOCITY LEVEL                       */
    float c9680;            /* velocity coeff, = juno_curve(57, vel)        */
    float c9744;            /* velocity smoother coeff                      */
    float c9808;            /* velocity GAIN smoother coeff                 */
    float c9824;            /* mute target (1.0 sounding, 0 kills)          */
    float c9888;            /* mute smoother coeff                          */
    float c9952;            /* gate ramp threshold offset                   */
    float c9968;            /* gate ramp attack coeff                       */
    float c9984;            /* gate ramp pre-threshold linear step          */
    float c10000;           /* gate ramp region scale (into the clamp)      */
    float c10016, c10032;   /* gate ramp release rate endpoints             */
    float c10176;           /* VCA MODE: Gate SW                            */
    float c10192;           /* VCA MODE: ENV1 SW                            */
    float c10208;           /* VCA MODE: ENV2 SW                            */
    float c10224;           /* VCA MODE: Ext ENV SW                         */
    float c10240;           /* HPF CUTOFF, used as the 1-pole LP coeff      */
    float c10256;           /* HPF SWITCH (dry/boost crossfade)             */
    float c10272;           /* Boost LPF level                              */
    float c10288;           /* Boost thru level                             */
    float c10304;           /* ENV LEVEL                                    */
    float c10320;           /* AMP LEVEL (per-voice CONDITION re-level)     */
    float c10336;           /* resonance-compensation gain                  */
    float c10352, c10368;   /* boost path taps (hp / lp)                    */
    float c10384;           /* post-HPF smoother coeff                      */
    float c10400;           /* voice output gain                            */
    float c10464;           /* DC blocker coeff                             */
    float c10560, c10576, c10592;   /* tone filter A: b0, b1, a1            */
    float c10608, c10624, c10640;   /* tone filter B: b0, b1, a1            */
} eb_vca_coef;

void eb_vca_reset(eb_vca_state *st);

/* One host sample for one voice.
 *   vcf   = the VCF output      [9040]
 *   env1  = ENV1 out            [2752]
 *   env2  = ENV2 out            [3232]
 *   rescomp = resonance-compensation source [6848]
 *   gate  = the gate flag       [560], one of 0.0 / 1.0 / 2.0
 * Returns the VOICE OUTPUT the port stores in [10672]. Not clamped. */
float eb_vca_tick(eb_vca_state *st, const eb_vca_coef *c,
                  float vcf, float env1, float env2, float rescomp,
                  float gate);

#endif /* ENGINEB_EB_VCA_HPF_H */
